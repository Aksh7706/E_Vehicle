import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          var rating = doc.document.data['rating'];
          var location = LatLng(doc.document.data['location'].latitude,
              doc.document.data['location'].longitude);

          bool isActive = doc.document.data['isActive'];

          if (!isActive) {
            allMarkers.remove(driverId);
          } else {
            allMarkers[driverId] = Marker(
                markerId: markerId,
                position: location,
                onTap: () {
                  print(drivers[markerId.value]);
                });
          }

          drivers[driverId] = DriverData(name, rating, isActive);
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
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: Set<Marker>.of(allMarkers.values),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => {},
      //   tooltip: 'Increment Counter',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
