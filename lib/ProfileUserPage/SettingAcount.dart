import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:friesdip/DrawerScreenPage/CustomAppBar.dart';
import 'package:friesdip/DrawerScreenPage/CustomDrawer.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:toast/toast.dart';

class SettingAcount extends StatefulWidget {
  @override
  _SettingAcountPageState createState() => _SettingAcountPageState();
}

class _SettingAcountPageState extends State<SettingAcount> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _numberPhoneUser = TextEditingController();
  TextEditingController _phonedialogController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  bool _load = false;
  String _userid;
  String _numberPhone, _nameUser, _gender;
  int _verticalGroupValue=0;
  List<String> _status = [
    translator.translate('Male'),
    translator.translate('Female')
  ];
  final userdatabaseReference =
  FirebaseDatabase.instance.reference().child("userdata");
  @override
  initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) => user == null
        ? setState(() {})
        : setState(() {
            _userid = user.uid;
          }));

    getUserData();
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
    return Scaffold(
      key: _formKey,
      drawer: Theme(
          data: Theme.of(context).copyWith(
            // Set the transparency here
            canvasColor: Colors.white10.withOpacity(
                0.8), //or any other color you want. e.g Colors.blue.withOpacity(0.5)
          ),
          child: BaseDrawer()),
      appBar: BaseAppBar(
        appBar: AppBar(),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    child: Icon(
                      Icons.person,
                      size: 100,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: .2,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.perm_identity, color: Theme.of(context).accentColor,),
                        labelText: _nameUser,
                        hintText: _nameUser),
                    controller: _nameController,
                    onEditingComplete: (){

                      if (_nameController.text.isNotEmpty ) {
                        userdatabaseReference.child(_userid).update({
                          "cName": _nameController.text,
                        }).then((_) {
                          setState(() {
                            _load = false;
                            Toast.show(translator.translate('done'), context,
                                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                            // Navigator.pop(context);
                          });
                        });
                      } else {
                        setState(() {
                          _load = false;
                          Toast.show(translator.translate('complete'), context,
                              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                        });

                      }}
                    // validator: (String value) {
                    //   if (value.isEmpty) {
                    //     return translator.translate(
                    //         'enterName'); //Translations.of(context).translate('please_enter_the_phone_number');
                    //   }
                    // },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: .2,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 100, left: 100),
                  child: Center(
                    child: RadioGroup<String>.builder(
                      direction: Axis.horizontal,
                      groupValue:_status[_verticalGroupValue] ,
                      onChanged: (value) => setState(() {
                        _gender = value;
                        for(var i=0;i<_status.length;i++){
                          if(value==_status[i]){ setState(() {
                            _verticalGroupValue=i;
                            userdatabaseReference.child(_userid).update({
                              "cGender": _verticalGroupValue,
                            }).then((_) {
                              setState(() {
                                _load = false;
                                Toast.show(translator.translate('done'), context,
                                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                // Navigator.pop(context);
                              });
                            });
                          });}
                        }

                       // print("$_verticalGroupValue");
                      }),
                      items: _status,
                      itemBuilder: (item) => RadioButtonBuilder(
                        item,textPosition: RadioButtonTextPosition.right,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: .2,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: (){
                     showAlertDialogphone(context, _numberPhone);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.phone_iphone, color: Theme.of(context).accentColor,),
                        Text("${_numberPhone}" ),


                      ],
                    ),
                  ),
                ),
                new Align(
                  child: loadingIndicator,
                  alignment: FractionalOffset.center,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              setState(() {
                _load = true;
              });
              try {
                final result = await InternetAddress.lookup('google.com');
                if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                  //  print('connected');
                  Future.delayed(Duration(seconds: 1), () async {
                    createRecord(_nameController.text);
                  });
                }
              } on SocketException catch (_) {
                //  print('not connected');
                Toast.show(translator.translate('connection'), context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              color: Theme.of(context).accentColor,
              child: Center(
                  child: Text(
                translator.translate('save_all'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
            ),
          ),
        ],
      ),
    );
  }

  void createRecord(String name) {

    if (name.isNotEmpty ) {
      userdatabaseReference.child(_userid).update({
        "cName": name,
      }).then((_) {
        setState(() {
          _load = false;
          Toast.show(translator.translate('done'), context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          // Navigator.pop(context);
        });
      });
    } else {
      setState(() {
        _load = false;
        Toast.show(translator.translate('complete'), context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      });

    }


  }
  void getUserData() async {
    FirebaseAuth _firebaseAuth;
    _firebaseAuth = FirebaseAuth.instance;
    final mDatabase = FirebaseDatabase.instance.reference();
    FirebaseUser usr = await _firebaseAuth.currentUser();
    if (usr != null) {
      mDatabase
          .child("userdata")
          .child(_userid)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
//        var result = values['rating'].reduce((a, b) => a + b) / values.length;
        setState(() {

          if (values["cPhone"] != null) {
            _numberPhone = values["cPhone"];

            print("####################_numberPhone :$_numberPhone");
          } else {
            _numberPhone = translator.translate('no_data');

            print("####################_numberPhone :$_numberPhone");
          }
          if (values["cName"] != null) {
            _nameUser = values["cName"];
            print("####################_nameUser :$_nameUser");
          } else {
            _nameUser = translator.translate('no_data');
            print("####################_nameUser :$_nameUser");
          }
          if (values["cGender"] != null) {
            _verticalGroupValue = values["cGender"];
            print("####################_gender :$_gender");
          } else {
            _verticalGroupValue = 0;
            print("####################_gender :$_gender");
          }


        });

      });
    }
  }
  showAlertDialogphone(BuildContext context, phone) {
    _phonedialogController = TextEditingController(text: phone);

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "إلغاء",
        style: TextStyle(color: Colors.black),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "حفظ",
        style: TextStyle(color: Colors.black),
      ),
      onPressed: () {
        setState(() {
          if (_formKey.currentState.validate()) {
            FirebaseAuth.instance.verifyPhoneNumber(
                phoneNumber:"+2${ _phonedialogController.text}",
                timeout: const Duration(minutes: 2),
                verificationCompleted: (credential) async {
                  await (await FirebaseAuth.instance.currentUser()).updatePhoneNumberCredential(credential);
                  // either this occurs or the user needs to manually enter the SMS code
                },
                verificationFailed: null,
                codeSent: (verificationId, [forceResendingToken]) async {
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
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    alignment: Alignment.center,
                                    matchTextDirection: true,
                                    repeat: ImageRepeat.noRepeat,
                                    image: AssetImage(
                                        "assets/images/ic_confirmephone.png"),
                                  ),
                                  borderRadius: BorderRadius.circular(21.0),
                                  //color: const Color(0xff4fc3f7),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text("تحقق من الكود المرسل؟"),
                              ),
                            ],
                          ),
//                  AssetImage("assets/logowhite.png"),
//Text("Give the code?"),
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
                              child: Text("تأكيد"),
                              textColor: Colors.white,
                              color: Colors.black,
                              onPressed: () async {

                                String smsCode=_codeController.text.trim();;
                                // get the SMS code from the user somehow (probably using a text field)
                                final AuthCredential credential =
                                PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: smsCode);
                                await (await FirebaseAuth.instance.currentUser()).updatePhoneNumberCredential(credential).then((value) {

                                  final userdatabaseReference =
                                  FirebaseDatabase.instance.reference().child("userdata");
                                  userdatabaseReference.child(_userid).update({
                                    "cPhone": _phonedialogController.text,
                                  }).then((_) {
                                    setState(() {
                                      _numberPhone = _phonedialogController.text;
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();

                                    });
                                  });

                                });
                               // Navigator.pop(context);
                                //FirebaseUser user = result.user;
                               // createRecord(result.user.uid);
                                // Navigator.of(context).pushReplacementNamed('/fragmentsouq');
                              },
                            )
                          ],
                        );
                      });




                },
                codeAutoRetrievalTimeout: null);




          }
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("تأكيد"),
      content: Form(
        key: _formKey,
        child: Padding(
            padding:
            EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextFormField(
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                //style: textStyle,
                //textDirection: TextDirection.rtl,
                controller: _phonedialogController,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'برجاء إدخال رقم الهاتف';
                  }
                  if (value.length < 10) {
                    return ' رقم الهاتف غير صحيح';
                  }
                },
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  //hintText: '$name',
                  //labelStyle: textStyle,
                  errorStyle: TextStyle(color: Colors.red, fontSize: 15.0),
                  // border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))
                ),
              ),
            )),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
