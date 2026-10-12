part of '../pages/services_page.dart';

class _ServicesBodyMobile extends StatelessWidget {
  final ServicePageModel    model;
  final List<BlogPostModel> blogs;
  final bool                isRtl;
  final Color               primaryColor;
  final Color               secondaryColor;
  const _ServicesBodyMobile({
    required this.model,
    required this.blogs,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final String sectionTitle =
    _t(model.journeyTitle, isRtl).isNotEmpty
        ? _t(model.journeyTitle, isRtl)
        : (isRtl
        ? 'أسباب اختيار بيانتز لرحلتك الرقمية'
        : 'Reasons to Choose Bayanatz for Your Digital Journey');
    final String importantReads =
    isRtl ? 'قراءات مهمة' : 'Important Reads';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only the first 4 services, then "See All" (same as desktop).
          _ShowAllSection(builder: (context, showAll, toggle) {
            final bool hasMore = model.journeyItems.length > _kServicesPreview;
            final List<JourneyItemModel> items = hasMore && !showAll
                ? model.journeyItems.take(_kServicesPreview).toList()
                : model.journeyItems;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child:
                      _Reveal(
                        delay:     const Duration(milliseconds: 80),
                        direction: _SlideDirection.fromLeft,
                        duration:  const Duration(milliseconds: 600),
                        // Cairo SemiBold 20 / 150 % — one plain text, primary colour.
                        child: Text(
                          FormatHelper.capitalize(sectionTitle),
                          style: StyleText.fontSize14Weight700.copyWith(
                            fontSize: 20,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      )
                    ),
                    if (hasMore) ...[
                      const SizedBox(width: 10),
                      _SeeAllButton(
                        showAll: showAll,
                        isRtl: isRtl,
                        primaryColor: primaryColor,
                        onTap: toggle,
                        fontSize: 13,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ...items.asMap().entries.map((e) => _Reveal(
                delay:     Duration(milliseconds: 100 + e.key * 90),
                direction: _SlideDirection.fromBottom,
                duration:  const Duration(milliseconds: 650),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16), // Figma 16
                  child: _ServiceCardMobile(
                      item:           e.value,
                      isRtl:          isRtl,
                      primaryColor:   primaryColor,
                      secondaryColor: secondaryColor),
                ),
              )),
              ],
            );
          }),
          const SizedBox(height: 24),

          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 600),
            // Figma: "Important Reads" Cairo SemiBold 24 primary.
            child: Text(importantReads,
                style: StyleText.fontSize14Weight700.copyWith(
                  fontSize: 24,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ))
          ),
          const SizedBox(height: 15),

          ...blogs.asMap().entries.map((e) => _Reveal(
            delay:     Duration(milliseconds: 100 + e.key * 120),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 650),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _BlogCardMobile(
                  post:         e.value,
                  isRtl:        isRtl,
                  primaryColor: primaryColor),
            ),
          )),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

// ✅ FIX: colorFilter removed — SVG icons now render in their real colors
Widget _svgIconBox({
  required String url,
  required double size,
  required double radius,
  required Color  primaryColor,
  Color secondaryColor = _kGreenLight,
}) {
  // BUG-137: the dark-green icons sat on the DARK secondary colour
  // (#0F6434 on #243E2F = 1.6:1). A dark secondary is swapped for a light
  // tint of the brand colour so the icon stays visible (≥ 3:1).
  final Color tileBg = secondaryColor.computeLuminance() < 0.2
      ? Color.lerp(primaryColor, Colors.white, 0.85)!
      : secondaryColor;
  return Container(
    width:  size,
    height: size,
    decoration: BoxDecoration(
        color:        tileBg,
        borderRadius: BorderRadius.circular(radius)),
    child: Center(
      child: url.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SvgPicture.network(
          url,
          width:  size * 0.6,
          height: size * 0.6,
          fit:    BoxFit.contain,
          // ✅ NO colorFilter — renders SVG in its original colors
          placeholderBuilder: (_) => SizedBox(
            width:  size * 0.5,
            height: size * 0.5,
            child: const CircleProgress(strokeWidth: 1.5, center: false),
          ),
        ),
      )
          : Icon(Icons.miscellaneous_services_outlined,
          size: size * 0.5, color: AppColors.textButton),
    ),
  );
}

Widget _svgBlogImage({
  required String url,
  required double width,
  required double height,
  required double radius,
  Color primaryColor = _kDefaultGreen,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: SizedBox(
      width:  width,
      height: height,
      child: url.isNotEmpty
          ? SmartNetworkImage( // BUG-251: raster-in-SVG safe
        url,
        width:  width,
        height: height,
        fit:    BoxFit.cover,
        fallback: Container(color: _kGreenLight),
      )
          : Container(color: _kGreenLight),
    ),
  );
}

// ─── Service Card – Mobile / Tablet ──────────────────────────────────────────
