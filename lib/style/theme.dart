import 'dart:ui';

import 'package:flutter/cupertino.dart';

class Colors {

  const Colors();
  // #36d1dc → #5b86e5
  // #fbab66 #f7418c
  static const Color loginGradientStart = const Color(0xFF36d1dc);
  static const Color loginGradientEnd = const Color(0xFF5b86e5);

  static const primaryGradient = const LinearGradient(
    colors: const [loginGradientStart, loginGradientEnd],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}