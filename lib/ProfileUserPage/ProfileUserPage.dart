import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:friesdip/DrawerScreenPage/CustomAppBar.dart';
import 'package:friesdip/DrawerScreenPage/CustomDrawer.dart';
import 'package:friesdip/ProfileUserPage/SettingAcount.dart';
import 'package:friesdip/DrawerScreenPage/FollowOrder.dart';
import 'package:friesdip/ProfileUserPage/userorders.dart';
import 'package:friesdip/ScreenPage/loginphone.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toast/toast.dart';

class ProfileUserPage extends StatefulWidget {
  //String logourl;

  ProfileUserPage();

  @override
  _ProfileUserPageState createState() => _ProfileUserPageState();
}

class _ProfileUserPageState extends State<ProfileUserPage> {
  TextEditingController _nameController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  bool _load = false;
  String gender = '';
  String _userid;

  @override
  initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) => user == null
        ? setState(() {})
        : setState(() {
            _userid = user.uid;
          }));
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
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
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
            child: Text(_nameController.text),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    if (_userid != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingAcount()));
                    } else {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SignIn()));
                    }

//                     Alert(
//                         context: context,
//                         title: translator.translate('AccountSettings'),
//                         content: Column(
//                           children: <Widget>[
//                             TextFormField(
//                               decoration: InputDecoration(
//                                 icon: Icon(Icons.perm_identity),
//                                 labelText: translator.translate('Name'),
//                               ),
//                               controller: _nameController,
//                               validator: (String value) {
//                                 if (value.isEmpty) {
//                                   return translator.translate(
//                                       'enterName'); //Translations.of(context).translate('please_enter_the_phone_number');
//                                 }
//                               },
//                             ),
//                             DropDown(
//                               items: ["Male", "Female"],
//                               hint: Text(
//                                 translator.translate('sex'),
//                               ),
//                               showUnderline: false,
//                               isCleared: false,
//                               onChanged: (v) {
//                                 setState(() {
//                                   gender = v;
//                                 });
//                                 print(gender);
//                               },
//                             ),
// //                            TextField(
// //                              obscureText: true,
// //                              decoration: InputDecoration(
// //                                icon: Icon(Icons.accessibility_new),
// //                                labelText: translator.translate('sex'),
// //                              ),
// //                            ),
//                           ],
//                         ),
//                         buttons: [
//                           DialogButton(
//                             onPressed: () async {
//                               setState(() {
//                                 _load = true;
//                               });
//                               try {
//                                 final result =
//                                     await InternetAddress.lookup('google.com');
//                                 if (result.isNotEmpty &&
//                                     result[0].rawAddress.isNotEmpty) {
//                                   //  print('connected');
//                                   Future.delayed(Duration(seconds: 3),
//                                       () async {
//                                     createRecord(_nameController.text, gender);
//                                   });
//                                 }
//                               } on SocketException catch (_) {
//                                 //  print('not connected');
//                                 Toast.show(
//                                     translator.translate('connection'), context,
//                                     duration: Toast.LENGTH_LONG,
//                                     gravity: Toast.BOTTOM);
//                               }
//                               //loginUserphone(_phoneController.text.trim(), context);
//                             },
//                             child: Text(
//                               translator.translate('confirmation'),
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 20),
//                             ),
//                           )
//                         ]).show();
                  },
                  child: Container(
                    width: 155.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xfff7f7f7),
                      border: Border.all(width: 1.0, color: Colors.grey),
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.settings,
                              color: Theme.of(context).primaryColor,
                              size: 50,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25, bottom: 15),
                          child: SizedBox(
//                            width: 74.0,
                            child: Text(
                              translator.translate('AccountSettings'),
                              style: TextStyle(
                                fontFamily: 'Estedad-Black',
                                fontSize: 18,
                                color: const Color(0xff41a0cb),
                                height: 1.2222222222222223,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
         Navigator.push(
             context,
             MaterialPageRoute(
                 builder: (context) =>
                     UserOrders()));
                  },
                  child: Container(
                    width: 155.2,
//                    height: 162.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xfff7f7f7),
                      border: Border.all(width: 1.0, color: Colors.grey),
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.event_note,
                              size: 50,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25, bottom: 15),
                          child: SizedBox(
//                            width: 74.0,
                            child: Text(
                              translator.translate('OrderHistory'),
                              style: TextStyle(
                                fontFamily: 'Estedad-Black',
                                fontSize: 18,
                                color: const Color(0xff41a0cb),
                                height: 1.2222222222222223,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    //StepperPage
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => StepperPage()));
                  },
                  child: Container(
                    width: 155.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xfff7f7f7),
                      border: Border.all(width: 1.0, color: Colors.grey),
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.track_changes,
                              color:Theme.of(context).primaryColor,
                              size: 50,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25, bottom: 15),
                          child: SizedBox(
//                            width: 74.0,
                            child: Text(
                              translator.translate('FollowOrder'),
                              style: TextStyle(
                                fontFamily: 'Estedad-Black',
                                fontSize: 18,
                                color: const Color(0xff41a0cb),
                                height: 1.2222222222222223,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
//                InkWell(
//                  onTap: () {},
//                  child: Container(
//                    width: 155.2,
////                    height: 162.0,
//                    decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(10.0),
//                      color: const Color(0xfff7f7f7),
//                      border: Border.all(width: 1.0, color: Colors.grey),
//                    ),
//                    child: Column(
//                      children: <Widget>[
//                        Padding(
//                          padding: const EdgeInsets.only(top: 20),
//                          child: Container(
//                            width: 50,
//                            height: 50,
//                            child: Icon(
//                              Icons.location_on,
//                              size: 50,
//                              color: Colors.black,
//                            ),
//                          ),
//                        ),
//                        Padding(
//                          padding: const EdgeInsets.only(top: 25, bottom: 15),
//                          child: SizedBox(
////                            width: 74.0,
//                            child: Text(
//                              translator.translate('MyAddresses'),
//                              style: TextStyle(
//                                fontFamily: 'Estedad-Black',
//                                fontSize: 18,
//                                color: const Color(0xff41a0cb),
//                                height: 1.2222222222222223,
//                              ),
//                              textAlign: TextAlign.right,
//                            ),
//                          ),
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
              ],
            ),
          ),
          new Align(
            child: loadingIndicator,
            alignment: FractionalOffset.center,
          ),
        ],
      ),
    );
  }


}
