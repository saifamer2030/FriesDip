import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friesdip/ScreenPage/HomePage.dart';
import 'package:friesdip/admin/ControlPanel/FragmentNavigationBar.dart';
import 'package:friesdip/admin/Branches/loginadmin.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:toast/toast.dart';

class LogoutAdmin extends StatefulWidget {
  LogoutAdmin();
  @override
  _LogoutAdminState createState() => _LogoutAdminState();
}

class _LogoutAdminState extends State<LogoutAdmin> {
  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;
  bool exist=false;


  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passconfirmController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  bool _load = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _load
        ? new Container(
            child: SpinKitCubeGrid(
              color: const Color(0xffBC0C0C),
            ),
          )
        : new Container();
    TextStyle textStyle = Theme.of(context).textTheme.subtitle;

    return Scaffold(
      backgroundColor: const Color(0xffffffff),

      appBar: AppBar(
//          Container(
//            child: Icon(Icons.shopping_cart,color: Colors.white,),
//          ) ,
        backgroundColor: Colors.black,
        title: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(
                    5.0) //                 <--- border radius here
                ),
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  translator.translate('appTitle'),
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Estedad-Black"),
                ),
              ),
            )),
        // centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,

        child: Stack(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Padding(
                  padding: EdgeInsets.only(
                      top: _minimumPadding * 20,
                      bottom: _minimumPadding * 2,
                      right: _minimumPadding * 2,
                      left: _minimumPadding * 2),
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                              top: _minimumPadding, bottom: _minimumPadding),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: TextFormField(
                              textAlign: TextAlign.right,
                              keyboardType: TextInputType.emailAddress,
                              style: textStyle,
                              //textDirection: TextDirection.rtl,
                              controller: _emailController,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return translator.translate('enterEmail'); //Translations.of(context).translate('please_enter_the_phone_number');
                                }
                                Pattern pattern =
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                RegExp regex = new RegExp(pattern);
                                if (!regex.hasMatch(value)) {
                                  return translator.translate('IncorrectEmail');
                                }

                              },
                              decoration: InputDecoration(
                                labelText: translator.translate('EmailAddress'),
                                //Translations.of(context).translate('telephone_number'),
                                hintText: "example@gmail.com",
                                prefixIcon: Icon(Icons.email),
                                labelStyle: textStyle,
                                errorStyle: TextStyle(
                                    color: Colors.red, fontSize: 15.0),
                                // border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))
                              ),
                            ),
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              top: _minimumPadding, bottom: _minimumPadding),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: TextFormField(
                              textAlign: TextAlign.right,
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              style: textStyle,
                              //textDirection: TextDirection.rtl,
                              controller: _passwordController,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return translator.translate('enterPassword'); //Translations.of(context).translate('please_enter_the_phone_number');
                                }
                                if (value.length < 6) {
                                  return translator.translate('IncorrectPassword'); //Translations.of(context).translate('phone_number_is_incorrect');
                                }
                              },
                              decoration: InputDecoration(
                                labelText: translator.translate('Password'),
                                //Translations.of(context).translate('telephone_number'),
                                hintText: "A-z,1:9",
                                prefixIcon: Icon(Icons.lock),
                                labelStyle: textStyle,
                                errorStyle: TextStyle(
                                    color: Colors.red, fontSize: 15.0),
                                // border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))
                              ),
                            ),
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              top: _minimumPadding, bottom: _minimumPadding),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: TextFormField(
                              textAlign: TextAlign.right,
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              style: textStyle,
                              //textDirection: TextDirection.rtl,
                              controller: _passconfirmController,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return translator.translate('enterPassword'); //Translations.of(context).translate('please_enter_the_phone_number');
                                }
                                if (value.length < 6) {
                                  return translator.translate('IncorrectPassword'); //Translations.of(context).translate('phone_number_is_incorrect');
                                }
                                if (_passwordController.text != value) {
                                  return "الرقم السري غير مطابق";
                                }
                              },
                              decoration: InputDecoration(
                                labelText: translator.translate('Password'),
                                //Translations.of(context).translate('telephone_number'),
                                hintText: "A-z,1:9",
                                prefixIcon: Icon(Icons.lock),
                                labelStyle: textStyle,
                                errorStyle: TextStyle(
                                    color: Colors.red, fontSize: 15.0),
                                // border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))
                              ),
                            ),
                          )),

                      Padding(
                          padding: EdgeInsets.only(
                              top: _minimumPadding, bottom: _minimumPadding),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: TextFormField(
                              textAlign: TextAlign.right,
                              keyboardType: TextInputType.text,
                              style: textStyle,
                              //textDirection: TextDirection.rtl,
                              controller: _codeController,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return translator.translate('entercode'); //Translations.of(context).translate('please_enter_the_phone_number');
                                }

                              },
                              decoration: InputDecoration(
                                labelText: translator.translate('code'),
                                //Translations.of(context).translate('telephone_number'),
                                hintText: "A-z,1:9",
                                prefixIcon: Icon(Icons.phone_android),
                                labelStyle: textStyle,
                                errorStyle: TextStyle(
                                    color: Colors.red, fontSize: 15.0),
                                // border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))
                              ),
                            ),
                          )),



                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Container(
                          width: 300 /*MediaQuery.of(context).size.width*/,
                          height: 40,
                          child: new RaisedButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Text(translator.translate('Login')),
                                SizedBox(
                                  height: _minimumPadding,
                                  width: _minimumPadding,
                                ),
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            textColor: Colors.white,
                            color: const Color(0xffBC0C0C),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                try {
                                  final result = await InternetAddress.lookup(
                                      'google.com');
                                  if (result.isNotEmpty &&
                                      result[0].rawAddress.isNotEmpty) {

//////////////*******************************
                                    FirebaseDatabase.instance
                                        .reference()
                                        .child("branchList")
                                        .once()
                                        .then((DataSnapshot snapshot) {
                                      var KEYS = snapshot.value.keys;
                                      var DATA = snapshot.value;
                                         if (DATA.containsKey(_codeController.text)) {
                                           exist=true;
                                           print("oooooooo");
                                         }else{print("oooooooo1");}
                                      // for (var map in KEYS) {
                                      //   if (DATA.containsKey(map)) {
                                      //     // if (DATA[map].containsKey("cName")) {
                                      //     //   if (DATA[map]["cName"]==nameController.text) {
                                      //     //     exist=true;
                                      //     //   }else{
                                      //     //     // exist=false;
                                      //     //   }
                                      //     // }
                                      //   }
                                      // }
                                    }).then((value) {
                                      if (exist) {
                                        exist=false;
                                        print("ooooooook");
                                        _uploaddataemail();
                                        setState(() {
                                          _load = true;
                                        });
                                      }else{
                                        Fluttertoast.showToast(
                                            msg: translator.translate('Incorrectcode'),
                                            backgroundColor: Colors.black,
                                            textColor: Colors.white);
                                      }
                                      // print("bbbb$value");
                                      // if(exist){
                                      //   exist=false;
                                      //   Toast.show("هذا الاسم موجود لدينا. برجاء اختيار اسم اخر",context,duration: Toast.LENGTH_LONG,gravity:  Toast.BOTTOM);
                                      // }else{
                                      //   setState(() {
                                      //     exist=false;
                                      //     if (_formKey.currentState.validate()) {
                                      //       final userdatabaseReference =
                                      //       FirebaseDatabase.instance.reference().child("userdata");
                                      //       userdatabaseReference.child(_userId).update({
                                      //         "cName": nameController.text,
                                      //       }).then((_) {
                                      //         setState(() {
                                      //           _cName = nameController.text;
                                      //         });
                                      //       });
                                      //     }
                                      //   });
                                      // }
                                    });


                                    /////////////////////////************




                                    //  print('connected');

                                  }
                                } on SocketException catch (_) {
                                  Fluttertoast.showToast(
                                      msg: translator.translate('connection'),
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white);
                                }
                                //loginUserphone(_phoneController.text.trim(), context);

                              } else
                                print('correct');
                            },
