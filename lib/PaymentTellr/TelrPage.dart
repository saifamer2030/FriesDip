

import 'package:flutter/material.dart';
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
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _cardExpiryMonth = TextEditingController();
  TextEditingController _cardExpiryYear = TextEditingController();
  TextEditingController _cardcvv = TextEditingController();

  bool _loading = false;
  String _errorMessage = '';
  bool _hasError = false;
  var _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cardExpiryMonth.dispose();
    _cardExpiryYear.dispose();
    _cardNumberController.dispose();
    _cardcvv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                /*  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _cardNumberController,
                    decoration: InputDecoration(hintText: 'Card Number'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your card number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _cardExpiryMonth,
                    decoration: InputDecoration(hintText: 'Expiry Month'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your card expiry month';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _cardExpiryYear,
                    decoration: InputDecoration(hintText: 'Expiry Year'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your card expiry year';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _cardcvv,
                    decoration: InputDecoration(hintText: 'cvv'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your card cvv';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  _hasError ? Text(_errorMessage) : Container(),*/
                  SizedBox(
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
