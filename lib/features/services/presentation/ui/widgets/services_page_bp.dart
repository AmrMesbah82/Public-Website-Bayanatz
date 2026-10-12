part of '../pages/services_page.dart';

class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

double _desktopContentWidth(BuildContext context) {
  final double screen  = MediaQuery.of(context).size.width;
  // Figma desktop content column (1400 of the 1800 frame).
  return SiteLayout.contentWidth(context).clamp(0.0, screen - 32.0);
}

String _monthName(int m) => const [
  '', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
][m];

String _monthNameAr(int m) => const [
  '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
][m];

String _t(BilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

String _tb(BlogBilingualText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

extension BilingualTextL10n on BilingualText {
  String l(BuildContext context) {
    final isAr  = context.read<LanguageCubit>().state.isArabic;
    final value = isAr ? ar : en;
    return value.isNotEmpty ? value : en;
  }
}

Color _parseColor(String hex, {required Color fallback}) {
  final h = hex.replaceAll('#', '');
  if (h.length == 6) {
    final value = int.tryParse('FF$h', radix: 16);
    if (value != null) return Color(value);
  }
  return fallback;
}

// ═══════════════════════════════════════════════════════════════════════════════
// SVG PRELOADER
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _preloadSvgImages(List<String> urls) =>
    // Safe preload: broken/non-SVG files are skipped quietly (no uncaught
    // XmlParserException) — see core/utils/svg_preload.dart.
    SvgPreload.preload(urls);

// ═══════════════════════════════════════════════════════════════════════════════
// ANIMATION
// ═══════════════════════════════════════════════════════════════════════════════

enum _SlideDirection { fromBottom, fromLeft, fromRight, fromTop }

// BUG-145: one date format per language (EN "29 Sep 2026", AR "٢٩ سبتمبر ٢٠٢٦").
String _formatDate(DateTime? dt, bool isRtl) {
  if (dt == null) return '';
  return FormDateTimeHelper.formatDayMonthYear(dt, arabic: isRtl);
}


// ═══════════════════════════════════════════════════════════════════════════
// "See All / See Less" for the service cards — the same behaviour on
// desktop, tablet and phones: only the first 4 services, then the button
// reveals the rest.
// ═══════════════════════════════════════════════════════════════════════════

/// How many services are shown before "See All".
const int _kServicesPreview = 4;

/// Keeps the open / closed state of a "See All" section.
class _ShowAllSection extends StatefulWidget {
  const _ShowAllSection({required this.builder});
  final Widget Function(BuildContext context, bool showAll, VoidCallback toggle)
      builder;

  @override
  State<_ShowAllSection> createState() => _ShowAllSectionState();
}

class _ShowAllSectionState extends State<_ShowAllSection> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) => widget.builder(
      context, _showAll, () => setState(() => _showAll = !_showAll));
}

/// The desktop "See All ↓" pill (primary, radius 8), sized for tablet/phone.
class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({
    required this.showAll,
    required this.isRtl,
    required this.primaryColor,
    required this.onTap,
    this.fontSize = 14,
  });
  final bool showAll;
  final bool isRtl;
  final Color primaryColor;
  final VoidCallback onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            constraints: const BoxConstraints(minHeight: 32, minWidth: 80),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  showAll
                      ? (isRtl ? 'عرض أقل' : 'See Less')
                      : (isRtl ? 'عرض الكل' : 'See All'),
                  style: StyleText.fontSize13Weight600.copyWith(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: showAll ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.arrow_downward_rounded,
                      color: Colors.white, size: fontSize + 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
