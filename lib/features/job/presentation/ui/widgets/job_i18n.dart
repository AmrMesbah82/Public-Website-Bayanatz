// ******************* FILE INFO *******************
// File Name: job_i18n.dart
// Purpose: BUG-217 / BUG-111 / BUG-234 / BUG-203 — job values shown in the
//          page language, and the shared salary / location / department
//          formatting used by the Jobs list, the Job page and the Apply header.
//
//  • Department: jobs store the ENGLISH department name; the Arabic name is
//    resolved from admin › Departments (Name_Ar) at render time.
//  • Location: jobs store the English office name chosen in admin; the
//    Arabic name comes from the Contact page office list (bilingual) or a
//    small built-in dictionary.
//  • Currency: the stored code (EGP, SAR …) is shown as an Arabic symbol in
//    Arabic and is ALWAYS appended to the salary range (BUG-111).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../contact_us/presentation/controller/contact_us_location_cubit.dart';
import '../../../../contact_us/presentation/controller/contact_us_location_state.dart';
import '../../../../departments/presentation/controller/department_cubit.dart';
import '../../../../departments/presentation/controller/department_state.dart';
import '../../../../departments/data/models/department_model.dart';
import '../../../../contact_us/data/models/contact_us_model_location.dart';
import '../../../../../core/widgets/format_helper.dart';
import '../../../../../core/theme/new_theme.dart';

const Map<String, String> _kCurrencyAr = {
  'EGP': 'ج.م',
  'SAR': 'ر.س',
  'AED': 'د.إ',
  'KWD': 'د.ك',
  'QAR': 'ر.ق',
  'BHD': 'د.ب',
  'OMR': 'ر.ع',
  'JOD': 'د.أ',
  'USD': 'دولار',
  'EUR': 'يورو',
  'GBP': 'جنيه إسترليني',
};

const Map<String, String> _kPlacesAr = {
  'cairo': 'القاهرة',
  'giza': 'الجيزة',
  'alexandria': 'الإسكندرية',
  'egypt': 'مصر',
  'riyadh': 'الرياض',
  'jeddah': 'جدة',
  'saudi arabia': 'السعودية',
  'ksa': 'السعودية',
  'dubai': 'دبي',
  'abu dhabi': 'أبوظبي',
  'uae': 'الإمارات',
  'united arab emirates': 'الإمارات',
  'kuwait': 'الكويت',
  'doha': 'الدوحة',
  'qatar': 'قطر',
  'amman': 'عمّان',
  'jordan': 'الأردن',
  'remote': 'عن بُعد',
};

/// "EGP" → "ج.م" in Arabic; the code itself in English.
String jobCurrency(String code, bool ar) {
  final c = code.trim().toUpperCase();
  if (c.isEmpty) return '';
  return ar ? (_kCurrencyAr[c] ?? c) : c;
}

/// "10000 - 20000 EGP" — the currency is always shown (BUG-111). The range
/// and its currency are joined with no-break spaces so the currency never
/// wraps onto its own line (BUG-243).
String jobSalaryRange(num? min, num? max, String currency, bool ar) {
  final lo = (min ?? 0).toInt().toString();
  final hi = (max ?? 0).toInt().toString();
  var range = '$lo - $hi';
  if (ar) range = FormDateTimeHelper.toArabicDigits(range);
  final cur = jobCurrency(currency, ar);
  return cur.isEmpty ? range : '$range $cur';
}

/// Department name in the page language (BUG-217).
String jobDepartment(BuildContext context, String en, bool ar) {
  if (!ar || en.trim().isEmpty) return en;
  try {
    final state = context.read<DepartmentCubit>().state;
    final List<DepartmentModel> list = switch (state) {
      DepartmentLoaded(:final departments) => departments,
      DepartmentError(:final lastDepartments) => lastDepartments ?? const [],
      _ => const [],
    };
    for (final d in list) {
      if (d.nameEn.trim().toLowerCase() == en.trim().toLowerCase() &&
          d.nameAr.trim().isNotEmpty) {
        return d.nameAr;
      }
    }
  } catch (_) {/* no DepartmentCubit in scope (admin preview) */}
  return en;
}

/// Location in the page language (BUG-217 / BUG-234).
String jobLocation(BuildContext context, String en, bool ar) {
  final value = en.trim();
  if (!ar || value.isEmpty) return value;
  try {
    final state = context.read<ContactUsCmsCubit>().state;
    final List<ContactOfficeLocation> offices = switch (state) {
      ContactUsCmsLoaded(:final data) => data.officeLocations,
      ContactUsCmsSaved(:final data) => data.officeLocations,
      _ => const [],
    };
    for (final o in offices) {
      if (o.locationName.en.trim().toLowerCase() == value.toLowerCase() &&
          o.locationName.ar.trim().isNotEmpty) {
        return o.locationName.ar;
      }
    }
  } catch (_) {/* no ContactUsCmsCubit in scope */}
  // Fallback: translate each comma-separated part we know.
  return value
      .split(',')
      .map((p) => _kPlacesAr[p.trim().toLowerCase()] ?? p.trim())
      .join('، ');
}


