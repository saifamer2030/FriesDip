import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friesdip/Classes/BranchListClass.dart';
import 'package:friesdip/Classes/FoodListClass.dart';
import 'package:friesdip/Classes/ItemFoodClass.dart';
import 'package:friesdip/ScreenPage/cur_loc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:time_range/time_range.dart';
import 'package:toast/toast.dart';
import 'package:translator/translator.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:friesdip/Classes/globals.dart' as globals;

import '../DrawerScreenPage/CustomAppBar.dart';
import '../DrawerScreenPage/MenuPage.dart';

class BranchesUsers extends StatefulWidget {
  BranchesUsers();

  @override
  _BranchesUsersState createState() => _BranchesUsersState();
}

class _BranchesUsersState extends State<BranchesUsers> {
  Completer<GoogleMapController> _mapcontroller = Completer();
  double zoomVal = 0.5;
  String _cName;
  final Set<Marker> _markers = {};


  List<BranchListClass> BranchList = [];
  List<BranchListClass> SearchList = [];
  List<BranchListClass> costantList = [];
  BitmapDescriptor icon;
  var _controller = ScrollController();
  String selectedbranch_ar="";
  String selectedbranch_en="";

  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  bool isLoaded = true;
  String url, id;
  var i;
  bool _load2 = false;
  TextEditingController searchcontroller = TextEditingController();
  void filterSearchResults(String filtter) {

    SearchList.clear();
    SearchList.addAll(BranchList);
    if ((filtter == '') ) {
      setState(() {
        BranchList.clear();
        BranchList.addAll(costantList);
      });
      return;
    } else {


      setState(() {
        List<BranchListClass> ListData = [];
        SearchList.forEach((item) {
          if (item.address.toString().contains(filtter) ||item.ar_title.toString().contains(filtter)||item.en_title.toString().contains(filtter)
          ) {
            ListData.add(item);
          }
        });
        setState(() {
          BranchList.clear();
          BranchList.addAll(ListData);
        });
        return;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    globals.deliverycheck = false;
    icon =  BitmapDescriptor.defaultMarker;
    getData();

  }

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator = _load2
        ? new Container(
            child: SpinKitCircle(
              color: Theme.of(context).accentColor,
            ),
          )
        : new Container();
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: BaseAppBar(
          appBar: AppBar(),
        ),
        body: Stack(
          children: [
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // width: 210,
                    height: 30,
                    margin: EdgeInsets.only(left: 2),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(97, 248, 248, 248),
                      border: Border.all(
                        width: 1,
                        color: Colors.lightBlue//Theme.of(context).accentColor,
                      ),
                      borderRadius:
                      BorderRadius.all(Radius.circular(10)),
                    ),

                    child: Container(
                        height: 13,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextField(
                            style: TextStyle(color: Colors.black),
                            onChanged: (value) {
                              setState(() {
                                filterSearchResults(value);
                              });
                            },
                            controller: searchcontroller,
                            // focusNode: focus,
                            decoration: InputDecoration(
                              labelText: searchcontroller.text.isEmpty
                                  ? translator.translate('branch_name')
                                  : '',
                              labelStyle: TextStyle(
                                  color: Colors.black, fontSize: 18.0),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              suffixIcon:
                              searchcontroller.text.isNotEmpty
                                  ? IconButton(
                                icon: Icon(Icons.cancel,
                                    color: Colors.black),
                                onPressed: () {
                                  setState(() {
                                    searchcontroller.clear();

                                    setState(() {
                                      filterSearchResults('');
                                    });
                                  });
                                },
                              )
                                  : null,
                              errorStyle: TextStyle(color: Colors.blue),
                              enabled: true,
                              alignLabelWithHint: true,
                            ),
                          ),
                        )),

                  ),
                ),
                Card(
                  color: Colors.grey,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 0.0, left: 0.0, right: 0.0, bottom: 0.0),
                    child: ExpansionTile(
                      title: Container(color:Colors.grey,child: Text(translator.translate('search_map'))),//backgroundColor: Colors.black,
                      children: <Widget>[
                        _googleMap(context),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: isLoaded
                      ? BranchList.length == 0
                      ? Center(
                      child: Text(
                        translator.translate('no_data'),
                      ))
                      : listView()
                      : Center(
                    child: SpinKitFadingCircle(
                      itemBuilder: (_, int index) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                              color: index.isEven
                                  ? Colors.orange
                                  : Colors.white),
                        );
                      },
                    ),
                  ),
                ),
                (selectedbranch_ar==""||selectedbranch_en=="" )? Container(): Container(
//              width: MediaQuery.of(context).size.width,
//              height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
//                  OutlineButton(
//                    onPressed: () {
//                      translator.setNewLanguage(
//                        context,
//                        newLanguage:
//                            translator.currentLanguage == 'ar' ? 'en' : 'ar',
//                        remember: true,
//                        restart: true,
//                      );
//                    },
//                    child: Text(translator.translate('buttonTitle')),
//                  ),
//                  OutlineButton(
//                    onPressed: () {
//                      translator.setNewLanguage(
//                        context,
//                        newLanguage:
//                            translator.currentLanguage == 'ar' ? 'en' : 'ar',
//                        remember: true,
//                        restart: true,
//                      );
//                    },
//                    child: Text(translator.translate('buttonTitle')),
//                  ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20,bottom: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width-10,
                            height: 50,
                            child: new RaisedButton(
                              child: new Text(translator.translate('pickup')),
                              textColor: Colors.white,
                              color: Theme.of(context).accentColor,
                              //BC0C0C
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MenuPage()));
                              },
