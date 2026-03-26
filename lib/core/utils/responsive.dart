import 'package:flutter/material.dart';

class Responsive {
  static const double _mobileBreakpoint = 600.0;
  static const double _baseScreenWidth = 375.0; // Standard mobile base width

  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  static bool isMobile(BuildContext context) => screenWidth(context) < _mobileBreakpoint;
  static bool isTablet(BuildContext context) => screenWidth(context) >= _mobileBreakpoint;

  // Scale value horizontally based on current screen width compared to base width
  static double scale(BuildContext context, double value) {
    return value * (screenWidth(context) / _baseScreenWidth);
  }

  // Scale padding/margins based on device
  static EdgeInsetsGeometry padding(BuildContext context, {double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: scale(context, horizontal),
      vertical: scale(context, vertical),
    );
  }

  // Cap text scale factor to prevet UI breaking
  static double textScaleFactor(BuildContext context) {
    final double factor = MediaQuery.textScalerOf(context).scale(1);
    return factor > 1.2 ? 1.2 : factor;
  }
}
