/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:friesdip/PaymentTellr/payable.dart';
import 'package:friesdip/PaymentTellr/payment_card.dart' as PaymentCard;
import 'package:friesdip/PaymentTellr/payment_response.dart';
import 'package:friesdip/PaymentTellr/telr.dart';
import 'Address.dart';

import 'Name.dart';
import 'payment_card.dart';

class PaymentController {
  Payable paymentGateway;

  PaymentController(this.paymentGateway);

  Future<PaymentResponse> payForOrder(double price, {PaymentCard.PaymentCard card, FirebaseUser user, Address address, Name name,}) async {
    PaymentResponse paymentResponse;
    if (this.paymentGateway is telr) {
   */
/* if( paymentCard != null ){
      paymentResponse = await this.paymentGateway.payForOrder(price, paymentCard: paymentCard );
    }*//*

    if( user != null ){
      paymentResponse = await this.paymentGateway.payForOrder(price, user: user );
    }

    if( paymentResponse.status == 'Authorized' ){
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      Firestore.instance.collection('profiles').where( 'user_id' , isEqualTo: user.uid ).getDocuments().then(( QuerySnapshot document) {
        Firestore.instance.collection('profiles').document(document.documents[0].documentID).updateData({
          'payment_id' : paymentResponse.id
        }).then((value) {
          return paymentResponse;
        });
      } );
    }else{
      throw Exception('Payment Error');
    }

      } */
/*else if( this.paymentGateway is CashOnDelivery ) {
      paymentResponse = await this.paymentGateway.payForOrder(amount);
    }*//*

    print(paymentResponse.status);
    return paymentResponse;
  }

}*/
