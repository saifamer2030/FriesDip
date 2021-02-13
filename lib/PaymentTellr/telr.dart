import 'dart:async';
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friesdip/Classes/OrderItemforBill.dart';
import 'package:friesdip/Classes/database_helper.dart';
import 'package:friesdip/DrawerScreenPage/FollowOrder.dart';
import 'package:friesdip/PaymentTellr/payment_response.dart';
import 'package:friesdip/ScreenPage/HomePage.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:friesdip/ScreenPage/ShoppingBasket.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';
import 'dart:io' show Platform;
import 'Address.dart';
import 'package:friesdip/Classes/globals.dart' as globals;

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';
bool complete = false;
String start_url = '';
String close_url = '';
String abort_url = '';
String url = '';
String code = '';

class Telr {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  static String AUTHKEY = "6tx44-xtmv~RvsVZ";
  static String STOREID = "24923";
  static String publicKey = '10cc319bM\$kmvptP#sh7NX#\$';
  static String paymentUrl =
      "https://secure.innovatepayments.com/gateway/mobile.xml";
  static String completeUrl =
      "https://secure.innovatepayments.com/gateway/mobile_complete.xml";
  PaymentResponse paymentRes;

  Map<String, String> paymentHeader = {
    'Content-Type': 'text/xml',
    'Authorization': 'Basic ' + publicKey
  };
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  String _NumberPhone, _userid, deliverytime;
  var arrange;
  double criticalkm, discount;
  int ttprice, more, less, ttitems;
  BuildContext context;

  Telr(
      this._NumberPhone,
      this._userid,
      this.deliverytime,
      this.criticalkm,
      this.ttprice,
      this.discount,
      this.more,
      this.less,
      this.arrange,
      this.ttitems,
      this.context) {
    initPlatformState();
  }

  TransactionRequest() {
    initPlatformState();
  }

  Future<String> create(int price, FirebaseUser user, Address address,
      int arrange, String _cEmail) async {
    Map<String, dynamic> deviceInfo = await initPlatformState();
    final request = XmlBuilder();
    request.processing('xml', 'version="1.0"');
    request.element('mobile', nest: () {
      // store id
      request.element('store', nest: STOREID);
      // Auth key
      request.element('key', nest: AUTHKEY);
      // Device info section
      request.element('device', nest: () {
        request.element('type', nest: deviceInfo['type']);
        request.element('id', nest: deviceInfo['deviceID']);
        request.element('agent', nest: 'WebView user agent header here');
        request.element('accept', nest: 'WebView accept header here');
      });
      // Application info section
      request.element('app', nest: () {
        request.element('name', nest: deviceInfo['name']);
        request.element('version', nest: deviceInfo['version']);
        request.element('user', nest: deviceInfo['fingerprint']);
        request.element('id', nest: deviceInfo['AppID']);
      });
      // Transaction info section

      request.element('tran', nest: () {
        // Test mode type, 0 for live mode, 1 for test mode
        request.element('test', nest: 1);
        // Transaction type
        request.element('type', nest: 'paypage');
        // Transaction class
        request.element('class', nest: 'ecom');
        // Transaction cart ID'

        request.element('cartid', nest: arrange.toString());

        // Transaction description
        request.element('description', nest: 'Transaction description');
        // Transaction currency, like SAR, USD
        request.element('currency', nest: 'SAR');
        // Transaction amount, like 8.50
        request.element('amount', nest: price);
        // Previous transaction reference
        request.element('ref', nest: 'Previous transaction reference');
      });
      // Card info section
      /*request.element('card', nest: () {
        request.element('number', nest: paymentCard.number);
        request.element('expiry', nest: () {
          request.element('month', nest: paymentCard.expiry_month);
          request.element('year', nest: paymentCard.expiry_year);
        });
        request.element('cvv', nest: paymentCard.cvv);
      });*/
      // Billing info: Customer info and address
      request.element('billing', nest: () {
        request.element('name', nest: () {
          // Name;
          request.element('title', nest: 'Mr');
          //  request.element( 'first', nest: name.first );
          // request.element( 'last', nest: name.last );
        });
        // Email address

        request.element('email', nest: _cEmail);

        // Address info
        request.element('address', nest: () {
          request.element('line1', nest: address.line1);
          request.element('city', nest: address.city);
          request.element('region', nest: address.region);
          request.element('country', nest: 'Saudi Arabia');
          request.element('zip', nest: address.zip);
        });
      });
    });
    // return the formatted xml text
    return request.buildDocument().toString();
  }

