import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

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
    // Prevent browser back/forward navigation when scrolling horizontally
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          if (event.scrollDelta.dx != 0) {
            html.window.history.pushState(null, '', html.window.location.href);
          }
        }
      },
      child: RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
              HorizontalDragGestureRecognizer>(
            () => HorizontalDragGestureRecognizer(),
            (HorizontalDragGestureRecognizer instance) {
              instance
                ..onStart = (_) {
                  html.window.history
                      .pushState(null, '', html.window.location.href);
                }
                ..onUpdate = (_) {
                  html.window.history
                      .pushState(null, '', html.window.location.href);
                };
            },
          ),
        },
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
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
