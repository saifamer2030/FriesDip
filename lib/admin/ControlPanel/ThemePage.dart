import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:friesdip/Classes/ThemeClass.dart';
import 'package:friesdip/DrawerScreenPage/MenuPage.dart';
import 'package:friesdip/DrawerScreenPage/OfferPage.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class ThemePage extends StatefulWidget {
  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  Color currentColor = Colors.red;
  bool theme_check2=false;
  bool theme_check1=false;
  Color testColor2;
  Color testColor1;
  List<Asset> images = List<Asset>();
  int colorcode1,colorcode2;
  bool _loading = false;
  String logourl;

  void changeColor(Color color) => setState(() => currentColor = color);
  @override
  void initState() {
    super.initState();

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
        colorcode1 = DATA['app_bar_theme'];
        colorcode2 = DATA['botton_theme'];
        logourl = DATA['logourl'];

      });
    });


  }
  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _loading
        ? new Container(
      child: SpinKitCircle(
        color:Theme.of(context).accentColor,
      ),
    )
        : new Container();

    return Scaffold(
        appBar: AppBar(

          backgroundColor:theme_check1?testColor1:Theme.of(context).primaryColor,
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
        body: Stack(
          children: <Widget>[
            ListView(
              physics: BouncingScrollPhysics(),
              children: [
                InkWell(
                  onTap: () {
                    loadAssets();
                  },

                  child: Container(
                    width: 200,
                    height: 400,
                    child: images.length>0?AssetThumb(
                      asset: images[0],
                      width: 200,
                      height: 400,
                    //  fit: BoxFit.contain,
                    ):logourl==null?Image.asset(
                      'assets/images/food.png',
                      width: 200,
                      height: 400,
                      fit: BoxFit.contain,
                    ):Image.network(
                         logourl,
                      fit: BoxFit.contain,
                    ),



                    // decoration: BoxDecoration(
                    //   image: DecorationImage(
                    //     image: AssetImage('assets/images/food.png'),
                    //     fit: BoxFit.fill,
                    //   ),
                    // ),
                  ),
                ),
                Container(
//              width: MediaQuery.of(context).size.width,
//              height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Padding(
                          padding: const EdgeInsets.only(top: 20,right: 5,left: 0),
                          child: Container(
                            width: (MediaQuery.of(context).size.width/2)-10,
                            height: 50,
                            child: new RaisedButton(
                              child: new Text(translator.translate('app_bar_theme')),
                              textColor: Colors.white,
                              color: theme_check2?testColor2:Theme.of(context).accentColor,

                              //BC0C0C
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      titlePadding: const EdgeInsets.all(0.0),
                                      contentPadding: const EdgeInsets.all(0.0),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor: Colors.red,
                                          onColorChanged: changeColor,
                                          colorPickerWidth: 300.0,
                                          pickerAreaHeightPercent: 0.7,
                                          enableAlpha: true,
                                          displayThumbColor: true,
                                          showLabel: true,
                                          paletteType: PaletteType.hsv,
                                          pickerAreaBorderRadius: const BorderRadius.only(
                                            topLeft: const Radius.circular(2.0),
                                            topRight: const Radius.circular(2.0),
                                          ),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Center(child: Text("تأكيد")),
                                          textColor: Colors.black,
                                          //color: Colors.black,
                                          onPressed: () async {

                                            Color color = currentColor;
                                            String colorString = color.toString(); // Color(0x12345678)
                                            String valueString = colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
                                            colorcode1 = int.parse(valueString, radix: 16);
                                            Color otherColor = new Color(colorcode1);
                                            (otherColor.toString().contains("0xff000000")||otherColor.toString().contains("0XFF000000"))?colorcode1=colorcode1+1:colorcode1=colorcode1;
                                            //testColor1 = new Color(value);
                                            setState(() { theme_check1=true;testColor1 = new Color(colorcode1);});

                                            Navigator.of(context).pop();

                                          },
                                        )  ,
                                        FlatButton(
                                          child: Text("إلغاء"),
                                          textColor: Colors.black,
                                          //color: Colors.black,
                                          onPressed: () async {
                                            Navigator.of(context).pop();

                                            // Navigator.of(context).pushReplacementNamed('/fragmentsouq');
                                          },
                                        )
                                      ],

                                    );
                                  },
                                );

                              },
//
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20,right: 0,left: 5),
                          child: Container(
                            width: (MediaQuery.of(context).size.width/2)-10,
                            height: 50,
                            child: new RaisedButton(
                              child: new Text(translator.translate('Button_theme')),
                              textColor: Colors.white,
                              color: theme_check2?testColor2:Theme.of(context).accentColor,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      titlePadding: const EdgeInsets.all(0.0),
                                      contentPadding: const EdgeInsets.all(0.0),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor: Colors.red,
                                          onColorChanged: changeColor,
                                          colorPickerWidth: 300.0,
                                          pickerAreaHeightPercent: 0.7,
                                          enableAlpha: true,
                                          displayThumbColor: true,
                                          showLabel: true,
                                          paletteType: PaletteType.hsv,
                                          pickerAreaBorderRadius: const BorderRadius.only(
                                            topLeft: const Radius.circular(2.0),
                                            topRight: const Radius.circular(2.0),
                                          ),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Center(child: Text("تأكيد")),
                                          textColor: Colors.black,
                                          //color: Colors.black,
                                          onPressed: () async {

                                            Color color = currentColor;
                                            String colorString = color.toString(); // Color(0x12345678)
                                            String valueString = colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
                                            colorcode2 = int.parse(valueString, radix: 16);
                                            Color otherColor = new Color(colorcode2);
                                            (otherColor.toString().contains("0xff000000")||otherColor.toString().contains("0XFF000000"))?colorcode2=colorcode2+1:colorcode2=colorcode2;

                                            setState(() {  testColor2 = new Color(colorcode2);theme_check2=true;});

                                            Navigator.of(context).pop();

                                          },
                                        )  ,
                                        FlatButton(
                                          child: Text("إلغاء"),
                                          textColor: Colors.black,
                                          //color: Colors.black,
                                          onPressed: () async {
                                            Navigator.of(context).pop();

                                            // Navigator.of(context).pushReplacementNamed('/fragmentsouq');
                                          },
                                        )
                                      ],

                                    );
                                  },
                                );

                              },
