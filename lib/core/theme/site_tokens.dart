// ******************* FILE INFO *******************
// File Name: site_tokens.dart
// Purpose: BUG-245 / BUG-136 / BUG-131 / BUG-242 — one colour + text token per
//          ROLE for the public site, so the same role looks the same on every
//          page (it used to be set inline per widget: five different greys for
//          descriptions, three reds for errors, 11 vs 13 px error text, …).
//
//  Contrast (WCAG AA ≥ 4.5:1) on both the white cards and the #F1F2ED page:
//    textStrong #2D2D2D ≈ 12:1 · body #4B5563 ≈ 6.9:1 · description #666666 ≈ 5.1:1
//    error #D32F2F ≈ 4.6:1 (beige) / 5.0:1 (white)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../responsive/site_layout.dart';

class SiteColors {
  SiteColors._();

  static const Color primary      = Color(0xFF008037);
  static const Color primaryTint  = Color(0xFFE0F0E6); // selected / focus fill
  static const Color textStrong   = Color(0xFF2D2D2D); // headings, labels, terms
  static const Color title        = Color(0xFF09090B); // card titles
  static const Color body         = Color(0xFF4B5563); // paragraphs
  static const Color description  = Color(0xFF666666); // descriptions / secondary
  static const Color meta         = Color(0xFF666666); // dates, hints, captions
  static const Color placeholder  = Color(0xFF6E6E6E); // ≥ 4.5:1 on #F1F2ED
  static const Color error        = Color(0xFFD32F2F); // the ONE error red
  static const Color page         = Color(0xFFF1F2ED); // page background
  static const Color surface      = Color(0xFFFFFFFF); // cards
  static const Color inputFill    = Color(0xFFF1F2ED); // every text field / dropdown
  static const Color chipFill     = Color(0xFFF1F2ED);
  static const Color divider      = Color(0xFFE5E7EB);
}

/// ONE size for every form control (text fields, dropdowns, phone code,
/// link fields): 36.sp tall with 10.sp inner padding.
class SiteField {
  SiteField._();

  /// Height of every one-line field and dropdown trigger.
  /// QA-Oct11 #25: 40 (was 36) — the extra 4 px is vertical padding so the
  /// text has the same room above and below it.
  static double get height => 40.sp;

  /// Inner (content) padding of every field and dropdown.
  static double get padding => 10.sp;

  /// Cairo's metrics are tall on top (ascent 1.303 em, descent 0.571 em), so
  /// with its natural line box Latin text sits LOW in a 36 px field. A 1.5
  /// line height with proportional leading puts the visual middle of the
  /// text on the middle of the box — used for every field value and hint.
  ///
  /// QA-Oct11 #4 / #17 / #25: text still sat LOW in every field. With the
  /// proportional split Cairo's tall ascent keeps most of the line box above
  /// the glyphs; an EVEN split of a 1.4 line box puts the middle of the Latin
  /// capitals / Arabic body on the middle of the box, so the value and the
  /// hint are visually centred.
  static TextStyle centred(TextStyle s) => s.copyWith(
        height: 1.4,
        leadingDistribution: TextLeadingDistribution.even,
      );
}

/// Text roles. Sizes are design px (scaled with `.sp`, floored at 13 px by
/// the ScreenUtil font resolver) — mobile and desktop share the same scale
/// steps so page titles are consistent (BUG-178 / BUG-242).
class SiteText {
  SiteText._();

  static bool _mobile(BuildContext c) => SiteLayout.isMobile(c);

  /// Page title (H1): Figma Cairo Bold 64 #008037 on desktop, 30 on phones.
  static TextStyle pageTitle(BuildContext c, {Color color = SiteColors.primary}) =>
      GoogleFonts.cairo(
        // Figma: 64 desktop, 48 on the iPad frame, 36 on the iPhone frame.
        fontSize:   _mobile(c) ? 36 : (SiteLayout.isTablet(c) ? 48.sp : 64.sp),
        fontWeight: FontWeight.w700,
        height:     1.2,
        color:      color,
      );

  /// Section title (H2): Figma 32 Bold.
  static TextStyle sectionTitle(BuildContext c, {Color color = SiteColors.primary}) =>
      GoogleFonts.cairo(
        fontSize:   _mobile(c) ? 22 : 32.sp,
        fontWeight: FontWeight.w700,
        height:     1.3,
        color:      color,
      );

  /// Card title: Figma SemiBold 20.
  static TextStyle cardTitle(BuildContext c, {Color color = SiteColors.title}) =>
      GoogleFonts.cairo(
        fontSize:   _mobile(c) ? 17 : 20.sp,
        fontWeight: FontWeight.w600,
        height:     1.35,
        color:      color,
      );

  /// Body / description text.
  static TextStyle body(BuildContext c, {Color color = SiteColors.description}) =>
      GoogleFonts.cairo(
        fontSize:   _mobile(c) ? 15 : 16.sp,
        fontWeight: FontWeight.w400,
        height:     1.6,
        color:      color,
      );

  /// Small meta text (dates, captions, chips).
  static TextStyle meta(BuildContext c, {Color color = SiteColors.meta}) =>
      GoogleFonts.cairo(
        fontSize:   _mobile(c) ? 13 : 14.sp,
        fontWeight: FontWeight.w500,
        height:     1.4,
        color:      color,
      );

  /// Form label (Figma 16 SemiBold #2D2D2D).
  static TextStyle label(BuildContext c) => GoogleFonts.cairo(
        fontSize:   _mobile(c) ? 14 : 16.sp,
        fontWeight: FontWeight.w600,
        color:      SiteColors.textStrong,
      );

  /// The ONE form error style (BUG-131): 13 px, one red, same spacing.
  static TextStyle error() => GoogleFonts.cairo(
        fontSize:   13,
        fontWeight: FontWeight.w500,
        height:     1.3,
        color:      SiteColors.error,
      );

  /// Gap between a field and its error text (BUG-131 / BUG-165).
  static const double errorGap = 6;
}
