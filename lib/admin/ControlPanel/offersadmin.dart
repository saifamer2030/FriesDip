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


class OffersAdmin extends StatefulWidget {
  String M_id,M_ar_title,M_en_title;
  OffersAdmin(this.M_id,this.M_ar_title,this.M_en_title);

  @override
  _OffersAdminState createState() => _OffersAdminState();
}

class _OffersAdminState extends State<OffersAdmin> {
  List<ItemFoodClass> foodList = [];
  var _controller = ScrollController();

  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  bool isLoaded = true;
  String url,id;
  var i;
  bool _load2 = false;

  List<bool> ischeckedSmall=[];
  List<bool> ischeckedMed=[];
  List<bool> ischeckedLarg=[];
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
                    builder: (context) => MyForm2(
                        "","",
                        "","",
                       "","","","","",
                        "",0,false,widget.M_id,widget.M_ar_title,widget.M_en_title,
                        true,false,false,false,
                        onSubmit2: onSubmit2,
                        onSubmit3: onSubmit3)));

          },
          child: Icon(Icons.add),
        ),
        body: itemsScreen(loadingIndicator));
  }

///////////********* Design *****////////////////////////////
  Widget itemsScreen(loadingIndicator) {
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
                  : Container()
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
                        padding: EdgeInsets.fromLTRB(40, 25, 0, 25),
                        child: IconSlideAction(
                          caption: translator.translate('edit1'),
                          color: Colors.green,
                          icon: Icons.edit,
                          onTap: () {
                            setState(() {

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyForm2(
                                          foodList[index].title_ar,foodList[index].title_en,
                                          foodList[index].details_ar,foodList[index].details_en,
                                          foodList[index].price_no,foodList[index].price_small,foodList[index].price_mid,foodList[index].price_large,
                                          foodList[index].url,
                                          foodList[index].id,index,true,widget.M_id,widget.M_ar_title,widget.M_en_title,
                                          foodList[index].heckedNo,foodList[index].heckedSmall,foodList[index].heckedMed,foodList[index].heckedLarg,
                                          onSubmit2: onSubmit2,
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
                          padding: EdgeInsets.fromLTRB(0, 25, 40, 25),
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
                                            // print("kkk${foodList[index].id}");
                                            setState(() {
                                              FirebaseDatabase.instance
                                                           .reference()
                                                  .child("FooditemsList").child(widget.M_id)
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
    return                     Padding(
      padding: const EdgeInsets.only(right:18.0,top:8,bottom: 8,left: 18),
      child: Stack(
        children: <Widget>[
          Card(
            shape: new RoundedRectangleBorder(
                side: new BorderSide(
                    color: Colors.grey,
                    //color: subfaultsList[index].ccolor,
                    width: 1.0),
                borderRadius: BorderRadius.circular(1.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  translator.currentLanguage == 'ar' ? foodList[index].title_ar: foodList[index].title_en  ,
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Estedad-Black"),
                ),
                Text(foodList[index].heckedNo?
                  "السعر ${foodList[index].price_no} ريال":foodList[index].heckedSmall? "السعر ${foodList[index].price_small} ريال":foodList[index].heckedMed? "السعر ${foodList[index].price_mid} ريال":"السعر ${foodList[index].price_large} ريال",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Estedad-Black"),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child:InkWell(
                    onTap: () {
                      setState(() {
                        foodList[index].animation=! foodList[index].animation;
                        // for (var i = 0;i < foodList.length;i++) {
                        //   if (i != index) {
                        //     foodList[index].animation=false;
                        //   }
                        // }
                      });
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: foodList[index].url==null?BoxDecoration(
                        image: DecorationImage(
                          image:
                          AssetImage('assets/images/food.png'),
                          fit: BoxFit.fill,
                        ),
                      ):BoxDecoration(
                        image: DecorationImage(
                          image:  NetworkImage(
                              foodList[index].url
                          ),

                          fit: BoxFit.fill,
                        )),
                    ),
                  ),
                ),
                !foodList[index].heckedNo?  Padding(
                  padding:
                  const EdgeInsets.only(top: 10, bottom: 10),
                  child: Card(
                    color: Colors.grey[200],
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 0.0, left: 0.0, right: 0.0, bottom: 0.0),
                      child: ExpansionTile(
                        title: Container(color:Colors.grey[200],child: Text(  translator.translate('size'))),//backgroundColor: Colors.black,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment:MainAxisAlignment.spaceEvenly ,
                            children: [
                              foodList[index].heckedSmall? Column(
                                children: [
                                  Text(translator.translate('small'),),
                                  Checkbox(value: ischeckedSmall[index],onChanged: (bool value){
                                    setState(() {
                                      ischeckedSmall[index]=value;
                                      if( ischeckedSmall[index]){
                                        ischeckedMed[index]=false;
                                        ischeckedLarg[index]=false;
                                      }
                                    });
                                  },),
                                ],
                              ):Container(),
                              foodList[index].heckedMed? Column(
                                children: [
                                  Text(translator.translate('medium'),),
                                  Checkbox(value: ischeckedMed[index],onChanged: (bool value){
                                    setState(() {
                                      ischeckedMed[index]=(value);
                                      if( ischeckedMed[index]){
                                        ischeckedSmall[index]=false;
                                        ischeckedLarg[index]=false;
                                      }
                                    });
                                  },),
                                ],
                              ):Container(),
                              foodList[index].heckedLarg? Column(
                                children: [
                                  Text(translator.translate('large'),),
                                  Checkbox(value: ischeckedLarg[index],onChanged: (bool value){
                                    setState(() {
                                      ischeckedLarg[index]=(value);
                                      if( ischeckedLarg[index]){
                                        ischeckedSmall[index]=false;
                                        ischeckedMed[index]=false;
                                      }
                                    });
                                  },),
                                ],
                              ):Container(),

                            ],
                          ),

                        ],
                      ),
                    ),
                  ),

                ):Container(),
              ],
            ),
          ),
          foodList[index].animation? Center(
            child: Padding(
              padding: const EdgeInsets.only(top:130,left:18.0),
              child: Container(
                height: 50,
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Text( translator.currentLanguage == 'ar' ? foodList[index].details_ar: foodList[index].details_en  ,
                    style: TextStyle(
                      fontFamily: 'Estedad-Black',
                      fontSize: 15,
                      color:Colors.white,
                      //height: 0.7471466064453125,
                    ),
                  ),
                ),


              ),
            ),
          ):Container(),
        ],
      ),
    );



    //   InkWell(
    //   onTap: (){
    //    // print("kkk"+sparepartsList[index].sName+"///"+sparepartsList[index].sid+"////"+sparepartsList[index].surl);
    //    //  Navigator.push(
    //    //      context,
    //    //      MaterialPageRoute(
    //    //          builder: (context) => SubFaultAdmin(foodList[index].sid,foodList[index].sName,foodList[index].surl)));
    //   },
    //   child: Card(
    //     elevation: 10,
    //     shape:
    //         new RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    //     margin: EdgeInsets.all(6),
    //     child: ListTile(
    //       title: Text(foodList[index].title_ar,
    //         //translator.currentLanguage == 'ar' ? foodList[index].title_ar: foodList[index].title_en  ,
    //         textDirection: TextDirection.rtl,
    //         style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    //       ),
    //
    //
    //     ),
    //   ),
    // );


  }

  void getData() {

    FirebaseDatabase.instance
        .reference()
        .child("offersList").child(widget.M_id)
        .once()
        .then((DataSnapshot snapshot) {
      var KEYS = snapshot.value.keys;
      var DATA = snapshot.value;

      foodList.clear();
      for (var individualkey in KEYS) {
        ItemFoodClass foodclass = new ItemFoodClass(
          DATA[individualkey]['id'],
          DATA[individualkey]['title_ar'],
          DATA[individualkey]['title_en'],
          DATA[individualkey]['details_ar'],
          DATA[individualkey]['details_en'],
          DATA[individualkey]['price_no'],
          DATA[individualkey]['price_small'],
          DATA[individualkey]['price_mid'],
          DATA[individualkey]['price_large'],
          DATA[individualkey]['url'],
          DATA[individualkey]['arrange'],
          false,
          DATA[individualkey]['mid'],
          DATA[individualkey]['mtitle_ar'],
          DATA[individualkey]['mtitle_en'],
          DATA[individualkey]['heckedNo'],
          DATA[individualkey]['heckedSmall'],
          DATA[individualkey]['heckedMed'],
          DATA[individualkey]['heckedLarg'],
        );
        print("${ DATA[individualkey]['id']}hhh");

        setState(() {

          foodList.add(foodclass);
          setState(() {
//            print("size of list : 5");
            foodList.sort((fl1, fl2) =>
                fl2.arrange.compareTo(fl1.arrange));
          });
        });

      }
      setState(() {
        ischeckedSmall = new List<bool>.generate(foodList.length, (i) => false);
        ischeckedMed = new List<bool>.generate(foodList.length, (i) => false);
        ischeckedLarg = new List<bool>.generate(foodList.length, (i) => false);
      });
      });
    }
  void onSubmit2(int result) {

    if(result==1000000){}else{
      setState(() {
        foodList.removeAt(result);
      });
    }
  }

  void onSubmit3(ItemFoodClass result) {

    setState(() {
      foodList.add(result);
    });
  }
}

