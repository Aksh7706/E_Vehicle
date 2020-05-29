import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_vehicle/ui/host.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RegisterDriver extends StatefulWidget{
  @override
  _RegisterDriverState createState()=> _RegisterDriverState();
}

class _RegisterDriverState extends State<RegisterDriver>{

  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController firstNameInputController;
  TextEditingController lastNameInputController;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;
  TextEditingController phoneNoInputController;

  File sampleImage;

  Future getImage() async{
    var tempImage=await ImagePicker.pickImage(source: ImageSource.gallery );
    setState(() {
      sampleImage=tempImage;
    });
  }

  @override
  initState() {
    firstNameInputController = new TextEditingController();
    lastNameInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
    super.initState();
  }

  Future<String> getuid(FirebaseUser user) async{
    return await user.uid;
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Register"),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: Expanded(
                child: Form(
                  key: _registerFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      FloatingActionButton(
                        onPressed: getImage,
                        mini: false,
                        tooltip: 'Upload Image',
                        child: Icon(
                            Icons.add_a_photo,
                          size: 30,
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Name*', hintText: "Gaurav"),
                        controller: firstNameInputController,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Email*', hintText: "john.doe@gmail.com"),
                        controller: emailInputController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Phone No*', hintText: "1234567890"),
                        controller: phoneNoInputController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Password*', hintText: "********"),
                        controller: pwdInputController,
                        obscureText: true,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'Confirm Password*', hintText: "********"),
                        controller: confirmPwdInputController,
                        obscureText: true,
                      ),
                      RaisedButton(
                        child: Text("Register"),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () {
                          if (_registerFormKey.currentState.validate()) {
                            if (pwdInputController.text ==
                                confirmPwdInputController.text) {
                              FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                  email: emailInputController.text,
                                  password: pwdInputController.text)
                                  .then((currentUser) => Firestore.instance
                                  .collection("Vehicle")
                                  .document(currentUser.user.uid)
                                  .setData({
                                "name": firstNameInputController.text,
                                "caddyId": "XXXX-23456",
                                "goingTowards":  "Pod 1-A",
                                "image": enableUpload(emailInputController.text),
                                "isActive": false,
                                "location": GeoPoint(22.529797,75.924519),
                                "phoneNo" : phoneNoInputController.text,
                                "rating": 5.0,
                              })
                                  .then((result) => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Host(currentUser.user) ),
                              ),
                                firstNameInputController.clear(),
                                lastNameInputController.clear(),
                                emailInputController.clear(),
                                pwdInputController.clear(),
                                confirmPwdInputController.clear(),
                                phoneNoInputController.clear()
                              })
                                  .catchError((err) => print(err)))
                                  .catchError((err) => print(err));
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Error"),
                                      content: Text("The passwords do not match"),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text("Close"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ))));
  }
  String enableUpload(String link) {
    if (sampleImage == null)
      return "https://firebasestorage.googleapis.com/v0/b/e-vehicle-project.appspot.com/o/avatar.jpg?alt=media&token=9c3a75b8-e1d5-43ea-96f2-1eb5af443944";
    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref()
        .child(link + '.jpg');
    final StorageUploadTask task = firebaseStorageRef.putFile(sampleImage);
    return "https://firebasestorage.googleapis.com/v0/b/e-vehicle-project.appspot.com/o/" +
        emailInputController.text +
        ".jpg?alt=media&token=9c3a75b8-e1d5-43ea-96f2-1eb5af443944";
  }
}