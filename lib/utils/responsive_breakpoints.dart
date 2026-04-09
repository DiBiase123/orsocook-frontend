import 'package:flutter/material.dart';
import 'device_classifier.dart';

class ResponsiveBreakpoints {
  static const double xs = 0;
  static const double sm = 600;
  static const double md = 840;
  static const double lg = 1200;
  static const double xl = 1600;
  static const double xxl = 1920;

  static bool isXs(BuildContext context) =>
      MediaQuery.of(context).size.width < sm;
  static bool isSm(BuildContext context) =>
      MediaQuery.of(context).size.width >= sm &&
      MediaQuery.of(context).size.width < md;
  static bool isMd(BuildContext context) =>
      MediaQuery.of(context).size.width >= md &&
      MediaQuery.of(context).size.width < lg;
  static bool isLg(BuildContext context) =>
      MediaQuery.of(context).size.width >= lg &&
      MediaQuery.of(context).size.width < xl;
  static bool isXl(BuildContext context) =>
      MediaQuery.of(context).size.width >= xl &&
      MediaQuery.of(context).size.width < xxl;
  static bool isXxl(BuildContext context) =>
      MediaQuery.of(context).size.width >= xxl;

  static bool isMobile(BuildContext context) =>
      DeviceClassifier.isMobile(context);
  static bool isTablet(BuildContext context) =>
      DeviceClassifier.isTablet(context);
  static bool isDesktop(BuildContext context) =>
      DeviceClassifier.isDesktop(context);
  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1600;

  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= xxl) return 48;
    if (width >= xl) return 40;
    if (width >= lg) return 32;
    if (width >= md) return 24;
    if (width >= sm) return 20;
    return 16;
  }

  static double getVerticalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= xxl) return 40;
    if (width >= xl) return 32;
    if (width >= lg) return 24;
    if (width >= md) return 20;
    if (width >= sm) return 16;
    return 12;
  }

  static double getFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width >= xxl) return baseSize + 8;
    if (width >= xl) return baseSize + 6;
    if (width >= lg) return baseSize + 4;
    if (width >= md) return baseSize + 2;
    return baseSize;
  }

  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
}