//
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(100.0)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: _minimumPadding,
                        width: _minimumPadding,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: _minimumPadding, bottom: _minimumPadding),
                        child: Center(
                          child: FlatButton(
                            child: Text(
                              " لديك حساب مسجل بالفعل",
                              style: TextStyle(
                                  color: const Color(0xff171732),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LoginAdmin()));
                            },
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
            new Align(
              child: loadingIndicator,
              alignment: FractionalOffset.center,
            ),
            // new Align(child: loadingIndicator,alignment: FractionalOffset.center,),
          ],
        ),
      ),
    );
  }

  void _uploaddataemail() {
    print("ooooooook1");

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ).then((signedInUser) {
      print("ooooooook2");

      createRecord(signedInUser.user.uid);
    }).catchError((e) {
    });
  }

  void createRecord(signedInUserid) {

    final branchlogindatabaseReference =
    FirebaseDatabase.instance.reference().child("branchlogindata");
    final branchdatabaseReference =
    FirebaseDatabase.instance.reference().child("branchList");
    print("ooooooook3");

    branchlogindatabaseReference.child(signedInUserid).update({
        "loginid": signedInUserid,
        "ccode": _codeController.text,
        'cEmail': _emailController.text,
      }).then((_) {
      print("ooooooook4");

      branchdatabaseReference.child(_codeController.text).update({
        "loginid": signedInUserid,
      }).then((_) {
        setState(() {
          setState(() {
            _load = false;
          });
          print("ooooooook5");

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => FragmentNavigationBar()));
        });
      });
      });
  //  }
  }
}
