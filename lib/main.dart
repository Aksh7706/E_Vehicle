import 'package:flutter/material.dart';
import 'ui/dashboard.dart';
import 'ui/login_page.dart';
import 'ui/home.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'TheGorgeousLogin',
      theme: new ThemeData(
        fontFamily: "WorkSansMedium",
        primarySwatch: Colors.blue,
      ),

      routes: {
        '/home' : (context) => MyHome(),
        '/dashboard': (context) => Dashboard(),
      },
     home: new MyHome(),
     //home: new LoginPage(),
    );
  }
}

// CA:4E:FE:CB:64:A4:8C:C5:36:5C:10:FE:94:2A:52:86:07:9F:80:C0
// AIzaSyA1oxJD8SfK5pWAB7KmbKkXQx2cJfwR1gQ