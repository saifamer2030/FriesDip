import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friesdip/Classes/BranchListClass.dart';
import 'package:friesdip/Classes/FoodListClass.dart';
import 'package:friesdip/Classes/ItemFoodClass.dart';
import 'package:friesdip/ScreenPage/cur_loc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:time_range/time_range.dart';
import 'package:toast/toast.dart';
import 'package:translator/translator.dart';

import 'menuitemsadmin.dart';
import 'offersadmin.dart';

class BranchesAdmin extends StatefulWidget {
  BranchesAdmin();

  @override
  _BranchesAdminState createState() => _BranchesAdminState();
}

class _BranchesAdminState extends State<BranchesAdmin> {
  List<BranchListClass> BranchList = [];
  var _controller = ScrollController();

  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  bool isLoaded = true;
  String url, id;
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
        ? new Container(
            child: SpinKitCircle(
              color: Theme.of(context).accentColor,
            ),
          )
        : new Container();
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyForm3(
                        "", "", "", 0, false, "", "", "", "", "",
                        onSubmit2: onSubmit2, onSubmit3: onSubmit3)));
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
                  ? BranchList.length == 0
                      ? Center(
                          child: Text(
                          translator.translate('no_data'),
                        ))
                      : listView()
                  : Center(
                      child: SpinKitFadingCircle(
                        itemBuilder: (_, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                                color: index.isEven
                                    ? Colors.orange
                                    : Colors.white),
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
                itemCount: BranchList.length,
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
                                          BranchList[index].ar_title,
                                          BranchList[index].en_title,
                                          BranchList[index].id,
                                          index,
                                          true,
                                          BranchList[index].starttime,
                                          BranchList[index].endtime,
                                          BranchList[index].lat,
                                          BranchList[index].long,
                                          BranchList[index].address,
                                          onSubmit2: onSubmit2,
                                          onSubmit3: onSubmit3)));
                              //  _en_titleController.text=foodList[index].en_title;
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
                                  title:
                                      new Text(translator.translate('alarm')),
                                  content:
                                      new Text(translator.translate('alarm1')),
                                  actions: [
                                    CupertinoDialogAction(
                                        isDefaultAction: false,
                                        child: new FlatButton(
                                          onPressed: () {
                                            print("kkk${BranchList[index].id}");
                                            setState(() {
                                              FirebaseDatabase.instance
                                                  .reference()
                                                  .child("branchList")
                                                  .child(BranchList[index].id)
                                                  .remove()
                                                  .whenComplete(() {
                                                setState(() {
                                                  BranchList.removeAt(index);
                                                  Navigator.pop(context);
                                                  Fluttertoast.showToast(
                                                      msg: translator
                                                          .translate('deleted'),
                                                      backgroundColor:
                                                          Colors.black,
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
      onTap: () {
        // print("kkk"+sparepartsList[index].sName+"///"+sparepartsList[index].sid+"////"+sparepartsList[index].surl);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OffersAdmin(BranchList[index].id,
                    BranchList[index].ar_title, BranchList[index].en_title)));
      },
      child: Card(
        elevation: 10,
        shape: new RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0)),
        margin: EdgeInsets.all(6),
        child: ListTile(
          title: Text(
            translator.currentLanguage == 'ar'
                ? BranchList[index].ar_title
                : BranchList[index].en_title,
            textDirection: TextDirection.rtl,
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[800]),
          ),
          subtitle: Column(
            children: <Widget>[
              Text(
                BranchList[index].address,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.fiber_manual_record,
                    size: 25,
                    color: Colors.green,
                  ),
                  Text(
                    BranchList[index].open
                        ? translator.translate('opened')
                        : translator.translate('closed'),
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
          leading: Icon(
            Icons.location_on,
            size: 30,
            color: Theme.of(context).accentColor,
          ),

          trailing: FlatButton(
            highlightColor:   Theme.of(context).accentColor,
            onLongPress: ()  {

              Clipboard.setData(new ClipboardData(text: BranchList[index].id));

              Fluttertoast.showToast(
            msg: (translator.translate('copied'))+ " "+BranchList[index].id,
            backgroundColor:
            Colors.black,
            textColor: Colors.white);
          },
            onPressed: () {  },
            child:Icon(Icons.content_copy,color:Colors.grey ,),
          ),
    // IconButton(
          //   icon: Icon(Icons.content_copy),
          //   color: Colors.grey,
          //   focusColor: Colors.red,
          //   splashColor:  Colors.yellow,
          //   hoverColor:  Colors.orange,
          //   highlightColor:  Colors.teal,
          //   //onPressed: () {},
          //   onLongPress: () => {
          //     //do something
          //   },
          // ),
        ),
      ),
    );
  }

  void getData() {
    DateTime now = DateTime.now();
    bool open = true;
    String b = now.month.toString();
    if (b.length < 2) {
      b = "0" + b;
    }
    String c = now.day.toString();
    if (c.length < 2) {
      c = "0" + c;
    }

    // open = new DateTime(_selectedValue.year, _selectedValue.month,
    //     _selectedValue.day, open.hour, open.minute - steptime);

    print("//////////");
    FirebaseDatabase.instance
        .reference()
        .child("branchList")
        .once()
        .then((DataSnapshot snapshot) async {
      var KEYS = snapshot.value.keys;
      var DATA = snapshot.value;
      // print("${snapshot.value}hhh");

      BranchList.clear();
      for (var individualkey in KEYS) {
        BranchListClass branchclass = new BranchListClass(
          DATA[individualkey]['id'],
          DATA[individualkey]['ar_title'],
          DATA[individualkey]['en_title'],
          DATA[individualkey]['arrange'],
          Colors.white,
          false,
          DATA[individualkey]['starttime'],
          DATA[individualkey]['endtime'],
          DATA[individualkey]['lat'],
          DATA[individualkey]['long'],
          DATA[individualkey]['address'],
          true,
          0.0,
            false,
          Colors.white,
        );

        DateTime open1 = DateTime.parse(
            "${now.year}-${b}-${c} ${DATA[individualkey]['starttime']}:00");
        // 2020-09-23 12:52:44.480093/////"2012-02-27 13:27:00"
        DateTime close1 = DateTime.parse(
            "${now.year}-${b}-${c} ${DATA[individualkey]['endtime']}:00");
        if (now.isAfter(open1) && now.isBefore(close1)) {
          open = true;
        } else {
          open = false;
        }

        try {
          List<Placemark> p = await Geolocator().placemarkFromCoordinates(
              double.parse(DATA[individualkey]['lat']),
              double.parse(DATA[individualkey]['long']));

          Placemark place = p[0];
          String name = place.name;
          String subLocality = place.subLocality;
          String locality = place.locality;
          String administrativeArea = place.administrativeArea;
          String postalCode = place.postalCode;
          String country = place.country;
          setState(() {
            BranchList.add(new BranchListClass(
              DATA[individualkey]['id'],
              DATA[individualkey]['ar_title'],
              DATA[individualkey]['en_title'],
              DATA[individualkey]['arrange'],
              Colors.white,
              false,
              DATA[individualkey]['starttime'],
              DATA[individualkey]['endtime'],
              DATA[individualkey]['lat'],
              DATA[individualkey]['long'],
              "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}",
              open,0.0,
                false,
              Colors.white,
            ));
            setState(() {
//            print("size of list : 5");
              BranchList.sort((fl1, fl2) => fl1.arrange.compareTo(fl2.arrange));
            });
          });

          // setState(() {
          //   _currentAddress =
          //   "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";
          //
          // });
        } catch (e) {
          setState(() {
            BranchList.add(new BranchListClass(
              DATA[individualkey]['id'],
              DATA[individualkey]['ar_title'],
              DATA[individualkey]['en_title'],
              DATA[individualkey]['arrange'],
              Colors.white,
              false,
              DATA[individualkey]['starttime'],
              DATA[individualkey]['endtime'],
              DATA[individualkey]['lat'],
              DATA[individualkey]['long'],
              DATA[individualkey]['address'],
              open,0.0,
                false,
              Colors.white,
            ));
            setState(() {
//            print("size of list : 5");
              BranchList.sort((fl1, fl2) => fl1.arrange.compareTo(fl2.arrange));
            });
          });
        }

        // }
      }
    });
  }

  void onSubmit2(int result) {
    if (result == 1000000) {
    } else {
      setState(() {
        BranchList.removeAt(result);
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

  void onSubmit3(BranchListClass result) {
    setState(() {
      BranchList.add(result);
    });
  }
}

typedef void MyFormCallback2(int result);
typedef void MyFormCallback3(BranchListClass result);

class MyForm3 extends StatefulWidget {
  final MyFormCallback2 onSubmit2;
  final MyFormCallback3 onSubmit3;
  String ar_title, en_title, id;
  bool editcheck;
  int index;
  String starttime, endtime;
  String lat, long, address;

  MyForm3(this.ar_title, this.en_title, this.id, this.index, this.editcheck,
      this.starttime, this.endtime, this.lat, this.long, this.address,
      {this.onSubmit2, this.onSubmit3});

  @override
  _MyForm3State createState() => _MyForm3State();
}

class _MyForm3State extends State<MyForm3> {
  int index = 0;
  String id;
  var _formKey = GlobalKey<FormState>();
  TextEditingController _ar_titleController = TextEditingController();
  TextEditingController _en_titleController = TextEditingController();
  bool editcheck = false;
  bool _loading = false;
  LatLng fromPlace, toPlace;

  String fromPlaceLat, fromPlaceLng;

  String fPlaceName = translator.translate('init_location');
  Map<String, dynamic> sendData = Map();
  TimeRangeResult _initialRange = null;
  String starttime;
  String endtime;
  String lat, long, address;

  @override
  void initState() {
    super.initState();
    setState(() {
      _ar_titleController.text = widget.ar_title;
      _en_titleController.text = widget.en_title;
      editcheck = widget.editcheck;
      id = widget.id;
      index = widget.index;
      // String starttime,endtime;

      if (widget.lat == "" || widget.long == "") {
        // fromPlaceLat=null;
        // fromPlaceLng=null;
      } else {
        fromPlaceLat = widget.lat;
        fromPlaceLng = widget.long;
      }

      if (widget.address != "") {
        fPlaceName = widget.address;
      } else {
        //fPlaceName=null;
      }
    });
    if (widget.starttime == "" || widget.endtime == "") {
      // _initialRange=null   ;
      // starttime=null;
      // endtime=null;
    } else {
      starttime = widget.starttime;
      endtime = widget.endtime;
      _initialRange = TimeRangeResult(
          TimeOfDay(
              hour: int.parse(starttime.split(":")[0]),
              minute: int.parse(starttime.split(":")[1])),
          TimeOfDay(
              hour: int.parse(endtime.split(":")[0]),
              minute: int.parse(endtime.split(":")[1])));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _loading
        ? new Container(
            child: SpinKitCircle(
              color: Theme.of(context).accentColor,
            ),
          )
        : new Container();
    return Scaffold(
      body: new Form(
        key: _formKey,
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
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
                                  editcheck
                                      ? translator.translate('edit_list')
                                      : translator.translate('add_list'),
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
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: TextFormField(
                                textAlign: TextAlign.right,
                                keyboardType: TextInputType.text,
                                textDirection: TextDirection.rtl,
                                controller: _ar_titleController,
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return translator.translate('ar_branch');
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText:
                                        translator.translate('ar_branch'),
                                    errorStyle: TextStyle(
                                        color: Colors.red, fontSize: 15.0),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0))),
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
                            if (_en_titleController.text != null ||
                                _en_titleController.text != "") {
                              var translator = GoogleTranslator();
                              _ar_titleController.text =
                                  "${await translator.translate(_en_titleController.text, to: 'ar')}";
                            } else {
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
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: TextFormField(
                                textAlign: TextAlign.right,
                                keyboardType: TextInputType.text,
                                textDirection: TextDirection.rtl,
                                controller: _en_titleController,
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return translator.translate('en_branch');
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText:
                                        translator.translate('en_branch'),
                                    errorStyle: TextStyle(
                                        color: Colors.red, fontSize: 15.0),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0))),
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
                            var translator = GoogleTranslator();
                            _en_titleController.text =
                                "${await translator.translate(_ar_titleController.text, to: 'en')}";
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TimeRange(
                    fromTitle: Text(
                      translator.translate('from'),
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    toTitle: Text(
                      translator.translate('to'),
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    titlePadding: 20,
                    textStyle: TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.black87),
                    activeTextStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    borderColor: Colors.black,
                    backgroundColor: Colors.transparent,
                    activeBackgroundColor: Theme.of(context).accentColor,
                    firstTime: TimeOfDay(hour: 00, minute: 00),
                    lastTime: TimeOfDay(hour: 23, minute: 49),
                    timeStep: 15,
                    timeBlock: 15,
                    initialRange: _initialRange,
                    // TimeRangeResult(
                    //   TimeOfDay(hour: 00, minute: 45),
                    //   TimeOfDay(hour: 01, minute: 00),
                    // ),
                    onRangeCompleted: (range) => setState(() {
                      starttime = range.start
                          .toString()
                          .replaceAll("TimeOfDay(", "")
                          .replaceAll(")", "");
                      endtime = range.end
                          .toString()
                          .replaceAll("TimeOfDay(", "")
                          .replaceAll(")", "");

                      print("${range.start}");
                      print(endtime.toString());
                    }),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () async {
                            sendData = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CurrentLocation2()),
                            );

                            // print("\n\n\n\n\n\n\nfromPlaceLng>>>>"+
                            //     fromPlaceLng+fPlaceName+"\n\n\n\n\n\n");
                            setState(() {
                              fromPlace = sendData["loc_latLng"];
                              fromPlaceLat = fromPlace.latitude.toString();
                              fromPlaceLng = fromPlace.longitude.toString();
                              fPlaceName = sendData["loc_name"];
                            });
                          },
                          child: Icon(
                            fromPlaceLat == null
                                ? Icons.gps_fixed
                                : Icons.check_circle,
                            color: Colors.purpleAccent,
                            size: 50,
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: Text(
                            fPlaceName,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Icon(
                            Icons.star,
                            color: Colors.red,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 3),
                    child: RaisedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          editcheck
                              ? Text(translator.translate('edit'))
                              : Text(translator.translate('add')),
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
                            final result =
                                await InternetAddress.lookup('google.com');
                            if (result.isNotEmpty &&
                                result[0].rawAddress.isNotEmpty) {
                              final userdatabaseReference = FirebaseDatabase
                                  .instance
                                  .reference()
                                  .child("branchList");
                              // arrange=ServerValue.timestamp;
                              if (editcheck) {
                                setState(() {
                                  _loading = true;
                                });
                                userdatabaseReference.child(id).update({
                                  'id': id,
                                  'ar_title': _ar_titleController.text,
                                  'en_title': _en_titleController.text,
                                  'arrange': ServerValue.timestamp,
                                  'starttime': starttime,
                                  'endtime': endtime,
                                  'lat': fromPlaceLat,
                                  'long': fromPlaceLng,
                                  'address': fPlaceName,
                                });
                                widget.onSubmit2(index);

                                widget.onSubmit3(new BranchListClass(
                                    id,
                                    _ar_titleController.text,
                                    _en_titleController.text,
                                    0,
                                    Colors.white,
                                    false,
                                    starttime,
                                    endtime,
                                    fromPlaceLat,
                                    fromPlaceLng,
                                    fPlaceName,
                                    true,0.0,
                                    false,
                                  Colors.white,));
                                Navigator.pop(context);
                                setState(() {
                                  _loading = false;
                                });
                              } else {
                                if (fromPlaceLat == "" ||
                                    fromPlaceLng == "" ||
                                    endtime == "" ||
                                    starttime == "" ||
                                    fromPlaceLat == null ||
                                    fromPlaceLng == null ||
                                    endtime == null ||
                                    starttime == null) {
                                  Fluttertoast.showToast(
                                      msg: translator.translate('complete'),
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white);
                                } else {
                                  setState(() {
                                    _loading = true;
                                  });
                                  id = userdatabaseReference.push().key;
                                  userdatabaseReference.child(id).set({
                                    'id': id,
                                    'ar_title': _ar_titleController.text,
                                    'en_title': _en_titleController.text,
                                    'arrange': ServerValue.timestamp,
                                    'starttime': starttime,
                                    'endtime': endtime,
                                    'lat': fromPlaceLat,
                                    'long': fromPlaceLng,
                                    'address': fPlaceName,
                                  });
                                  widget.onSubmit2(1000000);
                                  widget.onSubmit3(new BranchListClass(
                                      id,
                                      _ar_titleController.text,
                                      _en_titleController.text,
                                      0,
                                      Colors.white,
                                      false,
                                      starttime,
                                      endtime,
                                      fromPlaceLat,
                                      fromPlaceLng,
                                      fPlaceName,
                                      true,0.0,
                                      false,
                                    Colors.white,));
                                  Navigator.pop(context);
                                  setState(() {
                                    _loading = false;
                                  });
                                }
                              }

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
                              _loading = false;
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
