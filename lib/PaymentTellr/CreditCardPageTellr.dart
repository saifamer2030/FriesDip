import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friesdip/Classes/OrderItemforBill.dart';
import 'package:friesdip/Classes/database_helper.dart';
import 'package:friesdip/DrawerScreenPage/CustomAppBar.dart';
import 'package:friesdip/DrawerScreenPage/FollowOrder.dart';
import 'package:friesdip/ScreenPage/HomePage.dart';
import 'package:friesdip/ScreenPage/loginphone.dart';
import 'package:friesdip/ScreenPage/paymentCheckOut/input_formatters.dart';
import 'package:friesdip/ScreenPage/paymentCheckOut/my_strings.dart';
import 'package:friesdip/ScreenPage/paymentCheckOut/payment_card.dart';
import 'package:http/http.dart' as http;
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:friesdip/Classes/globals.dart' as globals;

class CreditCardPage extends StatefulWidget {
  var amount;
  var ttitems;
  var numberPhone;
  var deliverytime;
bool  deleted;
  CreditCardPage(
      this.amount, this.ttitems, this.numberPhone, this.deliverytime, this.deleted);

  @override
  State<StatefulWidget> createState() {
    return CreditCardPageState();
  }
}

class CreditCardPageState extends State<CreditCardPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _formKey = new GlobalKey<FormState>();
  var numberController = new TextEditingController();
  var _paymentCard = PaymentCard();
  var _autoValidate = false;
  var _card = new PaymentCard();
  var arrange;
  String _userid;
  bool _load = false;
  DatabaseHelper databaseHelper = DatabaseHelper();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const _tokenUrl = "https://api.sandbox.checkout.com/tokens";
  static const _paymentUrl = "https://api.sandbox.checkout.com/payments";
  static const String _publckKey =
      "pk_test_508ba4f0-0a24-4ea9-81f9-3b4cc85d3df4";
  static const String _secritKey =
      "sk_test_0c91f3fc-7484-4dda-847c-a6297699346b";

  static const Map<String, String> _tokenHeader = {
    'Content-Type': "Application/json",
    'Authorization': _publckKey
  };

  static const Map<String, String> _paymentHeader = {
    'Content-Type': "Application/json",
    'Authorization': _secritKey
  };

  @override
  void initState() {
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
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
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
    return new Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: BaseAppBar(
          appBar: AppBar(),
        ),
        body: new Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: new Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: Column(
                children: [
                  Expanded(
                    child: new ListView(
                      children: <Widget>[
                        new SizedBox(
                          height: 20.0,
                        ),
                        new TextFormField(
                          decoration: const InputDecoration(
                            border: const UnderlineInputBorder(),
                            filled: true,
                            icon: const Icon(
                              Icons.person,
                              size: 40.0,
                            ),
                            hintText: 'What name is written on card?',
                            labelText: 'Card Name',
                          ),
                          onSaved: (String value) {
                            _card.name = value;
                          },
                          keyboardType: TextInputType.text,
                          validator: (String value) =>
                              value.isEmpty ? Strings.fieldReq : null,
                        ),
                        new SizedBox(
                          height: 30.0,
                        ),
                        new TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            new LengthLimitingTextInputFormatter(19),
                            new CardNumberInputFormatter()
                          ],
                          controller: numberController,
                          decoration: new InputDecoration(
                            border: const UnderlineInputBorder(),
                            filled: true,
                            icon: CardUtils.getCardIcon(_paymentCard.type),
                            hintText: 'What number is written on card?',
                            labelText: 'Number',
                          ),
                          onSaved: (String value) {
                            print('onSaved = $value');
                            print(
                                'Num controller has = ${numberController.text}');
                            _paymentCard.number =
                                CardUtils.getCleanedNumber(value);
                          },
                          validator: CardUtils.validateCardNum,
                        ),
                        new SizedBox(
                          height: 30.0,
                        ),
                        new TextFormField(
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            new LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: new InputDecoration(
                            border: const UnderlineInputBorder(),
                            filled: true,
                            icon: new Image.asset(
                              'assets/images/card_cvv.png',
                              width: 40.0,
                              color: Colors.grey[600],
                            ),
                            hintText: 'Number behind the card',
                            labelText: 'CVV',
                          ),
                          validator: CardUtils.validateCVV,
                          keyboardType: TextInputType.number,
                          onSaved: (value) {
                            _paymentCard.cvv = int.parse(value);
                          },
                        ),
                        new SizedBox(
                          height: 30.0,
                        ),
                        new TextFormField(
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            new LengthLimitingTextInputFormatter(4),
                            new CardMonthInputFormatter()
                          ],
                          decoration: new InputDecoration(
                            border: const UnderlineInputBorder(),
                            filled: true,
                            icon: new Image.asset(
                              'assets/images/calender.png',
                              width: 40.0,
                              color: Colors.grey[600],
                            ),
                            hintText: 'MM/YY',
                            labelText: 'Expiry Date',
                          ),
                          validator: CardUtils.validateDate,
                          keyboardType: TextInputType.number,
                          onSaved: (value) {
                            List<int> expiryDate =
                                CardUtils.getExpiryDate(value);
                            _paymentCard.month = expiryDate[0].toString();
                            _paymentCard.year = expiryDate[1].toString();
                          },
                        ),
                      ],
                    ),
                  ),
                  new Container(
                      width: MediaQuery.of(context).size.width,
                      child: !_load ? _getPayButton() : loadingIndicator),
                ],
              )),
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() {
        _autoValidate = true; // Start validating on every change.
      });
      _load = false;
      _showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      // Encrypt and send send payment details to payment gateway

      int amount = int.tryParse(widget.amount) * (100);

