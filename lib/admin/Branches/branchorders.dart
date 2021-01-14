import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:friesdip/Classes/UsersClass.dart';
import 'package:friesdip/DrawerScreenPage/CustomAppBar.dart';
import 'package:friesdip/DrawerScreenPage/CustomDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:friesdip/Classes/globals.dart' as globals;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friesdip/Classes/BranchListClass.dart';
import 'package:friesdip/Classes/FoodListClass.dart';
import 'package:friesdip/Classes/ItemFoodClass.dart';
import 'package:friesdip/Classes/sendedorder.dart';
import 'package:friesdip/Classes/sendedorderlist.dart';
import 'package:friesdip/ScreenPage/cur_loc.dart';
import 'package:friesdip/admin/Branches/loginadmin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sk_alert_dialog/sk_alert_dialog.dart';
import 'package:time_range/time_range.dart';
import 'package:toast/toast.dart';
import 'package:translator/translator.dart';
import '../ControlPanel/menuitemsadmin.dart';
import '../ControlPanel/offersadmin.dart';

class BranchOrders extends StatefulWidget {
  BranchOrders();

  @override
  _BranchOrdersState createState() => _BranchOrdersState();
}

class _BranchOrdersState extends State<BranchOrders> {
  List<SendedOrderList> orderList = [];
  var _controller = ScrollController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  bool isLoaded = true;
  String _brunchId, branchcode;
  String _numberPhoneUser;
  String _userid;
  String _orderId;
  String OrderStatus;
  String _nameUser;
  var _gender;
  var i;
  bool _load2 = false;

  @override
  void initState() {
    super.initState();

    getBrunchId();
    getBranchcode();
    // getUserData();
//    getorderListforBranch();
  }

  void getBranchcode() async {
    FirebaseAuth _firebaseAuth;
    _firebaseAuth = FirebaseAuth.instance;
    final mDatabase = FirebaseDatabase.instance.reference();
    FirebaseUser usr = await _firebaseAuth.currentUser();
    if (usr != null) {
      mDatabase
          .child("branchlogindata")
          .child(_brunchId)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
//        var result = values['rating'].reduce((a, b) => a + b) / values.length;

        if (values != null) {
          /*HelperFunc.showToast("hii ${values['cName']}", Colors.red);
          */
          setState(() {
            branchcode = values['ccode'].toString();
//            _brunchId=usr.uid;
          });
          getData();
          print("####################branchcode :$branchcode");
        }
      });
    }
  }

//   void getUserData() async {
//     FirebaseAuth _firebaseAuth;
//     _firebaseAuth = FirebaseAuth.instance;
//     final mDatabase = FirebaseDatabase.instance.reference();
//     FirebaseUser usr = await _firebaseAuth.currentUser();
//     if (usr != null) {
//       mDatabase
//           .child("userdata")
//           .child(_userid)
//           .once()
//           .then((DataSnapshot snapshot) {
//         Map<dynamic, dynamic> values = snapshot.value;
// //        var result = values['rating'].reduce((a, b) => a + b) / values.length;
//         if (values["cPhone"] != null) {
//           _numberPhoneUser = values["cPhone"];
//
//           print("####################_numberPhone :$_numberPhoneUser");
//         } else {
//           _numberPhoneUser = translator.translate('no_data');
//
//           print("####################_numberPhone :$_numberPhoneUser");
//         }
//         if (values["cName"] != null) {
//           _nameUser = values["cName"];
//           print("####################_nameUser :$_nameUser");
//         } else {
//           _nameUser = translator.translate('no_data');
//           print("####################_nameUser :$_nameUser");
//         }
//         if (values["cGender"] != null) {
//           _gender = values["cGender"];
//           print("####################_gender :$_gender");
//         } else {
//           _gender = translator.translate('no_data');
//           print("####################_gender :$_gender");
//         }
//       });
//     }
//   }