// ═══════════════════════════════════════════════════════════════════════════
// Skills — ONE chip style on the Jobs list, Job page and Apply header
// (BUG-206: Figma filled chip #F1F2ED, radius 8, Medium #797979 text, no
// border, 15 px apart). BUG-250: the "Skills:" label sits on the FIRST chip
// row and the chips wrap under the chips, not under the label.
// ═══════════════════════════════════════════════════════════════════════════

class JobSkillChip extends StatelessWidget {
  final String label;
  final bool compact;

  /// Reduce the font by this many px (the Jobs list page uses 2).
  final double fontDelta;
  const JobSkillChip({
    super.key,
    required this.label,
    this.compact = false,
    this.fontDelta = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.sizeOf(context).width < 600;
    return Container(
      // Figma: 38 px tall, padding 12, radius 8, Cairo Medium 20 grey.
      // Figma iPhone: 24 px tall, padding 8, radius 4, Medium 12 (13 kept).
      // QA-Oct11 #18 / #19 / #31 / #32: no `alignment` — an aligned
      // Container stretches to the whole Wrap width, which put every skill
      // on its own full-width line. The chip now hugs its text (the height
      // comes from the vertical padding) so skills flow side by side and
      // only wrap when the line is full.
      padding: EdgeInsets.symmetric(
          horizontal: mobile ? 8 : 12.w,
          vertical: mobile ? 4 : (compact ? 7.h : 6.w)),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2ED),
        borderRadius: BorderRadius.circular(mobile ? 4 : 8.r),
      ),
      child: Text(
        label,
        style: StyleText.fontSize14Weight500.copyWith(
          fontSize: (mobile ? 13.0 : (compact ? 14.sp : 20.sp)) - fontDelta,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF666666),
          height: 1.3,
        ),
      ),
    );
  }
}

class JobSkillsRow extends StatelessWidget {
  final String label;
  final List<String> skills;
  final TextStyle labelStyle;
  final bool compact;

  /// Passed to every chip — reduce the chip font by this many px.
  final double chipFontDelta;
  const JobSkillsRow({
    super.key,
    required this.label,
    required this.skills,
    required this.labelStyle,
    this.compact = false,
    this.chipFontDelta = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool mobile = MediaQuery.sizeOf(context).width < 600;
    final double chipH = mobile ? 26 : (compact ? 32.h : 38.w);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vertically centred on the FIRST chip row only.
        SizedBox(
          height: chipH,
          child: Center(child: Text(label, style: labelStyle)),
        ),
        SizedBox(width: mobile ? 10 : 30.w), // Figma: "Skills:" → first chip
        Expanded(
          child: Wrap(
            spacing: mobile ? 8 : 15.w,
            runSpacing: 8,
            children: [
              for (final sk in skills)
                if (sk.trim().isNotEmpty) JobSkillChip(
                    label: sk, compact: compact, fontDelta: chipFontDelta),
            ],
          ),
        ),
      ],
    );
  }
}


// ═══════════════════════════════════════════════════════════════════════════
// BUG-222: ONE share component on the Jobs list cards AND the Job page — a
// square 40×40 icon button (same radius / colour everywhere) that copies the
// job link. Named "Copy link" for screen readers (BUG-205 / BUG-257).
// ═══════════════════════════════════════════════════════════════════════════

class JobShareButton extends StatelessWidget {
  final String jobId;
  final String title;
  final Color primary;
  final bool isAr;
  const JobShareButton({
    super.key,
    required this.jobId,
    required this.title,
    required this.primary,
    required this.isAr,
    this.dimension,
  });

  static const double size = 40;

  /// QA-Oct11 #37: optional square size so the share button can match the
  /// height of the Apply button next to it. Null = [size].
  final double? dimension;

  void _copy(BuildContext context) {
    final base = Uri.base.origin;
    final url  = '$base/jobs/$jobId';
    Clipboard.setData(ClipboardData(text: url));
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            isAr ? 'تم نسخ الرابط!' : 'Link Copied!',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: primary),
          ),
          content: SelectableText(
            url,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = isAr ? 'نسخ رابط الوظيفة' : 'Copy job link';
    return Tooltip(
      message: name,
      child: Semantics(
        button: true,
        label: name,
        excludeSemantics: true,
        child: SizedBox.square(
          dimension: dimension ?? size,
          child: Material(
            color: primary,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _copy(context),
              child: const Icon(Icons.share_outlined, size: 20, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
