import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import './driver_details.dart';

class User extends StatefulWidget {

  User({Key key}) : super(key: key);

  @override
  _UserState createState() => _UserState();
}


class _UserState extends State<User> {
  static final _db = Firestore.instance.collection("Vehicle");

  static double _intialLatitude = 22.529797;
  static double _intialLongitude = 75.924519;
  static double _zoom = 17.5;

  static GoogleMapController _mapController;
  Location _locationTracker = Location();

  Map<String, Marker> _allMarkers = new Map();
  Map<String, DriverData> _drivers = new Map();

  StreamSubscription<QuerySnapshot> _subscribe;

  DriverData currentDriver;
  bool _showCurrentDriver = false;

  DriverData _currentSOS;
  bool _sosCalled = false;

  Uint8List _imageData;

  void getSubscription() {
    this._subscribe = _db.snapshots().listen((snapshot) async {
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
          _drivers[driverId] = DriverData(name, rating, isActive, image, caddyId,
              goingTowards, doc.document.data['location'], doc.document.data['phoneNo']);

          if (!isActive) {
            _allMarkers.remove(driverId);
          } else {
            _allMarkers[driverId] = Marker(
                markerId: markerId,
                position: location,
                icon: BitmapDescriptor.fromBytes(_imageData),
                flat: true,
                anchor: Offset(0.5, 0.5),
                onTap: () {
                  if (_mapController != null) {
                    _mapController.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                      target: LatLng(location.latitude, location.longitude),
                      tilt: 0,
                      zoom: _zoom,
                    )));
                  }
                  setState(() {
                    _showCurrentDriver = true;
                    currentDriver = _drivers[markerId.value];
                  });
                });
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
    _subscribe.cancel();
    super.dispose();
  }

  Future<void> _getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/img/car_icon.png");
    setState(() {
      _imageData = byteData.buffer.asUint8List();
    });
  }

  void _getCurrentLocation() async {
    var location = await _locationTracker.getLocation();
    if (_mapController != null) {
      _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        tilt: 0,
        zoom: _zoom,
      )));
    }
  }

  void _sos(Map<String, DriverData> drivers) async {
    var location = await _locationTracker.getLocation();
    var minDist = double.infinity;
    String k;
    List<String> keyList = [];

    drivers.forEach((k, v) async {
      if(v.isActive){
        keyList.add(k);
    }});

    await Future.forEach(keyList, (key) async {
       DriverData d = drivers[key];
       
     double distanceInMeters = await Geolocator().distanceBetween(
          location.latitude,
          location.longitude,
          d.latlong.latitude,
          d.latlong.longitude);
        
      if (distanceInMeters < minDist) {
        minDist = distanceInMeters;
        k = key;
      }
    });

    print(drivers[k].driverName);
    setState(() {
      this._showCurrentDriver = false;
      this._sosCalled = true;
      this._currentSOS =drivers[k];
    });
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

  Widget _driverClosestDetails(DriverData c) {
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
    RaisedButton(
      shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
    onPressed: (){
       _sosCall(c.phoneNo);
      },
    color: Colors.red,
    child:  Row(
      mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Call Driver        ',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontFamily: "ChelseaMarket",
            ),
          ),
          Icon(
            Icons.call,
            color: Colors.white,
          )
        ],
      ),
    
  ),
      ],
    );
  }

  Widget _currentDriver() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: _showCurrentDriver
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
                                    _showCurrentDriver = false;
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

  Widget _currentClosestDriver() {
    return Align(
        alignment: Alignment.topCenter,
        child: _sosCalled
            ? Padding(
                padding: const EdgeInsets.only(top: 40.0, left: 5, right: 5),
                child: Card(
                  elevation: 2.0,
                  color: Color(0xFF0a97b0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    height: 205,
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
                                  "Emergency",
                                  style: TextStyle(
                                    fontFamily: "WorkSansMedium",
                                    fontSize: 20.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            
                              Padding(
                                padding: const EdgeInsets.only(left: 0.0),
                                child: Text(
                                  " Call Nearest Driver ",
                                  style: TextStyle(
                                    fontFamily: "ChelseaMarket",
                                    fontSize: 12.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                color: Colors.white,
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _sosCalled = false;
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
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0,top: 5, bottom: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                 Text(
                                    "Note : ",
                                    style: TextStyle(
                                      fontFamily: "ChelseaMarket",
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF303960),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Use this feature only in very urgent",
                                        style: TextStyle(
                                          fontFamily: "ChelseaMarket",
                                          fontSize: 14.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "situations",
                                        style: TextStyle(
                                          fontFamily: "ChelseaMarket",
                                          fontSize: 14.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),

                              ],
                            ),
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
                          height: 108,
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
                                width: 108,
                                height: 108,
                                child: Padding(
                                  padding: const EdgeInsets.all(9.5),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: NetworkImage(
                                      _currentSOS.image,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _driverClosestDetails(_currentSOS))
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
  
  void _sosCall(var number){
    launch("tel://"+number.toString());
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
        backgroundColor: Color(0xFF0a97b0),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                "SOS",
                style: TextStyle(
                    fontFamily: "WorkSansBold",
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18),
              ),
              onPressed: () {
                print("ad");
                _sos(this._drivers);
              },
              color: Colors.red,
            ),
          )
        ],
      ),
      body: Stack(children: [
        Container(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(_intialLatitude, _intialLongitude), zoom: _zoom),
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: Set<Marker>.of(_allMarkers.values),
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
                    _allMarkers.length.toString(),
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
        _currentClosestDriver()
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
