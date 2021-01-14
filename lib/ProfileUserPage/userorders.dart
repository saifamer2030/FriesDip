import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:friesdip/Classes/globals.dart' as globals;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friesdip/Classes/BranchListClass.dart';
import 'package:friesdip/Classes/FoodListClass.dart';
import 'package:friesdip/Classes/ItemFoodClass.dart';
import 'package:friesdip/Classes/sendedorder.dart';
import 'package:friesdip/Classes/sendedorderlist.dart';
import 'package:friesdip/DrawerScreenPage/CustomAppBar.dart';
import 'package:friesdip/DrawerScreenPage/CustomDrawer.dart';
import 'package:friesdip/ScreenPage/cur_loc.dart';
import 'package:friesdip/ScreenPage/reorderBasket.dart';
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

class UserOrders extends StatefulWidget {
  UserOrders();

  @override
  _UserOrdersState createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> {
  List<SendedOrderList> orderList = [];
  List<SendedOrder> re_orderList = [];

  var _controller = ScrollController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  bool isLoaded = true;
  String _brunchId, branchcode;
  String _numberPhoneUser;
  String _userid, _NumberPhone;
  String _orderId;
  String OrderStatus;
  var i;
  bool _load2 = false;

  @override
  void initState() {
    super.initState();

    getId();
    getBranchcode();
    DatabaseReference db;
    db = FirebaseDatabase.instance.reference().child("userdata");
    db.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        _numberPhoneUser = values["cPhone"];
        print("####################_numberPhoneUser :$_numberPhoneUser");
      });
    });
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
          // getData();
          print("####################branchcode :$branchcode");
        }
      });
    }
  }

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

  void getId() async {
    final FirebaseUser user = await auth.currentUser();
    setState(() {
      _userid = user.uid;

      FirebaseDatabase.instance
          .reference()
          .child("userdata")
          .child(_userid)
          .child("cPhone")
          .once()
          .then((DataSnapshot data1) {
        if (data1.value == null) {
        } else {
          setState(() {
            _NumberPhone = data1.value;
          });
        }
      });
    });

    getData();
    print("############_userid :$_userid");

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
    return Scaffold(
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
        body: sparepartssScreen(loadingIndicator));
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
                return FirebaseData(
                  index,
                );
              }),
        ),
      ],
    );
  }

  Widget FirebaseData(var index) {
    return Card(
      shape:
          new RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: InkWell(
        onTap: () {
          showMe(context, index);
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5, left: 5, top: 5),
                    child: Row(
                      children: [
                        Text(
                          translator.translate('date'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Estedad-Black',
                          ),
                        ),
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                    child: Row(
                      children: [
                        Text(
                          translator.translate('numOrder'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Estedad-Black',
                          ),
                        ),
                        Text(
                          orderList[index].carrange.toString(),
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red
                              // color: Colors.green[800]
                              ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
                    child: Row(
                      children: [
                        Text(
                          translator.translate('price'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Estedad-Black',
                          ),
                        ),
                        Text(
                          orderList[index].ttprice,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red
                              // color: Colors.green[800]
                              ),
                        ),
                        Text(
                          translator.translate('SAR'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Estedad-Black',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ReorderBasket(re_orderList[index])));
                      },
                      textColor: Colors.white,
                      color: Theme.of(context).accentColor,
                      padding: const EdgeInsets.all(0.0),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0)),
                      child: Text(
                        translator.translate('reorder'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: 'Estedad-Black',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showMe(BuildContext context, index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext contex) {
          return ListView(
            physics: BouncingScrollPhysics(),
            children: [
              for (var i = 0; i < orderList[index].title_ar_list.length; i++)
                Card(
                  color: OrderStatus == "4"
                      ? Colors.grey[400]
                      : OrderStatus == "5"
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
                              decoration: orderList[index].url_list[i] == null
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
                                          ? orderList[index].title_ar_list[i]
                                          : orderList[index].title_en_list[i],
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
                                      orderList[index].size_list[i] == "0"
                                          ? ""
                                          : orderList[index].size_list[i] == "1"
                                              ? "صغيرة"
                                              : orderList[index].size_list[i] ==
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
                                  child: Text(orderList[index].item_no_list[i],
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
                                      orderList[index].total_price_list[i],
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
          );
        });
  }

//   Widget firebasedata(var index) {
//     _orderId = orderList[index].orderId;
//     OrderStatus = orderList[index].OrderStatus;
//     print("############## OrderStatus :$OrderStatus");
//     return Stack(
//       children: [
//         Card(
//           elevation: 10,
//           shape: new RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(4.0)),
//           margin: EdgeInsets.all(6),
//           color: OrderStatus == "4"
//               ? Colors.grey
//               : OrderStatus == "5"
//                   ? Colors.grey[500]
//                   : Colors.white,
//           child: Container(
//             child: Column(
//               children: [
//                 ListTile(
//                   leading: Column(
//                     children: [
//                       Text(
//                         orderList[index].cdate,
//                         textDirection: TextDirection.rtl,
//                         style: TextStyle(
//                             fontSize: 10.0,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.red
//                             // color: Colors.green[800]
//                             ),
//                       ),
//                       Text(
//                         "رقم جوال العميل : ",
//                         textDirection: TextDirection.rtl,
//                         style: TextStyle(
//                             fontSize: 10.0,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.red
//                             // color: Colors.green[800]
//                             ),
//                       ),
//                       Text("$_NumberPhone"),
//                     ],
//                   ),
//                   title: Padding(
//                     padding: const EdgeInsets.only(top: 10),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         RaisedButton(
//                           onPressed: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         ReorderBasket(re_orderList[index])));
//                           },
//                           textColor: Colors.red,
//                           padding: const EdgeInsets.all(0.0),
//                           child: const Text('re-order'),
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Text(
//                               " عدد الطلبات : ",
//                               textDirection: TextDirection.rtl,
//                               style: TextStyle(
//                                   fontSize: 12.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black),
//                             ),
//                             Text(
//                               orderList[index].ttitems.toString(),
//                               textDirection: TextDirection.rtl,
//                               style: TextStyle(
//                                   fontSize: 18.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green[800]),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Text(
//                               "المطلوب دفعة من العميل : ",
//                               textDirection: TextDirection.rtl,
//                               style: TextStyle(
//                                   fontSize: 10.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black),
//                             ),
//                             Text(
//                               orderList[index].ttprice.toString(),
//                               textDirection: TextDirection.rtl,
//                               style: TextStyle(
//                                   fontSize: 18.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green[800]),
//                             ),
//                             Text(
//                               "ر.س",
//                               textDirection: TextDirection.rtl,
//                               style: TextStyle(
//                                   fontSize: 8.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green[800]),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Text(
//                               "رقم الطلب : ",
//                               textDirection: TextDirection.rtl,
//                               style: TextStyle(
//                                   fontSize: 10.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black),
//                             ),
//                             Text(
//                               orderList[index].carrange.toString(),
//                               textDirection: TextDirection.rtl,
//                               style: TextStyle(
//                                   fontSize: 18.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green[800]),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Text(
//                               orderList[index].deliverycheck
//                                   ? "التوصيل للمنزل"
//                                   : "الاستلام فى الفرع",
//                               textDirection: TextDirection.rtl,
//                               style: TextStyle(
//                                   fontSize: 18.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green[800]),
//                             ),
//                           ],
//                         ),
//                         Text(
//                           "عنوان العميل : ",
//                           textDirection: TextDirection.rtl,
//                           style: TextStyle(
//                               fontSize: 10.0,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black),
//                         ),
//                         Text(
//                           orderList[index].address_gps,
//                           textDirection: TextDirection.rtl,
//                           style: TextStyle(
//                               fontSize: 18.0,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green[800]),
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Text(
//                               "طريقة دفع العميل : ",
//                               textDirection: TextDirection.rtl,
//                               style: TextStyle(
//                                   fontSize: 10.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black),
//                             ),
//                             Text(
//                               orderList[index].Payment,
//                               textDirection: TextDirection.rtl,
//                               style: TextStyle(
//                                   fontSize: 18.0,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green[800]),
//                             ),
//                           ],
//                         ),
//                         Text(
//                           "وقت إستلام الطلب : ",
//                           textDirection: TextDirection.rtl,
//                           style: TextStyle(
//                               fontSize: 10.0,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black),
//                         ),
//                         Text(
//                           orderList[index].deliverytime.toString(),
//                           textDirection: TextDirection.rtl,
//                           style: TextStyle(
//                               fontSize: 18.0,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green[800]),
//                         ),
//                       ],
//                     ),
//                   ),
// //          subtitle:
//                 ),
//                 Column(
//                   children: [
//                     for (var i = 0;
//                         i < orderList[index].title_ar_list.length;
//                         i++)
//                       Card(
//                         color: OrderStatus == "4"
//                             ? Colors.grey[400]
//                             : OrderStatus == "5"
//                                 ? Colors.grey[600]
//                                 : Colors.white,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Container(
//                                     width: 100,
//                                     height: 100,
//                                     decoration: orderList[index].url_list[i] ==
//                                             null
//                                         ? BoxDecoration(
//                                             image: DecorationImage(
//                                               image: AssetImage(
//                                                   'assets/images/food.png'),
//                                               fit: BoxFit.contain,
//                                             ),
//                                           )
//                                         : BoxDecoration(
//                                             image: DecorationImage(
//                                             image: NetworkImage(
//                                                 orderList[index].url_list[i]),
//                                             fit: BoxFit.fill,
//                                           )),
//                                   ),
//                                   SizedBox(
//                                     width: 5,
//                                   ),
//                                   Column(
//                                     children: [
//                                       Container(
//                                         width: 150,
//                                         child: Text(
//                                             translator.currentLanguage == 'ar'
//                                                 ? orderList[index]
//                                                     .title_ar_list[i]
//                                                 : orderList[index]
//                                                     .title_en_list[i],
//                                             textAlign: TextAlign.right,
//                                             style: TextStyle(
//                                                 fontSize: 17,
//                                                 color: Colors.black,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontFamily: "Estedad-Black")),
//                                       ),
//                                       SizedBox(
//                                         height: 10,
//                                       ),
//                                       Container(
//                                         width: 150,
//                                         child: Text(
//                                             orderList[index].size_list[i] == "0"
//                                                 ? ""
//                                                 : orderList[index]
//                                                             .size_list[i] ==
//                                                         "1"
//                                                     ? "صغيرة"
//                                                     : orderList[index]
//                                                                 .size_list[i] ==
//                                                             "1"
//                                                         ? "متوسطة"
//                                                         : "كبيرة",
//                                             textAlign: TextAlign.right,
//                                             style: TextStyle(
//                                                 fontSize: 17,
//                                                 color: Colors.black,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontFamily: "Estedad-Black")),
//                                       ),
//                                       Container(
//                                         width: 150,
//                                         child: Text(
//                                             orderList[index].item_no_list[i],
//                                             textAlign: TextAlign.right,
//                                             style: TextStyle(
//                                                 fontSize: 17,
//                                                 color: Colors.black,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontFamily: "Estedad-Black")),
//                                       ),
//                                       Container(
//                                         width: 150,
//                                         child: Text(
//                                             orderList[index]
//                                                 .total_price_list[i],
//                                             textAlign: TextAlign.right,
//                                             style: TextStyle(
//                                                 fontSize: 17,
//                                                 color: Colors.black,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontFamily: "Estedad-Black")),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//         OrderStatus == "5"
//             ? Positioned(
//                 top: 20,
//                 right: 20,
//                 left: 20,
//                 bottom: 20,
//                 child: Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         image: AssetImage('assets/images/notreseved.png'),
//                         fit: BoxFit.contain,
//                       ),
//                     )),
//               )
//             : OrderStatus == "4"
//                 ? Positioned(
//                     top: 20,
//                     right: 20,
//                     left: 20,
//                     bottom: 20,
//                     child: Container(
//                         width: 100,
//                         height: 100,
//                         decoration: BoxDecoration(
//                           image: DecorationImage(
//                             image: AssetImage('assets/images/correct.png'),
//                             fit: BoxFit.contain,
//                           ),
//                         )),
//                   )
//                 : Container()
//       ],
//     );
//   }

  void getData() {
    print("bbbb$_userid");
    FirebaseDatabase.instance
        .reference()
        .child("orderListforUser")
        .child(_userid) //branchcode//"-MJPA6m9yJSVsnfIv0-p"
        .once()
        .then((DataSnapshot snapshot) async {
      var KEYS = snapshot.value.keys;
      var DATA = snapshot.value;
      print("bbbbb$DATA");
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
          re_orderList.add(sendedorder);
          re_orderList.sort((fl2, fl1) => fl1.carrange.compareTo(fl2.carrange));
          orderList.add(sendedorder1);
          orderList.sort((fl2, fl1) => fl1.carrange.compareTo(fl2.carrange));
        });
      }
    });
  }
}
