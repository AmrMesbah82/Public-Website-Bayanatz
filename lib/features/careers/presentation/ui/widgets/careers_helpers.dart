part of '../pages/careers_page.dart';

class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

// ── Content width + hPad ─────────────────────────────────────────────────────
// Figma desktop content column: 1400 px of the 1800 frame (`.w` = scale).
// The iPad frame (tablet band) uses the same components on a 1144 column.
double _desktopContentW([double? screenW]) =>
    (screenW != null && screenW < _BP.tablet) ? 1144.w : 1400.w;
double _desktopHPad(double screenW) =>
    ((screenW - _desktopContentW(screenW)) / 2).clamp(16.0, double.infinity);
double _tabletHPad() => 16.w;

// ── Deep-link tab resolution ──────────────────────────────────────────────────
int _resolveTabParam(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case 'why-join-our-team':
      return 0;
    case 'interns':
      return 1;
    case 'our-team':
      return 2;
    default:
      return 0;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANIMATION SYSTEM  (unchanged)
// ═══════════════════════════════════════════════════════════════════════════════

enum _SlideDirection { fromBottom, fromLeft, fromRight, fromTop }
