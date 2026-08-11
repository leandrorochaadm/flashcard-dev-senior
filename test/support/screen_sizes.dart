import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Screen sizes for widget tests.
///
/// `WidgetTester` renders into a virtual `TestFlutterView`, never the real
/// window, so the size set here is identical on a laptop and on the CI
/// container. The default is 800x600 at a device pixel ratio of 1 — a size no
/// real user has, and wide enough to hide exactly the overflow a phone would
/// show.
///
/// The product ships as a PWA on a phone, so [phone] is the default: a test
/// that passes only at 800x600 proves nothing about the screen the study
/// session actually runs on.
abstract final class ScreenSize {
  /// iPhone 14 / Pixel 7 class, in logical pixels. The narrowest layout the
  /// app has to survive — four rating buttons across ~390 points.
  static const phone = Size(390, 844);

  /// A small phone still in use, and the real floor of the layout.
  static const smallPhone = Size(360, 640);

  /// Tablet in portrait, where `AppScaffold` stops filling the width and its
  /// `maxWidth: 880` constraint starts to matter.
  static const tablet = Size(834, 1112);
}

/// Renders the rest of the test at [size], restoring the default afterwards.
///
/// Call it before `pumpWidget`. The tear-down is registered here so no test
/// leaks a screen size into the next one — sizes set on the view are global to
/// the test binding, not scoped to the widget under test.
void useScreenSize(
  WidgetTester tester, {
  Size size = ScreenSize.phone,
  double devicePixelRatio = 3,
}) {
  tester.view
    ..devicePixelRatio = devicePixelRatio
    // physicalSize is in device pixels; the logical size the widgets lay out
    // against is this divided by the ratio.
    ..physicalSize = size * devicePixelRatio;

  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