//  void getorderListforBranch() async {
//    FirebaseAuth _firebaseAuth;
//    _firebaseAuth = FirebaseAuth.instance;
//    final mDatabase = FirebaseDatabase.instance.reference();
//    FirebaseUser usr = await _firebaseAuth.currentUser();
//    if (usr != null) {
//      mDatabase
//          .child("orderListforBranch")
//          .child(_brunchId)
//          .child(_orderId)
//          .once()
//          .then((DataSnapshot snapshot) {
//        Map<dynamic, dynamic> values = snapshot.value;
//        if (values != null) {
//          setState(() {
//            _userid = values['userid'].toString();
//            _orderId = values['orderId'].toString();
//          });
//          getData();
//          print("####################_userid :$_userid");
//          print("####################_orderId :$_orderId");
//        }
//      });
//    }
//  }

  void getBrunchId() async {
    final FirebaseUser user = await auth.currentUser();
    _brunchId = user.uid;
    print("############_brunchId :$_brunchId");

    // here you write the codes to input the data into firestore
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _load2
        ? new Container(
      child: SpinKitCircle(
        color: Theme.of(context).accentColor,
      ),
    )
        : new Container();
    return Scaffold(body: sparepartssScreen(loadingIndicator));
  }

///////////********* Design *****////////////////////////////
  Widget sparepartssScreen(loadingIndicator) {
    return Stack(
      children: [
        Column(
          children: <Widget>[
            Flexible(
              child: isLoaded
                  ? orderList.length == 0
                  ? Center(
                  child: Text(
                    translator.translate('no_data'),
                  ))
                  : listView()
                  : Center(
                child: SpinKitFadingCircle(
                  itemBuilder: (_, int index) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                          color: index.isEven
                              ? Colors.orange
                              : Colors.white),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        new Align(
          child: loadingIndicator,
          alignment: FractionalOffset.center,
        ),
      ],
    );
  }

  Widget listView() {
    return Column(
      children: <Widget>[
        Expanded(
          child: new ListView.builder(
              physics: BouncingScrollPhysics(),
              controller: _controller,
              itemCount: orderList.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return firebasedata(
                  index,
                );
              }),
        ),
      ],
    );
  }

  Widget firebasedata(var index) {
    _orderId = orderList[index].orderId;
    OrderStatus = orderList[index].OrderStatus;
    final mDatabase = FirebaseDatabase.instance.reference();
    mDatabase
        .child("userdata")
        .child(orderList[index].userid)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
//        var result = values['rating'].reduce((a, b) => a + b) / values.length;
      if (values["cPhone"] != null) {
        _numberPhoneUser = values["cPhone"];

        print("####################_numberPhone :$_numberPhoneUser");
      } else {
        _numberPhoneUser = translator.translate('no_data');

        print("####################_numberPhone :$_numberPhoneUser");
      }
      if (values["cName"] != null) {
        _nameUser = values["cName"];
        print("####################_nameUser :$_nameUser");
      } else {
        _nameUser = translator.translate('no_data');
        print("####################_nameUser :$_nameUser");
      }
      if (values["cGender"] != null) {
        _gender = values["cGender"];
        print("####################_gender :$_gender");
      } else {
        _gender = translator.translate('no_data');
        print("####################_gender :$_gender");
      }
    });

    print("############## OrderStatus :$OrderStatus");
    return InkWell(
      onTap: () {
        SKAlertDialog.show(
          context: context,
          type: SKAlertType.radiobutton,
          radioButtonAry: {
            'إستلام الطلب': 1,
            'الطلب تحت التحضير': 2,
            'الطلب تحت التجهيز': 3,
            'تم تجهيز الطلب': 4,
            'تم الاستلام': 5,
            'لم يتم الاستلام': 6
          },
          title: "حالة الطلب",
          onCancelBtnTap: (value) {
            print('Cancel Button Tapped');
          },
          onRadioButtonSelection: (value) {
            print('onRadioButtonSelection $value');
            // ignore: unrelated_type_equality_checks
            if (value == "الطلب تحت التحضير") {
              final Reference = FirebaseDatabase.instance
                  .reference()
                  .child('NotificationStatusOrder');
              Reference.child(orderList[index].userid)
                  .child(orderList[index].orderId)
                  .update({
                'OrderStatus': 1,
              });
              final Reference2 = FirebaseDatabase.instance
                  .reference()
                  .child('orderListforBranch');
              Reference2.child(branchcode)
                  .child(orderList[index].orderId)
                  .update({
                'OrderStatus': 1,
              });
              print("okay");
            }
            if (value == "الطلب تحت التجهيز") {
              final Reference = FirebaseDatabase.instance
                  .reference()
                  .child('NotificationStatusOrder');
              Reference.child(orderList[index].userid)
                  .child(orderList[index].orderId)
                  .update({
                'OrderStatus': 2,
              });
              final Reference2 = FirebaseDatabase.instance
                  .reference()
                  .child('orderListforBranch');
              Reference2.child(branchcode)
                  .child(orderList[index].orderId)
                  .update({
                'OrderStatus': 2,
              });
              print("okay");
            }
            if (value == "تم تجهيز الطلب") {
              final Reference = FirebaseDatabase.instance
                  .reference()
                  .child('NotificationStatusOrder');
              Reference.child(orderList[index].userid)
                  .child(orderList[index].orderId)
                  .update({
                'OrderStatus': 3,
              });
              final Reference2 = FirebaseDatabase.instance
                  .reference()
                  .child('orderListforBranch');
              Reference2.child(branchcode)
                  .child(orderList[index].orderId)
                  .update({
                'OrderStatus':3,
              });
              print("okay");
            }
            if (value == "تم الاستلام") {
              final Reference = FirebaseDatabase.instance
                  .reference()
                  .child('NotificationStatusOrder');
              Reference.child(orderList[index].userid)
                  .child(orderList[index].orderId)
                  .update({
                'OrderStatus': 4,
              });
              final Reference2 = FirebaseDatabase.instance
                  .reference()
                  .child('orderListforBranch');
              Reference2.child(branchcode)
                  .child(orderList[index].orderId)
                  .update({
                'OrderStatus': 4,
              });
              print("okay");
            }
            if (value == "لم يتم الاستلام") {
              final Reference = FirebaseDatabase.instance
                  .reference()
                  .child('NotificationStatusOrder');
              Reference.child(orderList[index].userid)
                  .child(orderList[index].orderId)
                  .update({
                'OrderStatus': 5,
              });
              final Reference2 = FirebaseDatabase.instance
                  .reference()
                  .child('orderListforBranch');
              Reference2.child(branchcode)
                  .child(orderList[index].orderId)
                  .update({
                'OrderStatus': 5,
              });
              print("okay");
            }
          },
        );
      },
      child: Stack(
        children: [
          Card(
            elevation: 10,
            shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
            margin: EdgeInsets.all(6),
            // ignore: unrelated_type_equality_checks
            color: OrderStatus == 4
                ? Colors.grey
            // ignore: unrelated_type_equality_checks
                : OrderStatus == 5 ? Colors.grey[500] : Colors.white,
            child: Container(
              child: Column(
                children: [
                  ListTile(
                    leading: Column(
                      children: [
                        Text(
                          orderList[index].cdate,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red
                            // color: Colors.green[800]
                          ),
                        ),
                        Text(
                          "رقم جوال العميل : ",
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red
                            // color: Colors.green[800]
                          ),
                        ),
                        Text("$_numberPhoneUser"),
                      ],
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                " عدد الطلبات : ",
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Text(
                                orderList[index].ttitems.toString(),
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800]),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "المطلوب دفعة من العميل : ",
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Text(
                                orderList[index].ttprice.toString(),
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800]),
                              ),
                              Text(
                                "ر.س",
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontSize: 8.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800]),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "رقم الطلب : ",
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Text(
                                orderList[index].carrange.toString(),
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800]),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                orderList[index].deliverycheck
                                    ? "التوصيل للمنزل"
                                    : "الاستلام فى الفرع",
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800]),
                              ),
                            ],
                          ),
                          Text(
                            "عنوان العميل : ",
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Text(
                            orderList[index].address_gps,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800]),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "طريقة دفع العميل : ",
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              Text(
                                orderList[index].Payment,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800]),
                              ),
                            ],
                          ),
                          Text(
                            "وقت إستلام الطلب : ",
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Text(
                            orderList[index].deliverytime.toString(),
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800]),
                          ),
                        ],
                      ),
                    ),
