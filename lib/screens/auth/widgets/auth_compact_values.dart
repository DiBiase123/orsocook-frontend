import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_utils.dart';

class AuthCompactValues {
  // Padding per l'header
  static EdgeInsets headerPadding(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 10);
    }
    if (ResponsiveBreakpoints.isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 8);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }

  // Padding per il form (bottom = 0 per eliminare spazio bianco)
  static EdgeInsets formPadding(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) {
      return const EdgeInsets.fromLTRB(24, 16, 24, 0);
    }
    if (ResponsiveBreakpoints.isTablet(context)) {
      return const EdgeInsets.fromLTRB(20, 12, 20, 0);
    }
    return const EdgeInsets.fromLTRB(16, 12, 16, 0);
  }
}