typedef void MyFormCallback2(int result);
typedef void MyFormCallback3(ItemFoodClass result);

class MyForm2 extends StatefulWidget {
  final MyFormCallback2 onSubmit2;
  final MyFormCallback3 onSubmit3;
  String title_ar,title_en;
  String details_ar,details_en;
  String price,url;
  bool ischeckedNo;
  bool ischeckedSmall;
  bool ischeckedMed;
  bool ischeckedLarg;
  String id;
  bool editcheck;
  int index;
  String M_id,M_ar_title,M_en_title;
  String price_no;
  String price_small;
  String price_mid;
  String price_large;
  MyForm2(this.title_ar,this.title_en,
      this.details_ar,this.details_en,
      this.price_no,this.price_small,this.price_mid,this.price_large,
      this.url,
      this.id,this.index,this.editcheck,this.M_id,this.M_ar_title,this.M_en_title,
      this.ischeckedNo,this.ischeckedSmall,this.ischeckedMed,this.ischeckedLarg,

      {this.onSubmit2,this.onSubmit3});

  @override
  _MyForm2State createState() => _MyForm2State();
}

class _MyForm2State extends State<MyForm2> {
  int index =0;
  String id;
  var _formKey = GlobalKey<FormState>();
  TextEditingController _ar_titleController = TextEditingController();
  TextEditingController _en_titleController = TextEditingController();
  TextEditingController _ar_detailsController = TextEditingController();
  TextEditingController _en_detailsController = TextEditingController();

