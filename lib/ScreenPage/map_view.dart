import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:friesdip/Classes/globals.dart' as globals;
import 'package:localize_and_translate/localize_and_translate.dart';




class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

// final cofRef = FirebaseDatabase.instance.reference();

class _MapViewState extends State<MapView> {
  Map<String, String> categoriesList;
  Set<Marker> markers = Set();

  Completer<GoogleMapController> _controller = Completer();
  double zoomVal = 0.5;
  String _cName;
  //final Set<Marker> _markers = {};
  List<Marker> _markers = <Marker>[];

  @override
  void initState() {
    super.initState();
    _markers.add(
        Marker(
            markerId: MarkerId(globals.branch_id),
            position: LatLng(globals.branch_lat,globals.branch_long),
            infoWindow: InfoWindow(
                title:translator.currentLanguage == 'ar'
                    ? globals.branch_name_ar
                    : globals.branch_name_en,
            )
        )
    );
  }

  //close database
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _googleMap(context),
          // _zoomInFunction(),
          // _zoomOutFunction(),
          // _buildContainer(context),
        ],
      ),
    );
  }

  Widget _googleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition:
            CameraPosition(target: LatLng(globals.branch_lat,globals.branch_long), zoom: 15),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: Set<Marker>.of(_markers),
      ),
    );
  }





}
