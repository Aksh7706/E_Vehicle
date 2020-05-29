import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import '../utils/delayed_animation.dart';
import '../style/theme.dart' as Theme;
import '../services/check_logged.dart';
import 'dashboard.dart';

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {
  //final GoogleSignIn googleSignIn = GoogleSignIn();
  final int delayedAmount = 500;
  double _scale;
  AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.white;
    _scale = 1 - _controller.value;
    return MaterialApp(
      theme: new ThemeData(
        fontFamily: "ChelseaMarket",
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          //backgroundColor: Colors.blue,
          body: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [
                Theme.Colors.loginGradientStart,
                Theme.Colors.loginGradientEnd
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: AvatarGlow(
                      endRadius: 120,
                      duration: Duration(seconds: 3),
                      glowColor: Colors.white24,
                      repeat: true,
                      repeatPauseDuration: Duration(seconds: 2),
                      startDelay: Duration(seconds: 1),
                      child: Material(
                          elevation: 8.0,
                          shape: CircleBorder(),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Image(
                                image: AssetImage('assets/img/logo.png'),
                                fit: BoxFit.cover),
                            radius: 80.0,
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  DelayedAnimation(
                    child: Text(
                      "E-Rath",
                      style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontSize: 75.0,
                          fontFamily: "ChelseaMarket",
                          color: color),
                    ),
                    delay: delayedAmount + 1000,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  DelayedAnimation(
                    child: Text(
                      "E-Vehicle System IIT Indore",
                      style: TextStyle(
                          fontSize: 20.0,
                          color: color,
                          fontFamily: "ChelseaMarket"),
                    ),
                    delay: delayedAmount + 1000,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    DelayedAnimation(
                      child: GestureDetector(
                        onTap: () {
                          // bool logged = await googleSignIn.isSignedIn();
                          // if (!logged) {
                          //   await FirebaseAuth.instance.signOut();
                          //   FirebaseUser user = await signInWithGoogle();
                          //   Navigator.of(context).push(
                          //     MaterialPageRoute(
                          //         builder: (context) => Dashboard(user: user)),
                          //   );
                          // }else{
                          //   FirebaseUser user = await FirebaseAuth.instance.currentUser();
                          //   Navigator.of(context).push(
                          //     MaterialPageRoute(
                          //         builder: (context) => Dashboard(user: user)),
                          //   );
                          // }
                           Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => Dashboard()),
                            );
                        },
                        child: Transform.scale(
                          scale: _scale,
                          child: _animatedButtonUI,
                        ),
                      ),
                      delay: delayedAmount + 2000,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    DelayedAnimation(
                      child: FlatButton(
                        child: Text(
                          "Login As Caddy Driver".toUpperCase(),
                          style: TextStyle(
                              fontFamily: "ChelseaMarket",
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: color),
                        ),
                        onPressed: ()  {
                          // bool logged = await googleSignIn.isSignedIn();
                          // if (!logged) {
                          //    Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => BoolLogged()),
                          //   );
                          // }else{
                          //   await FirebaseAuth.instance.signOut();
                          //   await googleSignIn.signOut();
                          //  Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => BoolLogged()),
                          //   );
                          // }
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BoolLogged()),
                            );
                        },
                      ),
                      delay: delayedAmount + 2000,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget get _animatedButtonUI => Container(
        height: 60,
        width: 270,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            'Continue >>',
            style: TextStyle(
              fontFamily: "ChelseaMarket",
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      );

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }
}
