

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:friesdip/DrawerScreenPage/CustomAppBar.dart';
import 'package:friesdip/PaymentTellr/payment_card.dart'as PaymentCard;
import 'package:friesdip/PaymentTellr/payment_response.dart';
import 'package:friesdip/PaymentTellr/telr.dart';

import 'Address.dart';

class TelrPage extends StatefulWidget {
  //final List<Product> products;
  final double total;

  TelrPage( this.total);

  @override
  _TelrPageState createState() => _TelrPageState();
}

class _TelrPageState extends State<TelrPage> {
   num position = 1 ;

  bool _loading = false;
  String _errorMessage = '';
  bool _hasError = false;
  var _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }
   InAppWebViewController _webViewController;

   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       home: Scaffold(
         body: Container(
             child: Column(children: <Widget>[
               Expanded(
                 child:InAppWebView(
                 //  initialData: InAppWebViewInitialData( data: ),
                   initialOptions: InAppWebViewGroupOptions(
                       crossPlatform: InAppWebViewOptions( debuggingEnabled: true, )
                   ),
                   onWebViewCreated: (InAppWebViewController controller) {
                     _webViewController = controller;
                     _webViewController.addJavaScriptHandler(handlerName:'handlerFoo', callback: (args) {
                       return {'bar': 'bar_value', 'baz': 'baz_value'};
                     });

                     _webViewController.addJavaScriptHandler(handlerName: 'handlerFooWithArgs', callback: (args) {
                       print(args);
                     });
                   },
                   onConsoleMessage: (controller, consoleMessage) {
                     print(consoleMessage);
                   },
                 ),
               ),
             ])),
       ),
     );
   }

/*    return Scaffold(
      appBar: BaseAppBar(
        appBar: AppBar(),
      ),
      body: Column(
        children: <Widget>[

          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              'Total: \$${widget.total.toString()}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  WebView(
                    initialUrl: 'https://google.com',
                    javascriptMode: JavascriptMode.unrestricted,
                    onPageStarted: (value){setState(() {
                      position = 1;
                    });},
                    onPageFinished: (value){setState(() {
                      position = 0;
                    });},
                  ),

                  Container(
                    child: Center(
                        child: CircularProgressIndicator()),
                  ),

           *//*       SizedBox(
                    height: 24,
                  ),
                  RaisedButton(
                    child: _loading
                        ? CircularProgressIndicator()
                        : Text('PLACE ORDER NOW'),
                    onPressed: () async {
                      if (!_loading) {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _loading = true;
                          });

                        }
                      }
                    },
                  ),*//*
                ],
              ),
            ),
          ),
        ],
      ),
    );*/

}
