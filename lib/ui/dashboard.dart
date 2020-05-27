import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import '../services/check_logged.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class DriverData {
  String driverName;
  var rating;
  bool isActive;

  DriverData(this.driverName, this.rating, this.isActive);
}

class _DashboardState extends State<Dashboard> {
  static final db = Firestore.instance.collection("Vehicle");

  static double currentLatitude = 22.529797;
  static double currentLongitude = 75.924519;
  static double zoom = 17.5;

  static GoogleMapController mapController;
  Location _locationTracker = Location();

  Map<String, Marker> allMarkers = new Map();
  Map<String, DriverData> drivers = new Map();

  StreamSubscription<QuerySnapshot> subscribe;

  Uint8List imageData;
  @override
  void initState() {
    subscribe = Firestore.instance
        .collection("Vehicle")
        .snapshots()
        .listen((snapshot) async {
      await _getMarker();
      setState(() {
        snapshot.documentChanges.forEach((doc) {
          print(doc.document.data);
          String driverId = doc.document.documentID;
          MarkerId markerId = MarkerId(driverId);
          String name = doc.document.data['name'];
          print(name);
          var rating = doc.document.data['rating'];
          var location = LatLng(doc.document.data['location'].latitude,
              doc.document.data['location'].longitude);

          bool isActive = doc.document.data['isActive'];
          drivers[driverId] = DriverData(name, rating, isActive);

          if (!isActive) {
            allMarkers.remove(driverId);
          } else {
            allMarkers[driverId] = Marker(
                markerId: markerId,
                position: location,
                icon: BitmapDescriptor.fromBytes(imageData),
                flat: true,
                anchor: Offset(0.5, 0.5),
                onTap: () {
                  if (mapController != null) {
                    mapController.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                      target: LatLng(location.latitude, location.longitude),
                      tilt: 0,
                      zoom: zoom,
                    )));
                  }
                  print(drivers[markerId.value].driverName);
                });
          }
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // Cancel your subscription when the screen is disposed
    subscribe.cancel();
    super.dispose();
  }

  Future<void> _getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/img/car_icon.png");
    setState(() {
      imageData = byteData.buffer.asUint8List();
    });
  }

  void _getCurrentLocation() async {
    var location = await _locationTracker.getLocation();
    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        tilt: 0,
        zoom: zoom,
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontFamily: "ChelseaMarket",),),
         backgroundColor: Colors.blue,
      ),
      body: Stack(children: [
        Container(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(currentLatitude, currentLongitude), zoom: zoom),
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
            },
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: Set<Marker>.of(allMarkers.values),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Vehicles Online  :  ", style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 15.0,
                    fontFamily: "WorkSansMedium"
                  ),),
                  Text(allMarkers.length.toString(), style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    fontFamily: "WorkSansMedium"
                  ),),
                ],
              ),
            ),
            decoration: BoxDecoration(color: Colors.black.withAlpha(30), borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0),bottomLeft: Radius.circular(10.0))),
          ),
        ),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _getCurrentLocation(),
        tooltip: 'Get Current Location',
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}
