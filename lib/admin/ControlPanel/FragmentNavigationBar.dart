import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:friesdip/admin/ControlPanel/NotificationAllUsers/widget/messaging_widget.dart';
import 'package:friesdip/admin/ControlPanel/branchesadmin.dart';
import 'package:friesdip/admin/ControlPanel/ThemePage.dart';
import 'package:friesdip/admin/Branches/branchorders.dart';
import 'package:friesdip/admin/ControlPanel/menuadmin.dart';
import 'package:friesdip/admin/ControlPanel/promocodeadmin.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class FragmentNavigationBar extends StatefulWidget {
  @override ///////
  _FragmentNavigationBarState createState() => _FragmentNavigationBarState();
}
//db ref
final fcmReference = FirebaseDatabase.instance.reference().child('Fcm-Token');
class _FragmentNavigationBarState extends State<FragmentNavigationBar> {
  int currentTab = 3; // to keep track of active tab index
  String _userId;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  new FlutterLocalNotificationsPlugin();
  List<Widget> screens() => [
        BranchesAdmin(),
        MenuAdmin(),
        PromoCodeAdmin(),
        ThemePage()
      ]; // to store nested tabs
  final PageStorageBucket bucket = PageStorageBucket();
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();
  Widget currentScreen; // Our first view in viewport

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) => user == null
        ? null
        : setState(() {
      _userId = user.uid;
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
    setState(() {
      currentScreen = BranchesAdmin();
    });

//    _currentIndex = widget.selectPage != null ? widget.selectPage : 4;
  }

  @override
  Widget build(BuildContext context) {
    // final List<Widget> children = screens( );

    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),

      key: navigatorKey,
//      floatingActionButton: MyFloatingButton(),
//      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen =
                            ThemePage(); // if user taps on this dashboard tab will be active
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.color_lens,
                          color: currentTab == 0
                              ? const Color(0xff171732)
                              : Colors.grey,
                        ),
                        Text(
                          'إضافة لون',
                          style: TextStyle(
                            color: currentTab == 0
                                ? const Color(0xff171732)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen =
                            PromoCodeAdmin(); // if user taps on this dashboard tab will be active
                        currentTab = 2;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.local_offer,
                          color: currentTab == 2
                              ? const Color(0xff171732)
                              : Colors.grey,
                        ),
                        Text(
                          'إضافة برمو كود',
                          style: TextStyle(
                            color: currentTab == 2
                                ? const Color(0xff171732)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Right Tab bar icons

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen =
                            MenuAdmin(); // if user taps on this dashboard tab will be active
                        currentTab = 1;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.view_list,
                          color: currentTab == 1
                              ? const Color(0xff171732)
                              : Colors.grey,
                        ),
                        Text(
                          'قائمة المطعم',
                          style: TextStyle(
                            color: currentTab == 1
                                ? const Color(0xff171732)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen =
                            BranchesAdmin(); // if user taps on this dashboard tab will be active
                        currentTab = 3;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.public,
                          color: currentTab == 3
                              ? const Color(0xff171732)
                              : Colors.grey,
                        ),
                        Text(
                          'الفروع',
                          style: TextStyle(
                            color: currentTab == 3
                                ? const Color(0xff171732)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

//
//  Future<void> _makePhoneCall(String url) async {
//    if (await canLaunch(url)) {
//      await launch(url);
//    } else {
//      throw 'Could not launch $url';
//    }
//  }



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

class MyFloatingButton extends StatefulWidget {
  @override
  _MyFloatingButtonState createState() => _MyFloatingButtonState();
}

class _MyFloatingButtonState extends State<MyFloatingButton> {
  bool _show = true;
  final String appTitle = translator.translate('SendNotificationToAll');
  @override
  Widget build(BuildContext context) {
    return _show
        ? FloatingActionButton(
            backgroundColor: const Color(0xff171732),
            child: Text(
              translator.translate('notification'),
              style: TextStyle(
                fontFamily: 'Estedad-Black',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff),
                height: 0.7471466064453125,
              ),
            ),
            heroTag: "unique3",
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => MainPage(appTitle: appTitle,)));
            },
          )
        : Container();
  }

  void _showButton(bool value) {
    setState(() {
      _show = value;
    });
  }

}