  Future<Map<String, dynamic>> initPlatformState() async {
    Map<String, dynamic> deviceData = <String, dynamic>{
      'name': 'Name',
      'type': 'Type',
      'deviceID': 'Device ID',
      'version': 'Version',
      'AppID': 'App ID',
      'fingerprint': 'Fingerprint'
    };
    /*   try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo = deviceInfoPlugin.androidInfo as AndroidDeviceInfo;
        deviceData = <String, dynamic>{
          'name': androidDeviceInfo.version.codename,
          'type': androidDeviceInfo.type,
          'deviceID': androidDeviceInfo.id,
          'version': androidDeviceInfo.version.release,
          'AppID': androidDeviceInfo.androidId,
          'fingerprint': androidDeviceInfo.fingerprint
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = deviceInfoPlugin.iosInfo as IosDeviceInfo;
        deviceData = <String, dynamic>{
          'name': iosInfo.name,
          'type': iosInfo.model,
          'deviceID': iosInfo.utsname.sysname,
          'version': iosInfo.utsname.version,
          'AppID': iosInfo.utsname.machine,
          'fingerprint': iosInfo.identifierForVendor
        };
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }*/
    return deviceData;
  }

  @override
  Future<dynamic> payForOrder(int price, Address address, FirebaseUser user,
      int arrange, String _cEmail, BuildContext context) async {
    print("Start Payment!.");

    String body;
    bool _loading = false;
    if (user != null) {
      //  QuerySnapshot querySnapshot = await Firestore.instance.collection('profiles').where('user_id', isEqualTo: user.uid).getDocuments();
      //  payment_id = querySnapshot.documents[0]['payment_id'].toString();
    }

    // test
    body = await this.create(price, user, address, arrange, _cEmail);

    print(body);

    http.Response response =
        await http.post(paymentUrl, headers: paymentHeader, body: body);
    print(response.statusCode); //
    switch (response.statusCode) {
      case 200:
        Xml2Json xml2json = new Xml2Json();
        xml2json.parse(response.body);
        var json = xml2json.toParker();
        // the only method that worked for my XML type.
        var response1 = jsonDecode(json);
        start_url = response1['mobile']['webview']['start'].toString();
        close_url = response1['mobile']['webview']['close'].toString();
        abort_url = response1['mobile']['webview']['abort'].toString();
        code = response1['mobile']['webview']['code'].toString();

        // start
        url = start_url;

        print("ٍStart page");

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => telrPage(
                  "",
                  _NumberPhone,
                  _userid,
                  deliverytime,
                  criticalkm,
                  ttprice,
                  discount,
                  more,
                  less,
                  arrange,
                  ttitems,
                  context)),
        );

