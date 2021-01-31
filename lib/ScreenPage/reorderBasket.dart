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
import 'package:friesdip/Classes/sendedorder.dart';
import 'package:friesdip/DrawerScreenPage/CustomAppBar.dart';
import 'package:friesdip/DrawerScreenPage/CustomDrawer.dart';
import 'package:friesdip/DrawerScreenPage/MenuPage.dart';
import 'package:friesdip/DrawerScreenPage/FollowOrder.dart';
import 'package:friesdip/PaymentTellr/Address.dart';
import 'package:friesdip/PaymentTellr/TelrPage.dart';
import 'package:friesdip/PaymentTellr/payment_card.dart';
import 'package:friesdip/PaymentTellr/payment_response.dart';
import 'package:friesdip/PaymentTellr/telr.dart';
import 'package:friesdip/PaymentTellr/thankyou.dart';
import 'package:friesdip/ScreenPage/HomePage.dart';
import 'package:friesdip/ScreenPage/map_view.dart';
import 'package:friesdip/ScreenPage/paymentCheckOut/CreditCardPage.dart';
import 'package:gradual_stepper/gradual_stepper.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sqflite/sqflite.dart';
import 'package:time_range/time_range.dart';
import 'package:friesdip/Classes/globals.dart' as globals;

import 'branchesusers.dart';
import 'loginphone.dart';

class ReorderBasket extends StatefulWidget {
  SendedOrder re_orderList;
  ReorderBasket(this.re_orderList);

  @override
  _ReorderBasketState createState() => _ReorderBasketState();
}

enum SingingCharacter { cash, atm, onlinpyment }

class _ReorderBasketState extends State<ReorderBasket> {
  TimeOfDay _time = TimeOfDay.now().add(minutes: 15);
  String deliverytime = DateTime.now().toString();
  DateTime now = DateTime.now();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  SingingCharacter _character = SingingCharacter.onlinpyment;
  int count = 0;
  var arrange;
  String UserId;
  String _NumberPhone;
  bool blocked=false;
  bool deleted=false;

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

  List<OrderItem> orderList;
  int ttprice = 0;
  int ttitems = 0;
  double tax = 1.0;
  bool _load = false;


