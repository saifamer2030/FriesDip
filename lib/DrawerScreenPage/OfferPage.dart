import 'dart:math' show cos, sqrt, asin;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friesdip/Classes/BranchListClass.dart';
import 'package:friesdip/Classes/ItemFoodClass.dart';
import 'package:friesdip/Classes/OrderItem.dart';
import 'package:friesdip/Classes/database_helper.dart';
import 'package:friesdip/DrawerScreenPage/CustomAppBar.dart';
import 'package:friesdip/DrawerScreenPage/CustomDrawer.dart';
import 'package:friesdip/DrawerScreenPage/MenuPage.dart';
import 'package:friesdip/ScreenPage/HomePage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:friesdip/Classes/globals.dart' as globals;

class OfferPage extends StatefulWidget {
  //String logourl;

  OfferPage();

  @override
  _OfferPageState createState() => _OfferPageState();
}

class _OfferPageState extends State<OfferPage> {
  List<ItemFoodClass> fooditemList = [];

  List<BranchListClass> BranchList = [];
  var _controller = ScrollController();
  var _controller1 = ScrollController();
  double minarrange = 9000000000000000000.0;
  String minid;
  String minbranch_ar;
  String minbranch_en;
  DatabaseHelper helper = DatabaseHelper();
  String selected_branch_en,selected_branch_ar;
  @override
  void initState() {
    super.initState();
    print("globals.lat==${globals.lat_gps}");
    print("globals.long==${globals.long_gps}");
    setState(() {
      selected_branch_ar=globals.branch_name_ar;
      selected_branch_en=globals.branch_name_en;
    });

    getData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        drawer: Theme(
            data: Theme.of(context).copyWith(
              // Set the transparency here
              canvasColor: Colors.white10.withOpacity(
                  0.8), //or any other color you want. e.g Colors.blue.withOpacity(0.5)
            ),
            child: BaseDrawer()),
        appBar: BaseAppBar(
          appBar: AppBar(),
        ),
        body: Container(
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                color: Colors.black.withOpacity(0.6),
                height: 70,
                child: Center(
                  child: BranchList.length == 0
                      ? new Text(translator.translate('wait'),style: TextStyle(color: Colors.white),)
                      : new ListView.builder(
                          controller: _controller,
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          reverse: false,
                          itemCount: BranchList.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  BranchList[index].colorcheck =
                                      !BranchList[index].colorcheck;
                                  setState(() {
                                    selected_branch_ar=BranchList[index].ar_title;
                                    selected_branch_en=BranchList[index].en_title;
                                  });
                                  if (BranchList[index].colorcheck) {
                                    BranchList[index].color =
                                        Theme.of(context).accentColor;
                                    for (var i = 0;
                                        i < BranchList.length;
                                        i++) {
                                      if (i != index) {
                                        BranchList[i].color = Colors.white;
                                      }
                                    }
                                  } else {
                                    BranchList[index].color = Colors.white;
                                  }
                                });
//////////////////////////////////////////////////////////

                                FirebaseDatabase.instance
                                    .reference()
                                    .child("offersList")
                                    .child(BranchList[index].id)
                                    .once()
                                    .then((DataSnapshot snapshot1) {
                                  var KEYS1 = snapshot1.value.keys;
                                  var DATA1 = snapshot1.value;
                                  setState(() {
                                    fooditemList.clear();
                                  });
                                  fooditemList.clear();
                                  for (var individualkey1 in KEYS1) {
                                    ItemFoodClass foodclass = new ItemFoodClass(
                                      DATA1[individualkey1]['id'],
                                      DATA1[individualkey1]['title_ar'],
                                      DATA1[individualkey1]['title_en'],
                                      DATA1[individualkey1]['details_ar'],
                                      DATA1[individualkey1]['details_en'],
                                        DATA1[individualkey1]['price_no'],
                                        DATA1[individualkey1]['price_small'],
                                        DATA1[individualkey1]['price_mid'],
                                        DATA1[individualkey1]['price_large'],
                                        DATA1[individualkey1]['url'],
                                      DATA1[individualkey1]['arrange'],
                                      false,
                                      DATA1[individualkey1]['mid'],
                                      DATA1[individualkey1]['mtitle_ar'],
                                      DATA1[individualkey1]['mtitle_en'],

                                        DATA1[individualkey1]['heckedNo'],
                                        DATA1[individualkey1]['heckedSmall'],
                                        DATA1[individualkey1]['heckedMed'],
                                        DATA1[individualkey1]['heckedLarg']
                                    );
                                    print("${DATA1[individualkey1]['id']}hhh");

                                    setState(() {
                                      fooditemList.add(foodclass);
                                      setState(() {
//            print("size of list : 5");
                                        fooditemList.sort((fl1, fl2) =>
                                            fl2.arrange.compareTo(fl1.arrange));
                                      });
                                    });
                                    // }
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 15, left: 15, top: 15),
                                child: Text(
                                  translator.currentLanguage == 'ar'
                                      ? BranchList[index].ar_title
                                      : BranchList[index].en_title,
                                  style: TextStyle(
                                    fontFamily: 'Estedad-Black',
                                    fontSize: 15,
                                    color: BranchList[index].color,
                                    //height: 0.7471466064453125,
                                  ),
                                ),
                              ),
                            );
                          }),
                )),

              Container(
                  color: Theme.of(context).accentColor,
                  height: 30,
                  child:Padding(
                    padding: const EdgeInsets.only(left:8.0,right: 8.0, bottom: 5,top:5),
                    child: Text(
                        translator.currentLanguage == 'ar'
                            ? selected_branch_ar
                            : selected_branch_en,
                      style: TextStyle(
                      fontFamily: 'Estedad-Black',
                      fontSize: 13,
                      color: Colors.white,
                      //height: 0.7471466064453125,
                    ),
                        ),
                  )),

              Expanded(
                  child: fooditemList.length == 0
                      ? Center(child: new Text(translator.translate('wait')))
                      : new ListView.builder(
                          physics: BouncingScrollPhysics(),
                          controller: _controller1,
                          itemCount: fooditemList.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return firebasedata(
                              index,
                            );
                          })),
            ],
          ),
        )