        break;
      default:
        throw Exception('Payment failed');
        break;
    }
  }

  // complete payment
  Future<dynamic> complete(code) async {
    final request = XmlBuilder();
    request.processing('xml', 'version="1.0"');
    request.element('mobile', nest: () {
      // store id
      request.element('store', nest: STOREID);
      // Auth key
      request.element('key', nest: AUTHKEY);
      // transaction code
      request.element('complete', nest: code);
    });
    // make complete request
    String body = request.buildDocument().toXmlString();
    http.Response response =
        await http.post(completeUrl, headers: paymentHeader, body: body);
    print("Complete");

    Xml2Json xml2json = new Xml2Json();
    xml2json.parse(response.body);
    var json = xml2json.toParker();
    // the only method that worked for my XML type.
    var response1 = jsonDecode(json);
    PaymentResponse res = new PaymentResponse(
        response1['mobile']['auth']['status'].toString(),
        response1['mobile']['auth']['tranref'].toString(),
        response1['mobile']['auth']['message'].toString());

    paymentRes = res;
    chickPaymentSucsse(paymentRes);
    // ShoppingBasket().payment(paymentRes);
  }

  void chickPaymentSucsse(PaymentResponse paymentResponse) {
    DatabaseHelper databaseHelper = DatabaseHelper();
    print('Sucsse');
    print(paymentResponse.status);
    var amount = globals.deliverycheck
        ? (globals.distance > criticalkm
            ? (ttprice * (1 - discount) + more).toStringAsFixed(1)
            : (ttprice * (1 - discount) + less).toStringAsFixed(1))
        : (ttprice * (1 - discount) + 0).toStringAsFixed(0);
    Future.delayed(Duration(seconds: 1), () async {
      OrderItemforBill orderforbill1 =
          await databaseHelper.alldatafororder().then((orderforbill) async {
        if (paymentResponse.status == 'A') {
          // Approved
          print('Response message: ${paymentResponse.message}');
          print('Response tranref: ${paymentResponse.tranref}');
          DateTime now = DateTime.now();
          final orderbranchdatabaseReference = FirebaseDatabase.instance
              .reference()
              .child("orderListforBranch")
              .child(globals.branch_id);
          final orderuserdatabaseReference = FirebaseDatabase.instance
              .reference()
              .child("orderListforUser")
              .child(_userid);
          String orderid = orderbranchdatabaseReference.push().key;
          final ReferenceOrderId =
              FirebaseDatabase.instance.reference().child('OrderIdAndBranchId');
          ReferenceOrderId.child(_userid).set({
            'OrderId': orderid,
            'BranchId': globals.branch_id,
          });
          final ReferenceStatusOrder = FirebaseDatabase.instance
              .reference()
              .child('NotificationStatusOrder');
          ReferenceStatusOrder.child(_userid).child(orderid).update({
            'OrderStatus': 0,
          });
          orderbranchdatabaseReference.child(orderid).set({
            'carrange': arrange,
            'tranref': paymentResponse.tranref,
            'orderId': orderid,
            'userid': _userid,
            'cdate': now.toString(),
            'NumberPhoneUser': _NumberPhone,
            'Payment': 'online payment',
            'branch_id': globals.branch_id,
            'deliverycheck': globals.deliverycheck,
            'lat_gps': globals.lat_gps,
            'long_gps': globals.long_gps,
            'address_gps': globals.address_gps,
            'ttprice': globals.deliverycheck
                ? (globals.distance > criticalkm
                    ? (ttprice * (1 - discount) + more).toStringAsFixed(1)
                    : (ttprice * (1 - discount) + less).toStringAsFixed(1))
                : (ttprice * (1 - discount) + 0).toStringAsFixed(1),
            'ttitems': ttitems,
            'item_id_list': orderforbill.item_id,
            'title_ar_list': orderforbill.title_ar,
            'title_en_list': orderforbill.title_en,
            'total_price_list': orderforbill.total_price,
            'item_no_list': orderforbill.item_no,
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
                  'tranref': paymentResponse.tranref,
                  'cdate': now.toString(),
                  'NumberPhoneUser': _NumberPhone,
                  'Payment': 'online payment',
                  'branch_id': globals.branch_id,
                  'deliverycheck': globals.deliverycheck,
                  'lat_gps': globals.lat_gps,
                  'long_gps': globals.long_gps,
                  'address_gps': globals.address_gps,
                  'ttprice': globals.deliverycheck
                      ? (globals.distance > criticalkm
                          ? (ttprice * (1 - discount) + more).toStringAsFixed(1)
                          : (ttprice * (1 - discount) + less)
                              .toStringAsFixed(1))
                      : (ttprice * (1 - discount) + 0).toStringAsFixed(1),
                  'ttitems': ttitems,
                  'item_id_list': orderforbill.item_id,
                  'title_ar_list': orderforbill.title_ar,
                  'title_en_list': orderforbill.title_en,
                  'total_price_list': orderforbill.total_price,
                  'item_no_list': orderforbill.item_no,
                  'size_list': orderforbill.size,
                  'url_list': orderforbill.url,
                  'deliverytime': deliverytime,
                })
                .then((value) =>
                    /*Alert(
                      onWillPopActive: true,
                      context: context,
                      type: AlertType.success,
                      title: translator.translate('done'),
                      desc: translator.translate('OrderTracking'),
                      buttons: [
                        DialogButton(
                          child: Text(
                            translator.translate('confirmation'),
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StepperPage())),
                          color: Colors.red,
                        ),
                        DialogButton(
                          child: Text(
                            translator.translate('home'),
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage())),
                          color: Colors.black,
                        )
                      ],
                    ).show()*/
                    Fluttertoast.showToast(
                        msg: translator.translate('donePayment'),
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        fontSize: 16.0,
                        backgroundColor: Colors.red,
                        textColor: Colors.black))
                .then((value) => Fluttertoast.showToast(
                    msg: translator.translate('sendorder'),
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    fontSize: 16.0,
                    backgroundColor: Colors.black,
                    textColor: Colors.white));
            await _showNotificationCustomSound(ttitems, amount, deliverytime);
          });
          // Navigator.of(context).pushReplacement(
          //     MaterialPageRoute(
          //         builder: (context) =>
          //             ThankYouPage()));
        } else {
          Fluttertoast.showToast(
              msg: 'faild payment',
              fontSize: 16.0,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white);
        }
      });
    });
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _showNotificationCustomSound(
      int ttitems, String amount, deliverytime) async {
    var android = AndroidNotificationDetails('id', 'channel ', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0,
        translator.translate('sendorder'),
        '$ttitemsطلب/تكلفة طلبك:$amount SAR/وقت الاستلام:$deliverytime',
        platform,
        payload: 'Welcome to the Local Notification demo');
  }

  // abort payment
  Future<dynamic> abort(code) async {
    final request = XmlBuilder();
    request.processing('xml', 'version="1.0"');
    request.element('mobile', nest: () {
      // store id
      request.element('store', nest: STOREID);
      // Auth key
      request.element('key', nest: AUTHKEY);
      // transaction code
      request.element('abort', nest: code);
    });
    // make complete request
    String body = request.buildDocument().toXmlString();
    http.Response response =
        await http.post(completeUrl, headers: paymentHeader, body: body);
    print("Abort");
    Xml2Json xml2json = new Xml2Json();
    xml2json.parse(response.body);
    var json = xml2json.toParker();
    // the only method that worked for my XML type.
    var response1 = jsonDecode(json);
    PaymentResponse res = new PaymentResponse(
        response1['mobile']['auth']['status'].toString(),
        response1['mobile']['auth']['tranref'].toString(),
        response1['mobile']['auth']['message'].toString());
    chickPaymentSucsse(paymentRes);
    // ShoppingBasket().payment(paymentRes);
  }
}

