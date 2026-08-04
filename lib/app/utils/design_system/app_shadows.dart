import 'package:flutter/material.dart';

/// Monolithic Technical Interface — Shadow System
/// No shadows except hard-offset on modals (4px 4px 0px #000000)
/// and focused inputs (2px 2px 0px #000000).
///
/// In light mode the shadow is pure black; in dark mode it is a dark gray
/// so it remains visible against the dark surface.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> modal = [
    BoxShadow(
      offset: Offset(4, 4),
      blurRadius: 0,
      spreadRadius: 0,
      color: Color(0xFF000000),
    ),
  ];

  static const List<BoxShadow> inputFocus = [
    BoxShadow(
      offset: Offset(2, 2),
      blurRadius: 0,
      spreadRadius: 0,
      color: Color(0xFF000000),
    ),
  ];
}
