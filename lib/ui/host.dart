import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Host extends StatefulWidget {
  final FirebaseUser user;

  Host(this.user);

  @override
  _HostState createState() => _HostState();
}

class _HostState extends State<Host> {
  // is driver active
  bool isActive = false;

  // static variables
  static final db = Firestore.instance.collection("Vehicle");
  static double currentLatitude = 22.529797;
  static double currentLongitude = 75.924519;
  static double zoom = 15.0;

  // map controller
  static GoogleMapController mapController;
  Location _locationTracker = Location();

  // HaspMap containing all markers
  Map<String, Marker> allMarkers = new Map();

  StreamSubscription<QuerySnapshot> subscribe;
  StreamSubscription _locationSubscription;

  // For Custom Marker
  Future<Uint8List> _getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/img/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  // Update Caddy's Location
  void updateMarker(LocationData locData, Uint8List imageData) {
    LatLng location = LatLng(locData.latitude, locData.longitude);
    setState(() {
      print("Location Changed");
      allMarkers[widget.user.uid] = Marker(
          markerId: MarkerId(widget.user.uid),
          position: location,
          icon: BitmapDescriptor.fromBytes(imageData),
          rotation: locData.heading,
          flat: true,
          anchor: Offset(0.5, 0.5));
    });
  }

  void _getCurrentLocation() async {
    try {
      Uint8List imageData = await _getMarker();
      var location = await _locationTracker.getLocation();
      if (isActive) {
        await db.document(widget.user.uid).updateData({
          'location': GeoPoint(location.latitude, location.longitude),
        });
      }

      if (mapController != null) {
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          tilt: 0,
          zoom: zoom,
        )));
      }

      updateMarker(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocData) async {
        if (isActive) {
          await db.document(widget.user.uid).updateData({
            'location': GeoPoint(newLocData.latitude, newLocData.longitude),
          });
          print("Location Updated At Database as Well");
        }
        if (mapController != null) {
          mapController
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(newLocData.latitude, newLocData.longitude),
            tilt: 0,
            zoom: zoom,
          )));
        }
        updateMarker(newLocData, imageData);
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        // TODO : Show SnakBar Here
        print("Permission Denied");
      }
    }
  }

  @override
  void initState() {
    subscribe = db.snapshots().listen((snapshot) {
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
          if (driverId != widget.user.uid) {
            if (!isActive) {
              allMarkers.remove(driverId);
            } else {
              allMarkers[driverId] = Marker(
                  markerId: markerId,
                  position: location,
                  onTap: () {
                    print(markerId.value);
                  });
            }
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
    if (_locationSubscription != null) _locationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Color(0xFFfbab66),
        actions: <Widget>[
          Switch(
            value: isActive,
            onChanged: (value) {
              setState(() {
                isActive = value;
                db.document(widget.user.uid).updateData({
                  'isActive': value,
                });
                if (value) {
                  _getCurrentLocation();
                } else {
                  if (_locationSubscription != null)
                    _locationSubscription.cancel();
                }
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
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
            _getCurrentLocation();
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
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
