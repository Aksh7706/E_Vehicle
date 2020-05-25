import 'package:flutter/material.dart';
import 'ui/dashboard.dart';
import 'ui/login_page.dart';
import 'ui/dashboard.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'TheGorgeousLogin',
      theme: new ThemeData(

        primarySwatch: Colors.blue,
      ),

      routes: {
        '/home' : (context) => LoginPage(),
        '/dashboard': (context) => Dashboard(),
      },
      home: new Dashboard(),
    );
  }
}

// CA:4E:FE:CB:64:A4:8C:C5:36:5C:10:FE:94:2A:52:86:07:9F:80:C0
// AIzaSyA1oxJD8SfK5pWAB7KmbKkXQx2cJfwR1gQ