class telrPage extends StatefulWidget {
  telrPage(
      this.title,
      this._NumberPhone,
      this._userid,
      this.deliverytime,
      this.criticalkm,
      this.ttprice,
      this.discount,
      this.more,
      this.less,
      this.arrange,
      this.ttitems,
      BuildContext context);

  String title;
  String _NumberPhone, _userid, deliverytime;
  var arrange;
  double criticalkm, discount;
  int ttprice, more, less, ttitems;

  @override
  _telrPageState createState() => _telrPageState();
}

class _telrPageState extends State<telrPage> {
  // Instance of WebView plugin
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  // On destroy stream
  StreamSubscription _onDestroy;

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;

  // On urlChanged stream
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  StreamSubscription<WebViewHttpError> _onHttpError;

//  StreamSubscription<double> _onProgressChanged;

//  StreamSubscription<double> _onScrollYChanged;

//  StreamSubscription<double> _onScrollXChanged;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _history = [];

  @override
  void initState() {
    super.initState();
    Telr telr = new Telr(
        widget._NumberPhone,
        widget._userid,
        widget.deliverytime,
        widget.criticalkm,
        widget.ttprice,
        widget.discount,
        widget.more,
        widget.less,
        widget.arrange,
        widget.ttitems,
        context);
    flutterWebViewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
      if (mounted) {
        // close payment and abort
        if (!complete) {
          print("Destroy...");
          // abort
          // telr.abort(code);
          // close web view
          Navigator.pop(context);
        }
      }
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        setState(() {
          print("Change url...");
          print(url);
          // check for url
          if (url == close_url) {
            // payment complete
            complete = true;
            telr.complete(code);
            // close web view
            Navigator.pop(context);
          } else if (url == abort_url) {
            // closed by user
            complete = false;
            telr.abort(code);
            // close web view
            Navigator.pop(context);
          }
        });
      }
    });

    _onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        setState(() {
          // add loading status here | if needed
        });
      }
    });

    _onHttpError =
        flutterWebViewPlugin.onHttpError.listen((WebViewHttpError error) {
      if (mounted) {
        setState(() {
          // payment failed
          // complete = false;
          //  telr.abort(code);
          // close web view
          flutterWebViewPlugin.close();
        });
      }
    });
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    // _onProgressChanged.cancel();
    //  _onScrollXChanged.cancel();
    //  _onScrollYChanged.cancel();
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Plug'),
        ),
        body: /*Container(
          child: SingleChildScrollView(*/
            WebviewScaffold(
          url: url,
          mediaPlaybackRequiresUserGesture: false,
          withZoom: true,
          withLocalStorage: true,
          hidden: true,
          initialChild: Container(
            child: const Center(
              child: Text('Please Waiting.....'),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    flutterWebViewPlugin.goBack();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    flutterWebViewPlugin.goForward();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.autorenew),
                  onPressed: () {
                    flutterWebViewPlugin.reload();
                  },
                ),
              ],
            ),
          ),
        )
        // ),
        // )
        );
  }
/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child:  RaisedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/payment');
              },
              child: const Text('Open widget webview'),
            ),
      ),
    );
  } */
}
