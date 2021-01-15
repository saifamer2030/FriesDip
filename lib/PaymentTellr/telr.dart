import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friesdip/PaymentTellr/payment_response.dart';
import 'package:friesdip/ScreenPage/paymentCheckOut/my_strings.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';
import 'dart:io' show Platform;


import 'Address.dart';
class Telr {
  static String AUTHKEY = "6tx44-xtmv~RvsVZ";
  static String STOREID = "24923";
  static String publicKey = '10cc319bM\$kmvptP#sh7NX#\$';
  static String paymentUrl = "https://secure.innovatepayments.com/gateway/mobile.xml";
  Map<String, String> paymentHeader = {
    'Content-Type': 'text/xml',
    'Authorization': 'Basic ' + publicKey
  };
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin( );

  TransactionRequest() {
    initPlatformState( );
  }
  Future<String> create(int price, FirebaseUser user, Address  address,var arrange) async {
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
        request.element( 'test', nest: 0 );
        // Transaction type
        request.element( 'type', nest: 'paypage' );
        // Transaction class
        request.element( 'class', nest: 'ecom' );
        // Transaction cart ID'
        if (user != null) {
          request.element( 'cartid', nest: user.uid );
        } else {
          request.element( 'cartid', nest: arrange.toString() );
        }

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
        //  request.element( 'last', nest: name.last );
        } );
        // Email address
        if (user != null) {
          request.element( 'email', nest: user.email );
        } else {
          request.element( 'email', nest: 'user@mail.com' );
        }
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
  Future<PaymentResponse> payForOrder(int price, Address address, FirebaseUser user,var arrange) async {
    String body;
    String payment_id = '147899';
    if (user != null) {
    //  QuerySnapshot querySnapshot = await Firestore.instance.collection('profiles').where('user_id', isEqualTo: user.uid).getDocuments();
    //  payment_id = querySnapshot.documents[0]['payment_id'].toString();
    }
    // test
    body = await this.create( price, user, address,arrange);
    print( body.toString( ) );

    http.Response response = await http.post( paymentUrl, headers: paymentHeader, body: body );
    print( response.statusCode );
    print( response.body );

    switch (response.statusCode) {
      case 200:
        Xml2Json xml2json = new Xml2Json( );
        xml2json.parse( response.body );
        var json = xml2json.toParker( );
// the only method that worked for my XML type.
        var response1 = jsonDecode( json );
        String url = (response1['mobile']['webview']['start'].toString( ));

        if (await canLaunch( url )) {
          await launch( url ,
            forceWebView: true,
            enableJavaScript: true,
            enableDomStorage: true,
          );

        } else {
          throw 'Could not launch $url';
        }
        // return PaymentResponse( response1['start'].toString(), data['source']['id'].toString());
        break;
      default:
        throw Exception( 'Payment failed' );
        break;
    }
  }}