  @override
  initState() {
    super.initState();
    arrange = ServerValue.timestamp;
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
    flutterLocalNotificationsPlugin.initialize(
      initSetttings,
      /*onSelectNotification: onSelectNotification*/
    );

    FirebaseAuth.instance.currentUser().then((user) => user == null
        ? setState(() {})
        : setState(() {
            _userid = user.uid;

            FirebaseDatabase.instance
                .reference()
                .child("userdata").child(_userid)
                .child("cPhone")
                .once()
                .then((DataSnapshot data1) {
              _NumberPhone = data1.value;
            });
            print("############$_NumberPhone");

            FirebaseDatabase.instance
                .reference()
                .child("userdata").child(_userid)
                .child("blocked")
                .once()
                .then((DataSnapshot data1) {
              if(data1.value!=null){
                blocked = data1.value;

                print("hhhhblocked${blocked}");

              }else{
                setState(() {
                  blocked = false;
                  print("hhhhblocked${blocked}");

                });


              }
            });

            FirebaseDatabase.instance
                .reference()
                .child("userdata").child(_userid)
                .child("deleted")
                .once()
                .then((DataSnapshot data1) {
              if(data1.value!=null){
                setState(() {
                  deleted = data1.value;
                  print("hhhhdeleted${deleted}");

                });

              }else{
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
                      ListView(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        children: [
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
                          print("kkk$deleted$blocked");
                          if(blocked){
                            Fluttertoast.showToast(
                                msg: translator.translate("blocked"),
                                backgroundColor: Colors.black,
                                textColor: Colors.white);

                          }
                          else{

                          if (   _userid != null &&
                              _character == SingingCharacter.onlinpyment) {

                            setState(() {
                              _load = true;
                            });
                            Address _address = new Address(
                                ' s1,s2,sa',
                                'RIYADH',
                                'SA',
                                'RIYADH',
                              'RIYADH', );
                            Telr _Telr = new Telr();
                            try {
                              PaymentResponse response = await _Telr.payForOrder(int.parse(widget.re_orderList.ttprice), _address, null, arrange,'_cEmail');
                              if (response.status == 'Approved') {

                                DateTime now = DateTime.now();
                                final orderbranchdatabaseReference =
                                FirebaseDatabase.instance
                                    .reference()
                                    .child(
                                    "orderListforBranch")
                                    .child( widget.re_orderList.branch_id);
                                final orderuserdatabaseReference =
                                FirebaseDatabase.instance
                                    .reference()
                                    .child("orderListforuser")
                                    .child(_userid);

                                String orderid =
                                    orderbranchdatabaseReference
                                        .push()
                                        .key;

                                orderbranchdatabaseReference
                                    .child(orderid)
                                    .set({
                                  'carrange':
                                  arrange,
                                  'orderId': orderid,
                                  'userid': _userid,
                                  'cdate': now.toString(),
                                  'NumberPhoneUser': _NumberPhone,
                                  'Payment': _character ==
                                      SingingCharacter.cash
                                      ? 'Cash'
                                      : 'ATM',
                                  'branch_id': widget.re_orderList.branch_id,
                                  'deliverycheck': widget.re_orderList.deliverycheck,

                                  'lat_gps':widget.re_orderList.lat_gps,
                                  'long_gps': widget.re_orderList.long_gps,
                                  'address_gps':
                                  widget.re_orderList.address_gps,
                                  'ttprice': widget.re_orderList.ttprice,
                                  'ttitems':widget.re_orderList.ttitems,
                                  'item_id_list':
                                  widget.re_orderList.item_id_list,
                                  'title_ar_list':
                                  widget.re_orderList.title_ar_list,
                                  'title_en_list':
                                  widget.re_orderList.title_en_list,
                                  'total_price_list':
                                  widget.re_orderList.total_price_list,
                                  'item_no_list':
                                  widget.re_orderList.item_no_list,
                                  'size_list':  widget.re_orderList.size_list,
                                  'url_list': widget.re_orderList.url_list,
                                  'deliverytime': deliverytime,
                                }).whenComplete(() {
                                  orderuserdatabaseReference
                                      .child(orderid)
                                      .set({
                                    'carrange':
                                    arrange,
                                    'orderId': orderid,
                                    'userid': _userid,
                                    'cdate': now.toString(),
                                    'NumberPhoneUser': _NumberPhone,
                                    'Payment': _character ==
                                        SingingCharacter.cash
                                        ? 'Cash'
                                        : 'ATM',
                                    'branch_id': widget.re_orderList.branch_id,
                                    'deliverycheck': widget.re_orderList.deliverycheck,

                                    'lat_gps':widget.re_orderList.lat_gps,
                                    'long_gps': widget.re_orderList.long_gps,
                                    'address_gps':
                                    widget.re_orderList.address_gps,
                                    'ttprice': widget.re_orderList.ttprice,
                                    'ttitems':widget.re_orderList.ttitems,
                                    'item_id_list':
                                    widget.re_orderList.item_id_list,
                                    'title_ar_list':
                                    widget.re_orderList.title_ar_list,
                                    'title_en_list':
                                    widget.re_orderList.title_en_list,
                                    'total_price_list':
                                    widget.re_orderList.total_price_list,
                                    'item_no_list':
                                    widget.re_orderList.item_no_list,
                                    'size_list':  widget.re_orderList.size_list,
                                    'url_list': widget.re_orderList.url_list,
                                    'deliverytime': deliverytime,
                                  }).whenComplete(() =>
                                      Fluttertoast.showToast(
                                          msg: translator
                                              .translate(
                                              'done'),
                                          backgroundColor:
                                          Colors.black,
                                          textColor:
                                          Colors.white));
                                  _load = false;
                                });
                                //     }

                                //   }
                                // });

                              }
                            } catch (e) {
                              setState(() {});
                            }
/*
                            telr _telr = new telr();
                            PaymentCard _card = new PaymentCard(
                                '4000 0000 0000 0002', "12", "20", "123");
                            double _price = ( 300);
                            Address _address = new Address(
                                'Street 1 - line 3 - block 5',
                                'RIYADH',
                                'SA',
                                'RIYADH',
                                '11543');
                            Name _name = new Name('Jonh', 'Smaith');
                            _telr.pay(_price, _card, _address, _name, null);*/
                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (context) => TelrPage(  800 )
                            // ));




                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => CreditCardPage(
                            //             widget.re_orderList.ttprice, widget.re_orderList.ttitems, _NumberPhone,deliverytime,deleted)));
                          } else {
                            if (_userid == null||deleted) {
                              FirebaseAuth.instance.signOut();

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignIn()));
                            } else {

                                setState(() {
                                  _load = true;
                                  Future.delayed(Duration(seconds: 0),
                                      () async {


                                            //send data to branch


                                        Alert(
                                          onWillPopActive: true,
                                          context: context,
                                          type: AlertType.warning,
                                          title: translator.translate(
                                              'confirmationOrder'),
                                          desc: translator.translate(
                                              'desConfirmation'),
                                          buttons: [
                                            DialogButton(
                                              child: Text(
                                                translator.translate(
                                                    'confirmation'),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _load = true;
                                                  Navigator.pop(context);
                                                });












                                                DateTime now = DateTime.now();
                                                final orderbranchdatabaseReference =
                                                FirebaseDatabase.instance
                                                    .reference()
                                                    .child(
                                                    "orderListforBranch")
                                                    .child( widget.re_orderList.branch_id);
                                                final orderuserdatabaseReference =
                                                FirebaseDatabase.instance
                                                    .reference()
                                                    .child("orderListforuser")
                                                    .child(_userid);

                                                String orderid =
                                                    orderbranchdatabaseReference
                                                        .push()
                                                        .key;

                                                orderbranchdatabaseReference
                                                    .child(orderid)
                                                    .set({
                                                  'carrange':
                                                  arrange,
                                                  'orderId': orderid,
                                                  'userid': _userid,
                                                  'cdate': now.toString(),
                                                  'NumberPhoneUser': _NumberPhone,
                                                  'Payment': _character ==
                                                      SingingCharacter.cash
                                                      ? 'Cash'
                                                      : 'ATM',
                                                  'branch_id': widget.re_orderList.branch_id,
                                                  'deliverycheck': widget.re_orderList.deliverycheck,

                                                  'lat_gps':widget.re_orderList.lat_gps,
                                                  'long_gps': widget.re_orderList.long_gps,
                                                  'address_gps':
                                                  widget.re_orderList.address_gps,
                                                  'ttprice': widget.re_orderList.ttprice,
                                                  'ttitems':widget.re_orderList.ttitems,
                                                  'item_id_list':
                                                  widget.re_orderList.item_id_list,
                                                  'title_ar_list':
                                                  widget.re_orderList.title_ar_list,
                                                  'title_en_list':
                                                  widget.re_orderList.title_en_list,
                                                  'total_price_list':
                                                  widget.re_orderList.total_price_list,
                                                  'item_no_list':
                                                  widget.re_orderList.item_no_list,
                                                  'size_list':  widget.re_orderList.size_list,
                                                  'url_list': widget.re_orderList.url_list,
                                                  'deliverytime': deliverytime,
                                                }).whenComplete(() {
                                                  orderuserdatabaseReference
                                                      .child(orderid)
                                                      .set({
                                                    'carrange':
                                                    arrange,
                                                    'orderId': orderid,
                                                    'userid': _userid,
                                                    'cdate': now.toString(),
                                                    'NumberPhoneUser': _NumberPhone,
                                                    'Payment': _character ==
                                                        SingingCharacter.cash
                                                        ? 'Cash'
                                                        : 'ATM',
                                                    'branch_id': widget.re_orderList.branch_id,
                                                    'deliverycheck': widget.re_orderList.deliverycheck,

                                                    'lat_gps':widget.re_orderList.lat_gps,
                                                    'long_gps': widget.re_orderList.long_gps,
                                                    'address_gps':
                                                    widget.re_orderList.address_gps,
                                                    'ttprice': widget.re_orderList.ttprice,
                                                    'ttitems':widget.re_orderList.ttitems,
                                                    'item_id_list':
                                                    widget.re_orderList.item_id_list,
                                                    'title_ar_list':
                                                    widget.re_orderList.title_ar_list,
                                                    'title_en_list':
                                                    widget.re_orderList.title_en_list,
                                                    'total_price_list':
                                                    widget.re_orderList.total_price_list,
                                                    'item_no_list':
                                                    widget.re_orderList.item_no_list,
                                                    'size_list':  widget.re_orderList.size_list,
                                                    'url_list': widget.re_orderList.url_list,
                                                    'deliverytime': deliverytime,
                                                  }).whenComplete(() =>
                                                      Fluttertoast.showToast(
                                                          msg: translator
                                                              .translate(
                                                              'done'),
                                                          backgroundColor:
                                                          Colors.black,
                                                          textColor:
                                                          Colors.white));
                                                  _load = false;
                                                });
                                                //     }

                                                //   }
                                                // });

                                              },
                                              color: Theme.of(context)
                                                  .accentColor,
                                            ),
                                            DialogButton(
                                              child: Text(
                                                translator
                                                    .translate('edit'),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      context),
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            )
                                          ],
                                        ).show();

                                  });
                                });
                          //    }
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
                    ],
                  ),
                )
        ],
      ),
    );
  }

  Future<void> _showNotificationCustomSound(int ttitems,String amount) async {
    var android = AndroidNotificationDetails(
        'id', 'channel ', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, translator.translate('sendorder'),
        'عدد الطلبات : $ttitems طلب / تكلفة طلبك : $amount SAR ', platform,
        payload: 'Welcome to the Local Notification demo');
  }
}

