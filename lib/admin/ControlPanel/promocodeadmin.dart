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
import 'package:friesdip/Classes/PromoCodeClass.dart';
import 'package:friesdip/ScreenPage/cur_loc.dart';
import 'package:friesdip/admin/ControlPanel/FragmentNavigationBar.dart';
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

class PromoCodeAdmin extends StatefulWidget {
  PromoCodeAdmin();

  @override
  _PromoCodeAdminState createState() => _PromoCodeAdminState();
}

class _PromoCodeAdminState extends State<PromoCodeAdmin> {
  bool _loading = false;

  String promo_title_ar;
  String promo_title_en;
  int promo_percentage;

  var _formKey = GlobalKey<FormState>();
  TextEditingController _ar_titleController = TextEditingController();
  TextEditingController _en_titleController = TextEditingController();
  TextEditingController _percentageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // getData();
    FirebaseDatabase.instance
        .reference()
        .child("adminpromocode")
        .reference()
        .once()
        .then((DataSnapshot data1) {
      var DATA = data1.value;

      // promo_title_ar = DATA['promo_title_ar'];
      // promo_title_en = DATA['promo_title_en'];
      // promo_percentage = DATA['promo_percentage'];
      print("oooo${DATA}");
      print("oooo${DATA['promo_title_ar']}");
      print("oooo${DATA['promo_title_en']}");
      print("oooo${DATA['promo_percentage']}");
      setState(() {
        _ar_titleController.text = DATA['promo_title_ar'] ?? "";
        _en_titleController.text = DATA['promo_title_en'] ?? "";
        _percentageController.text = DATA['promo_percentage'].toString() ?? "0";
      });
    });
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
        floatingActionButton: MyFloatingButton(),
        body: Stack(
          children: [
            Form(
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
                                        translator.translate('edit_promo_code'),
                                      )),
                                ))),
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: TextFormField(
                                      textAlign: TextAlign.right,
                                      keyboardType: TextInputType.text,
                                      textDirection: TextDirection.rtl,
                                      controller: _ar_titleController,
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return translator
                                              .translate('ar_promo_code');
                                        }
                                      },
                                      decoration: InputDecoration(
                                          labelText: translator
                                              .translate('ar_promo_code'),
                                          errorStyle: TextStyle(
                                              color: Colors.red,
                                              fontSize: 15.0),
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
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: TextFormField(
                                      textAlign: TextAlign.right,
                                      keyboardType: TextInputType.text,
                                      textDirection: TextDirection.rtl,
                                      controller: _en_titleController,
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return translator
                                              .translate('en_promo_code');
                                        }
                                      },
                                      decoration: InputDecoration(
                                          labelText: translator
                                              .translate('en_promo_code'),
                                          errorStyle: TextStyle(
                                              color: Colors.red,
                                              fontSize: 15.0),
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
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: TextFormField(
                                      textAlign: TextAlign.right,
                                      keyboardType: TextInputType.number,
                                      textDirection: TextDirection.rtl,
                                      controller: _percentageController,
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return translator.translate(
                                              'percentage_promo_code');
                                        }
                                      },
                                      decoration: InputDecoration(
                                          labelText: translator.translate(
                                              'percentage_promo_code'),
                                          errorStyle: TextStyle(
                                              color: Colors.red,
                                              fontSize: 15.0),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0))),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5.0, right: 5.0, bottom: 3),
                          child: RaisedButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(translator.translate('edit')),
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
                                  final result = await InternetAddress.lookup(
                                      'google.com');
                                  if (result.isNotEmpty &&
                                      result[0].rawAddress.isNotEmpty) {
                                    setState(() {
                                      _loading = true;
                                    });
                                    FirebaseDatabase.instance
                                        .reference()
                                        .child("adminpromocode")
                                        .update({
                                      'promo_title_ar':
                                          _ar_titleController.text,
                                      'promo_title_en':
                                          _en_titleController.text,
                                      'promo_percentage':
                                          _percentageController.text,
                                    }).whenComplete(() => setState(() {
                                              _loading = false;
                                              Fluttertoast.showToast(
                                                  msg: translator
                                                      .translate("saved"),
                                                  backgroundColor: Colors.black,
                                                  textColor: Colors.white);
                                            }));
                                  }
                                } on SocketException catch (_) {
                                  Fluttertoast.showToast(
                                      msg: translator.translate('no_internet'),
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white);
                                  setState(() {
                                    // _loading = false;
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
            new Align(
              child: loadingIndicator,
              alignment: FractionalOffset.center,
            ),
          ],
        ));
  }

  void getData() {
    FirebaseDatabase.instance
        .reference()
        .child("adminpromocode")
        .reference()
        .once()
        .then((DataSnapshot data1) {
      var DATA = data1.value;
      print("oooo${DATA}");
      print("oooo${DATA['promo_title_ar']}");
      print("oooo${DATA['promo_title_en']}");
      print("oooo${DATA['promo_percentage']}");
      promo_title_ar = DATA['promo_title_ar'];
      promo_title_en = DATA['promo_title_en'];
      promo_percentage = DATA['promo_percentage'];
      setState(() {
        _ar_titleController.text = DATA['promo_title_ar'] ?? "";
        _en_titleController.text = DATA['promo_title_en'] ?? "";
        _percentageController.text = DATA['promo_percentage'].toString() ?? "0";
      });
    });
  }
}
