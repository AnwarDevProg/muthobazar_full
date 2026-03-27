// MB Scroll Behavior
// ------------------
// Custom scroll behavior for MuthoBazar.
//
// Purpose:
// - remove Android overscroll glow
// - allow mouse + touch scrolling
// - provide consistent scroll physics across platforms

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MBScrollBehavior extends MaterialScrollBehavior {
  const MBScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };

  @override
  Widget buildOverscrollIndicator(
      BuildContext context,
      Widget child,
      ScrollableDetails details,
      ) {
    return child;
  }
}











