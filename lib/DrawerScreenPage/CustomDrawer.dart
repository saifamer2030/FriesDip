import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friesdip/DrawerScreenPage/MenuPage.dart';
import 'package:friesdip/DrawerScreenPage/OfferPage.dart';
import 'package:friesdip/ProfileUserPage/ProfileUserPage.dart';
import 'package:friesdip/DrawerScreenPage/FollowOrder.dart';
import 'package:friesdip/ScreenPage/HomePage.dart';
import 'package:friesdip/ScreenPage/branchesusers.dart';
import 'package:friesdip/ScreenPage/loginphone.dart';
import 'package:friesdip/admin/ControlPanel/FragmentNavigationBar.dart';
import 'package:friesdip/admin/ControlPanel/branchesadmin.dart';
import 'package:friesdip/admin/Branches/loginadmin.dart';
import 'package:friesdip/admin/ControlPanel/menuadmin.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:toast/toast.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseDrawer extends StatefulWidget {
//final String logourl;
  const BaseDrawer();

  @override
  _BaseDrawerState createState() => _BaseDrawerState();
}

class _BaseDrawerState extends State<BaseDrawer> {
  String _userid;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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
    return Drawer(
      key: _scaffoldKey,
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.home,
                      color: Theme.of(context).primaryColor,
                      size: 25,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      translator.translate('home'),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Estedad-Black"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: .2,
            color: Colors.black,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MenuPage()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.library_books,
                      color: Theme.of(context).primaryColor,
                      size: 25,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      translator.translate('menu'),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Estedad-Black"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: .2,
            color: Colors.black,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OfferPage()));
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.local_offer,
                      color: Theme.of(context).primaryColor,
                      size: 25,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      translator.translate('promos'),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Estedad-Black"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: .2,
            color: Colors.black,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => BranchesUsers()));
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.public,
                      color: Theme.of(context).primaryColor,
                      size: 25,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      translator.translate('branches'),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Estedad-Black"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: .2,
            color: Colors.black,
          ),
          InkWell(
            onTap: () {
              print("##### id :$_userid");
              if (_userid != null) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => StepperPage()));
              } else {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.pin_drop,
                      color: Theme.of(context).primaryColor,
                      size: 25,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      translator.translate('OrderTracking'),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Estedad-Black"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: .2,
            color: Colors.black,
          ),
          InkWell(
            onTap: () {
              print("##### id :$_userid");
              if (_userid != null) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileUserPage()));
              } else {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.person_pin,
                      color: Theme.of(context).primaryColor,
                      size: 25,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      translator.translate('account'),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Estedad-Black"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: .2,
            color: Colors.black,
          ),
          InkWell(
            onTap: () {
              _makePhoneCall('tel:+966556089627');
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.headset_mic,
                      color: Theme.of(context).primaryColor,
                      size: 25,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      translator.translate('help'),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Estedad-Black"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: .2,
            color: Colors.black,
          ),
          InkWell(
            onTap: () {
              if (_userid != null) {
                Toast.show(translator.translate('exitsec'), context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

                Future.delayed(Duration(seconds: 3), () async {
                  await FirebaseAuth.instance.signOut();
                  Toast.show(translator.translate('exitdon'), context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignIn()));
                });
              } else {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.exit_to_app,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _userid == null
                        ? Text(
                            translator.translate('Login'),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Estedad-Black"),
                          )
                        : Text(
                            translator.translate('Exit'),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Estedad-Black"),
                          ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: OutlineButton(
              onPressed: () {
                translator.setNewLanguage(
                  context,
                  newLanguage: translator.currentLanguage == 'ar' ? 'en' : 'ar',
                  remember: true,
                  restart: true,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.translate,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      translator.translate('buttonTitle'),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Estedad-Black"),
                    ),
                  ),
                ],
              ),
            ),
          ),
//          OutlineButton(
//            onPressed: () async {
//              final translator = GoogleTranslator();
//
//              final input = "Здравствуйте. Ты в порядке?";
//
//              translator.translate(input, from: 'ru', to: 'ar').then(print);
//              // prints Hello. Are you okay?
//
//              var translation = await translator.translate("Dart is very cool!", to: 'ar');
//              print(translation);
//              // prints Dart jest bardzo fajny!
//
//              print(await "example".translate(to: 'ar'));
//              // prints exemplo
//            },
//            child: Text(translator.translate('googleTest')),
//          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
}