//
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
//              width: MediaQuery.of(context).size.width,
//              height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Padding(
                          padding: const EdgeInsets.only(top: 5,right: 5,left: 0),
                          child: Container(
                            width: (MediaQuery.of(context).size.width/2)-10,
                            height: 50,
                            child: new RaisedButton(
                              child: new Text(translator.translate('save_all')),
                              textColor: Colors.white,
                              color: theme_check2?testColor2:Theme.of(context).accentColor,

                              //BC0C0C
                              onPressed: () {
                                setState(() {
                                  _loading = true;
                                });
                                uploadpp0();

                              },
//
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20,right: 0,left: 5),
                          child: Container(
                            width: (MediaQuery.of(context).size.width/2)-10,
                            height: 50,
                            child: new RaisedButton(
                              child: new Text(translator.translate('restart')),
                              textColor: Colors.white,
                              color: theme_check2?testColor2:Theme.of(context).accentColor,
                              onPressed: () {
                                LocalizedApp.restart(context);

                              },
//
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              ],
            ),
            new Align(
              child: loadingIndicator,
              alignment: FractionalOffset.center,
            ),
          ],
        )

    );
  }
  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';
//print("hhhhhhhhh");
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: false,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "FriseDip"),
        materialOptions: MaterialOptions(
          statusBarColor: Theme.of(context).primaryColor.toString().replaceAll("Color(0xff", "#").replaceAll(")", ""),
          actionBarColor:  Theme.of(context).primaryColor.toString().replaceAll("Color(0xff", "#").replaceAll(")", ""),
          actionBarTitle: "Frise Dip",
          allViewTitle: translator.translate('All_photo'),
          useDetailsView: false,
          selectCircleStrokeColor:  Theme.of(context).primaryColor.toString().replaceAll("Color(0xff", "#").replaceAll(")", ""),
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
      // print("hhh$e");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
     // print("lll${images.length}");
    });
  }
  Future uploadpp0() async {
    if(images.length>0){

      final StorageReference storageRef =
      FirebaseStorage.instance.ref().child('myimage');

      var byteData = await images[0].getByteData(quality: 50);

      DateTime now = DateTime.now();
      final file = File('${(await getTemporaryDirectory()).path}/${images[0]}');
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      final StorageUploadTask uploadTask =
      storageRef.child('$now.jpg').putFile(file);
      var Imageurl = await (await uploadTask.onComplete).ref.getDownloadURL();
      Fluttertoast.showToast(
          msg: translator.translate('photo_uploaded'),
          backgroundColor: Colors.black,
          textColor: Colors.white);
      logourl = Imageurl.toString();
     // print("lll"+logourl);
    }
    FirebaseDatabase.instance.reference().child("adminthemes").update({
      'app_bar_theme':colorcode1,
      'botton_theme': colorcode2,
      'logourl': logourl,

    }).whenComplete(() => setState(() {
      _loading = false;
      Fluttertoast.showToast(
          msg: translator.translate("saved"),
          backgroundColor: Colors.black,
          textColor: Colors.white);
    }));



  }

}
