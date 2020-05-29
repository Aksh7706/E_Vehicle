import 'package:flutter/material.dart';
import 'ui/home.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'E-Rath',
      theme: new ThemeData(
        fontFamily: "WorkSansMedium",
        primarySwatch: Colors.blue,
      ),
     home: new MyHome(),
    );
  }
}