  TextEditingController _price_no_Controller = TextEditingController();
  TextEditingController _price_small_Controller = TextEditingController();
  TextEditingController _price_med_Controller = TextEditingController();
  TextEditingController _price_large_Controller = TextEditingController();
  bool ischeckedNo;
  bool ischeckedSmall;
  bool ischeckedMed;
  bool ischeckedLarg;
  bool editcheck=false;
  List<Asset> images = List<Asset>();
  String url;
 bool _loading=false;
  @override
  void initState() {
    super.initState();
    _ar_titleController.text=widget.title_ar;
    _en_titleController.text=widget.title_en;
    _ar_detailsController.text=widget.details_ar;
    _en_detailsController.text=widget.details_en;
    _price_no_Controller.text=widget.price_no;
    _price_small_Controller.text=widget.price_small;
    _price_med_Controller.text=widget.price_mid;
    _price_large_Controller.text=widget.price_large;
    editcheck=widget.editcheck;
    id=widget.id;
    index=widget.index;
    url=widget.url;

    ischeckedNo=widget.ischeckedNo??true;
    ischeckedSmall=widget.ischeckedSmall??false;
    ischeckedMed=widget.ischeckedMed??false;
    ischeckedLarg=widget.ischeckedLarg??false;
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

                              // _ar_titleController.text= await translator.translateWithGoogle(
                              //   key:  _en_titleController.text,
                              //   from: 'en',to:'ar',
                              // );
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
                            if( _ar_titleController.text!=null||_ar_titleController.text!=""){
                              var  translator = GoogleTranslator();
                              _en_titleController.text=  "${await translator.translate(  _ar_titleController.text, to: 'en')}";

                              // _ar_titleController.text= await translator.translateWithGoogle(
                              //   key:  _en_titleController.text,
                              //   from: 'en',to:'ar',
                              // );
                            }else{
                              Fluttertoast.showToast(
                                  msg: translator.translate('no_text'),
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white);
                            }
                           //
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





                  Row(
                    children: [

                      Flexible(
                      child:  Container(
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: TextFormField(
                                textAlign: TextAlign.right,
                                keyboardType: TextInputType.text,
                                textDirection: TextDirection.rtl,
                                controller: _ar_detailsController,
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return translator.translate('ar_details');
                                  }
                                },
                                maxLength: 100,
                                maxLines: 2,
                                decoration: InputDecoration(
                                    contentPadding:
                                    new EdgeInsets.symmetric(
                                        vertical: 100.0),
                                    errorStyle: TextStyle(
                                        color: Colors.red, fontSize: 15.0),
                                    labelText: translator.translate('ar_details'),
                                    hintText: translator.translate('ar_details'),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)))),


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
                            if( _en_detailsController.text!=null||_en_detailsController.text!=""){
                              var  translator = GoogleTranslator();
                              _ar_detailsController.text=  "${await translator.translate(  _en_detailsController.text, to: 'ar')}";

                              // _ar_detailsController.text= await translator.translateWithGoogle(
                              //   key:  _en_titleController.text,
                              //   from: 'en',to:'ar',
                              // );
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
                        child:  Container(
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: TextFormField(
                                textAlign: TextAlign.right,
                                keyboardType: TextInputType.text,
                                textDirection: TextDirection.rtl,
                                controller: _en_detailsController,
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return translator.translate('en_details');
                                  }
                                },
                                maxLength: 100,
                                maxLines: 2,
                                decoration: InputDecoration(
                                    contentPadding:
                                    new EdgeInsets.symmetric(
                                        vertical: 100.0),
                                    errorStyle: TextStyle(
                                        color: Colors.red, fontSize: 15.0),
                                    labelText: translator.translate('en_details'),
                                    hintText: translator.translate('en_details'),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)))),


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
                            if( _ar_detailsController.text!=null||_ar_detailsController.text!=""){
                              var  translator = GoogleTranslator();
                              _en_detailsController.text=  "${await translator.translate(  _ar_detailsController.text, to: 'en')}";

                              // _ar_titleController.text= await translator.translateWithGoogle(
                              //   key:  _en_titleController.text,
                              //   from: 'en',to:'ar',
                              // );
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Flexible(
                      //   child: Container(
                      //     child: Directionality(
                      //       textDirection: TextDirection.rtl,
                      //       child: Padding(
                      //         padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      //         child: TextFormField(
                      //           textAlign: TextAlign.right,
                      //           keyboardType: TextInputType.number,
                      //           textDirection: TextDirection.rtl,
                      //           controller: _priceController,
                      //           validator: (String value) {
                      //             if (value.isEmpty) {
                      //               return  translator.translate('price');
                      //             }
                      //           },
                      //           decoration: InputDecoration(
                      //               labelText: translator.translate('price'),
                      //               errorStyle:
                      //               TextStyle(color: Colors.red, fontSize: 15.0),
                      //               border: OutlineInputBorder(
                      //                   borderRadius: BorderRadius.circular(5.0))),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.add_a_photo,
                            size: 50,
                          ),
                          color: Theme.of(context).accentColor,
                          onPressed: () async {
                            loadAssets();
                          },
                        ),
                      ),

                    ],
                  ),

                  Center(child: Text( translator.translate('size'),
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      //color: Colors.green[800]
                    ),)),
                  Row(
                    mainAxisAlignment:MainAxisAlignment.spaceAround ,
                    children: [
                      Column(
                        children: [
                          Text(translator.translate('nothing'),),
                          Checkbox(value: ischeckedNo,onChanged: (bool value){onChangedNo(value);},),
                          Container(
                            width: ((MediaQuery.of(context).size.width)/4)-5,
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: TextFormField(
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.number,
                                  textDirection: TextDirection.rtl,
                                  controller: _price_no_Controller,
                                  // validator: (String value) {
                                  //   if (value.isEmpty) {
                                  //     return  translator.translate('price');
                                  //   }
                                  // },
                                  decoration: InputDecoration(
                                      labelText: translator.translate('price'),
                                      errorStyle:
                                      TextStyle(color: Colors.red, fontSize: 15.0),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0))),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                      Column(
                        children: [
                          Text(translator.translate('small'),),
                          Checkbox(value: ischeckedSmall,onChanged: (bool value){onChangedSmall(value);},),
                          Container(
                            width: ((MediaQuery.of(context).size.width)/4)-5,
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: TextFormField(
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.number,
                                  textDirection: TextDirection.rtl,
                                  controller: _price_small_Controller,
                                  // validator: (String value) {
                                  //   if (value.isEmpty) {
                                  //     return  translator.translate('price');
                                  //   }
                                  // },
                                  decoration: InputDecoration(
                                      labelText: translator.translate('price'),
                                      errorStyle:
                                      TextStyle(color: Colors.red, fontSize: 15.0),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0))),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                      Column(
                        children: [
                          Text(translator.translate('medium'),),
                          Checkbox(value: ischeckedMed,onChanged: (bool value){onChangedMed(value);},),
                          Container(
                            width: ((MediaQuery.of(context).size.width)/4)-5,
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: TextFormField(
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.number,
                                  textDirection: TextDirection.rtl,
                                  controller: _price_med_Controller,
                                  // validator: (String value) {
                                  //   if (value.isEmpty) {
                                  //     return  translator.translate('price');
                                  //   }
                                  // },
                                  decoration: InputDecoration(
                                      labelText: translator.translate('price'),
                                      errorStyle:
                                      TextStyle(color: Colors.red, fontSize: 15.0),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0))),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                      Column(
                        children: [
                          Text(translator.translate('large'),),
                          Checkbox(value: ischeckedLarg,onChanged: (bool value){onChangedLarg(value);},),
                          Container(
                            width: ((MediaQuery.of(context).size.width)/4)-5,
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: TextFormField(
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.number,
                                  textDirection: TextDirection.rtl,
                                  controller: _price_large_Controller,
                                  // validator: (String value) {
                                  //   if (value.isEmpty) {
                                  //     return  translator.translate('price');
                                  //   }
                                  // },
                                  decoration: InputDecoration(
                                      labelText: translator.translate('price'),
                                      errorStyle:
                                      TextStyle(color: Colors.red, fontSize: 15.0),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0))),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),

                    ],
                  ),
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
    if(images.length>0||editcheck) {
      setState(() {
        _loading=true;
      });
      uploadpp0();
    }else{
      Fluttertoast.showToast(
              msg: translator.translate('no_photo'),
              backgroundColor: Colors.black,
              textColor: Colors.white);
    }


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
  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: false,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "FriseDip"),
        materialOptions: MaterialOptions(
          statusBarColor: Theme.of(context).primaryColor.toString().replaceAll("Color(0xff", "#").replaceAll(")", ""),
          actionBarColor:  Theme.of(context).primaryColor.toString().replaceAll("Color(0xff", "#").replaceAll(")", ""),
          actionBarTitle: "Frise Dip",
          allViewTitle: translator.translate('All_photo'),
          useDetailsView: false,
          selectCircleStrokeColor:  Theme.of(context).primaryColor.toString().replaceAll("Color(0xff", "#").replaceAll(")", ""),
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() {
      images = resultList;
    });
  }
  Future uploadpp0() async {

   if(images.length>0){

      final StorageReference storageRef =
      FirebaseStorage.instance.ref().child('myimage');

      var byteData = await images[0].getByteData(quality: 50);

      DateTime now = DateTime.now();
      final file = File('${(await getTemporaryDirectory()).path}/${images[0]}');
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      final StorageUploadTask uploadTask =
      storageRef.child('$now.jpg').putFile(file);
      var Imageurl = await (await uploadTask.onComplete).ref.getDownloadURL();
      Fluttertoast.showToast(
          msg: translator.translate('photo_uploaded'),
          backgroundColor: Colors.black,
          textColor: Colors.white);
      url = Imageurl.toString();
      // print("lll"+logourl);
}
    recorddata();
   setState(() {
     _loading=true;
   });


  }
recorddata(){

  final userdatabaseReference =
  FirebaseDatabase.instance.reference().child("offersList").child(widget.M_id);
  // arrange=ServerValue.timestamp;
  if(editcheck){
    userdatabaseReference.child(id).update({
      'id': id,
      'ar_title': _ar_titleController.text,
      'en_title': _en_titleController.text,
      'ar_details': _ar_detailsController.text,
      'en_details': _en_detailsController.text,
      'price_no': _price_no_Controller.text,
      'price_small': _price_small_Controller.text,
      'price_mid': _price_med_Controller.text,
      'price_large': _price_large_Controller.text,
      'url': url,
      'arrange': ServerValue.timestamp,
      'mid': widget.M_id,
      'mtitle_ar': widget.M_ar_title,
      'mtitle_en': widget.M_en_title,

      'heckedNo': ischeckedNo,
      'heckedSmall': ischeckedSmall,
      'heckedMed': ischeckedMed,
      'heckedLarg': ischeckedLarg,
    }).whenComplete(() {
      widget.onSubmit2(index);
      widget.onSubmit3(new ItemFoodClass(
          id,
          _ar_titleController.text,_en_titleController.text,
          _ar_detailsController.text,_en_detailsController.text,
          _price_no_Controller.text, _price_small_Controller.text, _price_med_Controller.text, _price_large_Controller.text,
          url,
          0,
          false,widget.M_id,widget.M_ar_title,widget.M_en_title,ischeckedNo,ischeckedSmall,ischeckedMed,ischeckedLarg));
      Navigator.pop(context);

    });;

  }else{
    id= userdatabaseReference.push().key;
    userdatabaseReference.child(id).set({
      'id': id,
      'title_ar': _ar_titleController.text,
      'title_en': _en_titleController.text,
      'details_ar': _ar_detailsController.text,
      'details_en': _en_detailsController.text,
      'price_no': _price_no_Controller.text,
      'price_small': _price_small_Controller.text,
      'price_mid': _price_med_Controller.text,
      'price_large': _price_large_Controller.text,
      'url': url,
      'arrange': ServerValue.timestamp,
      'mid': widget.M_id,
      'mtitle_ar': widget.M_ar_title,
      'mtitle_en': widget.M_en_title,
      'heckedNo': ischeckedNo,
      'heckedSmall': ischeckedSmall,
      'heckedMed': ischeckedMed,
      'heckedLarg': ischeckedLarg,

    }).whenComplete(() {
      widget.onSubmit2(1000000);
      widget.onSubmit3(new ItemFoodClass(
          id,
          _ar_titleController.text,_en_titleController.text,
          _ar_detailsController.text,_en_detailsController.text,
          _price_no_Controller.text, _price_small_Controller.text, _price_med_Controller.text, _price_large_Controller.text,
          url,
          0,
          false,widget.M_id,widget.M_ar_title,widget.M_en_title,ischeckedNo,ischeckedSmall,ischeckedMed,ischeckedLarg));

      Navigator.pop(context);

    });

  }
  setState(() {
     _loading = false;
    Fluttertoast.showToast(
        msg: translator.translate("saved"),
        backgroundColor: Colors.black,
        textColor: Colors.white);
  });
}
  void onChangedNo(bool value) {
    setState(() {
      ischeckedNo=value;
      if(value){
        ischeckedSmall=false;
        ischeckedMed=false;
        ischeckedLarg=false;

      }
    });
  }
  void onChangedSmall(bool value) {
    setState(() {
      if(ischeckedNo){}else{      ischeckedSmall=value;   }
    });
  }
  void onChangedMed(bool value) {
    setState(() {
      if(ischeckedNo){}else{      ischeckedMed=value;   }


    });
  }
  void onChangedLarg(bool value) {
    setState(() {
      if(ischeckedNo){}else{      ischeckedLarg=value;  }


    });
  }
}
