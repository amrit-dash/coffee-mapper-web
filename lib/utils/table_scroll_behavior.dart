import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TableScrollBehavior extends ScrollBehavior {
  const TableScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Prevent browser back/forward gestures
        details.globalPosition;
      },
      child: child,
    );
  }

  //Required
  bool shouldUpdateScrollBehavior(ScrollBehavior oldDelegate) => false;

  @override
  TargetPlatform getPlatform(BuildContext context) =>
      Theme.of(context).platform;

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