//                  '4242424242424242'
      PaymentCard card = PaymentCard(
          name: _paymentCard.name,
          number: _paymentCard.number,
          month: _paymentCard.month,
          year: _paymentCard.year,
          cvv: _paymentCard.cvv,
          type: _paymentCard.type);
      print('${_paymentCard.month}///${_paymentCard.year}');
      makePayment(card, amount);
    }
  }

  Future<String> _getToken(PaymentCard card) async {
    Map<String, String> body = {
      'type': 'card',
      'number': card.number,
      'expiry_month': card.month,
      'expiry_year': card.year,
    };
    http.Response response = await http.post(_tokenUrl,
        headers: _tokenHeader, body: jsonEncode(body));
    switch (response.statusCode) {
      case 201:
        var data = jsonDecode(response.body);
        return data['token'];
        break;
      default:
        _load = false;
        _showInSnackBar('card invalid!');
        _showNotificationPayment("card invalid!", "card invalid!");
        throw Exception('card invalid');
        break;
    }
  }

  Future<bool> makePayment(PaymentCard card, int amuont) async {
    print('$amuont');
    String token = await _getToken(card);
    print(token);
    Map<String, dynamic> body = {
      'source': {'type': 'token', 'token': token},
      'amount': amuont,
      'currency': 'SAR'
    };
    http.Response response = await http.post(_paymentUrl,
        headers: _paymentHeader, body: jsonEncode(body));
    switch (response.statusCode) {
      case 201:
        var data = jsonDecode(response.body);
        print(data['response_summary']);
        _load = false;
        if (data['response_summary'] == 'Approved') {
          _showInSnackBar('Payment was successful!');

          if (_userid == null||widget.deleted) {
            FirebaseAuth.instance.signOut();

            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignIn()));
          } else {
            setState(() {
              Future.delayed(Duration(seconds: 0), () async {
                OrderItemforBill orderforbill1 =
                    await databaseHelper.alldatafororder().then((orderforbill) {
                  if (globals.deliverycheck) {
                    /////////delivery////////////
                    if (globals.distancecheck) {
                      if (globals.address_gps == "" ||
                          globals.address_gps == null ||
                          globals.branch_id == "" ||
                          globals.branch_id == null) {
                        Fluttertoast.showToast(
                            msg: translator.translate('enter_ur_address'),
                            backgroundColor: Colors.black,
                            textColor: Colors.white);
                      } else {
                        //send data to branch

                        DateTime now = DateTime.now();
                        final orderbranchdatabaseReference = FirebaseDatabase
                            .instance
                            .reference()
                            .child("orderListforBranch")
                            .child(globals.branch_id);
                        final orderuserdatabaseReference = FirebaseDatabase
                            .instance
                            .reference()
                            .child("orderListforuser")
                            .child("_userid");

                        String orderid =
                            orderbranchdatabaseReference.push().key;

                        orderbranchdatabaseReference.child(orderid).set({
                          'carrange': arrange,
                          'orderId': orderid,
                          'userid': _userid,
                          'cdate': now.toString(),
                          'NumberPhoneUser': widget.numberPhone,
                          'Payment': 'Onlin Payment',
                          'branch_id': globals.branch_id,
                          'deliverycheck': globals.deliverycheck,
                          'lat_gps': globals.lat_gps,
                          'long_gps': globals.long_gps,
                          'address_gps': globals.address_gps,
                          'ttprice': widget.amount,
                          'ttitems': widget.ttitems,
                          'item_id_list': orderforbill.item_id,
                          'title_ar_list': orderforbill.title_ar,
                          'title_en_list': orderforbill.title_en,
                          'total_price_list': orderforbill.total_price,
                          'item_no_list': orderforbill.item_no,
                          'size_list': orderforbill.size,
                          'url_list': orderforbill.url,
                          'deliverytime': widget.deliverytime,
                        }).whenComplete(() {
                          orderuserdatabaseReference.child(orderid).set({
                            'carrange': arrange,
                            'orderId': orderid,
                            'userid': _userid,
                            'cdate': now.toString(),
                            'NumberPhoneUser': widget.numberPhone,
                            'Payment': 'Onlin Payment',
                            'branch_id': globals.branch_id,
                            'deliverycheck': globals.deliverycheck,
                            'lat_gps': globals.lat_gps,
                            'long_gps': globals.long_gps,
                            'address_gps': globals.address_gps,
                            'ttprice': widget.amount,
                            'ttitems': widget.ttitems,
                            'item_id_list': orderforbill.item_id,
                            'title_ar_list': orderforbill.title_ar,
                            'title_en_list': orderforbill.title_en,
                            'total_price_list': orderforbill.total_price,
                            'item_no_list': orderforbill.item_no,
                            'size_list': orderforbill.size,
                            'url_list': orderforbill.url,
                            'deliverytime': widget.deliverytime,
                          }).whenComplete(() => Fluttertoast.showToast(
                              msg: translator.translate('done'),
                              backgroundColor: Colors.black,
                              textColor: Colors.white));
                        });
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: translator.translate('no_delivery'),
                          backgroundColor: Colors.black,
                          textColor: Colors.white);
                    }
                  } else {
                    /////////branch////////////
                    if (globals.branch_name_ar == "" ||
                        globals.branch_name_ar == null ||
                        globals.branch_name_en == "" ||
                        globals.branch_name_en == null ||
                        globals.branch_id == "" ||
                        globals.branch_id == null) {
                      print(
                          "bbbb${globals.branch_name_ar}///${globals.branch_name_en}////${globals.branch_id}");
                      Fluttertoast.showToast(
                          msg: translator.translate('branch_location'),
                          backgroundColor: Colors.black,
                          textColor: Colors.white);
                    } else {
                      //send data to branch
                      DateTime now = DateTime.now();
                      final orderbranchdatabaseReference = FirebaseDatabase
                          .instance
                          .reference()
                          .child("orderListforBranch")
                          .child(globals.branch_id);
                      final orderuserdatabaseReference = FirebaseDatabase
                          .instance
                          .reference()
                          .child("orderListforUser")
                          .child(_userid);

                      String orderid = orderbranchdatabaseReference.push().key;

                      orderbranchdatabaseReference.child(orderid).set({
                        'carrange': arrange,
                        'orderId': orderid,
                        'userid': _userid,
                        'cdate': now.toString(),
                        'NumberPhoneUser': widget.numberPhone,
                        'Payment': 'Onlin Payment',
                        'branch_id': globals.branch_id,
                        'deliverycheck': globals.deliverycheck,
                        'lat_gps': globals.lat_gps,
                        'long_gps': globals.long_gps,
                        'address_gps': globals.address_gps,
                        'ttprice': widget.amount,
                        'ttitems': widget.ttitems,
                        'item_id_list': orderforbill.item_id,
                        'title_ar_list': orderforbill.title_ar,
                        'title_en_list': orderforbill.title_en,
                        'total_price_list': orderforbill.total_price,
                        'item_no_list': orderforbill.item_no,
                        'size_list': orderforbill.size,
                        'url_list': orderforbill.url,
                        'deliverytime': widget.deliverytime,
                      }).whenComplete(() {
                        orderuserdatabaseReference
                            .child(orderid)
                            .set({
                              'carrange': arrange,
                              'orderId': orderid,
                              'userid': _userid,
                              'cdate': now.toString(),
                              'NumberPhoneUser': widget.numberPhone,
                              'Payment': 'Onlin Payment',
                              'branch_id': globals.branch_id,
                              'deliverycheck': globals.deliverycheck,
                              'lat_gps': globals.lat_gps,
                              'long_gps': globals.long_gps,
                              'address_gps': globals.address_gps,
                              'ttprice': widget.amount,
                              'ttitems': widget.ttitems,
                              'item_id_list': orderforbill.item_id,
                              'title_ar_list': orderforbill.title_ar,
                              'title_en_list': orderforbill.title_en,
                              'total_price_list': orderforbill.total_price,
                              'item_no_list': orderforbill.item_no,
                              'size_list': orderforbill.size,
                              'url_list': orderforbill.url,
                              'deliverytime': widget.deliverytime,
                            })
                            .whenComplete(() => Fluttertoast.showToast(
                                msg: translator.translate('done'),
                                backgroundColor: Colors.black,
                                textColor: Colors.white))
                            .then((value) => Alert(
                                  context: context,
                                  type: AlertType.success,
                                  title: translator.translate('done'),
                                  desc: translator.translate('OrderTracking'),
                                  buttons: [
                                    DialogButton(
                                      child: Text(
                                        translator.translate('confirmation'),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  StepperPage())),
                                      color: Theme.of(context).accentColor,
                                    ),
                                    DialogButton(
                                      child: Text(
                                        translator.translate('home'),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomePage())),
                                      color: Colors.black,
                                    )
                                  ],
                                ).show());
                        _showNotificationCustomSound(
                            widget.ttitems, widget.amount);
                      });
                      final Reference = FirebaseDatabase.instance
                          .reference()
                          .child('OrderIdAndBranchId');
                      Reference.child(_userid)
                          .push()
                          .set({
                        'OrderId': orderid,
                        'BranchId': globals.branch_id,
                      });
                    }
                  }
                });
              });
            });
          }

          Alert(
            onWillPopActive: true,
            context: context,
            type: AlertType.success,
            title: "Payment was successful",
            desc: "Go to track the order?",
            buttons: [
              DialogButton(
                child: Text(
                  "Okay",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => StepperPage())),
                color: Color.fromRGBO(0, 179, 134, 1.0),
              ),
              DialogButton(
                child: Text(
                  "Back Home",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage())),
               color: Colors.blueAccent,
              )
            ],
          ).show().then((value) => _showNotificationPayment(
              "Payment was successful",
              "Your request has been sent to the branch"));
        } else {
          _showInSnackBar('payment failed pleas tyr again!');
          Alert(
            context: context,
            type: AlertType.error,
            title: "payment failed pleas tyr again!",
            desc: "Tyr again?",
            buttons: [
              DialogButton(
                child: Text(
                  "Okay",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.pop(context),
                width: 120,
              )
            ],
          ).show().then((value) => _showNotificationPayment(
              "payment failed pleas tyr again!",
              "payment failed pleas tyr again!"));
        }
        return true;
        break;
      default:
        _load = false;
        _showInSnackBar('payment failed pleas tyr again!');
        Alert(
          context: context,
          type: AlertType.error,
          title: "payment failed pleas tyr again!",
          desc: "Tyr again?",
          buttons: [
            DialogButton(
              child: Text(
                "Okay",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show().then((value) => _showNotificationPayment(
            "payment failed pleas tyr again!",
            "payment failed pleas tyr again!"));
        throw Exception('payment failed pleas tyr again');

        break;
    }
  }

  Widget _getPayButton() {
    if (Platform.isIOS) {
      return new CupertinoButton(
        onPressed: _validateInputs,
        color: CupertinoColors.activeBlue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              Strings.pay,
              style: const TextStyle(fontSize: 17.0),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: new Text(
                '${widget.amount}',
                style: const TextStyle(fontSize: 17.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: new Text(
                'SAR',
                style: const TextStyle(fontSize: 17.0),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        color: Theme.of(context).accentColor,
        width: MediaQuery.of(context).size.width,
        child: new FlatButton(
          onPressed: () {
            setState(() {
              _load = true;
              _validateInputs();
            });
          },
          color: Theme.of(context).accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(const Radius.circular(100.0)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
          textColor: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new Text(
                Strings.pay.toUpperCase(),
                style: const TextStyle(fontSize: 17.0),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: new Text(
                  '${widget.amount}',
                  style: const TextStyle(fontSize: 17.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: new Text(
                  'SAR',
                  style: const TextStyle(fontSize: 17.0),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      duration: new Duration(seconds: 3),
    ));
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

  Future<void> _showNotificationPayment(String s, String i) async {
    var android = AndroidNotificationDetails('id', 'channel ', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(0, s, i, platform,
        payload: 'Welcome to the Local Notification demo');
  }
}
