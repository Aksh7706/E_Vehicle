import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_vehicle/ui/login_page.dart';
import 'package:e_vehicle/ui/register_driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import './home.dart';
import './chatPage.dart';

class Host extends StatefulWidget {
  final FirebaseUser user;

  Host(this.user);

  @override
  _HostState createState() => _HostState();
}

class _HostState extends State<Host> {
  // is driver active
  var name,rating,location,isActive;
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

  StreamSubscription<QuerySnapshot> subscribe;
  StreamSubscription _locationSubscription;

  // For Custom Marker
  Future<Uint8List> _getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/img/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  void signOut() async{
    await FirebaseAuth.instance.signOut();
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

  @override
  void initState() {
    subscribe = db.snapshots().listen((snapshot) async {
      Uint8List imageData = await _getMarker();
      setState(() {
        snapshot.documentChanges.forEach((doc) {
          print(doc.document.data);
          String driverId = doc.document.documentID;
          MarkerId markerId = MarkerId(driverId);
          name = doc.document.data['name'];
          rating = doc.document.data['rating'];
          location = LatLng(doc.document.data['location'].latitude,
              doc.document.data['location'].longitude);
          isActive = doc.document.data['isActive'];
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
                        target: LatLng(location.latitude, location.longitude),
                        tilt: 0,
                        zoom: zoom,
                      )));
                    }
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
        title: Text(
          "Dashboard",
          style: TextStyle(
            fontFamily: "ChelseaMarket",
          ),
        ),
        backgroundColor: Colors.blue,
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
      drawer: new Drawer(
        child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
                accountName: new Text(
                  name,
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
                onTap: (){
                  Navigator.of(context).pushReplacement( MaterialPageRoute(
                                builder: (context) => MyHome()));
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
                onTap: () async{
                  await Firestore.instance.collection("Vehicle").document(widget.user.uid).get().then((snapshot){
                    var currentUser = snapshot.data; // make this current user global and use setState
                    print(currentUser['image']);
                  });
                },
              ),
              FlatButton(
                child: ListTile(
                  leading: new Icon(Icons.add),
                  title: new Text(
                    "Register Driver",
                    style: new TextStyle(
                      fontSize: 18.0,
                      fontFamily: "ChelseaMarket",
                    ),
                  ),
                ),
                onPressed: (){
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterDriver()),
                  );
                }
              ),
              FlatButton(
                child: ListTile(
                  leading: new Icon(Icons.chat),
                  title: new Text(
                    "Chat",
                    style: new TextStyle(
                      fontSize: 18.0,
                      fontFamily: "ChelseaMarket",
                    ),
                  ),
                ),
                onPressed: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => chatPage(widget.user)),
                  );
                }
              ),
              ListTile(
                leading: new Icon(Icons.power_settings_new),
                title: new Text(
                  "Sign Out",
                  style: new TextStyle(
                    fontSize: 18.0,
                    fontFamily: "ChelseaMarket",
                  ),
                ),
                onTap: ()async{
                  await FirebaseAuth.instance.signOut().then((_){
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement( MaterialPageRoute(
                                builder: (context) => MyHome()));
                  });
                },
              )
            ]),
          ],
        ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _getCurrentLocation(),
        tooltip: 'Get Current Location',
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}

