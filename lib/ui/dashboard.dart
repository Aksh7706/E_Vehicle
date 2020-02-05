import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('Dashboard'),
      backgroundColor: Color(0xFFfbab66),
      actions: <Widget>[
      IconButton(
      icon: Icon(
        FontAwesomeIcons.powerOff,
        color: Colors.white,
      ),
      onPressed: () {
        // do something
        signOutGoogle();
        Navigator.pushReplacementNamed(context, '/home');
      },
    )
  ],
    ),
    body: Center(
      child: Text('Welcome to dashboard. Map will be displayed here')
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => {},
      tooltip: 'Increment Counter',
      child: const Icon(Icons.add),
    ),
  );
  }
}