//          subtitle:
                  ),
                  Column(
                    children: [
                      for (var i = 0;
                      i < orderList[index].title_ar_list.length;
                      i++)
                        Card(
                          // ignore: unrelated_type_equality_checks
                          color: OrderStatus == 4
                              ? Colors.grey[400]
                          // ignore: unrelated_type_equality_checks
                              : OrderStatus == 5
                              ? Colors.grey[600]
                              : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: orderList[index]
                                          .url_list[i] ==
                                          null
                                          ? BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/food.png'),
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                          : BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                orderList[index].url_list[i]),
                                            fit: BoxFit.fill,
                                          )),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          width: 150,
                                          child: Text(
                                              translator.currentLanguage == 'ar'
                                                  ? orderList[index]
                                                  .title_ar_list[i]
                                                  : orderList[index]
                                                  .title_en_list[i],
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Estedad-Black")),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          width: 150,
                                          child: Text(
                                              orderList[index].size_list[i] ==
                                                  "0"
                                                  ? ""
                                                  : orderList[index]
                                                  .size_list[i] ==
                                                  "1"
                                                  ? "صغيرة"
                                                  : orderList[index]
                                                  .size_list[
                                              i] ==
                                                  "1"
                                                  ? "متوسطة"
                                                  : "كبيرة",
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Estedad-Black")),
                                        ),
                                        Container(
                                          width: 150,
                                          child: Text(
                                              orderList[index].item_no_list[i],
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Estedad-Black")),
                                        ),
                                        Container(
                                          width: 150,
                                          child: Text(
                                              orderList[index]
                                                  .total_price_list[i],
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Estedad-Black")),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ignore: unrelated_type_equality_checks
          OrderStatus == 5
              ? Positioned(
            top: 20,
            right: 20,
            left: 20,
            bottom: 20,
            child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/notreseved.png'),
                    fit: BoxFit.contain,
                  ),
                )),
          )
          // ignore: unrelated_type_equality_checks
              : OrderStatus == 4
              ? Positioned(
            top: 20,
            right: 20,
            left: 20,
            bottom: 20,
            child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/correct.png'),
                    fit: BoxFit.contain,
                  ),
                )),
          )
              : Container()
        ],
      ),
    );
  }

  void getData() {
    FirebaseDatabase.instance
        .reference()
        .child("orderListforBranch")
        .child(branchcode) //branchcode//"-MJPA6m9yJSVsnfIv0-p"
        .once()
        .then((DataSnapshot snapshot) async {
      var KEYS = snapshot.value.keys;
      var DATA = snapshot.value;
      orderList.clear();
      for (var individualkey in KEYS) {
        SendedOrder sendedorder = new SendedOrder(
          DATA[individualkey]['carrange'],
          DATA[individualkey]['orderId'],
          DATA[individualkey]['userid'],
          DATA[individualkey]['cdate'],
          DATA[individualkey]['Payment'],
          DATA[individualkey]['branch_id'],
          DATA[individualkey]['deliverycheck'],
          DATA[individualkey]['deliverytime'],
          DATA[individualkey]['lat_gps'],
          DATA[individualkey]['long_gps'],
          DATA[individualkey]['address_gps'],
          DATA[individualkey]['ttprice'],
          DATA[individualkey]['ttitems'],
          DATA[individualkey]['item_id_list'],
          DATA[individualkey]['title_ar_list'],
          DATA[individualkey]['title_en_list'],
          DATA[individualkey]['total_price_list'],
          DATA[individualkey]['item_no_list'],
          DATA[individualkey]['size_list'],
          DATA[individualkey]['url_list'],
        );
        SendedOrderList sendedorder1 = new SendedOrderList(
          DATA[individualkey]['carrange'],
          DATA[individualkey]['orderId'],
          DATA[individualkey]['userid'],
          DATA[individualkey]['cdate'],
          DATA[individualkey]['Payment'],
          DATA[individualkey]['branch_id'],
          DATA[individualkey]['deliverycheck'],
          DATA[individualkey]['deliverytime'],
          DATA[individualkey]['lat_gps'],
          DATA[individualkey]['long_gps'],
          DATA[individualkey]['address_gps'],
          DATA[individualkey]['ttprice'],
          DATA[individualkey]['ttitems'],
          DATA[individualkey]['item_id_list'].substring(1).split(","),
          DATA[individualkey]['title_ar_list'].substring(1).split(","),
          DATA[individualkey]['title_en_list'].substring(1).split(","),
          DATA[individualkey]['total_price_list'].substring(1).split(","),
          DATA[individualkey]['item_no_list'].substring(1).split(","),
          DATA[individualkey]['size_list'].substring(1).split(","),
          DATA[individualkey]['url_list'].substring(1).split(","),
          DATA[individualkey]['OrderStatus'],
        );
// print("pppppp"+DATA[individualkey]['item_id_list'].substring(1) .split(",").toString());
//         print("pppppp"+DATA[individualkey]['title_ar_list'] .substring(1).split(",").toString());
//         print("pppppp"+DATA[individualkey]['total_price_list'].substring(1) .split(",").toString());
//         print("pppppp"+DATA[individualkey]['item_no_list'] .substring(1).split(",").toString());
//         print("pppppp"+DATA[individualkey]['url_list'] .substring(1).split(",").toString());

        setState(() {
          orderList.add(sendedorder1);
          orderList.sort((fl2, fl1) => fl1.carrange.compareTo(fl2.carrange));
        });
      }
    });
  }
}
