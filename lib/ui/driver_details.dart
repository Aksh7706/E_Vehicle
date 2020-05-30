import 'package:cloud_firestore/cloud_firestore.dart';

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
   

  getDriverName(){
    return driverName;
  }

  getRating(){
    return rating;
  }

  getIsActive(){
    return isActive;
  }

  getImage(){
    return image;
  }

  getCaddyId(){
    return caddyId;
  }

  getGoingTowards(){
    return goingTowards;
  }

  getLatLong(){
    return latlong;
  }

  getPhoneNo(){
    return phoneNo;
  }
}