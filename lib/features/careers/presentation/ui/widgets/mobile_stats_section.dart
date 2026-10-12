part of '../pages/careers_page.dart';

class _MobileStatsSection extends StatelessWidget {
  final Color primary;
  final bool isRtl;
  final List<CareerStatItem> statistics;
  const _MobileStatsSection({
    required this.primary,
    required this.isRtl,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    if (statistics.isEmpty) return const SizedBox.shrink();
    return Container(
      // Figma (iPhone): white card radius 15, padding 20, 10 px between
      // items; value Playfair Display ExtraBold 32 primary, text Cairo
      // SemiBold 14 / 23 grey.
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: statistics
            .map(
              (s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRtl ? s.title.ar : s.title.en,
                  style: (isRtl ? GoogleFonts.cairo : GoogleFonts.playfairDisplay)(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isRtl ? s.shortDescription.ar : s.shortDescription.en,
                  style: StyleText.fontSize13Weight400.copyWith(
                    fontSize: 14,
                    height: 23 / 14,
                    fontWeight: FontWeight.w600,
                    color: SiteColors.description,
                  ),
                ),
              ],
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}
