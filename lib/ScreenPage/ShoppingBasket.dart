import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friesdip/Classes/OrderItem.dart';
import 'package:friesdip/Classes/OrderItemforBill.dart';
import 'package:friesdip/Classes/database_helper.dart';
import 'package:friesdip/DrawerScreenPage/CustomAppBar.dart';
import 'package:friesdip/DrawerScreenPage/CustomDrawer.dart';
import 'package:friesdip/DrawerScreenPage/MenuPage.dart';
import 'package:friesdip/DrawerScreenPage/FollowOrder.dart';
import 'package:friesdip/PaymentTellr/Address.dart';
import 'package:friesdip/PaymentTellr/payment_response.dart';
import 'package:friesdip/PaymentTellr/telr.dart';
import 'package:friesdip/PaymentTellr/thankyou.dart';
import 'package:friesdip/ScreenPage/HomePage.dart';
import 'package:friesdip/ScreenPage/map_view.dart';
import 'package:gradual_stepper/gradual_stepper.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite/sqflite.dart';
import 'package:time_range/time_range.dart';
import 'package:friesdip/Classes/globals.dart' as globals;
import 'branchesusers.dart';
import 'loginphone.dart';

class ShoppingBasket extends StatefulWidget {
  @override
  _ShoppingBasketState createState() => _ShoppingBasketState();
}

enum SingingCharacter { cash, atm, onlinpyment }

