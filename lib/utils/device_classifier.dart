import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

class DeviceClassifier {
  // Soglie basate su dati reali
  static const double mobileMaxWidth = 900; // telefono landscape fino a 900px
  static const double tabletMaxWidth =
      1024; // tablet portrait (es. iPad Pro 12.9")

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileMaxWidth) {
      return DeviceType.mobile;
    } else if (width < tabletMaxWidth) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;
  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;
  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;
}
