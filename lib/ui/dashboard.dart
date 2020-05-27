import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class DriverData {
  String driverName;
  var rating;
  bool isActive;
  String image;
  String caddyId;
  String goingTowards;
  DriverData(this.driverName, this.rating, this.isActive, this.image,
      this.caddyId, this.goingTowards);
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

  DriverData currentDriver;
  bool showCurrentDriver = false;

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
          String caddyId = doc.document.data['caddyId'];
          String image = doc.document.data['image'];
          String goingTowards = doc.document.data['goingTowards'];
          print(name);
          var rating = doc.document.data['rating'];
          var location = LatLng(doc.document.data['location'].latitude,
              doc.document.data['location'].longitude);

          bool isActive = doc.document.data['isActive'];
          drivers[driverId] =
              DriverData(name, rating, isActive, image, caddyId, goingTowards);

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
                  setState(() {
                    showCurrentDriver = true;
                    currentDriver = drivers[markerId.value];
                  });
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

  Widget _driverDetails() {
    TextStyle textStyle1 = TextStyle(
              fontFamily: "ChelseaMarket", color: Colors.white, fontSize: 15.0);
    TextStyle textStyle = TextStyle(
              fontFamily: "ChelseaMarket", color: Color(0xFF303960), fontSize: 15.0, fontWeight: FontWeight.bold);
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              "Name : ",
              style: textStyle
            ),
            Text(
              currentDriver.driverName,
              style: textStyle1
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              "Caddy No. : "  ,
              style: textStyle,
            ),
            Text(
              currentDriver.caddyId,
              style: textStyle1,
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              "Going Towards : ",
              style: textStyle,
            ),
            Text(
              currentDriver.goingTowards,
              style: textStyle1,
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              "Rating : ",
              style: textStyle,
            ),
            Text(
              currentDriver.rating.toString() + "/5",
              style: textStyle1,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontFamily: "ChelseaMarket",
          ),
        ),
        backgroundColor:Color(0xFF0a97b0),
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
                  Text(
                    "Vehicles Online  :  ",
                    style: TextStyle(
                        color:  Color(0xFF0a97b0),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontSize: 15.0,
                        fontFamily: "WorkSansMedium"),
                  ),
                  Text(
                    allMarkers.length.toString(),
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        fontFamily: "WorkSansMedium"),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
                color: Colors.black.withAlpha(30),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0))),
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: showCurrentDriver
                ? Padding(
                    padding:
                        const EdgeInsets.only(bottom: 85.0, left: 5, right: 5),
                    child: Card(
                      elevation: 2.0,
                      color: Color(0xFF0a97b0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        height: 170,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      "Details",
                                      style: TextStyle(
                                        fontFamily: "ChelseaMarket",
                                        fontSize: 18.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    color: Colors.white,
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        showCurrentDriver = false;
                                      });
                                    },
                                  )
                                ],
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(),
                              height: 120,
                              width: double.infinity,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.white,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    width: 120,
                                    height: 120,
                                    child: Padding(
                                      padding: const EdgeInsets.all(9.5),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: NetworkImage(
                                          currentDriver.image,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: _driverDetails()
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 0,
                  ))
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF0a97b0),
        onPressed: () => _getCurrentLocation(),
        tooltip: 'Get Current Location',
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}
