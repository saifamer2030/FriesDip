import 'package:flutter/material.dart';
import 'package:friesdip/admin/Branches/loginadmin.dart';
import 'package:friesdip/admin/Branches/SignUpAdmin.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Classes/ThemeClass.dart';
import 'PaymentTellr/CreditCardPageTellr.dart';
import 'PaymentTellr/TelrPage.dart';
import 'PaymentTellr/telr.dart';
import 'ScreenPage/HomePage.dart';
import 'admin/ControlPanel/ThemePage.dart';
import 'admin/ControlPanel/branchesadmin.dart';
import 'admin/ControlPanel/menuadmin.dart';
import 'package:friesdip/Classes/globals.dart' as globals;

import 'admin/ControlPanel/promocodeadmin.dart';

main() async {
  // if your flutter > 1.7.8 :  ensure flutter activated


  WidgetsFlutterBinding.ensureInitialized();

  await translator.init(
    localeDefault: LocalizationDefaultType.device,
    languagesList: <String>['ar', 'en'],
    assetsDirectory: 'assets/langs/',
    apiKeyGoogle: '<Key>', // NOT YET TESTED
  ); // intialize

  runApp(LocalizedApp(child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int app_bar_theme=4294198070;
  int botton_theme=4294198070;
  String logourl;


  MaterialColor black = const MaterialColor(
    0xFF000000,
    const <int, Color>{
      50: const Color(0xFF000000),
      100: const Color(0xFF000000),
      200: const Color(0xFF000000),
      300: const Color(0xFF000000),
      400: const Color(0xFF000000),
      500: const Color(0xFF000000),
      600: const Color(0xFF000000),
      700: const Color(0xFF000000),
      800: const Color(0xFF000000),
      900: const Color(0xFF000000),
    },
  );
  MaterialColor red = const MaterialColor(
    0xFFFF0000	,
    const <int, Color>{
      50: const Color(0),
      100: const Color(0xffBC0C0C),
      200: const Color(0xffBC0C0C),
      300: const Color(0xffBC0C0C),
      400: const Color(0xffBC0C0C),
      500: const Color(0xffBC0C0C),
      600: const Color(0xffBC0C0C),
      700: const Color(0xffBC0C0C),
      800: const Color(0xffBC0C0C),
      900: const Color(0xffBC0C0C),
    },
  );
  @override
  void initState() {
    super.initState();
    // FirebaseDatabase.instance.reference().child("adminthemes").child("app_bar_theme")
    //     .once()
    //     .then((DataSnapshot snapshot) {
    //   setState(() {
    //     if (snapshot.value != null) {
    //       setState(() {
    //         app_bar_theme = snapshot.value;
    //       });
    //     }
    //   });
    // });
    FirebaseDatabase.instance.reference().child("adminthemes")
        .reference()
        //.child("app_bar_theme")
        .once()
        .then((DataSnapshot data1) {
      var DATA = data1.value;
      setState(() {
        ThemeClass themeclass = new ThemeClass(
          DATA['app_bar_theme'],
          DATA['botton_theme'],
          DATA['logourl'],
        );
        setState(() {

        });
        (app_bar_theme==null)?app_bar_theme=4294198070: app_bar_theme = DATA['app_bar_theme'];
        (botton_theme==null)?botton_theme=4294198070: botton_theme = DATA['botton_theme'];
        if(DATA['logourl']==null){
          globals.logourl = "a";
         // logourl="a";
        }else{
         // logourl = DATA['logourl'];
          globals.logourl =DATA['logourl'];
        }
       // (DATA['logourl']==null)?logourl="a":  logourl = DATA['logourl'];
       //print("hhh//$logourl//${DATA['logourl']}");
        //botton_theme = DATA['botton_theme'];


      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          child: child,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      debugShowCheckedModeBanner: false,
      home:Splash(),//UsersAdmin(),//LoginAdmin(),//PromoCodeAdmin(),//BranchesAdmin(),//MenuAdmin(), //Splash(),
      theme:
      ThemeData(

        primaryColor: Color(app_bar_theme),
        accentColor:Color(botton_theme),
        // textTheme: TextTheme(bodyText2: TextStyle(color: Colors.white)),

        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: translator.delegates,
      locale: translator.locale,
      supportedLocales: translator.locals(),
    );
  }
}

class Splash extends StatefulWidget {
 // String logourl;

  Splash();
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () async {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Center(
        child: Container(
          // height: 370,
          // width: 400,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/ic_logo.png'),
              // fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }

}
