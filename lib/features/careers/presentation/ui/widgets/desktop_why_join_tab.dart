part of '../pages/careers_page.dart';

class _DesktopWhyJoinTab extends StatelessWidget {
  final Color primary;
  final bool isTablet;
  final bool isRtl;
  final List<CareersSectionItem> items;
  const _DesktopWhyJoinTab({
    required this.primary,
    this.isTablet = false,
    required this.isRtl,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // BUG-198: reasons are compact white cards (title + text). A picture is
    // shown ONLY when one was uploaded — otherwise the text uses the full
    // width (each reason used to reserve a half-row blank area for a picture
    // the admin cannot add any more).
    // Figma (Careers › Why Join Our Team, desktop): rows sit directly on the
    // page (no card), text Cairo SemiBold 24 grey (≈ 38 px lines) next to a
    // 400 px illustration that alternates sides; 40 px between rows.
    final double svgW = isTablet ? 160.w : 400.w;
    final double svgH = isTablet ? 140.h : 280.w;
    final double gap = isTablet ? 20.w : 20.w;
    final double textFz = isTablet ? 15.sp : 24.sp;
    final double rowGap = isTablet ? 14.h : 40.w;

    return Column(
      children: List.generate(items.length, (i) {
        final item = items[i];
        final String text =
        isRtl ? item.description.ar : item.description.en;
        final String title = (isRtl ? item.title.ar : item.title.en).trim();
        final String svgUrl = item.svgUrl;
        final bool hasPicture = svgUrl.isNotEmpty;
        final imgLeft = i.isOdd;

        final Widget textBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title.isNotEmpty && i > 0) ...[
              Text(title, style: SiteText.cardTitle(context, color: primary)),
              SizedBox(height: 8.h),
            ],
            Text(
              text,
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: textFz,
                height: isTablet ? 1.7 : 1.58,
                fontWeight: isTablet ? null : FontWeight.w600,
                color: SiteColors.description,
              ),
            ),
          ],
        );

        final Widget picture = SizedBox(
          width: svgW,
          height: svgH,
          child: SmartNetworkImage(svgUrl, width: svgW, height: svgH),
        );

        return _Reveal(
          delay: Duration(milliseconds: 60 + i * 80),
          direction: imgLeft
              ? _SlideDirection.fromRight
              : _SlideDirection.fromLeft,
          duration: const Duration(milliseconds: 700),
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: rowGap),
            padding: EdgeInsets.all(isTablet ? 18.w : 0),
            decoration: BoxDecoration(
              color: isTablet ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: hasPicture
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: imgLeft
                        ? [picture, SizedBox(width: gap), Expanded(child: textBlock)]
                        : [Expanded(child: textBlock), SizedBox(width: gap), picture],
                  )
                : textBlock,
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP TAB: OUR INTERNS  (Firebase data via InternModel)
// ═══════════════════════════════════════════════════════════════════════════════
