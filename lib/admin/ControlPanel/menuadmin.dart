import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friesdip/Classes/FoodListClass.dart';
import 'package:friesdip/Classes/ItemFoodClass.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toast/toast.dart';
import 'package:translator/translator.dart';

import 'menuitemsadmin.dart';


class MenuAdmin extends StatefulWidget {
  MenuAdmin();

  @override
  _MenuAdminState createState() => _MenuAdminState();
}

class _MenuAdminState extends State<MenuAdmin> {
  List<FoodListClass> foodList = [];
  var _controller = ScrollController();

  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  bool isLoaded = true;
  String url,id;
  var i;
  bool _load2 = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _load2
        ? new Container( child: SpinKitCircle(
        color: Theme.of(context).accentColor,
      ),
    ): new Container();
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed:() {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyForm3(
                        "","","",0,false,onSubmit2: onSubmit2,
                        onSubmit3: onSubmit3)));
          },
          child: Icon(Icons.add),
        ),
        body: sparepartssScreen(loadingIndicator));
  }

///////////********* Design *****////////////////////////////
  Widget sparepartssScreen(loadingIndicator) {
    return Stack(
      children: [
        Column(
          children: <Widget>[
            Flexible(
              child: isLoaded
                  ? foodList.length == 0
                      ? Center(child: Text(
                translator.translate('no_data')
                ,))
                      : listView()
                  : Center(
                      child: SpinKitFadingCircle(
                        itemBuilder: (_, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                                color:
                                    index.isEven ? Colors.orange : Colors.white),
                          );
                        },
                      ),
                    ),
            ),

          ],
        ),
        new Align(
          child: loadingIndicator,
          alignment: FractionalOffset.center,
        ),
      ],
    );
  }

  Widget listView() {
    return Column(
      children: <Widget>[
        Expanded(
            child: new ListView.builder(
                physics: BouncingScrollPhysics(),
                controller: _controller,
                itemCount: foodList.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Slidable(
                    actionPane: SlidableDrawerDismissal(),
                    child: firebasedata(
                      index,
                    ),
                    actions: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                        child: IconSlideAction(
                          caption: translator.translate('edit1'),
                          color: Colors.green,
                          icon: Icons.edit,
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyForm3(
                                          foodList[index].ar_title,foodList[index].en_title,foodList[index].id,index,true,onSubmit2: onSubmit2,
                                          onSubmit3: onSubmit3)));                             //  _en_titleController.text=foodList[index].en_title;
                             //  _ar_titleController.text=foodList[index].ar_title;
                             // id=foodList[index].id;
                             // editcheck=true;
                             // i=index;
                             //  updatedata(foodList[index].id);

                            });
                          },
                        ),
                      )
                    ],
                    secondaryActions: <Widget>[
                      Container(
                          padding: EdgeInsets.fromLTRB(0, 10, 20, 10),
                          child: IconSlideAction(
                            caption: translator.translate('delet1'),
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    new CupertinoAlertDialog(
                                      title: new Text(translator.translate('alarm')),
                                      content: new Text(translator.translate('alarm1')),
                                  actions: [
                                    CupertinoDialogAction(
                                        isDefaultAction: false,
                                        child: new FlatButton(
                                          onPressed: () {
                                            print("kkk${foodList[index].id}");
                                            setState(() {
                                              FirebaseDatabase.instance
                                                           .reference()
                                                  .child("FoodList")
                                                  .child(foodList[index].id)
                                                  .remove()
                                                  .whenComplete(() {
                                                setState(() {
                                                  foodList.removeAt(index);
                                                  Navigator.pop(context);
                                                  Fluttertoast.showToast(
                                                      msg: translator.translate(
                                                          'deleted'),
                                                      backgroundColor: Colors
                                                          .black,
                                                      textColor: Colors.white);
                                                });
                                              });
                                            });
                                          },
                                          child: Text("موافق"),
                                        )),
                                    CupertinoDialogAction(
                                        isDefaultAction: false,
                                        child: new FlatButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("إلغاء"),
                                        )),
                                  ],
                                ),
                              );
                            },
                          )),
                    ],
                  );
                })),
      ],
    );
  }

  Widget firebasedata(var index) {
    return InkWell(
      onTap: (){
       // print("kkk"+sparepartsList[index].sName+"///"+sparepartsList[index].sid+"////"+sparepartsList[index].surl);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MenuItemsAdmin(foodList[index].id,foodList[index].ar_title,foodList[index].en_title)));
      },
      child: Card(
        elevation: 10,
        shape:
            new RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        margin: EdgeInsets.all(6),
        child: ListTile(
          title: Text(
            translator.currentLanguage == 'ar' ? foodList[index].ar_title: foodList[index].en_title  ,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),


        ),
      ),
    );


  }

  void getData() {

    FirebaseDatabase.instance
        .reference()
        .child("FoodList")
        .once()
        .then((DataSnapshot snapshot) {
      var KEYS = snapshot.value.keys;
      var DATA = snapshot.value;
       print("${snapshot.value}hhh");

      foodList.clear();
      for (var individualkey in KEYS) {
        FoodListClass foodclass = new FoodListClass(
          DATA[individualkey]['id'],
          DATA[individualkey]['ar_title'],
          DATA[individualkey]['en_title'],
          DATA[individualkey]['arrange'],
          Colors.white,
          false,
        );
        print("${ DATA[individualkey]['id']}hhh");

        setState(() {

          foodList.add(foodclass);
          setState(() {
//            print("size of list : 5");
            foodList.sort((fl1, fl2) =>
                fl1.arrange.compareTo(fl2.arrange));
          });
        });
        // }
      }
      });
    }
  void onSubmit2(int result) {

    if(result==1000000){}else{
      setState(() {
        foodList.removeAt(result);
      });
    }
    setState(() {
    //int  i=result;
      // this.reassemble();

      // dep1 = result.split(",")[0];
      // dep2 = result.split(",")[1];
      // Toast.show(
      //     "${result.split(",")[0]}///////${result.split(",")[1]}", context,
      //     duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    });
  }

  void onSubmit3(FoodListClass result) {

    setState(() {
      foodList.add(result);
     // this.reassemble();

      // dep1 = result.split(",")[0];
      // dep2 = result.split(",")[1];
      // Toast.show(
      //     "${result.split(",")[0]}///////${result.split(",")[1]}", context,
      //     duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    });
  }
}

typedef void MyFormCallback2(int result);
typedef void MyFormCallback3(FoodListClass result);

class MyForm3 extends StatefulWidget {
  final MyFormCallback2 onSubmit2;
  final MyFormCallback3 onSubmit3;
  String ar_title,en_title,id;
  bool editcheck;
  int index;
  MyForm3(this.ar_title,this.en_title,this.id,this.index,this.editcheck, {this.onSubmit2,this.onSubmit3});

  @override
  _MyForm3State createState() => _MyForm3State();
}

class _MyForm3State extends State<MyForm3> {
  int index =0;
  String id;
  var _formKey = GlobalKey<FormState>();
  TextEditingController _ar_titleController = TextEditingController();
  TextEditingController _en_titleController = TextEditingController();
  bool editcheck=false;
 bool _loading=false;


  @override
  void initState() {
    super.initState();
    _ar_titleController.text=widget.ar_title;
    _en_titleController.text=widget.en_title;
    editcheck=widget.editcheck;
    id=widget.id;
    index=widget.index;

  }

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _loading
        ? new Container(
      child: SpinKitCircle(
        color:  Theme.of(context).accentColor,
      ),
    )
        : new Container();
    return Scaffold(
      body: new  Form(
        key: _formKey,
        child: Container(
          height: MediaQuery.of(context).size.height ,
          child:  Stack(
            children: <Widget>[
              ListView(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                    editcheck?  translator.translate('edit_list'): translator.translate('add_list'),
                                  textScaleFactor: 1.5,
                                )),
                          ))),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: TextFormField(
                                textAlign: TextAlign.right,
                                keyboardType: TextInputType.text,
                                textDirection: TextDirection.rtl,
                                controller: _ar_titleController,
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return  translator.translate('p_ar_litle');
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText: translator.translate('ar_litle'),
                                    errorStyle:
                                    TextStyle(color: Colors.red, fontSize: 15.0),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0))),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.g_translate,
                            size: 50,
                          ),
                          color: Theme.of(context).accentColor,
                          onPressed: () async {
                            if( _en_titleController.text!=null||_en_titleController.text!=""){
                             var  translator = GoogleTranslator();
                             _ar_titleController.text=  "${await translator.translate(  _en_titleController.text, to: 'ar')}";

                            }else{
                              Fluttertoast.showToast(
                                  msg: translator.translate('no_text'),
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white);
                            }

                          },
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: TextFormField(
                                textAlign: TextAlign.right,
                                keyboardType: TextInputType.text,
                                textDirection: TextDirection.rtl,
                                controller: _en_titleController,
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return translator.translate('p_en_litle');
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText: translator.translate('en_litle'),
                                    errorStyle:
                                    TextStyle(color: Colors.red, fontSize: 15.0),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0))),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.g_translate,
                            size: 50,
                          ),
                          color: Theme.of(context).accentColor,
                          onPressed: () async {
                            var  translator = GoogleTranslator();
                            _en_titleController.text=  "${await translator.translate(  _ar_titleController.text, to: 'en')}";
//                             var translation = await translator.translate("Dart is very cool!", to: 'ar');
//                             print(translation);
// print("${translator.translate( "احمد", to: 'en')}");
                            // _en_titleController.text= await translator.translateWithGoogle(
                            //   key:  _ar_titleController.text,
                            //   from: 'ar',to:'en',
                            // );
                          },
                        ),
                      ),

                    ],
                  ),

                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 3),
                    child: RaisedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          editcheck?Text(translator.translate('edit')):Text(translator.translate('add')),
                          SizedBox(
                            height: 8.0,
                            width: 8.0,
                          ),
                          Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      textColor: Colors.white,
                      color: const Color(0xff171732),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          try {
                            final result = await InternetAddress.lookup('google.com');
                            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                              setState(() {
                                _loading=true;
                              });
                              final userdatabaseReference =
                              FirebaseDatabase.instance.reference().child("FoodList");
                              // arrange=ServerValue.timestamp;
                              if(editcheck){
                                userdatabaseReference.child(id).update({
                                  'id': id,
                                  'ar_title': _ar_titleController.text,
                                  'en_title': _en_titleController.text,
                                  'arrange': ServerValue.timestamp
                                });
                                widget.onSubmit2(index);

                                widget.onSubmit3(new FoodListClass(id,_ar_titleController.text,_en_titleController.text,0,Colors.white,
                                  false,));
                              }else{
                                id= userdatabaseReference.push().key;
                                userdatabaseReference.child(id).set({
                                  'id': id,
                                  'ar_title': _ar_titleController.text,
                                  'en_title': _en_titleController.text,
                                  'arrange': ServerValue.timestamp
                                });
                                widget.onSubmit2(1000000);
                                widget.onSubmit3(new FoodListClass(id,_ar_titleController.text,_en_titleController.text,0,Colors.white,
                                  false,));
                              }
                              Navigator.pop(context);
                              setState(() {
                                _loading=false;
                              });
                              // if(editcheck){//uploadpp0();
                              //   setState(() {
                              //     _load2 = true;
                              //   });
                              // }else{
                              //
                              //
                              // }

                            }
                          } on SocketException catch (_) {
                            Fluttertoast.showToast(
                                msg: translator.translate('no_internet'),
                                backgroundColor: Colors.black,
                                textColor: Colors.white);
                            setState(() {
                              _loading=false;
                            });
                          }
                          //loginUserphone(_phoneController.text.trim(), context);

                        } else
                          print('correct');
                      },
//
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0)),
                    ),
                  ),
                ],
              ),
              new Align(
                child: loadingIndicator,
                alignment: FractionalOffset.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
