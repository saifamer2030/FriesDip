import 'dart:async';
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:friesdip/PaymentTellr/payment_response.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';
import 'dart:io' show Platform;
import 'Address.dart';

const kAndroidUserAgent = 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';
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
  static String paymentUrl = "https://secure.innovatepayments.com/gateway/mobile.xml";
  static String completeUrl = "https://secure.innovatepayments.com/gateway/mobile_complete.xml";

  Map<String, String> paymentHeader = {
    'Content-Type': 'text/xml',
    'Authorization': 'Basic ' + publicKey
  };
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Telr() { initPlatformState(); }

  TransactionRequest() {
    initPlatformState();
  }

  Future<String> create(int price, FirebaseUser user, Address address, int arrange, String _cEmail) async {
    Map<String, dynamic> deviceInfo = await initPlatformState( );
    final request = XmlBuilder( );
    request.processing( 'xml', 'version="1.0"' );
    request.element( 'mobile', nest: () {
      // store id
      request.element( 'store', nest: STOREID );
      // Auth key
      request.element( 'key', nest: AUTHKEY );
      // Device info section
      request.element( 'device', nest: () {
        request.element( 'type', nest: deviceInfo['type'] );
        request.element( 'id', nest: deviceInfo['deviceID'] );
        request.element( 'agent', nest: 'WebView user agent header here' );
        request.element( 'accept', nest: 'WebView accept header here' );
      } );
      // Application info section
      request.element( 'app', nest: () {
        request.element( 'name', nest: deviceInfo['name'] );
        request.element( 'version', nest: deviceInfo['version'] );
        request.element( 'user', nest: deviceInfo['fingerprint'] );
        request.element( 'id', nest: deviceInfo['AppID'] );
      } );
      // Transaction info section

      request.element( 'tran', nest: () {
        // Test mode type, 0 for live mode, 1 for test mode
        request.element( 'test', nest:1);
        // Transaction type
        request.element( 'type', nest: 'paypage' );
        // Transaction class
        request.element( 'class', nest: 'ecom' );
        // Transaction cart ID'

        request.element( 'cartid', nest: arrange.toString( ) );


        // Transaction description
        request.element( 'description', nest: 'Transaction description' );
        // Transaction currency, like SAR, USD
        request.element( 'currency', nest: 'SAR' );
        // Transaction amount, like 8.50
        request.element( 'amount', nest: price );
        // Previous transaction reference
        request.element( 'ref', nest: 'Previous transaction reference' );
      } );
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
      request.element( 'billing', nest: () {
        request.element( 'name', nest: () {
          // Name;
          request.element( 'title', nest: 'Mr' );
          //  request.element( 'first', nest: name.first );
          // request.element( 'last', nest: name.last );
        } );
        // Email address

        request.element( 'email', nest: _cEmail );

        // Address info
        request.element( 'address', nest: () {
          request.element( 'line1', nest: address.line1 );
          request.element( 'city', nest: address.city );
          request.element( 'region', nest: address.region );
          request.element( 'country', nest: 'Saudi Arabia' );
          request.element( 'zip', nest: address.zip );
        } );
      } );
    } );
    // return the formatted xml text
    return request.buildDocument( ).toString( );
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
  Future<PaymentResponse> payForOrder(int price, Address address, FirebaseUser user, int arrange, String _cEmail, BuildContext context) async {
    print("Start Payment!.");

    String body;
    bool _loading = false;
    if (user != null) {
      //  QuerySnapshot querySnapshot = await Firestore.instance.collection('profiles').where('user_id', isEqualTo: user.uid).getDocuments();
      //  payment_id = querySnapshot.documents[0]['payment_id'].toString();
    }

    // test
    body = await this.create( price, user, address, arrange, _cEmail );

    print(body);

    http.Response response = await http.post( paymentUrl, headers: paymentHeader, body: body );
    print(response.statusCode); //
    switch (response.statusCode) {
      case 200:
        Xml2Json xml2json = new Xml2Json( );
        xml2json.parse( response.body );
        var json = xml2json.toParker( );
        // the only method that worked for my XML type.
        var response1 = jsonDecode( json );
        start_url = response1['mobile']['webview']['start'].toString();
        close_url = response1['mobile']['webview']['close'].toString();
        abort_url = response1['mobile']['webview']['abort'].toString();
        code = response1['mobile']['webview']['code'].toString();

        // start
        url = start_url;

        print("ٍStart payment");

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => telrPage()),
        );

        break;
      default:
        throw Exception( 'Payment failed' );
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
    http.Response response = await http.post( completeUrl, headers: paymentHeader, body: body );
    print("Complete");
    print(response.body);

    return response;

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
    http.Response response = await http.post( completeUrl, headers: paymentHeader, body: body );
    print("Abort");
    print(response.body);

    return response;
  }
}

class telrPage extends StatefulWidget {
  const telrPage({Key key, this.title}) : super(key: key);
  final String title;

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

  StreamSubscription<double> _onProgressChanged;

  StreamSubscription<double> _onScrollYChanged;

  StreamSubscription<double> _onScrollXChanged;



  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _history = [];

  Telr telr = new Telr();

  @override
  void initState() {
    super.initState();

    flutterWebViewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
      if (mounted) {
        // close payment and abort
        if (!complete) {
          // abort
          telr.abort(code);
        }
      }
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        setState(() {
          // check for url
          if (url == close_url) {
              // payment complete
              complete = true;
              telr.complete(code);
          } else if (url == abort_url) {
              // closed by user
              complete = false;
              telr.abort(code);
          } else {
              // payment failed for some reason
              complete = false;
              telr.abort(code);
          }
         }
        );
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
                complete = false;
                telr.abort(code);
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
    _onProgressChanged.cancel();
    _onScrollXChanged.cancel();
    _onScrollYChanged.cancel();
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
              WebviewScaffold( url: url, mediaPlaybackRequiresUserGesture: false,
                withZoom: true,
                withLocalStorage: true,
                hidden: true,
                initialChild: Container(
                  child: const Center(
                    child: Text( 'Please Waiting.....' ),
                  ),
                ),
                bottomNavigationBar: BottomAppBar(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: const Icon( Icons.arrow_back_ios ),
                        onPressed: () {
                          flutterWebViewPlugin.goBack( );
                        },
                      ),
                      IconButton(
                        icon: const Icon( Icons.arrow_forward_ios ),
                        onPressed: () {
                          flutterWebViewPlugin.goForward( );
                        },
                      ),
                      IconButton(
                        icon: const Icon( Icons.autorenew ),
                        onPressed: () {
                          flutterWebViewPlugin.reload( );
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