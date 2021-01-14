import 'dart:async';
import 'package:access_settings_menu/access_settings_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alert/flutter_alert.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:friesdip/Classes/globals.dart' as globals;
import '../main.class.dart';

class CurrentLocation2 extends StatefulWidget {
  @override
  _CurrentLocationState createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation2> {
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

  Completer<GoogleMapController> _controller = Completer();
  double zoomVal = 0.5;

  @override
  void initState() {
    super.initState();
    checkGPS('ACTION_LOCATION_SOURCE_SETTINGS');
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
//      appBar: AppBar(
//        title: Text("Current Location"),
//        centerTitle: true,
//      ),
      body: Stack(
        children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
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
    );
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
        //
      });
    } catch (e) {
      print(e);
    }
  }

  void _onAddMarker(BuildContext context)async {
    if (_myLoc != null) _myLoc = _lastMapPostion;
    await _getAddressFromLatLng(_myLoc.latitude , _myLoc.longitude);
    // print("\n\n\n\n\n\n\n"+_currentAddress+"\n\n\n\n\n\n");
    //add _currentAddress to args
    Map <String , dynamic > sendData = Map();
    sendData["loc_latLng"] = _myLoc;
    sendData["loc_name"] = _currentAddress;
    Navigator.pop(context, sendData);
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
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
    });
  }



  checkGPS(settingsName) async {
    isLocationEnabled = await Geolocator().isLocationServiceEnabled();
    if (!isLocationEnabled) {
      _showDialog(_context, settingsName);
    }
  }

  void _showDialog(BuildContext context, String settingsName) {
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
      cancelable: true,
    );
  }

  openSettingsMenu(settingsName) async {
    isLocationEnabled = await Geolocator().isLocationServiceEnabled();

    try {
      isLocationEnabled =
          await AccessSettingsMenu.openSettings(settingsType: settingsName).then((value) {
            _getCurrentLocation();
            //  print("aabb$value");
          });
    } catch (e) {
      isLocationEnabled = false;
    }
  }
}