//      Container(
//        width: double.infinity,
//        child: Center(
//          child: Text(
//            translator.translate('textArea'),
//            textAlign: TextAlign.center,
//            style: TextStyle(fontSize: 35),
//          ),
//        ),
//      ),
        );
  }

  void getData() {
    FirebaseDatabase.instance
        .reference()
        .child("branchList")
        .once()
        .then((DataSnapshot snapshot) async {
      var KEYS = snapshot.value.keys;
      var DATA = snapshot.value;
      // print("${snapshot.value}hhh");

      BranchList.clear();
      for (var individualkey in KEYS) {
        BranchListClass branchclass = new BranchListClass(
          DATA[individualkey]['id'],
          DATA[individualkey]['ar_title'],
          DATA[individualkey]['en_title'],
          DATA[individualkey]['arrange'],
          Colors.white,
          false,
          DATA[individualkey]['starttime'],
          DATA[individualkey]['endtime'],
          DATA[individualkey]['lat'],
          DATA[individualkey]['long'],
          DATA[individualkey]['address'],
          true,0.0,
            false,
          Colors.white,
        );

        try {
          List<Placemark> p = await Geolocator().placemarkFromCoordinates(
              double.parse(DATA[individualkey]['lat']),
              double.parse(DATA[individualkey]['long']));

////////////***************
          double lat2=double.parse(DATA[individualkey]['lat']);
          double  lon2= double.parse(DATA[individualkey]['long']);
          double lat1=globals.lat_gps;
          double  lon1= globals.long_gps;

          // print("globals.lat==${globals.lat_gps}");
          // print("globals.long==${globals.long_gps}");

          var pi = 0.017453292519943295;
          var c = cos;
          var a = 0.5 -
              c((lat2 - lat1) * pi) / 2 +
              c(lat1 * pi) * c(lat2 * pi) * (1 - c((lon2 - lon1) * pi)) / 2;
          double distance= 12742 * asin(sqrt(a));

          ////////////***********
          Placemark place = p[0];
          String name = place.name;
          String subLocality = place.subLocality;
          String locality = place.locality;
          String administrativeArea = place.administrativeArea;
          String postalCode = place.postalCode;
          String country = place.country;
          setState(() {
            BranchList.add(new BranchListClass(
              DATA[individualkey]['id'],
              DATA[individualkey]['ar_title'],
              DATA[individualkey]['en_title'],
              DATA[individualkey]['arrange'],
              Colors.white,
              false,
              DATA[individualkey]['starttime'],
              DATA[individualkey]['endtime'],
              DATA[individualkey]['lat'],
              DATA[individualkey]['long'],
              "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}",
              true,
              distance,
              false,
              Colors.white,
            ));
            print("bbbb1${DATA[individualkey]['id']}");
            if (distance < minarrange) {
              minid = DATA[individualkey]['id'];
              minarrange = distance;
              minbranch_ar=DATA[individualkey]['ar_title'];
              minbranch_en=DATA[individualkey]['en_title'];
            }
            setState(() {
              BranchList.sort((fl1, fl2) => fl1.distance.compareTo(fl2.distance));
            });
          });

          // setState(() {
          //   _currentAddress =
          //   "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";
          //
          // });
        } catch (e) {
          setState(() {
            BranchList.add(new BranchListClass(
              DATA[individualkey]['id'],
              DATA[individualkey]['ar_title'],
              DATA[individualkey]['en_title'],
              DATA[individualkey]['arrange'],
              Colors.white,
              false,
              DATA[individualkey]['starttime'],
              DATA[individualkey]['endtime'],
              DATA[individualkey]['lat'],
              DATA[individualkey]['long'],
              DATA[individualkey]['address'],
              true,
              0.0,
              false,
              Colors.white,
            ));
            setState(() {
              BranchList.sort((fl1, fl2) => fl2.distance.compareTo(fl1.distance));
            });
          });
        }


        //print("${ DATA[individualkey]['id']}hhh");

//         setState(() {
//           BranchList.add(branchclass);
//           setState(() {
// //            print("size of list : 5");
//             BranchList.sort((fl1, fl2) => fl1.arrange.compareTo(fl2.arrange));
//           });
//         });
        // }
      }
    }).whenComplete(() {
      if(selected_branch_ar==''){
        setState(() {
          selected_branch_ar=minbranch_ar;
        });

        }
      if(selected_branch_en==''){
        setState(() {
          selected_branch_en=minbranch_en;
        });
             }
      getinitdata();
    });
    ;
  }

  Widget firebasedata(var index) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
          child: Center(
            child: Container(
//                shape: new RoundedRectangleBorder(
//                    side: new BorderSide(
//                        color: Colors.grey,
//                        //color: subfaultsList[index].ccolor,
//                        width: 1.0),
//                    borderRadius: BorderRadius.circular(1.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    translator.currentLanguage == 'ar'
                        ? fooditemList[index].title_ar
                        : fooditemList[index].title_en,
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Estedad-Black"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          translator.translate('price'),
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Estedad-Black"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child:Text(fooditemList[index].heckedNo?
                      "${fooditemList[index].price_no}":fooditemList[index].heckedSmall? "${fooditemList[index].price_small}":fooditemList[index].heckedMed? "${fooditemList[index].price_mid}":"${fooditemList[index].price_large}",
                        style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Estedad-Black"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          translator.translate('SAR'),
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Estedad-Black"),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          fooditemList[index].animation =
                              !fooditemList[index].animation;
                          // for (var i = 0;i < foodList.length;i++) {
                          //   if (i != index) {
                          //     foodList[index].animation=false;
                          //   }
                          // }
                        });
                      },
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: fooditemList[index].url == null
                            ? BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/food.png'),
                                  fit: BoxFit.fill,
                                ),
                              )
                            : BoxDecoration(
                                image: DecorationImage(
                                image: NetworkImage(fooditemList[index].url),
                                fit: BoxFit.fill,
                              )),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 15, right: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height:  35,
                      child: new RaisedButton(

                        child: new Text(
                          translator.translate('AddAndCustomize'),
                          style: TextStyle(
//                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Estedad-Black"),
                        ),

                        textColor: Colors.white,
                        color: Theme.of(context).accentColor,
                        //BC0C0C
                        onPressed: () {
                          print("oooo");
                          Future.delayed(Duration(seconds: 0), () async {
                            OrderItem orderitem= OrderItem(
                                fooditemList[index].id,
                                fooditemList[index].title_ar,
                                fooditemList[index].title_en,
                                fooditemList[index].details_ar,
                                fooditemList[index].details_en,
                                fooditemList[index].heckedNo?"${fooditemList[index].price_no}":fooditemList[index].heckedSmall? "${fooditemList[index].price_small}":fooditemList[index].heckedMed? "${fooditemList[index].price_mid}":"${fooditemList[index].price_large}",
                                fooditemList[index].price_no,
                                fooditemList[index].price_small,
                                fooditemList[index].price_mid,
                                fooditemList[index].price_large,
                                fooditemList[index].url==null|| fooditemList[index].url==""?"a":fooditemList[index].url,
                                fooditemList[index].mid,
                                fooditemList[index].mtitle_ar,
                                fooditemList[index].mtitle_en,
                                fooditemList[index].heckedNo?1:0,
                                fooditemList[index].heckedSmall?1:0,
                                fooditemList[index].heckedMed?1:0,
                                fooditemList[index].heckedLarg?1:0,
                                fooditemList[index].heckedNo? int.parse(fooditemList[index].price_no):fooditemList[index].heckedSmall? int.parse(fooditemList[index].price_small):fooditemList[index].heckedMed? int.parse(fooditemList[index].price_mid): int.parse(fooditemList[index].price_large),
                                1,0

                            );
                            //  print("hhhhh2");

                            if(await helper.inCart(orderitem)){

                              Fluttertoast.showToast(
                                  msg: translator.translate('exist_cart'),
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white);
                              // helper.updateOrder(orderitem).whenComplete(() {
                              // setState(() {
                              // });
                              //
                              //
                              // });
                            }else{
                              // print("kkkkkkk");

                              helper.insertOrder(orderitem).whenComplete(() {
                                setState(() {Fluttertoast.showToast(
                                    msg: translator.translate('add_cart'),
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white);});
                              });


                            }// print("kkkkkkkkkkkkk$a");

                          });                        },
//
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(5.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        fooditemList[index].animation
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 130, left: 18.0),
                  child: Container(
                    height: 50,
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Text(
                        translator.currentLanguage == 'ar'
                            ? fooditemList[index].details_ar
                            : fooditemList[index].details_en,
                        style: TextStyle(
                          fontFamily: 'Estedad-Black',
                          fontSize: 15,
                          color: Colors.white,
                          //height: 0.7471466064453125,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  void getinitdata() {
    FirebaseDatabase.instance
        .reference()
        .child("offersList")
        .child(globals.branch_id==""?minid:globals.branch_id)
        .once()
        .then((DataSnapshot snapshot1) {
      var KEYS1 = snapshot1.value.keys;
      var DATA1 = snapshot1.value;

      fooditemList.clear();
      for (var individualkey1 in KEYS1) {
        ItemFoodClass foodclass = new ItemFoodClass(
          DATA1[individualkey1]['id'],
          DATA1[individualkey1]['title_ar'],
          DATA1[individualkey1]['title_en'],
          DATA1[individualkey1]['details_ar'],
          DATA1[individualkey1]['details_en'],
            DATA1[individualkey1]['price_no'],
            DATA1[individualkey1]['price_small'],
            DATA1[individualkey1]['price_mid'],
            DATA1[individualkey1]['price_large'],
            DATA1[individualkey1]['url'],
          DATA1[individualkey1]['arrange'],
          false,
          DATA1[individualkey1]['mid'],
          DATA1[individualkey1]['mtitle_ar'],
          DATA1[individualkey1]['mtitle_en'],

            DATA1[individualkey1]['heckedNo'],
            DATA1[individualkey1]['heckedSmall'],
            DATA1[individualkey1]['heckedMed'],
            DATA1[individualkey1]['heckedLarg']
        );
      //  print("${DATA1[individualkey1]['id']}hhh");

        setState(() {
          fooditemList.add(foodclass);
          setState(() {
//            print("size of list : 5");
            fooditemList.sort((fl1, fl2) => fl2.arrange.compareTo(fl1.arrange));
          });
        });
        // }
      }
    });
  }
}
