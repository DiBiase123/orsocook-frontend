import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

class ResponsiveValues {
  // Padding screen principali
  static EdgeInsets screenPadding(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) {
      return const EdgeInsets.all(32);
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  // Padding orizzontale
  static EdgeInsets horizontalPadding(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 32);
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16);
    }
  }

  // Padding per header del modale
  static EdgeInsets headerPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding(context).horizontal,
      vertical: gapSmall(context),
    );
  }

  // Font size titoli
  static double titleSize(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) return 28;
    if (ResponsiveBreakpoints.isTablet(context)) return 24;
    return 20;
  }

  // Font size body
  static double bodySize(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) return 16;
    if (ResponsiveBreakpoints.isTablet(context)) return 14;
    return 13;
  }

  // Altezza bottoni
  static double buttonHeight(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) return 56;
    if (ResponsiveBreakpoints.isTablet(context)) return 52;
    return 48;
  }

  // Spaziatura tra elementi (gap)
  static double gapSmall(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) return 16;
    if (ResponsiveBreakpoints.isTablet(context)) return 12;
    return 8;
  }

  static double gapMedium(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) return 24;
    if (ResponsiveBreakpoints.isTablet(context)) return 20;
    return 16;
  }

  static double gapLarge(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) return 32;
    if (ResponsiveBreakpoints.isTablet(context)) return 28;
    return 24;
  }

  static double gapExtraLarge(BuildContext context) {
    if (ResponsiveBreakpoints.isDesktop(context)) return 48;
    if (ResponsiveBreakpoints.isTablet(context)) return 40;
    return 32;
  }

  // Larghezza massima container modali
  static double modalMaxWidth(BuildContext context) {
    if (ResponsiveBreakpoints.isLargeDesktop(context)) return 600;
    if (ResponsiveBreakpoints.isDesktop(context)) return 550;
    if (ResponsiveBreakpoints.isTablet(context)) return 500;
    return MediaQuery.of(context).size.width * 0.95;
  }
}