//
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 20),
//                           child: Container(
//                             width: (MediaQuery.of(context).size.width/2)-5,
//                             height: 50,
//                             child: new RaisedButton(
//                               child: new Text(translator.translate('deliver_car')),
//                               textColor: Colors.white,
//                               color: Theme.of(context).accentColor,
//                               onPressed: () {
//
//                               },
// //
//                               shape: new RoundedRectangleBorder(
//                                   borderRadius: new BorderRadius.circular(10.0)),
//                             ),
//                           ),
//                         ),
                      ],
                    ),
                  ),
                )

              ],
            ),
            new Align(
              child: loadingIndicator,
              alignment: FractionalOffset.center,
            ),
          ],
        )
    );
  }

///////////********* Design *****////////////////////////////


  Widget listView() {
    return Column(
      children: <Widget>[

        Expanded(
            child: new ListView.builder(
                physics: BouncingScrollPhysics(),
                controller: _controller,
                itemCount: BranchList.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return InkWell(
                    onTap: () {
                     // setState(() {
                        setState(() {
                          if(  BranchList[index].distance<20.0 ){
                            if(BranchList[index].open){
                          BranchList[index].saved =   ! BranchList[index].saved;
                          if (BranchList[index].saved) {
                            setState(() {
                              BranchList[index].colorsaved = Colors.grey[300];
                              BranchList[index].saved = true;
                              selectedbranch_ar=BranchList[index].ar_title;
                              selectedbranch_en=BranchList[index].en_title;

                              globals.branch_lat = double.parse(BranchList[index].lat);
                              globals.branch_long = double.parse(BranchList[index].long);
                              globals.branch_name_ar = selectedbranch_ar;
                              globals.branch_name_en =selectedbranch_en;
                              globals.branch_id= BranchList[index].id;

                                  Fluttertoast.showToast(
                                  msg:( translator.currentLanguage == 'ar' ? BranchList[index].ar_title: BranchList[index].en_title)+" "+translator.translate('saved')  ,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white);


                            });
                            for (var i = 0; i < BranchList.length; i++) {
                              if (i != index){
                                setState(() {
                                  BranchList[i].colorsaved = Colors.white;
                                });
                              }
                                //print("hhhh$i");

                            }
                          } else {
                            setState(() {
                              BranchList[index].colorsaved= Colors.white;
                              BranchList[index].saved = false;
                              selectedbranch_ar="";
                               selectedbranch_en="";

                              globals.branch_lat = 24.774265;
                              globals.branch_long = 46.738586;
                              globals.branch_name_ar = selectedbranch_ar;
                              globals.branch_name_en =selectedbranch_en;
                              globals.branch_id= BranchList[index].en_title;
                            });
                          }
                            }else{  Fluttertoast.showToast(
                                msg:translator.translate('closed')  ,
                                backgroundColor: Colors.black,
                                textColor: Colors.white);
                            }
                          }
                          else{
  Fluttertoast.showToast(
      msg:translator.translate('long_distance_message')  ,
      backgroundColor: Colors.black,
      textColor: Colors.white);
}
                        });

                        //////////////////////////////
                        //    print(selectedbranch_ar+"////"+selectedbranch_en);
                     // });
                    },
                    child: Card(
                      color: BranchList[index].colorsaved,
                      elevation: 10,
                      shape: new RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0)),
                      margin: EdgeInsets.all(6),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Text(
                              translator.currentLanguage == 'ar'
                                  ? BranchList[index].ar_title
                                  : BranchList[index].en_title,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800]),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Text(double.parse(BranchList[index].distance.toStringAsFixed(2)).toString(),
                                  //BranchList[index].distance.toString(),
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    // fontWeight: FontWeight.bold,
                                    // color: Colors.grey[500]
                                  ),
                                ),
                                Text(
                                  translator.translate('km'),
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    // fontWeight: FontWeight.bold,
                                    //  color: Colors.grey[500]
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                        subtitle: Column(
                          children: <Widget>[
                            Text(
                              BranchList[index].address,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.fiber_manual_record,
                                  size: 25,
                                  color: Colors.green,
                                ),
                                Text(
                                  BranchList[index].open
                                      ? translator.translate('opened')
                                      : translator.translate('closed'),
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                        leading: Icon(
                          Icons.location_on,
                          size: 30,
                          color: Theme.of(context).accentColor,
                        ),
                        // trailing: Column(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text(double.parse(BranchList[index].distance.toStringAsFixed(2)).toString(),
                        // //BranchList[index].distance.toString(),
                        //       textDirection: TextDirection.rtl,
                        //       style: TextStyle(
                        //           fontSize: 15.0,
                        //          // fontWeight: FontWeight.bold,
                        //           color: Colors.grey[500]
                        //         ),
                        //     ),
                        //     Text(
                        //       translator.translate('km'),
                        //       textDirection: TextDirection.rtl,
                        //       style: TextStyle(
                        //           fontSize: 15.0,
                        //          // fontWeight: FontWeight.bold,
                        //            color: Colors.grey[500]
                        //       ),
                        //     ),
                        //
                        //   ],
                        // ),

                      ),
                    ),
                  );
                })),
      ],
    );
  }


  void getData() {
    DateTime now = DateTime.now();
    bool open = true;
    String b = now.month.toString();
    if (b.length < 2) {
      b = "0" + b;
    }
    String c = now.day.toString();
    if (c.length < 2) {
      c = "0" + c;
    }

    // open = new DateTime(_selectedValue.year, _selectedValue.month,
    //     _selectedValue.day, open.hour, open.minute - steptime);

    print("//////////");
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

        DateTime open1 = DateTime.parse(
            "${now.year}-${b}-${c} ${DATA[individualkey]['starttime']}:00");
        // 2020-09-23 12:52:44.480093/////"2012-02-27 13:27:00"
        DateTime close1 = DateTime.parse(
            "${now.year}-${b}-${c} ${DATA[individualkey]['endtime']}:00");
        if (now.isAfter(open1) && now.isBefore(close1)) {
          open = true;
        } else {
          open = false;
        }

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
              open,
                distance,
                false,
              Colors.white,
            ));
            print("bbbb1${DATA[individualkey]['id']}");
            _onFindCoifAddMarker(DATA[individualkey]['lat'], DATA[individualkey]['long'], DATA[individualkey]['ar_title'], DATA[individualkey]['en_title'],false,distance,DATA[individualkey]['id'],open);

            costantList.add(new BranchListClass(
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
                open,
                distance,
                false,
              Colors.white,
            ));
            setState(() {
              BranchList.sort((fl1, fl2) => fl1.distance.compareTo(fl2.distance));
              costantList.sort((fl1, fl2) => fl1.distance.compareTo(fl2.distance));
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
              open,
              0.0,
                false,
              Colors.white,
            ));
            costantList.add(new BranchListClass(
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
                open,
                0.0,
                false,
              Colors.white,
            ));
            setState(() {
              costantList.sort((fl1, fl2) => fl2.distance.compareTo(fl1.distance));
              BranchList.sort((fl1, fl2) => fl2.distance.compareTo(fl1.distance));
            });
          });
        }

        // }
      }
    });
  }

