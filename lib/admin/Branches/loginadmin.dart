import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friesdip/ScreenPage/HomePage.dart';
import 'package:friesdip/admin/ControlPanel/FragmentNavigationBar.dart';
import 'package:friesdip/admin/Branches/SignUpAdmin.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:toast/toast.dart';

class LoginAdmin extends StatefulWidget {
  LoginAdmin();
  @override
  _LoginAdminState createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;
  bool exist=false;


  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

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

                                    _uploaddataemail();
                                    setState(() {
                                      _load = true;
                                    });
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
                              "ليس لديك حساب ... ",
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
                                          LogoutAdmin()));
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
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text)
        .then((signedInUser) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => FragmentNavigationBar()));
      setState(() {
        _load = false;
      });
    }).catchError((e) {
//      Toast.show(e, context,
//          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      setState(() {
        _load = false;
      });
    });
  }

}
