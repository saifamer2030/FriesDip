import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:friesdip/Classes/sendedorder.dart';
import 'package:friesdip/Classes/sendedorderlist.dart';
import 'package:friesdip/DrawerScreenPage/CustomAppBar.dart';
import 'package:friesdip/DrawerScreenPage/CustomDrawer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:friesdip/Classes/globals.dart' as globals;

class StepperPage extends StatefulWidget {
  StepperPage();

  @override
  _StepperPageState createState() => _StepperPageState();
}

class _StepperPageState extends State<StepperPage> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var _controller = ScrollController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String _error = 'No Error Dectected';
  bool isLoaded = true;
  String _brunchId;
  String _userid, _numberPhone;
  var _orderStatus;
  String _orderId;
  String _numOrder = translator.translate('noOrder');
  String _priceOrder = translator.translate('noOrder');
  String _dateOrder = translator.translate('noOrder');
  bool success = false;
  List<Step> steps = [
    Step(
      title: Text(translator.translate('receivedYourOrder')),
      content: Text(
        translator.translate('beingProcessed'),
        style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontFamily: "Estedad-Black"),
      ),
      isActive: true,
    ),
    Step(
      title: Text(translator.translate('underPreparation')),
      content: Text(
        translator.translate('beingPreparedNow'),
        style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontFamily: "Estedad-Black"),
      ),
      isActive: true,
    ),
    Step(
      title: Text(translator.translate('nowUnderProcessing')),
      content: Text(
        translator.translate('beingProcessedNow'),
        style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontFamily: "Estedad-Black"),
      ),
      isActive: true,
    ),
    Step(
      title: Text(translator.translate('readyForDelivery')),
      content: Text(
        translator.translate('WePreparedYourOrder'),
        style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontFamily: "Estedad-Black"),
      ),
      // state:
      // StepState.complete,
      isActive: true,
    ),
    Step(
      title: Text(translator.translate('Received')),
      content: Text(
        translator.translate('YourRequestHasBeenReceived'),
        style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontFamily: "Estedad-Black"),
      ),
      state:
      StepState.complete,
      isActive: true,
    ),
    Step(
      title: Text(translator.translate('NoReceipt')),
      content: Text(
        translator.translate('TheRequestWasNotReceived'),
        style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontFamily: "Estedad-Black"),
      ),
      state:
      StepState.error,
      isActive: false,

    ),
  ];

  @override
  void initState() {
    super.initState();

    getId();
    getOrderIdBranchId();
    getUserData();

    Future.delayed(Duration(seconds: 3), () async {
      setState(() {
        success = true;
      });
    });
  }

  void getOrderIdBranchId() async {
    FirebaseAuth _firebaseAuth;
    _firebaseAuth = FirebaseAuth.instance;
    final mDatabase = FirebaseDatabase.instance.reference();
    FirebaseUser usr = await _firebaseAuth.currentUser();
    if (usr != null) {
      mDatabase
          .child("OrderIdAndBranchId")
          .child(_userid)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
//        var result = values['rating'].reduce((a, b) => a + b) / values.length;

        if (values != null) {
          /*HelperFunc.showToast("hii ${values['cName']}", Colors.red);
          */
          setState(() {
            _orderId = values['OrderId'].toString();
            _brunchId = values['BranchId'].toString();
//            _brunchId=usr.uid;
          });
          // getData();

          print("####################_orderId :$_orderId");
          print("####################_brunchId :$_brunchId");
          getStatusOrer();
          getOrderListforUser();
        }
      });
    }
  }

  void getUserData() async {
    FirebaseAuth _firebaseAuth;
    _firebaseAuth = FirebaseAuth.instance;
    final mDatabase = FirebaseDatabase.instance.reference();
    FirebaseUser usr = await _firebaseAuth.currentUser();
    if (usr != null) {
      mDatabase
          .child("userdata")
          .child(_userid)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
//        var result = values['rating'].reduce((a, b) => a + b) / values.length;

        if (values != null) {
          /*HelperFunc.showToast("hii ${values['cName']}", Colors.red);
          */
          setState(() {
            _numberPhone = values['cPhone'].toString();
            _brunchId = values['BranchId'].toString();
//            _brunchId=usr.uid;
          });
          // getData();
          print("####################_NumberPhone :$_numberPhone");
        }
      });
    }
  }

  void getStatusOrer() async {
    FirebaseAuth _firebaseAuth;
    _firebaseAuth = FirebaseAuth.instance;
    final mDatabase = FirebaseDatabase.instance.reference();
    FirebaseUser usr = await _firebaseAuth.currentUser();
    if (usr != null) {
      mDatabase
          .child("NotificationStatusOrder")
          .child(_userid)
          .child(_orderId)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
//        var result = values['rating'].reduce((a, b) => a + b) / values.length;

        if (values != null) {
          /*HelperFunc.showToast("hii ${values['cName']}", Colors.red);
          */
          setState(() {
            _orderStatus = values['OrderStatus'];
//            _brunchId=usr.uid;
          });
          // getData();
          print("####################_orderStatus :$_orderStatus");
        }
      });
    }
  }

  void getOrderListforUser() async {
    FirebaseAuth _firebaseAuth;
    _firebaseAuth = FirebaseAuth.instance;
    final mDatabase = FirebaseDatabase.instance.reference();
    FirebaseUser usr = await _firebaseAuth.currentUser();
    if (usr != null) {
      mDatabase
          .child("orderListforUser")
          .child(_userid)
          .child(_orderId)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
//        var result = values['rating'].reduce((a, b) => a + b) / values.length;

        if (values != null) {
          /*HelperFunc.showToast("hii ${values['cName']}", Colors.red);
          */
          setState(() {
            _numOrder = values['carrange'].toString();
            _priceOrder = values['ttprice'].toString();
            _dateOrder = values['cdate'].toString();
//            _brunchId=usr.uid;
          });
          // getData();
          print("####################_numOrder :$_numOrder");
          print("####################_priceOrder :$_priceOrder");
          print("####################_dateOrder :$_dateOrder");
        }
      });
    }
  }

  void getId() async {
    final FirebaseUser user = await auth.currentUser();
    setState(() {
      _userid = user.uid;
    });

    print("############_userid :$_userid");

    // here you write the codes to input the data into firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      navigationBar: CupertinoNavigationBar(
//        middle: Text(translator.translate('OrderTracking')),
//      ),
      appBar: BaseAppBar(
        appBar: AppBar(),
      ),
      drawer: Theme(
          data: Theme.of(context).copyWith(
            // Set the transparency here
            canvasColor: Colors.white10.withOpacity(
                0.8), //or any other color you want. e.g Colors.blue.withOpacity(0.5)
          ),
          child: BaseDrawer()),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        color: Colors.white,
        backgroundColor: Theme.of(context).accentColor,
        child: success
            ? Container(
                child: ListView(
                  physics: BouncingScrollPhysics(),
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        translator.translate('lastOrder'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Estedad-Black',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          translator.translate('numOrder'),
                        ),
                        Text(
                          _numOrder,
                          style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red
                              // color: Colors.green[800]
                              ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          translator.translate('date'),
                        ),
                        Text(
                          _dateOrder,
                          style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red
                              // color: Colors.green[800]
                              ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          translator.translate('price'),
                        ),
                        Text(
                          _priceOrder,
                          style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red
                              // color: Colors.green[800]
                              ),
                        ),
                        Text(translator.translate('SAR'),
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Estedad-Black")),
                      ],
                    ),
                  ),
                  _orderStatus == 5 ?
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: Padding(
                        padding:
                        const EdgeInsets.only(right: 8.0, left: 8.0),
                        child: new RaisedButton(
                          child: new Text(
                            translator.translate('NoReceipt'),
                            style: TextStyle(
                              fontFamily: 'Estedad-Black',
                            ),
                          ),
                          textColor: Colors.white,
                          color: Theme.of(context).accentColor,
                          shape: new RoundedRectangleBorder(
                              borderRadius:
                              new BorderRadius.circular(25.0)),
                          onPressed: () {


                        },
                        ),
                      ),
                    ),
                  ):
                      Container(),
                  _orderStatus == 4 ?
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: Padding(
                        padding:
                        const EdgeInsets.only(right: 8.0, left: 8.0),
                        child: new RaisedButton(
                          child: new Text(
                            translator.translate('Received'),
                            style: TextStyle(
                              fontFamily: 'Estedad-Black',
                            ),
                          ),
                          textColor: Colors.white,
                          color: Theme.of(context).accentColor,
                          shape: new RoundedRectangleBorder(
                              borderRadius:
                              new BorderRadius.circular(25.0)),
                          onPressed: () {


                          },
                        ),
                      ),
                    ),
                  ):
                  Container(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _orderStatus != null && success
                        ? Stepper(
                            currentStep: this._orderStatus,
                            steps: steps,
                            type: StepperType.vertical,
//            onStepTapped: (step) {
//              setState(() {
//                current_step = step;
//              });
//            },
//            onStepContinue: () {
//              setState(() {
//                if (current_step < steps.length - 1) {
//                  current_step = current_step + 1;
//                } else {
//                  current_step = 0;
//                }
//              });
//            },
//            onStepCancel: () {
//              setState(() {
//                if (current_step > 0) {
//                  current_step = current_step - 1;
//                } else {
//                  current_step = 0;
//                }
//              });
//            },
                          )
                        : Center(
                            child: Text(translator.translate('noOrder'),
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Estedad-Black"))),
                  ),
                ],
              ))
            : Center(
                child: Container(
                  child: SpinKitCubeGrid(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> refreshList() async {
    refreshKey.currentState?.show(atTop: false);

    await Future.delayed(Duration(seconds: 2));

    Navigator.pushReplacement(
      context,
      new MaterialPageRoute(
          builder: (BuildContext context) => new StepperPage()),
    );
  }
}
