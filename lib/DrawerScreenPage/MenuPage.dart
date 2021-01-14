import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friesdip/Classes/AllFoodListClass.dart';
import 'package:friesdip/Classes/FoodListClass.dart';
import 'package:friesdip/Classes/ItemFoodClass.dart';
import 'package:friesdip/Classes/OrderItem.dart';
import 'package:friesdip/Classes/database_helper.dart';
import 'package:friesdip/DrawerScreenPage/CustomAppBar.dart';
import 'package:friesdip/DrawerScreenPage/CustomDrawer.dart';
import 'package:friesdip/DrawerScreenPage/OfferPage.dart';
import 'package:friesdip/ScreenPage/HomePage.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class MenuPage extends StatefulWidget {
  MenuPage();

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<ItemFoodClass> fooditemList = [];

  List<FoodListClass> foodList = [];
  var _controller = ScrollController();
  var _controller1 = ScrollController();
  int minarrange = 9000000000000000000;
  String minid;
  DatabaseHelper helper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
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
              // Container(
              //   color: Colors.red.withOpacity(0.6),
              //   height: 50,
              //   child: ListView(
              //     physics: BouncingScrollPhysics(),
              //     scrollDirection: Axis.horizontal,
              //     children: [
              //       Text("data"),
              //       Text("data"),
              //       Text("data"),
              //       Text("data"),
              //       Text("data"),
              //       Text("data"),
              //       Text("data"),
              //     ],
              //   ),
              // ),
              Container(
                color: Colors.black.withOpacity(0.6),
                height: 70,
                child:Center(
                  child: foodList.length == 0
                      ? new Text(
                          translator.translate('wait'),
                          style: TextStyle(color: Colors.white),
                        )
                      : new ListView.builder(
                          controller: _controller,
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          reverse: false,
                          itemCount: foodList.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  foodList[index].colorcheck =
                                      !foodList[index].colorcheck;
                                  if (foodList[index].colorcheck) {
                                    foodList[index].color =
                                        Theme.of(context).accentColor;
                                    for (var i = 0; i < foodList.length; i++) {
                                      if (i != index) {
                                        foodList[i].color = Colors.white;
                                      }
                                    }
                                  } else {
                                    foodList[index].color = Colors.white;
                                  }
                                });
//////////////////////////////////////////////////////////

                                FirebaseDatabase.instance
                                    .reference()
                                    .child("FooditemsList")
                                    .child(foodList[index].id)
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
                                      DATA1[individualkey1]['heckedLarg'],
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
//
//                                         departments1databaseReference =
//                                             FirebaseDatabase.instance;
//                                         departments1databaseReference
//                                             .setPersistenceEnabled(true);
//                                         departments1databaseReference
//                                             .setPersistenceCacheSizeBytes(10000000);
// //                                    final departments1databaseReference =
// //                                        FirebaseDatabase.instance
// //                                            .reference()
// //                                            .child("Departments1")
// //                                            .child(departlist[index].title);
//                                         departments1databaseReference
//                                             .reference()
//                                             .child("Departments1")
//                                             .child(departlist[index].title)
//                                             .once()
//                                             .then((DataSnapshot snapshot) {
//                                           var KEYS = snapshot.value.keys;
//                                           var DATA = snapshot.value;
//                                           //Toast.show("${snapshot.value.keys}",context,duration: Toast.LENGTH_LONG,gravity:  Toast.BOTTOM);
//                                           //   print("kkkk${DATA.toString()}");
//
//                                           for (var individualkey in KEYS) {
//                                             DepartmentClass departmentclass =
//                                             new DepartmentClass(
//                                               DATA[individualkey]['id'],
//                                               DATA[individualkey]['title'],
//                                               DATA[individualkey]['subtitle'],
//                                               DATA[individualkey]['uri'],
//                                               Colors.white,
//                                               false,
//                                               DATA[individualkey]['arrange'],
//                                             );
//                                             setState(() {
//                                               if (DATA[individualkey]['arrange'] ==
//                                                   null)
//                                                 departmentclass = new DepartmentClass(
//                                                   DATA[individualkey]['id'],
//                                                   DATA[individualkey]['title'],
//                                                   DATA[individualkey]['subtitle'],
//                                                   DATA[individualkey]['uri'],
//                                                   const Color(0xff8C8C96),
//                                                   false,
//                                                   100,
//                                                 );
//                                               departlist1.add(departmentclass);
//                                               setState(() {
//                                                 print("size of list : 5");
//                                                 departlist1.sort((depart1, depart2) =>
//                                                     depart1.arrange
//                                                         .compareTo(depart2.arrange));
//                                               });
//                                             });
//                                             // }
//                                           }
//                                         }).whenComplete(() {
//                                           if (departlist[index].title == 'الكل' ||
//                                               departlist1.length == 0) {
//                                             setState(() {
//                                               depart1 = false;
//                                               carcheck=false;
//                                               _indyearcurrentItemSelected="الموديل";
//                                             });
//                                           } else {
//                                             setState(() {
//                                               departlist1.add(new DepartmentClass(
//                                                 "",
//                                                 "اخري",
//                                                 null,
//                                                 "https://firebasestorage.googleapis.com/v0/b/souqnagran-49abe.appspot.com/o/departments1%2Fhiclipart.com%20(10).png?alt=media&token=7ea64e1a-5170-45ef-bca0-e6adf272dead",
//                                                 const Color(0xff8C8C96),
//                                                 false,
//                                                 100,
//                                               ));
//                                               depart1 = true;
//                                               if(departlist[index].title == 'السيارات'){
//                                                 setState(() {
//                                                   carcheck=true;
//                                                 });
//                                               }else{
//                                                 setState(() {
//                                                   carcheck=false;
//                                                   _indyearcurrentItemSelected="الموديل";
//                                                 });
//                                               }
//                                             });
//                                           }
//                                         }).catchError(() {
//                                           if (departlist[index].title == 'الكل' ||
//                                               departlist1.length == 0) {
//                                             setState(() {
//                                               depart1 = false;
//                                               carcheck=false;
//                                               _indyearcurrentItemSelected="الموديل";
//                                             });
//                                           } else {
//                                             setState(() {
//                                               depart1 = true;
//                                               if(departlist[index].title == 'السيارات'){
//                                                 setState(() {
//                                                   carcheck=true;
//                                                 });
//                                               }else{
//                                                 setState(() {
//                                                   carcheck=false;
//                                                   _indyearcurrentItemSelected="الموديل";
//                                                 });
//                                               }
//                                             });
//                                           }
//                                         });

                                /////////////////////////////////////////////////////////
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 15, left: 15, top: 15),
                                child: Text(
                                  translator.currentLanguage == 'ar'
                                      ? foodList[index].ar_title
                                      : foodList[index].en_title,
                                  style: TextStyle(
                                    fontFamily: 'Estedad-Black',
                                    fontSize: 15,
                                    color: foodList[index].color,
                                    //height: 0.7471466064453125,
                                  ),
                                ),
                              ),
                            );
                          }),
                )
                ,
              ),
              Expanded(
                  child: fooditemList.length == 0
                      ? Center(
                          child: new Text(
                          translator.translate('wait'),
                        ))
                      : new ListView.builder(
                          physics: BouncingScrollPhysics(),
                          controller: _controller1,
                          itemCount: fooditemList.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return firebasedata(
                              index,
                            );
                          }
                          )
              ),
            ],
          ),
        ));
  }

  void getData() {
    FirebaseDatabase.instance
        .reference()
        .child("FoodList")
        .once()
        .then((DataSnapshot snapshot) {
      var KEYS = snapshot.value.keys;
      var DATA = snapshot.value;
      // print("${snapshot.value}hhh");

      foodList.clear();
      for (var individualkey in KEYS) {
        FoodListClass foodclass = new FoodListClass(
          DATA[individualkey]['id'],
          DATA[individualkey]['ar_title'],
          DATA[individualkey]['en_title'],
          DATA[individualkey]['arrange'],
          Colors.white,
          false,
        );
        if (DATA[individualkey]['arrange'] < minarrange) {
          minid = DATA[individualkey]['id'];
          minarrange = DATA[individualkey]['arrange'];
        }
        print("${DATA[individualkey]['id']}hhh");
        setState(() {
          foodList.add(foodclass);
          setState(() {
//            print("size of list : 5");
            foodList.sort((fl1, fl2) => fl1.arrange.compareTo(fl2.arrange));
          });
        });
      }
      // foodList.where((arrange) {arrange==minarrange;}) ;
    }).whenComplete(() {
      getinitdata();
    });
  }

  Widget firebasedata(var index) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
          child: Center(
            child: Card(
              shape: new RoundedRectangleBorder(
                  side: new BorderSide(
                      color: Colors.grey,
                      //color: subfaultsList[index].ccolor,
                      width: 1.0),
                  borderRadius: BorderRadius.circular(10.0)),
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
                        child: Text(
                          fooditemList[index].heckedNo
                              ? "${fooditemList[index].price_no}"
                              : fooditemList[index].heckedSmall
                                  ? "${fooditemList[index].price_small}"
                                  : fooditemList[index].heckedMed
                                      ? "${fooditemList[index].price_mid}"
                                      : "${fooditemList[index].price_large}",
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
                        top: 10, bottom: 10, left: 10, right: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 35,
                      child: new RaisedButton(
                        child:
                            new Text(translator.translate('AddAndCustomize')),
                        textColor: Colors.white,
                        color: Theme.of(context).accentColor,
                        //BC0C0C
                        onPressed: () {
                          print("hhhhh1");
                          Future.delayed(Duration(seconds: 0), () async {
                            OrderItem orderitem = OrderItem(
                                fooditemList[index].id,
                                fooditemList[index].title_ar,
                                fooditemList[index].title_en,
                                fooditemList[index].details_ar,
                                fooditemList[index].details_en,
                                fooditemList[index].heckedNo
                                    ? "${fooditemList[index].price_no}"
                                    : fooditemList[index].heckedSmall
                                        ? "${fooditemList[index].price_small}"
                                        : fooditemList[index].heckedMed
                                            ? "${fooditemList[index].price_mid}"
                                            : "${fooditemList[index].price_large}",
                                fooditemList[index].price_no,
                                fooditemList[index].price_small,
                                fooditemList[index].price_mid,
                                fooditemList[index].price_large,
                                fooditemList[index].url == null ||
                                        fooditemList[index].url == ""
                                    ? "a"
                                    : fooditemList[index].url,
                                fooditemList[index].mid,
                                fooditemList[index].mtitle_ar,
                                fooditemList[index].mtitle_en,
                                fooditemList[index].heckedNo ? 1 : 0,
                                fooditemList[index].heckedSmall ? 1 : 0,
                                fooditemList[index].heckedMed ? 1 : 0,
                                fooditemList[index].heckedLarg ? 1 : 0,
                                fooditemList[index].heckedNo
                                    ? int.parse(fooditemList[index].price_no)
                                    : fooditemList[index].heckedSmall
                                        ? int.parse(
                                            fooditemList[index].price_small)
                                        : fooditemList[index].heckedMed
                                            ? int.parse(
                                                fooditemList[index].price_mid)
                                            : int.parse(fooditemList[index]
                                                .price_large),
                                1,
                                fooditemList[index].heckedNo?0:5);//new for size
                            //  print("hhhhh2");
/*
        fooditemList[index].heckedNo? int.parse(fooditemList[index].price_no):fooditemList[index].heckedSmall?int.parse(fooditemList[index].price_small:fooditemList[index].heckedMed? int.parse(fooditemList[index].price_mid:int.parse(fooditemList[index].price_large,

fooditemList[index].heckedNo?
                      "${fooditemList[index].price_no}":fooditemList[index].heckedSmall? "${fooditemList[index].price_small}":fooditemList[index].heckedMed? "${fooditemList[index].price_mid}":"${fooditemList[index].price_large}",

* */
                            if (await helper.inCart(orderitem)) {
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
                            } else {
                              // print("kkkkkkk");

                              helper.insertOrder(orderitem).whenComplete(() {
                                setState(() {
                                  Fluttertoast.showToast(
                                      msg: translator.translate('add_cart'),
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white);
                                });
                              });

                              if (await helper.inCart(orderitem)) {
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
                              } else {
                                // print("kkkkkkk");

                                helper.insertOrder(orderitem).whenComplete(() {
                                  setState(() {
                                    Fluttertoast.showToast(
                                        msg: translator.translate('add_cart'),
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white);
                                  });
                                });
                              } // print("kkkkkkkkkkkkk$a");
                            }
                          });
                        },
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
                  padding: const EdgeInsets.only(top: 130),
                  child: Container(
//                      height: 50,
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          translator.currentLanguage == 'ar'
                              ? fooditemList[index].details_ar
                              : fooditemList[index].details_en,
                          style: TextStyle(
                            fontFamily: 'Estedad-Black',
                            fontSize: 13,
                            color: Colors.white,
                            //height: 0.7471466064453125,
                          ),
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
        .child("FooditemsList")
        .child(minid)
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
          DATA1[individualkey1]['heckedLarg'],
        );
        print("${DATA1[individualkey1]['id']}hhh");

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
