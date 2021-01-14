import 'dart:async';
import 'package:access_settings_menu/access_settings_menu.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alert/flutter_alert.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:friesdip/Classes/BranchListClass.dart';
import 'package:friesdip/DrawerScreenPage/CustomAppBar.dart';
import 'package:friesdip/DrawerScreenPage/MenuPage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:friesdip/Classes/globals.dart' as globals;
import 'package:localize_and_translate/localize_and_translate.dart';
import 'dart:math' show cos, sqrt, asin;


class UserDeliveryLocation extends StatefulWidget {
  @override
  _UserDeliveryLocationState createState() => _UserDeliveryLocationState();
}

class _UserDeliveryLocationState extends State<UserDeliveryLocation> {
  static LatLng _center = const LatLng(24.774265, 46.738586);
  LatLng _lastMapPostion = _center;
  LatLng _myLoc;
  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  bool isLocationEnabled;
  BuildContext _context;
  Position _currentPosition;
  Position _geoPosition;
  String _currentAddress;
  TextEditingController _cur_loc_Controller = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  double zoomVal = 0.5;
  var _formKey = GlobalKey<FormState>();
  _getCurrentLocation1() async {
    print("ooo"+isLocationEnabled.toString());
    // final GoogleMapController controller = await _controller.future;

    _geoPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((po) {
      print("ooo2$po");
      _getAddressFromLatLng(po.latitude, po.longitude);
      _myLoc = LatLng(po.latitude, po.longitude);
      // controller.animateCamera(CameraUpdate.newCameraPosition(
      //   CameraPosition(target: LatLng(po.latitude, po.longitude), zoom: 15.0),
      // ));
      // double a=po.latitude; po.longitude;
      //_myLoc = LatLng(po.latitude, po.longitude);
    });
  }

