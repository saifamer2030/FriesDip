import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:access_settings_menu/access_settings_menu.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alert/flutter_alert.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:friesdip/DrawerScreenPage/CustomAppBar.dart';
import 'package:friesdip/DrawerScreenPage/CustomDrawer.dart';
import 'package:friesdip/DrawerScreenPage/MenuPage.dart';
import 'package:friesdip/DrawerScreenPage/OfferPage.dart';
import 'package:friesdip/ScreenPage/branchesusers.dart';
import 'package:friesdip/ScreenPage/loginphone.dart';
import 'package:friesdip/ScreenPage/userdeliverylocation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:friesdip/Classes/globals.dart' as globals;

class HomePage extends StatefulWidget {
  //String logourl;

  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

//db ref
final fcmReference = FirebaseDatabase.instance.reference().child('Fcm-Token');

class _HomePageState extends State<HomePage> {
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  DateTime backbuttonpressedTime;
  Completer<GoogleMapController> _controller = Completer();
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  bool isLocationEnabled;
  BuildContext _context;
  LatLng _myLoc;
  Position _geoPosition;
  String _userId;

  @override
  void initState() {
    super.initState();

    firebaseMessaging.subscribeToTopic('All');
    FirebaseAuth.instance.currentUser().then((user) => user == null
        ? null
        : setState(() {
            _userId = user.uid;
            FirebaseDatabase.instance
                .reference()
                .child("userdata")
                .child(_userId)
                .child("deleted")
                .once()
                .then((DataSnapshot data1) {
              if (data1.value != null) {
                setState(() {
                  if (data1.value) {
                    Future.delayed(Duration(seconds: 0), () async {
                      FirebaseUser user =
                          await FirebaseAuth.instance.currentUser();
                      print("kkkjjj${data1.value}$_userId");

                      user.delete().then((value) {
                        print("kkkjjj1");

                        FirebaseDatabase.instance
                            .reference()
                            .child("userdata")
                            .child(_userId)
                            .remove();
                      }).catchError((e) {
                        print("kkkjjj1$e");
                      });
                    });
                  }
                });
              }
            });
          }));
    firebaseMessaging.getToken().then((token) {
      if (_userId != null) {
        update(token);
      }
    }).then((_) {});
    setState(() {
      registerNotification();
      configLocalNotification();
    });
    firebaseMessaging.subscribeToTopic('All');

    checkGPS('ACTION_LOCATION_SOURCE_SETTINGS');
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
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
        body: WillPopScope(
          onWillPop: onWillPop,
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2,
                child: globals.logourl == "a" || globals.logourl == null
                    ? Image.asset('assets/images/food.png')
                    : CachedNetworkImage(
                        imageUrl: globals.logourl,
                        placeholder: (context, url) => SpinKitCubeGrid(
                          color: Theme.of(context).accentColor,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        // fit: BoxFit.fill,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
//              width: MediaQuery.of(context).size.width,
//              height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(40.0),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: const Color(0x8c6583f3),
                    //     blurRadius: 2,
                    //   ),
                    // ],
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, left: 8.0),
                              child: new RaisedButton(
                                child: new Text(
                                  translator.translate('receipt'),
                                  style: TextStyle(
                                    fontFamily: 'Estedad-Black',
                                  ),
                                ),
                                textColor: Colors.white,
                                color: Theme.of(context).accentColor,
                                //BC0C0C
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BranchesUsers()));
                                },
//
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0)),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            translator.translate('or'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              fontFamily: 'Estedad-Black',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, left: 8.0),
                              child: new RaisedButton(
                                child: new Text(
                                  translator.translate('delivery'),
                                  style: TextStyle(
                                    fontFamily: 'Estedad-Black',
                                  ),
                                ),
                                textColor: Colors.white,
                                color: Theme.of(context).accentColor,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UserDeliveryLocation()));
                                },
//
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        )
//      Container(
//        width: double.infinity,
//        child: Center(
//          child: Text(
//            translator.translate('textArea'),
//            textAlign: TextAlign.center,
//            style: TextStyle(fontSize: 35),
//          ),
//        ),
//      ),
        );
  }

  Future<bool> onWillPop() async {
    DateTime currentTime = DateTime.now();
    //Statement 1 Or statement2
    bool backButton = backbuttonpressedTime == null ||
        currentTime.difference(backbuttonpressedTime) > Duration(seconds: 3);

    if (backButton) {
      backbuttonpressedTime = currentTime;
      Fluttertoast.showToast(
          msg: translator.translate('ExitApp'),
          backgroundColor: Colors.black,
          textColor: Colors.white);
      return false;
    }
    return true;
  }

  //current loc
  checkGPS(settingsName) async {
    print("mmm" + isLocationEnabled.toString());

    isLocationEnabled = await Geolocator().isLocationServiceEnabled();
    print("mmm" + isLocationEnabled.toString());
    if (!isLocationEnabled) {
      print("mmm" + isLocationEnabled.toString());

      showAlert(
        context: context,
        title: translator.translate('enable_gps'),
        body: translator.translate('enable_gps_text'),
        actions: [
          AlertAction(
            text: translator.translate('enable'),
            isDestructiveAction: true,
            onPressed: () {
              // TODO
              openSettingsMenu(settingsName);
            },
          ),
        ],
        cancelable: false,
      );
    }
  }

  openSettingsMenu(settingsName) async {
    isLocationEnabled = await Geolocator().isLocationServiceEnabled();

    try {
      isLocationEnabled =
          await AccessSettingsMenu.openSettings(settingsType: settingsName)
              .then((value) {
        _getCurrentLocation();
        //  print("aabb$value");
      });

      // _getCurrentLocation();
    } catch (e) {
      isLocationEnabled = false;
    }
  }

  _getCurrentLocation() async {
    //  print("kkk"+isLocationEnabled.toString());

    _geoPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((po) {
      _getAddressFromLatLng(po.latitude, po.longitude);
      print("mmm" + po.latitude.toString());
      // double a=po.latitude; po.longitude;
      //_myLoc = LatLng(po.latitude, po.longitude);
    });
  }

  _getAddressFromLatLng(double lt, double lg) async {
    try {
      List<Placemark> p = await Geolocator().placemarkFromCoordinates(lt, lg);

      Placemark place = p[0];
      String name = place.name;
      String subLocality = place.subLocality;
      String locality = place.locality;
      String administrativeArea = place.administrativeArea;
      String postalCode = place.postalCode;
      String country = place.country;

      print("mmm$lt////$lg");
      setState(() {
        globals.lat_gps = lt;
        globals.long_gps = lg;
        globals.address_gps =
            "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";
        //  _currentAddress =
        //   "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";
        print("mmm" + lg.toString());
      });
    } catch (e) {
      print(e);
    }
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true),
    );
    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');

      showNotification(message['notification']);
//      _serialiseAndNavigate(message);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');

//      _serialiseAndNavigate(message);
      return;
    },
        // onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
//        onBackgroundMessage: myBackgroundMessageHandler,

        onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
//          _serialiseAndNavigate(message);
      return;
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@drawable/ic_notification');
    var initializationSettingsIOS = new IOSInitializationSettings(
      defaultPresentAlert: true,
      requestSoundPermission: true,
      defaultPresentSound: true,
      requestAlertPermission: true,
    );
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      /*onSelectNotification: selectNotification*/
    );
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.arabdevelopers.friesdip'
          : 'com.arabdevelopers.friesdip',
      'Fries DIP',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails(
      presentSound: true,
      presentAlert: true,
    );
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  update(String token) async {
    fcmReference.child(_userId).set({"Token": token});
  }
}
