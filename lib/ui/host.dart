import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_vehicle/ui/register_driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import './home.dart';
import './chatPage.dart';

class DriverData {
  String driverName;
  var rating;
  bool isActive;
  String image;
  String caddyId;
  String goingTowards;
  GeoPoint latlong;
  var phoneNo;
  DriverData(this.driverName, this.rating, this.isActive, this.image,
      this.caddyId, this.goingTowards, this.latlong, this.phoneNo);
}

class Host extends StatefulWidget {
  final FirebaseUser user;

  Host(this.user);

  @override
  _HostState createState() => _HostState();
}

class _HostState extends State<Host> {
  // is driver active
  var rating, location;
  bool isActive = false;

  
  // static variables
  static final db = Firestore.instance.collection("Vehicle");
  static double currentLatitude = 22.529797;
  static double currentLongitude = 75.924519;
  static double zoom = 16.5;
  // map controller
  static GoogleMapController mapController;
  Location _locationTracker = Location();

  // HaspMap containing all markers
  Map<String, Marker> allMarkers = new Map();
  Map<String, DriverData> drivers = new Map();

  StreamSubscription<QuerySnapshot> subscribe;
  StreamSubscription _locationSubscription;

  List<String> headedTowards = [
    "Pod 1-A",
    "Pod 1-B",
    "Pod 1-C",
    "Pod 1-D",
    "Pod 1-E",
    "School Building",
    "Gate 1",
    "Gate 2",
    "WorkShop Building"
  ];
  List<String> caddyNo = [
    "XXXX-23456",
    "XXXX-23555",
    "XXXX-23890",
    "XXXX-23876",
    "XXXX-23907"
  ];

  String selectedLocation = "Pod 1-A";
  String selectedCaddy = "XXXX-23456";
  DriverData currentDriver;
  bool showCurrentDriver = false;
  bool showDialog = false;
  // For Custom Marker

