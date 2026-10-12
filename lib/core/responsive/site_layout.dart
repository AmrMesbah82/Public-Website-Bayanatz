// ******************* FILE INFO *******************
// File Name: site_layout.dart
// Purpose: ONE place for the public site's breakpoints and its ScreenUtil
//          scale (BUG-161 / BUG-162 / BUG-163 / BUG-191 / BUG-242).
//
//  Before: the ScreenUtil design size was picked ONCE from the first window
//  size and every `.w/.sp/.h` value was then multiplied by the live width,
//  so dragging the window scaled the whole page instead of re-arranging it
//  (narrow = 4 px text, wide = giant page), 541–767 px loaded an enlarged
//  desktop layout, and `.h` values grew with the window HEIGHT.
//
//  Now:
//   • the design size is recomputed on every resize (see main.dart);
//   • three layout bands — mobile < 600, tablet 600–1023, desktop ≥ 1024 —
//     the header switches to ☰ below 1024;
//   • the scale is clamped per band, so a wide window never inflates the
//     page and a narrow one never shrinks it to an unreadable size;
//   • the design HEIGHT is derived from the width scale, so `.h == .w`
//     and nothing depends on the window height any more;
//   • text never resolves below 13 px (see [SiteLayout.resolveFontSize]).

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SiteLayout {
  SiteLayout._();

  // ── Breakpoints (logical px of the browser window) ─────────────────────────
  static const double mobileMax  = 600;  // < 600   → mobile layout
  static const double desktopMin = 1024; // ≥ 1024  → desktop layout (+ full menu)
  static const double wideMin    = 1440; // ≥ 1440  → wide (content capped)

  /// Smallest font size any `.sp` value may resolve to.
  static const double minFontSize = 13;

  static bool isMobile(BuildContext c)  => MediaQuery.sizeOf(c).width <  mobileMax;
  static bool isTablet(BuildContext c)  {
    final w = MediaQuery.sizeOf(c).width;
    return w >= mobileMax && w < desktopMin;
  }
  static bool isDesktop(BuildContext c) => MediaQuery.sizeOf(c).width >= desktopMin;

  // ── Scale per band ──────────────────────────────────────────────────────────
  // `.w / .sp / .r / .h` = (Figma px of that band) × scale, so widgets are
  // written with the numbers straight from the Figma frames:
  //   • desktop ≥ 1024 → Figma desktop frame 1800 px (content column 1400):
  //     scale = window / 1800, never above 1 (content stays 1400 px on very
  //     wide screens) — e.g. 0.80 on a 1440 window, 0.76 on 1366;
  //   • tablet 600–1023 → Figma "iPad Vertical View" frame 1224 px
  //     (content column 1144) — it reuses the desktop components/sizes;
  //   • mobile < 600 → Figma iPhone frame 375 px.
  static const double figmaDesktopFrame = 1800;
  static const double figmaTabletFrame  = 1224;
  static const double figmaMobileFrame  = 375;

  static double scaleFor(double width) {
    if (width < mobileMax) {
      return (width / figmaMobileFrame).clamp(0.85, 1.2).toDouble();
    }
    if (width < desktopMin) {
      return width / figmaTabletFrame;
    }
    return math.min(1.0, width / figmaDesktopFrame);
  }

  /// Design size handed to ScreenUtil for the current window.
  /// `designWidth = width / scale` makes `.w` equal to [scaleFor]; the height is
  /// derived from the SAME scale (with ScreenUtil's split-screen 700 px floor)
  /// so `.h` and `.r` follow the width only — never the window height.
  static Size designSizeFor(Size screen) {
    final double s = scaleFor(screen.width);
    final double h = math.max(screen.height, 700);
    return Size(screen.width / s, h / s);
  }

  /// Font-size resolver for ScreenUtil: width scale, but never below 13 px
  /// (or below the design value itself when that is smaller than 13).
  static double resolveFontSize(num fontSize, ScreenUtil instance) {
    final double v = fontSize * instance.scaleWidth;
    final double floor = math.min(fontSize.toDouble(), minFontSize);
    return v < floor ? floor : v;
  }

  // ── Content column ──────────────────────────────────────────────────────────
  // Figma (file MESBAH › page "BAYANATZ WEB"):
  //   • desktop frames are 1800 wide with a 1400 px content column
  //     (header card / page body; footer card 1440);
  //   • "iPad Vertical View" frames are 1224 wide with a 1144 px column;
  //   • "iPhone View" frames are 375 wide with a 343 px column (16 px gutters).
  static const double figmaDesktopContent = 1400;
  static const double figmaTabletContent  = 1144;
  static const double figmaMobileContent  = 343;

  /// Width of the page content column shared by the header card, every page
  /// body and the footer, so they all line up (BUG-174 / BUG-178).
  /// Desktop = Figma 1400 of 1800 (≈ 78 %), never wider than 1400 px.
  static double contentWidth(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    if (w < mobileMax) return w - 32;
    if (w < desktopMin) return figmaTabletContent * scaleFor(w); // 93.5 %
    return figmaDesktopContent * scaleFor(w);
  }

  /// Figma → screen factor for the current band: the live content column
  /// divided by the Figma content column of that band. Multiply any Figma px
  /// value by this (see [fx] / [fs]) so the page keeps the Figma proportions
  /// at every window width — exactly 1.0 on a 1800 px desktop window.
  static double figK(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    final double cw = contentWidth(context);
    if (w < desktopMin && w >= mobileMax) return cw / figmaTabletContent;
    return scaleFor(w);
  }

  /// A Figma length (px) on the current screen.
  static double fx(BuildContext context, num figmaPx) =>
      figmaPx * figK(context);

  /// A Figma font size on the current screen — never below 13 px (or below
  /// the Figma value itself when that is smaller than 13).
  static double fs(BuildContext context, num figmaPx) {
    final double v = figmaPx * figK(context);
    final double floor = math.min(figmaPx.toDouble(), minFontSize);
    return v < floor ? floor : v;
  }

  /// Horizontal padding that centres [contentWidth] in the window.
  static double sidePadding(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    return ((w - contentWidth(context)) / 2).clamp(16.0, double.infinity).toDouble();
  }
}

/// Marks EVERY element below it dirty whenever [token] changes.
///
/// ScreenUtil only rebuilds public, non-const widgets on resize, so private
/// or `const` widgets kept `.w/.sp` values from the old window size (e.g. the
/// ☰ icon shrinking to 10 px after a live resize — BUG-161 / BUG-257).
class RebuildOnResize extends StatefulWidget {
  const RebuildOnResize({super.key, required this.token, required this.child});

  final Object token;
  final Widget child;

  @override
  State<RebuildOnResize> createState() => _RebuildOnResizeState();
}

class _RebuildOnResizeState extends State<RebuildOnResize> {
  @override
  void didUpdateWidget(covariant RebuildOnResize oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) {
      void mark(Element e) {
        e.markNeedsBuild();
        e.visitChildren(mark);
      }
      (context as Element).visitChildren(mark);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
