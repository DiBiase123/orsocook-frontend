import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  // Breakpoint costanti
  static const double tablet = 600;
  static const double desktop = 900;
  static const double largeDesktop = 1400;

  // Check device type
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet &&
      MediaQuery.of(context).size.width < desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= largeDesktop;

  // Orientation
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  // Get current width
  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  // Get current height
  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
}