  Future<Uint8List> _getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/img/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => MyHome()));
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
          anchor: Offset(0.5, 0.5),
          onTap: () {
            if (mapController != null) {
              mapController
                  .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                target: LatLng(location.latitude, location.longitude),
                tilt: 0,
                zoom: zoom,
              )));
            }
            setState(() {
              showCurrentDriver = true;
              currentDriver = drivers[widget.user.uid];
            });
          });
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
        // if (mapController != null) {
        //   mapController
        //       .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        //     target: LatLng(newLocData.latitude, newLocData.longitude),
        //     tilt: 0,
        //     zoom: zoom,
        //   )));
        // }
        updateMarker(newLocData, imageData);
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        // TODO : Show SnakBar Here
        print("Permission Denied");
      }
    }
  }

  void getSubscription() {
    this.subscribe = db.snapshots().listen((snapshot) async {
      Uint8List imageData = await _getMarker();
      setState(() {
        snapshot.documentChanges.forEach((doc) {
          print(doc.document.data);
          String driverId = doc.document.documentID;
          MarkerId markerId = MarkerId(driverId);
          String name = doc.document.data['name'];
          rating = doc.document.data['rating'];
          String caddyId = doc.document.data['caddyId'];
          String image = doc.document.data['image'];
          String goingTowards = doc.document.data['goingTowards'];
          location = LatLng(doc.document.data['location'].latitude,
              doc.document.data['location'].longitude);
          bool isActive = doc.document.data['isActive'];

          drivers[driverId] = DriverData(
              name,
              rating,
              isActive,
              image,
              caddyId,
              goingTowards,
              doc.document.data['location'],
              doc.document.data['phoneNo']);

          if (driverId != widget.user.uid) {
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
                        target: LatLng(doc.document.data['location'].latitude, doc.document.data['location'].longitude),
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
          }
        });
      });
    });
  }

  @override
  void initState() {
    getSubscription();
    super.initState();
  }

  @override
  void dispose() {
    // Cancel your subscription when the screen is disposed
    subscribe.cancel();
    if (_locationSubscription != null) _locationSubscription.cancel();
    super.dispose();
  }

  Widget _showDialog() {
    return showDialog
        ? Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Align(
              alignment: Alignment.center,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: Container(
                  height: 210,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Select Destination : "),
                        DropdownButton<String>(
                          isExpanded: true,
                          hint: Text("Select item"),
                          onChanged: (String value) {
                            setState(() {
                              selectedLocation = value;
                            });
                          },
                          items: headedTowards.map((String loc) {
                            return DropdownMenuItem<String>(
                              value: loc,
                              child: Text(
                                loc,
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          value: selectedLocation,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Select Caddy No : "),
                        DropdownButton<String>(
                          isExpanded: true,
                          hint: Text("Select item"),
                          value: selectedCaddy,
                          onChanged: (String value) {
                            setState(() {
                              selectedCaddy = value;
                            });
                          },
                          items: caddyNo.map((String loc) {
                            return DropdownMenuItem<String>(
                              value: loc,
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    loc,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          width: 320.0,
                          child: RaisedButton(
                            onPressed: () async {
                              await db.document(widget.user.uid).updateData({
                                'goingTowards': selectedLocation,
                                'caddyId' : selectedCaddy
                              });
                              setState(() {
                                showDialog =false;
                              });
                            },
                            child: Text(
                              "Confirm",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.blue,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : SizedBox(
            height: 0,
          );
  }

  void _handleClientStream(bool value) {
    setState(() {
      this.isActive = value;
      db.document(widget.user.uid).updateData({
        'isActive': value,
      });
      if (value) {
        showDialog = true;
        _getCurrentLocation();
      } else {
        showDialog = false;
        if (_locationSubscription != null) _locationSubscription.cancel();
      }
    });
  }

  Widget _currentDriver() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: showCurrentDriver
            ? Padding(
                padding: const EdgeInsets.only(bottom: 85.0, left: 5, right: 5),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  child: _driverDetails(currentDriver))
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
              ));
  }

  Widget _driverDetails(DriverData c) {
    TextStyle textStyle1 = TextStyle(
        fontFamily: "ChelseaMarket", color: Colors.white, fontSize: 15.0);
    TextStyle textStyle = TextStyle(
        fontFamily: "ChelseaMarket",
        color: Color(0xFF303960),
        fontSize: 15.0,
        fontWeight: FontWeight.bold);
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text("Name : ", style: textStyle),
            Text(c.driverName, style: textStyle1),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              "Caddy No. : ",
              style: textStyle,
            ),
            Text(
              c.caddyId,
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
              c.goingTowards,
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
              c.rating.toString() + "/5",
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
        title: Text(
          "Driver Console",
          style: TextStyle(
            fontFamily: "ChelseaMarket",
          ),
        ),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          Switch(
            value: isActive,
            onChanged: (value) {
              _handleClientStream(value);
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ],
      ),
      drawer: new Drawer(
        child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
                accountName: new Text(
                  drivers.containsKey(widget.user.uid) ? drivers[widget.user.uid].driverName : " ",
                  style: new TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w500),
                ),
                accountEmail: new Text(
                  widget.user.email,
                  style: new TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w500),
                )),
            new Column(children: [
              ListTile(
                leading: new Icon(Icons.home),
                title: new Text(
                  "Home",
                  style: new TextStyle(
                    fontSize: 18.0,
                    fontFamily: "ChelseaMarket",
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => MyHome()));
                },
              ),
              ListTile(
                leading: new Icon(Icons.edit),
                title: new Text(
                  "Edit Profile",
                  style: new TextStyle(
                    fontSize: 18.0,
                    fontFamily: "ChelseaMarket",
                  ),
                ),
                onTap: () async {},
              ),
              ListTile(
                leading: new Icon(Icons.add),
                title: new Text(
                  "Register Driver",
                  style: new TextStyle(
                    fontSize: 18.0,
                    fontFamily: "ChelseaMarket",
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterDriver()),
                  );
                },
              ),
              ListTile(
                  leading: new Icon(Icons.chat),
                  title: new Text(
                    "Chat",
                    style: new TextStyle(
                      fontSize: 18.0,
                      fontFamily: "ChelseaMarket",
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => chatPage(widget.user)),
                    );
                  }),
              ListTile(
                leading: new Icon(Icons.power_settings_new),
                title: new Text(
                  "Sign Out",
                  style: new TextStyle(
                    fontSize: 18.0,
                    fontFamily: "ChelseaMarket",
                  ),
                ),
                onTap: () async {
                  await signOut(context);
                },
              )
            ]),
          ],
        ),
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
              _getCurrentLocation();
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
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
                        color: Color(0xFF0a97b0),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontSize: 15.0,
                        fontFamily: "WorkSansMedium"),
                  ),
                  Text(
                    (allMarkers.length).toString(),
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
        _currentDriver(),
        _showDialog()
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
