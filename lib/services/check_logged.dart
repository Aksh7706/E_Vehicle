import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../ui/login_page.dart';
import '../ui/host.dart';

// This Part Handles If The Driver Is Logged In Or Not
// Since CurrentUser Method is an async method hence we use future builder here
// If Not Logged -> Goto Login Page
// If Logged -> Go To Driver's Page

class BoolLogged extends StatelessWidget {
  const BoolLogged({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.hasData) {
              FirebaseUser user = snapshot.data;
              return Host(user);
            } else {
              /// other way there is no user logged.
              return LoginPage();
            }
        });
  }
}
