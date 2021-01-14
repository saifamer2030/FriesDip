import 'package:flutter/material.dart';
import 'package:friesdip/ScreenPage/HomePage.dart';

class ThankYouPage extends StatefulWidget {
  @override
  _ThankYouPageState createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Status'),
      ),
      body: Container(
        padding: EdgeInsets.all(48),
        child: Column(
          children: <Widget>[
            Text('Order has been placed'),
            RaisedButton(
              child: Text('Go Home'),
              onPressed: (){
                Navigator.of(context).pushReplacement( MaterialPageRoute(
                  builder: ( context ) => HomePage()
                ) );
              },
            ),
          ],
        ),
      ),
    );
  }
}