/////////////////////////////////
  Widget _googleMap(BuildContext context) {
    return Container(
      height:200,// MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition:
        CameraPosition(target: LatLng(globals.lat_gps,globals.long_gps), zoom: 12),
        onMapCreated: (GoogleMapController controller) {
          _mapcontroller.complete(controller);
        },
        markers: _markers,
      ),
    );
  }

  _onFindCoifAddMarker(String lat, String lng, String ar_tit, String en_tit,saved,double dis,String branch_id,bool open) async {
    LatLng newLatLng = LatLng(double.parse(lat), double.parse(lng));

    // BitmapDescriptor icon ;
    //BitmapDescriptor icon = await BitmapDescriptor.defaultMarker;
        //  ImageConfiguration(size: Size(116, 116)), 'assets/images/ic_green.png');
    // } else {
    //  icon =  await BitmapDescriptor.fromAsset('assets/images/ic_red.png',);
    //     // }
    print("bbbb2222${branch_id}");

    setState(() {
      //saved=true;
      _markers.add(Marker(
          markerId: MarkerId(newLatLng.toString()),
          position: newLatLng,
          infoWindow: InfoWindow(title:translator.currentLanguage == 'ar' ? ar_tit: en_tit  ,
                                snippet:translator.translate('press_to_save'),

              onTap: () {
            setState(() {
      if(dis<20){
      if(open){

      selectedbranch_ar=ar_tit;
      selectedbranch_en=en_tit;

      globals.branch_lat =double.parse(lat);
      globals.branch_long = double.parse(lng);
      globals.branch_name_ar = selectedbranch_ar;
      globals.branch_name_en =selectedbranch_en;
      globals.branch_id= branch_id;

      Fluttertoast.showToast(
      msg:( translator.currentLanguage == 'ar' ? ar_tit: en_tit)+" "+translator.translate('saved') ,
      backgroundColor: Colors.black,
      textColor: Colors.white);
      }else{
        Fluttertoast.showToast(
      msg:translator.translate('closed')  ,
      backgroundColor: Colors.black,
      textColor: Colors.white);
      }
      }else{
        print("bbbb444${ar_tit}");

        selectedbranch_ar="";
        selectedbranch_en="";

              globals.branch_lat = 24.774265;
              globals.branch_long = 46.738586;
              globals.branch_name_ar = selectedbranch_ar;
              globals.branch_name_en =selectedbranch_en;
        globals.branch_id=  "";

        Fluttertoast.showToast(
            msg:translator.translate('long_distance_message')  ,
            backgroundColor: Colors.black,
            textColor: Colors.white);
      }
          //    print(selectedbranch_ar+"////"+selectedbranch_en);
            });

              }
          ),
          icon: icon,
          // BitmapDescriptor.defaultMarkerWithHue(
          //     BitmapDescriptor.hueViolet),
          onTap: () {


          }
      ));
    });
  }



}

