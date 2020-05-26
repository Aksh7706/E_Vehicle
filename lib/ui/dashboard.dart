import 'dart:async';

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
  static double zoom = 15.0;

  static GoogleMapController mapController;
  Location _locationTracker = Location();
  
  Map<String, Marker> allMarkers = new Map();
  Map<String, DriverData> drivers = new Map();

  StreamSubscription<QuerySnapshot> subscribe;

  @override
  void initState() {
    subscribe =
        Firestore.instance.collection("Vehicle").snapshots().listen((snapshot) {
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
                onTap: () {
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

  void _getCurrentLocation() async {

    var location = await _locationTracker.getLocation();

    if (mapController != null) {
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
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
        title: const Text('Dashboard'),
        backgroundColor: Color(0xFFfbab66),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              FontAwesomeIcons.powerOff,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BoolLogged()),
              );
              ;
            },
          )
        ],
      ),
      body: Container(
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
     floatingActionButton: FloatingActionButton(
        onPressed: () => _getCurrentLocation(),
        tooltip: 'Get Current Location',
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}
