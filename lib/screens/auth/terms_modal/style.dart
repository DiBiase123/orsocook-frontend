import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_breakpoints.dart';

class TermsModalStyle {
  static double getCardWidth(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) {
      return MediaQuery.of(context).size.width * 0.5;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return MediaQuery.of(context).size.width * 0.7;
    } else {
      return MediaQuery.of(context).size.width * 0.9;
    }
  }

  static double getCardHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * 0.75;
  }

  static const double borderRadius = 24.0;
}