class _ShoppingBasketState extends State<ShoppingBasket> {
  TimeOfDay _time = TimeOfDay.now().add(minutes: 15);
  String deliverytime = DateTime.now().toString();
  DateTime now = DateTime.now();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  SingingCharacter _character = SingingCharacter.cash;
  DatabaseHelper databaseHelper = DatabaseHelper();
  var _offerlistcontroller = ScrollController();
  int count = 0;
  var arrange;
  String UserId;
  String _NumberPhone;
  bool blocked = false;
  bool deleted = false;
  double discount = 0.0;
  TextEditingController _discountController = TextEditingController();
  String promo_title_ar;
  String promo_title_en;
  int promo_percentage;
  String _userid;
  List<bool> ischeckedSmall = [];
  List<bool> ischeckedMed = [];
  List<bool> ischeckedLarg = [];
  List<int> servno = [];
  List<int> ssize = [];
double criticalkm=10.0;int less=10;int more =20;
  List<OrderItem> orderList;
  int ttprice = 0;
  int ttitems = 0;
  double tax = 1.0;
  bool _load = false;

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<OrderItem>> orderListFuture = databaseHelper.getOrderList();
      orderListFuture.then((orderlist) {
        setState(() {
          this.orderList = orderlist;
          this.count = orderlist.length;
          ischeckedSmall =
              new List<bool>.generate(orderlist.length, (i) => false);
          ischeckedMed =
              new List<bool>.generate(orderlist.length, (i) => false);
          ischeckedLarg =
              new List<bool>.generate(orderlist.length, (i) => false);
          servno = new List<int>.generate(orderlist.length, (i) => 0);
          ssize = new List<int>.generate(orderlist.length, (i) => 0);
        });
      });
    });
  }

  @override
  initState() {
    super.initState();

    FirebaseDatabase.instance
        .reference()
        .child("admindeliveryprice")
        .child("less")
        .once()
        .then((DataSnapshot data1) {
          setState(() {
            less = data1.value;
          });
    });
    FirebaseDatabase.instance
        .reference()
        .child("admindeliveryprice")
        .child("more")
        .once()
        .then((DataSnapshot data1) {
      setState(() {
        more = data1.value;
      });
    });
    FirebaseDatabase.instance
        .reference()
        .child("admindeliveryprice")
        .child("criticalkm")
        .once()
        .then((DataSnapshot data1) {
      setState(() {
        criticalkm= data1.value;
      });
    });
    arrange = ServerValue.timestamp;
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
    flutterLocalNotificationsPlugin.initialize(
      initSetttings, /*onSelectNotification: onSelectNotification*/
    );
    if (orderList == null) {
      orderList = List<OrderItem>();
      setState(() {
        Future.delayed(Duration(seconds: 0), () async {
          ttprice = await databaseHelper.calcTotalprice();
          ttitems = await databaseHelper.calcTotalItems();
          updateListView();
        });
      });
    }
    FirebaseAuth.instance.currentUser().then((user) => user == null
        ? setState(() {})
        : setState(() {
            _userid = user.uid;

            FirebaseDatabase.instance
                .reference()
                .child("userdata")
                .child(_userid)
                .child("cPhone")
                .once()
                .then((DataSnapshot data1) {
              _NumberPhone = data1.value;
            });
            print("############$_NumberPhone");

            FirebaseDatabase.instance
                .reference()
                .child("userdata")
                .child(_userid)
                .child("blocked")
                .once()
                .then((DataSnapshot data1) {
              if (data1.value != null) {
                blocked = data1.value;

                print("hhhhblocked${blocked}");
              } else {
                setState(() {
                  blocked = false;
                  print("hhhhblocked${blocked}");
                });
              }
            });

            FirebaseDatabase.instance
                .reference()
                .child("userdata")
                .child(_userid)
                .child("deleted")
                .once()
                .then((DataSnapshot data1) {
              if (data1.value != null) {
                setState(() {
                  deleted = data1.value;
                  print("hhhhdeleted${deleted}");
                });
              } else {
                setState(() {
                  deleted = false;
                  print("hhhhdeleted${deleted}");
                });
              }
            });
          }));

    FirebaseDatabase.instance
        .reference()
        .child("adminpromocode")
        .reference()
        .once()
        .then((DataSnapshot data1) {
      var DATA = data1.value;

      promo_title_ar = DATA['promo_title_ar'];
      promo_title_en = DATA['promo_title_en'];
      promo_percentage = int.parse(DATA['promo_percentage']);
    });
    print("hhhh11h$promo_title_ar");
  }

  showAlertDialog(BuildContext context, int id, String title_ar,
      String title_en, int position) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(translator.translate('cancel')),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(translator.translate('confirmation')),
      onPressed: () async {
        int result = await databaseHelper.deleteOrder(id).then((value) {
          if (value != 0) {
            Fluttertoast.showToast(
                msg: translator.translate("deleted"),
                backgroundColor: Colors.black,
                textColor: Colors.white);

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Hero(tag: new Text("hero1"), child: ShoppingBasket())));
            // setState(() {
            //
            //   Future.delayed(Duration(seconds: 0), () async {
            //     ttprice= await databaseHelper.calcTotalprice();
            //     ttitems= await databaseHelper.calcTotalItems();
            //     servno.removeAt(position);
            //     ischeckedSmall.removeAt(position);
            //     ischeckedMed.removeAt(position);
            //     ischeckedLarg.removeAt(position);
            //     updateListView();
            //      Navigator.of(context).pop();
            //
            //     // ChangeNotifier().notifyListeners();
            //
            //   }
            //
            //   );
            //
            // });
            //
            // Fluttertoast.showToast(
            //     msg: translator.translate("deleted"),
            //     backgroundColor: Colors.black,
            //     textColor: Colors.white);
            // Navigator.of(context).pop();
          }
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(translator.translate('confirmation')),
      content: Text(translator.translate('alarm1')),
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
      backgroundColor: Colors.white,

//        drawer: Theme(
//            data: Theme.of(context).copyWith(
//              // Set the transparency here
//              canvasColor: Colors.white10.withOpacity(
//                  0.8), //or any other color you want. e.g Colors.blue.withOpacity(0.5)
//            ),
//            child: BaseDrawer(widget.logourl)),
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
                Card(
                  shape: new RoundedRectangleBorder(
                      side: new BorderSide(
                          color: Colors.grey[300],
                          //color: subfaultsList[index].ccolor,
                          width: 1.0),
                      borderRadius: BorderRadius.circular(3.0)),
                  child: Column(
                    children: [
                      Container(
                        color: Colors.grey[400],
                        height: 20,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8, left: 8),
                          child: Row(
                            children: [
                              Text(translator.translate('OrderSummary'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Estedad-Black")),
                              Text("["),
                              Text(ttitems.toString()),
                              Text(translator.translate('Products'),
                                  style: TextStyle(
                                      fontSize: 12,
//                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Estedad-Black")),
                              Text("]")
                            ],
                          ),
                        ),
                      ),

                      Container(
                        height: 350,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8, left: 8),
                          child: count == 0
                              ? Center(
                                  child: Text(
                                  translator.translate('no_data'),
                                ))
                              : ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount: count,
                                  controller: _offerlistcontroller,
                                  itemBuilder:
                                      (BuildContext context, int position) {
                                    servno[position] =
                                        orderList[position].item_no;
                                    int tprice =
                                        orderList[position].total_price;
                                    ssize[position] = orderList[position].size;
                                    if (ssize[position] == 1) {
                                      ischeckedSmall[position] = true;
                                    } else if (ssize[position] == 2) {
                                      ischeckedMed[position] = true;
                                    } else if (ssize[position] == 3) {
                                      ischeckedLarg[position] = true;
                                    } else if (ssize[position] == 0) {
                                      ischeckedSmall[position] = false;
                                      ischeckedMed[position] = false;
                                      ischeckedLarg[position] = false;
                                    }
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration: orderList[
                                                                  position]
                                                              .url ==
                                                          null
                                                      ? BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image: AssetImage(
                                                                'assets/images/food.png'),
                                                            fit: BoxFit.contain,
                                                          ),
                                                        )
                                                      : BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                          image: NetworkImage(
                                                              orderList[
                                                                      position]
                                                                  .url),
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
                                                          translator
                                                                      .currentLanguage ==
                                                                  'ar'
                                                              ? orderList[
                                                                      position]
                                                                  .title_ar
                                                              : orderList[
                                                                      position]
                                                                  .title_en,
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                              fontSize: 17,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  "Estedad-Black")),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Container(
                                                      // height: 100,
                                                      width: 150,
                                                      child: Text(
                                                          translator.currentLanguage ==
                                                                  'ar'
                                                              ? orderList[
                                                                      position]
                                                                  .details_ar
                                                              : orderList[
                                                                      position]
                                                                  .details_en,
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.grey,
                                                              fontFamily:
                                                                  "Estedad-Black")),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                Text(
                                                    orderList[position]
                                                        .total_price
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            "Estedad-Black")),
                                                Text(
                                                    translator.translate('SAR'),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            "Estedad-Black")),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 0),
                                                  child: Container(
                                                    width: 140,
                                                    height: 40,
                                                    child: GradualStepper(
                                                        initialValue:
                                                            orderList[position]
                                                                .item_no,
                                                        minimumValue: 1,
                                                        maximumValue: 100,
                                                        stepValue: 1,
                                                        onChanged: (int value) {
                                                          print(
                                                              'new value $value');
                                                          setState(() {
                                                            servno[position] =
                                                                value;
                                                            // print("kkkkkk$servno");
                                                            tprice = servno[
                                                                    position] *
                                                                int.parse(orderList[
                                                                        position]
                                                                    .selected_price);
                                                            OrderItem
                                                                orderitem =
                                                                OrderItem(
                                                              orderList[
                                                                      position]
                                                                  .item_id,
                                                              orderList[
                                                                      position]
                                                                  .title_ar,
                                                              orderList[
                                                                      position]
                                                                  .title_en,
                                                              orderList[
                                                                      position]
                                                                  .details_ar,
                                                              orderList[
                                                                      position]
                                                                  .details_en,
                                                              orderList[
                                                                      position]
                                                                  .selected_price,
                                                              orderList[
                                                                      position]
                                                                  .price_no,
                                                              orderList[
                                                                      position]
                                                                  .price_small,
                                                              orderList[
                                                                      position]
                                                                  .price_mid,
                                                              orderList[
                                                                      position]
                                                                  .price_large,
                                                              orderList[
                                                                      position]
                                                                  .url,
                                                              orderList[
                                                                      position]
                                                                  .category_id,
                                                              orderList[
                                                                      position]
                                                                  .cat_title_ar,
                                                              orderList[
                                                                      position]
                                                                  .cat_title_en,
                                                              orderList[
                                                                      position]
                                                                  .heckedNo,
                                                              orderList[
                                                                      position]
                                                                  .heckedSmall,
                                                              orderList[
                                                                      position]
                                                                  .heckedMed,
                                                              orderList[
                                                                      position]
                                                                  .heckedLarg,
                                                              servno[position] *
                                                                  int.parse(orderList[
                                                                          position]
                                                                      .selected_price),
                                                              servno[position],
                                                              orderList[
                                                                      position]
                                                                  .size,
                                                            );
                                                            databaseHelper
                                                                .updateOrder(
                                                                    orderitem)
                                                                .then((value) {
                                                              setState(() {
                                                                print(
                                                                    "kkkk$value");
                                                                Future.delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            0),
                                                                    () async {
                                                                  ttprice =
                                                                      await databaseHelper
                                                                          .calcTotalprice();
                                                                  ttitems =
                                                                      await databaseHelper
                                                                          .calcTotalItems();
                                                                  updateListView();
                                                                });
                                                              });
                                                            });
                                                            //offerlist1[position].total_price=offerlist1[position].item_no*int.parse(offerlist1[position].price);

                                                            //   }
                                                          });
                                                        }),
                                                  ),
                                                ),
                                                Spacer(),
                                                Container(
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.cancel,
                                                      size: 30,
                                                      color: Colors.grey,
                                                    ),
                                                    tooltip: translator
                                                        .translate('delet1'),
                                                    onPressed: () {
                                                      showAlertDialog(
                                                          context,
                                                          orderList[position]
                                                              .id,
                                                          orderList[position]
                                                              .title_ar,
                                                          orderList[position]
                                                              .title_en,
                                                          position);
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                            orderList[position].heckedNo == 0
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            bottom: 10),
                                                    child: Card(
                                                      color: Colors.grey[200],
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 0.0,
                                                                left: 0.0,
                                                                right: 0.0,
                                                                bottom: 0.0),
                                                        child: ExpansionTile(
                                                          title: Container(
                                                              color: Colors
                                                                  .grey[200],
                                                              child: Text(translator
                                                                  .translate(
                                                                      'size'))),
                                                          //backgroundColor: Colors.black,
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                orderList[position]
                                                                            .heckedSmall ==
                                                                        1
                                                                    ? Column(
                                                                        children: [
                                                                          Text(
                                                                            translator.translate('small'),
                                                                          ),
                                                                          Checkbox(
                                                                            value:
                                                                                ischeckedSmall[position],
                                                                            onChanged:
                                                                                (bool value) {
                                                                              setState(() {
                                                                                ischeckedSmall[position] = value;
                                                                                if (ischeckedSmall[position]) {
                                                                                  ischeckedMed[position] = false;
                                                                                  ischeckedLarg[position] = false;
                                                                                  ssize[position] = 1;
                                                                                } else {
                                                                                  ssize[position] = 0;
                                                                                }
                                                                                ///////////////////////
                                                                                setState(() {
                                                                                  tprice = servno[position] * int.parse(orderList[position].price_small);
                                                                                  OrderItem orderitem = OrderItem(
                                                                                    orderList[position].item_id,
                                                                                    orderList[position].title_ar,
                                                                                    orderList[position].title_en,
                                                                                    orderList[position].details_ar,
                                                                                    orderList[position].details_en,
                                                                                    orderList[position].price_small,
                                                                                    orderList[position].price_no,
                                                                                    orderList[position].price_small,
                                                                                    orderList[position].price_mid,
                                                                                    orderList[position].price_large,
                                                                                    orderList[position].url,
                                                                                    orderList[position].category_id,
                                                                                    orderList[position].cat_title_ar,
                                                                                    orderList[position].cat_title_en,
                                                                                    orderList[position].heckedNo,
                                                                                    orderList[position].heckedSmall,
                                                                                    orderList[position].heckedMed,
                                                                                    orderList[position].heckedLarg,
                                                                                    orderList[position].item_no * int.parse(orderList[position].price_small),
                                                                                    orderList[position].item_no,
                                                                                    ssize[position],
                                                                                  );
                                                                                  databaseHelper.updateOrder(orderitem).then((value) {
                                                                                    setState(() {
                                                                                      Future.delayed(Duration(seconds: 0), () async {
                                                                                        ttprice = await databaseHelper.calcTotalprice();
                                                                                        ttitems = await databaseHelper.calcTotalItems();
                                                                                        updateListView();
                                                                                      });
                                                                                    });
                                                                                  });
                                                                                });
                                                                                ///////////////////
                                                                              });
                                                                            },
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Container(),
                                                                orderList[position]
                                                                            .heckedMed ==
                                                                        1
                                                                    ? Column(
                                                                        children: [
                                                                          Text(
                                                                            translator.translate('medium'),
                                                                          ),
                                                                          Checkbox(
                                                                            value:
                                                                                ischeckedMed[position],
                                                                            onChanged:
                                                                                (bool value) {
                                                                              setState(() {
                                                                                ischeckedMed[position] = (value);
                                                                                if (ischeckedMed[position]) {
                                                                                  ischeckedSmall[position] = false;
                                                                                  ischeckedLarg[position] = false;
                                                                                  ssize[position] = 2;
                                                                                } else {
                                                                                  ssize[position] = 0;
                                                                                }
                                                                                ///////////////////////
                                                                                setState(() {
                                                                                  tprice = servno[position] * int.parse(orderList[position].price_mid);
                                                                                  OrderItem orderitem = OrderItem(
                                                                                    orderList[position].item_id,
                                                                                    orderList[position].title_ar,
                                                                                    orderList[position].title_en,
                                                                                    orderList[position].details_ar,
                                                                                    orderList[position].details_en,
                                                                                    orderList[position].price_mid,
                                                                                    orderList[position].price_no,
                                                                                    orderList[position].price_small,
                                                                                    orderList[position].price_mid,
                                                                                    orderList[position].price_large,
                                                                                    orderList[position].url,
                                                                                    orderList[position].category_id,
                                                                                    orderList[position].cat_title_ar,
                                                                                    orderList[position].cat_title_en,
                                                                                    orderList[position].heckedNo,
                                                                                    orderList[position].heckedSmall,
                                                                                    orderList[position].heckedMed,
                                                                                    orderList[position].heckedLarg,
                                                                                    orderList[position].item_no * int.parse(orderList[position].price_mid),
                                                                                    orderList[position].item_no,
                                                                                    ssize[position],
                                                                                  );
                                                                                  databaseHelper.updateOrder(orderitem).then((value) {
                                                                                    setState(() {
                                                                                      Future.delayed(Duration(seconds: 0), () async {
                                                                                        ttprice = await databaseHelper.calcTotalprice();
                                                                                        ttitems = await databaseHelper.calcTotalItems();
                                                                                        updateListView();
                                                                                      });
                                                                                    });
                                                                                  });
                                                                                });
                                                                                ///////////////////
                                                                              });
                                                                            },
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Container(),
                                                                orderList[position]
                                                                            .heckedLarg ==
                                                                        1
                                                                    ? Column(
                                                                        children: [
                                                                          Text(
                                                                            translator.translate('large'),
                                                                          ),
                                                                          Checkbox(
                                                                            value:
                                                                                ischeckedLarg[position],
                                                                            onChanged:
                                                                                (bool value) {
                                                                              setState(() {
                                                                                ischeckedLarg[position] = (value);
                                                                                if (ischeckedLarg[position]) {
                                                                                  ischeckedSmall[position] = false;
                                                                                  ischeckedMed[position] = false;
                                                                                  ssize[position] = 3;
                                                                                } else {
                                                                                  ssize[position] = 0;
                                                                                }
                                                                                ///////////////////////
                                                                                setState(() {
                                                                                  tprice = servno[position] * int.parse(orderList[position].price_large);
                                                                                  OrderItem orderitem = OrderItem(
                                                                                    orderList[position].item_id,
                                                                                    orderList[position].title_ar,
                                                                                    orderList[position].title_en,
                                                                                    orderList[position].details_ar,
                                                                                    orderList[position].details_en,
                                                                                    orderList[position].price_large,
                                                                                    orderList[position].price_no,
                                                                                    orderList[position].price_small,
                                                                                    orderList[position].price_mid,
                                                                                    orderList[position].price_large,
                                                                                    orderList[position].url,
                                                                                    orderList[position].category_id,
                                                                                    orderList[position].cat_title_ar,
                                                                                    orderList[position].cat_title_en,
                                                                                    orderList[position].heckedNo,
                                                                                    orderList[position].heckedSmall,
                                                                                    orderList[position].heckedMed,
                                                                                    orderList[position].heckedLarg,
                                                                                    orderList[position].item_no * int.parse(orderList[position].price_large),
                                                                                    orderList[position].item_no,
                                                                                    ssize[position],
                                                                                  );
                                                                                  databaseHelper.updateOrder(orderitem).then((value) {
                                                                                    setState(() {
                                                                                      Future.delayed(Duration(seconds: 0), () async {
                                                                                        ttprice = await databaseHelper.calcTotalprice();
                                                                                        ttitems = await databaseHelper.calcTotalItems();
                                                                                        updateListView();
                                                                                      });
                                                                                    });
                                                                                  });
                                                                                });
                                                                                ///////////////////
                                                                              });
                                                                            },
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Container(),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    );

                                    //( offerlist1[position],onSubmit4: onSubmit4,onSubmit5: onSubmit5);
                                  },
                                ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 8, left: 8),
                      //   child: ListView(
                      //     physics: BouncingScrollPhysics(),
                      //     shrinkWrap: true,
                      //     children: [
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Card(
                  shape: new RoundedRectangleBorder(
                      side: new BorderSide(
                          color: Colors.grey[300],
                          //color: subfaultsList[index].ccolor,
                          width: 1.0),
                      borderRadius: BorderRadius.circular(3.0)),
                  child: Column(
                    children: [
                      Container(
                        color: Colors.grey[400],
                        height: 20,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8, left: 8),
                          child: Row(
                            children: [
                              Text(translator.translate('Total'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Estedad-Black")),
                              Text(ttprice.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Estedad-Black")),
                            ],
                          ),
                        ),
                      ),
                      ListView(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          Container(
                            color: Colors.grey[200],
                            height: 50,
                            child: Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: TextField(
//                                      controller: _Name,
                                    onChanged: (value) {},
                                    controller: _discountController,
                                    decoration: InputDecoration(
                                        labelText: translator
                                            .translate('DiscountCode'),
                                        hintText: translator
                                            .translate('DiscountCode'),
                                        prefixIcon: Icon(
                                          Icons.local_offer,
                                          color: Colors.black,
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0)))),
                                  ),
                                ),
                                Spacer(),
                                RaisedButton(
                                  child: new Text(
                                    translator.translate('Implementation'),
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: "Estedad-Black"),
                                  ),
                                  textColor: Colors.white,
                                  color: Theme.of(context).accentColor,
                                  //BC0C0C
                                  onPressed: () {
                                    if (promo_title_ar ==
                                            _discountController.text ||
                                        promo_title_en ==
                                            _discountController.text) {
                                      setState(() {
                                        discount = promo_percentage / 100;
                                      });
                                      Fluttertoast.showToast(
                                          msg: translator.translate(
                                                  'done_promo_code') +
                                              " ${discount * 100} % ",
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white);
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: translator
                                              .translate('no_promo_code'),
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white);
                                    }
                                    //print("oooo");
                                  },
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(5.0)),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 30, left: 15, right: 15),
                            child: Row(
                              children: [
                                Text(translator.translate('Total'),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Estedad-Black")),
                                Spacer(),
                                Text(ttprice.toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Estedad-Black")),
                                Text(translator.translate('SAR'),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Estedad-Black"))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 30, left: 15, right: 15),
                            child: Row(
                              children: [
                                Text(translator.translate('deliveryFee'),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Estedad-Black")),
                                Spacer(),
                                Text(
                                    globals.deliverycheck
                                        ? (globals.distance > 10.0
                                            ? "20"
                                            : "10")
                                        : "0",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Estedad-Black")),
                                Text(translator.translate('SAR'),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Estedad-Black"))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 15, left: 15, right: 15),
                            child: Row(
                              children: [
                                Text(translator.translate('Discount'),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: "Estedad-Black")),
                                Spacer(),
                                Text('${(discount * 100).toStringAsFixed(0)}',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Estedad-Black")),
                                Text('%',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Estedad-Black")),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 15, left: 15, right: 15),
                            child: Row(
                              children: [
                                Text(translator.translate('Final'),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).accentColor,
                                        fontFamily: "Estedad-Black")),
                                Spacer(),
                                Text(
                                    globals.deliverycheck
                                        ? (globals.distance > 10.0
                                            ? (ttprice * (1 - discount) + 20)
                                                .toStringAsFixed(1)
                                            : (ttprice * (1 - discount) + 10)
                                                .toStringAsFixed(1))
                                        : (ttprice * (1 - discount) + 0)
                                            .toStringAsFixed(1),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Estedad-Black")),
                                Text(translator.translate('SAR'),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Estedad-Black")),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 15, left: 15, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(translator.translate('IncludesVAT'),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        fontFamily: "Estedad-Black")),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Card(
                  shape: new RoundedRectangleBorder(
                      side: new BorderSide(
                          color: Colors.grey[300],
                          //color: subfaultsList[index].ccolor,
                          width: 1.0),
                      borderRadius: BorderRadius.circular(3.0)),
                  child: Column(
                    children: [
                      Container(
                        color: Colors.grey[400],
                        height: 20,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8, left: 8),
                          child: Row(
                            children: [
                              Text(
                                  translator
                                      .translate('BranchAndTimeOfReceipt'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Estedad-Black")),
                            ],
                          ),
                        ),
                      ),
                      ListView(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BranchesUsers()));
                                setState(() {
                                  globals.deliverycheck;
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  Text(translator.translate('ReceiveFrom'),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).accentColor,
                                          fontFamily: "Estedad-Black")),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10, left: 10),
                                    child: Text(
                                      (globals.branch_name_ar == "" ||
                                              globals.branch_name_en == "")
                                          ? translator
                                              .translate('branch_location')
                                          : translator.currentLanguage == 'ar'
                                              ? globals.branch_name_ar
                                              : globals.branch_name_en,
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MapView()));
                                    },
                                    child: Text(
                                      translator.translate('map'),
                                    ),
                                    textColor: Theme.of(context).accentColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Theme.of(context).accentColor,
                                ),
                                Text(
                                    translator
                                        .translate('ChooseTheReceivingTime'),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).accentColor,
                                        fontFamily: "Estedad-Black")),
                              ],
                            ),
                          ),
                          FlatButton(
                            child: Text(
                              translator.translate('ChooseTheReceivingTime1'),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: "Estedad-Black"),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              Navigator.of(context).push(
                                showPicker(
                                  context: context,
                                  value: _time,
                                  onChange: (TimeOfDay newTime) {
                                    print("llll" + newTime.toString());

                                    setState(() {
                                      _time = newTime;
                                    });
                                  },
                                  is24HrFormat: true,
                                  // Optional onChange to receive value as DateTime
                                  onChangeDateTime: (DateTime dateTime) {
                                    setState(() {
                                      deliverytime = dateTime.toString();
                                    });
                                    print("kkk" + dateTime.toString());
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Card(
                  shape: new RoundedRectangleBorder(
                      side: new BorderSide(
                          color: Colors.grey[300],
                          //color: subfaultsList[index].ccolor,
                          width: 1.0),
                      borderRadius: BorderRadius.circular(3.0)),
                  child: Column(
                    children: [
                      Container(
                        color: Colors.grey[400],
                        height: 20,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8, left: 8),
                          child: Row(
                            children: [
                              Text(translator.translate('ChoosePaymentMethod'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Estedad-Black")),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _character == SingingCharacter.onlinpyment
                              ? Container(
                                  height: 70,
                                  color: Colors.yellow,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8, left: 8),
                                        child: Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8, left: 8),
                                        child: Text(
                                          translator.translate('HttpsPage'),
                                          style: TextStyle(
                                              fontSize: 7,
                                              fontFamily: 'Estedad-Black',
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Container(),
                          ListTile(
                            title: Text(
                              translator.translate('payCash'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'Estedad-Black',
                              ),
                              textAlign: TextAlign.right,
                            ),
                            leading: Icon(
                              Icons.attach_money,
                              color: Colors.deepOrangeAccent,
                            ),
                            trailing: Radio(
                              value: SingingCharacter.cash,
                              groupValue: _character,
                              onChanged: (SingingCharacter value) {
                                setState(() {
                                  _character = value;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: Text(
                              translator.translate('ATMCard'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'Estedad-Black',
                              ),
                              textAlign: TextAlign.right,
                            ),
                            leading: Icon(
                              Icons.atm,
                              color: Colors.red,
                            ),
                            trailing: Radio(
                              value: SingingCharacter.atm,
                              groupValue: _character,
                              onChanged: (SingingCharacter value) {
                                setState(() {
                                  _character = value;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: Text(
                              translator.translate('OnlinePayment'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
//                                          fontFamily: 'Estedad-Black',
                              ),
                              textAlign: TextAlign.right,
                            ),
                            leading: Icon(
                              Icons.payment,
                              color: Colors.green,
                            ),
                            trailing: Radio(
                              value: SingingCharacter.onlinpyment,
                              groupValue: _character,
                              onChanged: (SingingCharacter value) {
                                setState(() {
                                  _character = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _load
              ? loadingIndicator
              : Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey[600],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          print(globals.address_gps);

                          if (blocked) {
                            Fluttertoast.showToast(
                                msg: translator.translate("blocked"),
                                backgroundColor: Colors.black,
                                textColor: Colors.white);
                          } else {
                            var amount = globals.deliverycheck
                                ? (globals.distance > criticalkm
                                    ? (ttprice * (1 - discount) + more)
                                        .toStringAsFixed(1)
                                    : (ttprice * (1 - discount) + less)
                                        .toStringAsFixed(1))
                                : (ttprice * (1 - discount) + 0)
                                    .toStringAsFixed(0);
                            if (count != 0 &&
/*
                                _userid != null &&
*/
                                _character == SingingCharacter.onlinpyment) {
                              setState(() {
                                Future.delayed(Duration(seconds: 0), () async {
                                  OrderItemforBill orderforbill1 =
                                      await databaseHelper
                                          .alldatafororder()
                                          .then((orderforbill) async {
                                    if (orderforbill.size.contains("5")) {
                                      Fluttertoast.showToast(
                                          msg: translator
                                              .translate('select_size'),
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white);
                                    } else {
                                      Address _address = new Address(
                                         ' s1,s2,sa',
                                          'RIYADH',
                                          'SA',
                                          'RIYADH',
                                          '11543');
                                      Telr _Telr = new Telr();
                                      try {

                                        PaymentResponse response = await _Telr.payForOrder( ttprice,_address, null,arrange);
                                        if (response.status == 'Approved') {
                                          Navigator.of(context).pushReplacement( MaterialPageRoute( builder: (context) => ThankYouPage()));

                                        }
                                      } catch (e) {
                                        setState(() {



                                        });
                                      }
                                    }
                                  });
                                });
                              });
                            } else {
                              if (_userid == null || deleted) {
                                FirebaseAuth.instance.signOut();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignIn()));
                              } else {
                                if (count == 0) {
                                  Fluttertoast.showToast(
                                      msg: translator.translate('no_data'),
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white);
                                } else {
                                  setState(() {
                                    _load = true;
                                    Future.delayed(Duration(seconds: 0),
                                        () async {
                                      OrderItemforBill orderforbill1 =
                                          await databaseHelper
                                              .alldatafororder()
                                              .then((orderforbill) {
                                        if (orderforbill.size.contains("5")) {
                                          Fluttertoast.showToast(
                                              msg: translator
                                                  .translate('select_size'),
                                              backgroundColor: Colors.black,
                                              textColor: Colors.white);
                                        } else {
                                          if (globals.deliverycheck) {
                                            /////////delivery////////////
                                            if (globals.distancecheck) {
                                              if (globals.address_gps == "" ||
                                                  globals.address_gps == null ||
                                                  globals.branch_id == "" ||
                                                  globals.branch_id == null) {
                                                Fluttertoast.showToast(
                                                    msg: translator.translate(
                                                        'enter_ur_address'),
                                                    backgroundColor:
                                                        Colors.black,
                                                    textColor: Colors.white);
                                              } else {
                                                //send data to branch

                                                DateTime now = DateTime.now();

                                                final orderbranchdatabaseReference =
                                                    FirebaseDatabase.instance
                                                        .reference()
                                                        .child(
                                                            "orderListforBranch")
                                                        .child(
                                                            globals.branch_id);
                                                final orderuserdatabaseReference =
                                                    FirebaseDatabase.instance
                                                        .reference()
                                                        .child(
                                                            "orderListforuser")
                                                        .child(_userid);

                                                String orderid =
                                                    orderbranchdatabaseReference
                                                        .push()
                                                        .key;

                                                orderbranchdatabaseReference
                                                    .child(orderid)
                                                    .set({
                                                  'carrange': arrange,
                                                  'orderId': orderid,
                                                  'userid': _userid,
                                                  'cdate': now.toString(),
                                                  'NumberPhoneUser':
                                                      _NumberPhone,
                                                  'Payment': _character ==
                                                          SingingCharacter.cash
                                                      ? 'Cash'
                                                      : 'ATM',
                                                  'branch_id':
                                                      globals.branch_id,
                                                  'deliverycheck':
                                                      globals.deliverycheck,
                                                  'lat_gps': globals.lat_gps,
                                                  'long_gps': globals.long_gps,
                                                  'address_gps':
                                                      globals.address_gps,
                                                  'ttprice': globals
                                                          .deliverycheck
                                                      ? (globals.distance > criticalkm
                                                          ? (ttprice *
                                                                      (1 -
                                                                          discount) +
                                                                  more)
                                                              .toStringAsFixed(
                                                                  1)
                                                          : (ttprice *
                                                                      (1 -
                                                                          discount) +
                                                                  less)
                                                              .toStringAsFixed(
                                                                  1))
                                                      : (ttprice *
                                                                  (1 -
                                                                      discount) +
                                                              0)
                                                          .toStringAsFixed(1),
                                                  'ttitems': ttitems,
                                                  'item_id_list':
                                                      orderforbill.item_id,
                                                  'title_ar_list':
                                                      orderforbill.title_ar,
                                                  'title_en_list':
                                                      orderforbill.title_en,
                                                  'total_price_list':
                                                      orderforbill.total_price,
                                                  'item_no_list':
                                                      orderforbill.item_no,
                                                  'size_list':
                                                      orderforbill.size,
                                                  'url_list': orderforbill.url,
                                                  'deliverytime': deliverytime,
                                                }).whenComplete(() {
                                                  orderuserdatabaseReference
                                                      .child(orderid)
                                                      .set({
                                                    'carrange': arrange,
                                                    'orderId': orderid,
                                                    'userid': _userid,
                                                    'cdate': now.toString(),
                                                    'NumberPhoneUser':
                                                        _NumberPhone,
                                                    'Payment': _character ==
                                                            SingingCharacter
                                                                .cash
                                                        ? 'Cash'
                                                        : 'ATM',
                                                    'branch_id':
                                                        globals.branch_id,
                                                    'deliverycheck':
                                                        globals.deliverycheck,
                                                    'lat_gps': globals.lat_gps,
                                                    'long_gps':
                                                        globals.long_gps,
                                                    'address_gps':
                                                        globals.address_gps,
                                                    'ttprice': globals
                                                            .deliverycheck
                                                        ? (globals.distance >
                                                        criticalkm
                                                            ? (ttprice *
                                                                        (1 -
                                                                            discount) +
                                                                    more)
                                                                .toStringAsFixed(
                                                                    1)
                                                            : (ttprice *
                                                                        (1 -
                                                                            discount) +
                                                                    less)
                                                                .toStringAsFixed(
                                                                    1))
                                                        : (ttprice *
                                                                    (1 -
                                                                        discount) +
                                                                0)
                                                            .toStringAsFixed(1),
                                                    'ttitems': ttitems,
                                                    'item_id_list':
                                                        orderforbill.item_id,
                                                    'title_ar_list':
                                                        orderforbill.title_ar,
                                                    'title_en_list':
                                                        orderforbill.title_en,
                                                    'total_price_list':
                                                        orderforbill
                                                            .total_price,
                                                    'item_no_list':
                                                        orderforbill.item_no,
                                                    'size_list':
                                                        orderforbill.size,
                                                    'url_list':
                                                        orderforbill.url,
                                                    'deliverytime':
                                                        deliverytime,
                                                  }).whenComplete(() =>
                                                          Fluttertoast.showToast(
                                                              msg: translator
                                                                  .translate(
                                                                      'done'),
                                                              backgroundColor:
                                                                  Colors.black,
                                                              textColor: Colors
                                                                  .white));
                                                  _load = false;
                                                });
                                              }
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: translator
                                                      .translate('no_delivery'),
                                                  backgroundColor: Colors.black,
                                                  textColor: Colors.white);
                                            }
                                          } else {
                                            /////////branch////////////
                                            if (globals.branch_name_ar == "" ||
                                                globals.branch_name_ar ==
                                                    null ||
                                                globals.branch_name_en == "" ||
                                                globals.branch_name_en ==
                                                    null ||
                                                globals.branch_id == "" ||
                                                globals.branch_id == null) {
                                              print(
                                                  "bbbb${globals.branch_name_ar}///${globals.branch_name_en}////${globals.branch_id}");
                                              Fluttertoast.showToast(
                                                  msg: translator.translate(
                                                      'branch_location'),
                                                  backgroundColor: Colors.black,
                                                  textColor: Colors.white);
                                            } else {
                                              //send data to branch
                                              DateTime now = DateTime.now();
                                              final orderbranchdatabaseReference =
                                                  FirebaseDatabase.instance
                                                      .reference()
                                                      .child(
                                                          "orderListforBranch")
                                                      .child(globals.branch_id);
                                              final orderuserdatabaseReference =
                                                  FirebaseDatabase.instance
                                                      .reference()
                                                      .child("orderListforUser")
                                                      .child(_userid);

                                              String orderid =
                                                  orderbranchdatabaseReference
                                                      .push()
                                                      .key;

                                              final ReferenceOrderId =
                                                  FirebaseDatabase.instance
                                                      .reference()
                                                      .child(
                                                          'OrderIdAndBranchId');
                                              ReferenceOrderId.child(_userid)
                                                  .set({
                                                'OrderId': orderid,
                                                'BranchId': globals.branch_id,
                                              });
                                              final ReferenceStatusOrder =
                                                  FirebaseDatabase.instance
                                                      .reference()
                                                      .child(
                                                          'NotificationStatusOrder');
                                              ReferenceStatusOrder.child(
                                                      _userid)
                                                  .child(orderid)
                                                  .update({
                                                'OrderStatus': 0,
                                              });
                                              orderbranchdatabaseReference
                                                  .child(orderid)
                                                  .set({
                                                'carrange': arrange,
                                                'orderId': orderid,
                                                'userid': _userid,
                                                'cdate': now.toString(),
                                                'NumberPhoneUser': _NumberPhone,
                                                'Payment': _character ==
                                                        SingingCharacter.cash
                                                    ? 'Cash'
                                                    : 'ATM',
                                                'branch_id': globals.branch_id,
                                                'deliverycheck':
                                                    globals.deliverycheck,
                                                'lat_gps': globals.lat_gps,
                                                'long_gps': globals.long_gps,
                                                'address_gps':
                                                    globals.address_gps,
                                                'ttprice': globals.deliverycheck
                                                    ? (globals.distance > criticalkm
                                                        ? (ttprice *
                                                                    (1 -
                                                                        discount) +
                                                                more)
                                                            .toStringAsFixed(1)
                                                        : (ttprice *
                                                                    (1 -
                                                                        discount) +
                                                                less)
                                                            .toStringAsFixed(1))
                                                    : (ttprice *
                                                                (1 - discount) +
                                                            0)
                                                        .toStringAsFixed(1),
                                                'ttitems': ttitems,
                                                'item_id_list':
                                                    orderforbill.item_id,
                                                'title_ar_list':
                                                    orderforbill.title_ar,
                                                'title_en_list':
                                                    orderforbill.title_en,
                                                'total_price_list':
                                                    orderforbill.total_price,
                                                'item_no_list':
                                                    orderforbill.item_no,
                                                'size_list': orderforbill.size,
                                                'url_list': orderforbill.url,
                                                'deliverytime': deliverytime,
                                              }).whenComplete(() async {
                                                orderuserdatabaseReference
                                                    .child(orderid)
                                                    .set({
                                                      'carrange': arrange,
                                                      'orderId': orderid,
                                                      'userid': _userid,
                                                      'cdate': now.toString(),
                                                      'NumberPhoneUser':
                                                          _NumberPhone,
                                                      'Payment': _character ==
                                                              SingingCharacter
                                                                  .cash
                                                          ? 'Cash'
                                                          : 'ATM',
                                                      'branch_id':
                                                          globals.branch_id,
                                                      'deliverycheck':
                                                          globals.deliverycheck,
                                                      'lat_gps':
                                                          globals.lat_gps,
                                                      'long_gps':
                                                          globals.long_gps,
                                                      'address_gps':
                                                          globals.address_gps,
                                                      'ttprice': globals
                                                              .deliverycheck
                                                          ? (globals.distance >
                                                          criticalkm
                                                              ? (ttprice *
                                                                          (1 -
                                                                              discount) +
                                                                      more)
                                                                  .toStringAsFixed(
                                                                      1)
                                                              : (ttprice *
                                                                          (1 -
                                                                              discount) +
                                                                      less)
                                                                  .toStringAsFixed(
                                                                      1))
                                                          : (ttprice *
                                                                      (1 -
                                                                          discount) +
                                                                  0)
                                                              .toStringAsFixed(
                                                                  1),
                                                      'ttitems': ttitems,
                                                      'item_id_list':
                                                          orderforbill.item_id,
                                                      'title_ar_list':
                                                          orderforbill.title_ar,
                                                      'title_en_list':
                                                          orderforbill.title_en,
                                                      'total_price_list':
                                                          orderforbill
                                                              .total_price,
                                                      'item_no_list':
                                                          orderforbill.item_no,
                                                      'size_list':
                                                          orderforbill.size,
                                                      'url_list':
                                                          orderforbill.url,
                                                      'deliverytime':
                                                          deliverytime,
                                                    })
                                                    .whenComplete(() =>
                                                        Fluttertoast.showToast(
                                                            msg: translator
                                                                .translate(
                                                                    'done'),
                                                            backgroundColor:
                                                                Colors.black,
                                                            textColor:
                                                                Colors.white))
                                                    .then((value) => Alert(
                                                          onWillPopActive: true,
                                                          context: context,
                                                          type:
                                                              AlertType.success,
                                                          title: translator
                                                              .translate(
                                                                  'done'),
                                                          desc: translator
                                                              .translate(
                                                                  'OrderTracking'),
                                                          buttons: [
                                                            DialogButton(
                                                              child: Text(
                                                                translator
                                                                    .translate(
                                                                        'confirmation'),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        20),
                                                              ),
                                                              onPressed: () => Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              StepperPage())),
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor,
                                                            ),
                                                            DialogButton(
                                                              child: Text(
                                                                translator
                                                                    .translate(
                                                                        'home'),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        20),
                                                              ),
                                                              onPressed: () => Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              HomePage())),
                                                              color:
                                                                  Colors.black,
                                                            )
                                                          ],
                                                        ).show());
                                                await _showNotificationCustomSound(
                                                    ttitems, amount);
                                                _load = false;
                                              });
                                            }
                                          }
                                        }
                                      });
                                    });
                                  });
                                }
                              }
                            }
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2,
                          color: Theme.of(context).accentColor,
                          child: Center(
                              child: Text(
                            translator.translate('ExecuteYourRequest'),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Estedad-Black"),
                          )),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MenuPage()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20, left: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: Center(
                                child: Text(
                              translator.translate('AddProducts'),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Estedad-Black"),
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
        ],
      ),
    );
  }

  Future<void> _showNotificationCustomSound(int ttitems, String amount) async {
    var android = AndroidNotificationDetails('id', 'channel ', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0,
        translator.translate('sendorder'),
        'عدد الطلبات : $ttitems طلب / تكلفة طلبك : $amount SAR ',
        platform,
        payload: 'Welcome to the Local Notification demo');
  }
}
