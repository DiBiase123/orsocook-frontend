import 'package:flutter/material.dart';

// ============================================================
// DEVICE CLASSIFIER (soglie: mobile <600, tablet 600-1199, desktop ≥1200)
// ============================================================

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

class DeviceClassifier {
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1200;

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

// ============================================================
// RESPONSIVE BREAKPOINTS (breakpoint granulari + utility)
// ============================================================

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

// ============================================================
// RESPONSIVE VALUES (valori UI dinamici)
// ============================================================

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