  @override
  void initState() {
    super.initState();
    globals.deliverycheck = true;
    checkGPS('ACTION_LOCATION_SOURCE_SETTINGS');
    _getCurrentLocation();

    _getCurrentLocation1();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        appBar: AppBar(),
      ),
      body: new Form(
        key: _formKey,
        child: Container(
          //height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top:8.0, bottom: 0.0),
                child: Container(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Padding(
                      padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: TextFormField(
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.text,
                        textDirection: TextDirection.rtl,
                        controller: _cur_loc_Controller,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return translator.translate('cur_location');
                          }
                        },
                        decoration: InputDecoration(
                            labelText:
                            translator.translate('cur_location'),
                            errorStyle: TextStyle(
                                color: Colors.red, fontSize: 15.0),
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(5.0))),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8,bottom: 8),
                child: Container(
                  width: (MediaQuery.of(context).size.width)/2,
                  height: 45,
                  child: new RaisedButton(
                    child: new Text(translator.translate('cur_location')),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      _getCurrentLocation1();

                    },
//
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0)),
                  ),
                ),
              ),
              Card(
                color: Colors.grey,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 0.0, left: 0.0, right: 0.0, bottom: 0.0),
                  child: ExpansionTile(
                    title: Container(color:Colors.grey,child: Text(translator.translate('search_loc_map'))),//backgroundColor: Colors.black,
                    children: <Widget>[
                      Container(
                        height: 300,
                        child: Stack(
                          children: <Widget>[
                            Container(
                                // height: MediaQuery.of(context).size.height,
                                // width: MediaQuery.of(context).size.width,
                                child: GoogleMap(
                                  mapType: _currentMapType,
                                  initialCameraPosition: CameraPosition(
                                      target: _myLoc != null ? _myLoc : _center, zoom: 8.0),
                                  onMapCreated: _onMapCreated,
                                  markers: _markers,
                                  onCameraMove: _onCameraMove,
                                  myLocationEnabled: true,

                                )),
                            new Align(
                              alignment: Alignment.center,
                              child: new Icon(FontAwesomeIcons.mapPin, size: 40.0),
                            ),
                            Container(
                              width: (MediaQuery.of(context).size.width / 3) * 2,
                              alignment: Alignment.bottomCenter,
                              margin: EdgeInsets.all(16.0),
                              child: RaisedButton(
                                  color: Theme.of(context).accentColor,
                                  onPressed: () {
                                    _onAddMarker(context);
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(  translator.translate('save_location'),
                                          style: TextStyle(fontSize: 20.0, color: Colors.white),
                                          textAlign: TextAlign.center),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Icon(Icons.save, color: Colors.white),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  )),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              (_currentAddress==""||_currentAddress==null )? Container(): Container(
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
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 10,bottom: 10),
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
            ],
          ),
        ),
      ),


    );
  }

  void getBranchData(double lat,double lng) {
    print("//////////");
    FirebaseDatabase.instance
        .reference()
        .child("branchList")
        .once()
        .then((DataSnapshot snapshot) async {
      var KEYS = snapshot.value.keys;
      var DATA = snapshot.value;
      // print("${snapshot.value}hhh");
      double mindistance=99999999999999.0;
int i=0;
print("nnnnooo${KEYS.length}");
     // BranchList.clear();
      for (var individualkey in KEYS) {
        i++;
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

        // DateTime open1 = DateTime.parse(
        //     "${now.year}-${b}-${c} ${DATA[individualkey]['starttime']}:00");
        // // 2020-09-23 12:52:44.480093/////"2012-02-27 13:27:00"
        // DateTime close1 = DateTime.parse(
        //     "${now.year}-${b}-${c} ${DATA[individualkey]['endtime']}:00");
        // if (now.isAfter(open1) && now.isBefore(close1)) {
        //   open = true;
        // } else {
        //   open = false;
        // }

        try {
          List<Placemark> p = await Geolocator().placemarkFromCoordinates(
              double.parse(DATA[individualkey]['lat']),
              double.parse(DATA[individualkey]['long']));

////////////***************
          double lat2=double.parse(DATA[individualkey]['lat']);
          double  lon2= double.parse(DATA[individualkey]['long']);
          double lat1=lat;
          double  lon1=lng;

          // print("globals.lat==${globals.lat_gps}");
          // print("globals.long==${globals.long_gps}");

          var pi = 0.017453292519943295;
          var c = cos;
          var a = 0.5 -
              c((lat2 - lat1) * pi) / 2 +
              c(lat1 * pi) * c(lat2 * pi) * (1 - c((lon2 - lon1) * pi)) / 2;
          double distance= 12742 * asin(sqrt(a));
          print("nnnn$distance");

          if(distance<mindistance){
            mindistance=distance;
            globals.branch_id=  DATA[individualkey]['id'];
            globals.branch_lat=   DATA[individualkey]['lat'];
            globals.branch_long=  DATA[individualkey]['long'];
            globals.branch_name_ar=  DATA[individualkey]['ar_title'];
            globals.branch_name_en=  DATA[individualkey]['en_title'];
            globals.distancecheck=true;

          }
        } catch (e) {

        }
if(i==KEYS.length){
  if(mindistance>20.0){
    globals.branch_id=  "";
    print("nnnnuuu$mindistance");
    globals.distancecheck=false;
    Fluttertoast.showToast(
        msg:translator.translate('no_delivery') ,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }else{
    globals.distancecheck=true;
    globals.distance=mindistance;
    Fluttertoast.showToast(
        msg:translator.translate('done') ,
        backgroundColor: Colors.black,
        textColor: Colors.white);
  }
}

      }



    });
  }

_getAddressFromLatLng(double lt, double lg) async {
    try {
      List<Placemark> p = await Geolocator().placemarkFromCoordinates(lt, lg);

      Placemark place = p[0];
      String name = place.name;
      String subLocality = place.subLocality;
      String locality = place.locality;
      String administrativeArea = place.administrativeArea;
      String postalCode = place.postalCode;
      String country = place.country;


      setState(() {
        _currentAddress = 
        "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";
        globals.lat_gps = lt;
        globals.long_gps = lg;
        globals.address_gps = "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";
        _cur_loc_Controller.text=_currentAddress;
        getBranchData(lt,lg);
      });
    } catch (e) {
      print(e);
    }
  }

  void _onAddMarker(BuildContext context)async {
    if (_myLoc != null) _myLoc = _lastMapPostion;
    await _getAddressFromLatLng(_myLoc.latitude , _myLoc.longitude);
     print("\n\n\n\n\n\n\n"+_myLoc.toString()+"\n\n\n\n\n\n");
    //add _currentAddress to args
    // Map <String , dynamic > sendData = Map();
    // sendData["loc_latLng"] = _myLoc;
    // sendData["loc_name"] = _currentAddress;
    // Navigator.pop(context, sendData);
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
    print("kkk111kkk${position.target}");
    _lastMapPostion = position.target;
  }

  Widget actionBtn(IconData icon, Function function) {
    return FloatingActionButton(
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.amber,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }

  _onMapTypePressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  _onAddMarkerPressed() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_lastMapPostion.toString()),
          position: _lastMapPostion,
          infoWindow:
              InfoWindow(title: "Ryadah - KSA", snippet: "this is snippet"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet)));
    });
  }

//  Future<void> _goToPositionOne() async {
//    final GoogleMapController controller = await _controller.future;
//    controller.animateCamera(CameraUpdate.newCameraPosition(_position));
//  }

  //current loc
  _getCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    _geoPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((po) {
      _myLoc = LatLng(po.latitude, po.longitude);
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(po.latitude, po.longitude), zoom: 15.0),
      ));
      _getAddressFromLatLng(_myLoc.latitude , _myLoc.longitude);

    });
  }

  checkGPS(settingsName) async {
    print("mmm"+isLocationEnabled.toString());

    isLocationEnabled = await Geolocator().isLocationServiceEnabled();

    if (!isLocationEnabled) {
      print("mmm"+isLocationEnabled.toString());

      showAlert(
        context: context,
        title:   translator.translate('enable_gps'),
        body:   translator.translate('enable_gps_text'),
        actions: [
          AlertAction(
            text:   translator.translate('enable'),
            isDestructiveAction: true,
            onPressed: () {
              // TODO
              openSettingsMenu(settingsName);
            },
          ),
        ],
        cancelable: false,
      );
    }
  }

  openSettingsMenu(settingsName) async {
    isLocationEnabled = await Geolocator().isLocationServiceEnabled();

    try {
      isLocationEnabled =
      await AccessSettingsMenu.openSettings(settingsType: settingsName).then((value) {
        _getCurrentLocation1();
        //  print("aabb$value");
      });
    } catch (e) {
      isLocationEnabled = false;
    }
  }
}
