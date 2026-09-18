import 'package:flutter/material.dart';

/// Exact Stitch Spacing and Border Radius Tokens
class AppSpacing {
  AppSpacing._();

  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Horizontal screen margin
  static const double screenMargin = 16.0;

  // Border Radii
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 9999.0;

  // BorderRadius objects
  static final BorderRadius roundedSm = BorderRadius.circular(radiusSm);
  static final BorderRadius roundedMd = BorderRadius.circular(radiusMd);
  static final BorderRadius roundedLg = BorderRadius.circular(radiusLg);
  static final BorderRadius roundedXl = BorderRadius.circular(radiusXl);
  static final BorderRadius roundedFull = BorderRadius.circular(radiusFull);

  // Box Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A12355B),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x1412355B),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> bottomNavShadow = [
    BoxShadow(
      color: Color(0x0D12355B),
      blurRadius: 20,
      offset: Offset(0, -4),
      spreadRadius: 0,
    ),
  ];
}
