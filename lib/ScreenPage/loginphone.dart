import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:friesdip/ScreenPage/HomePage.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:toast/toast.dart';

class SignIn extends StatefulWidget {
  SignIn();
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;

//  TextEditingController _nameController = TextEditingController();
//  TextEditingController _emailController = TextEditingController();
//  TextEditingController _passwordController = TextEditingController();
//  TextEditingController _confirmpasswordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _codeController = TextEditingController();

//  var _initpassword = '';
//  var _initpasswordconf = '';
  bool _load = false;

//  final userdatabaseReference =
//  FirebaseDatabase.instance.reference().child("userdata");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _load
        ? new Container(
            child: SpinKitCubeGrid(
              color: Theme.of(context).primaryColor,
            ),
          )
        : new Container();
    TextStyle textStyle = Theme.of(context).textTheme.subtitle;

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
//      floatingActionButton: FloatingActionButton(
//        backgroundColor: const Color(0xff171732),
//        child: Icon(Icons.mail,color: Colors.white,),
//        heroTag: "unique3",
//        onPressed: () {
//          Navigator.pushReplacement(
//              context,
//              MaterialPageRoute(
//                  builder: (context) =>
//                      LoginScreen2(widget.regionlist)));
//        },
//      ),
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
//        decoration: new BoxDecoration(
//          image: new DecorationImage(
//            image: new AssetImage("assets/images/ic_background.png"),
//            fit: BoxFit.cover,
//          ),
//        ),
        child: Stack(
          children: <Widget>[
            Form(
              key: _formKey,

                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    top: _minimumPadding*40, bottom: _minimumPadding),
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: TextFormField(
                                    textAlign: TextAlign.right,
                                    keyboardType: TextInputType.number,
                                    style: textStyle,
                                    //textDirection: TextDirection.rtl,
                                    controller: _phoneController,
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return translator.translate('enterNumber'); //Translations.of(context).translate('please_enter_the_phone_number');
                                      }
                                      if (value.length < 9) {
                                        return translator.translate('IncorrectPhone'); //Translations.of(context).translate('phone_number_is_incorrect');
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: translator.translate('MobileNumber'),
                                      //Translations.of(context).translate('telephone_number'),
                                      hintText: translator.translate('Like'),
                                      prefixIcon: Icon(Icons.phone_android),
                                      labelStyle: textStyle,
                                      errorStyle: TextStyle(
                                          color: Colors.red, fontSize: 15.0),
                                      // border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))
                                    ),
                                  ),
                                )),

                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
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
                            color: Theme.of(context).accentColor,
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                try {
                                  final result = await InternetAddress.lookup(
                                      'google.com');
                                  if (result.isNotEmpty &&
                                      result[0].rawAddress.isNotEmpty) {
                                    //  print('connected');
                                    loginphone(
                                        _phoneController.text.trim(), context);
                                    setState(() {
                                      _load = true;
                                    });
                                  }
                                } on SocketException catch (_) {
                                  //  print('not connected');
                                  Toast.show(
                                      translator.translate('connection'), context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                }
                                //loginUserphone(_phoneController.text.trim(), context);

                              } else
                                print('correct');
                            },
//

                          ),
                        ),
                      ),
                    ],
                  )

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

  Future<bool> loginphone(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        //phoneNumber: "+966$phone",
        phoneNumber: "+966$phone",
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          Navigator.of(context).pop();

          AuthResult result = await _auth.signInWithCredential(credential);
          createRecord(result.user.uid);
          setState(() {
            _load = false;
          });
        },
        verificationFailed: (AuthException exception) {
          setState(() {
            _load = false;
          });
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          setState(() {
            _load = false;
          });
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Column(
                    children: <Widget>[
                      Container(
                        width: 50.0,
                        height: 50.0,
                        child: Icon(
                          Icons.vpn_key,
                          color: Colors.black,
                        ),
//                        decoration: BoxDecoration(
//                          image: DecorationImage(
//                            alignment: Alignment.center,
//                            matchTextDirection: true,
//                            repeat: ImageRepeat.noRepeat,
//                            image: AssetImage(
//                                "assets/images/ic_confirmephone.png"),
//                          ),
//                          borderRadius: BorderRadius.circular(21.0),
//                          //color: const Color(0xff4fc3f7),
//                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(translator.translate('CheckCode')),
                      ),
                    ],
                  ),
//
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        color: Colors.grey[300],
                        width: 150,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _codeController,
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(translator.translate('confirmation')),
                      textColor: Colors.white,
                      color: Colors.black,
                      onPressed: () async {
                        final code = _codeController.text.trim();
                        AuthCredential credential =
                            PhoneAuthProvider.getCredential(
                                verificationId: verificationId, smsCode: code);

                        AuthResult result =
                            await _auth.signInWithCredential(credential);

                        createRecord(result.user.uid);
                        setState(() {
                          _load = false;
                        });
                      },
                    )
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: null);
  }

  void createRecord(signedInUserid) {
    final userdatabaseReference =
        FirebaseDatabase.instance.reference().child("userdata");

    if (signedInUserid == null) {
      userdatabaseReference.child(signedInUserid).set({
        "cId": signedInUserid,
        "cPhone": _phoneController.text,
      }).then((_) {
        setState(() {
          _load = false;
        });
        setState(() {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        });

      });
    } else {
      userdatabaseReference.child(signedInUserid).update({
        "cPhone": _phoneController.text,
        "cId": signedInUserid,
      }).then((_) {
        setState(() {
          _load = false;
        });
        setState(() {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        });

      });
    }
  }
}
