part of '../pages/services_page.dart';

class _ServicesBodyTablet extends StatelessWidget {
  final ServicePageModel    model;
  final List<BlogPostModel> blogs;
  final bool                isRtl;
  final Color               primaryColor;
  final Color               secondaryColor;
  const _ServicesBodyTablet({
    required this.model,
    required this.blogs,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    // Same side margins as the navbar card (site content column), so the
    // page content lines up with the header.
    final double hPad    = ((screenW - SiteLayout.contentWidth(context)) / 2)
        .clamp(16.0, double.infinity);
    final double gap     = 12.w;
    final double cardW   = (screenW - hPad * 2 - gap) / 2;

    final String sectionTitle =
    _t(model.journeyTitle, isRtl).isNotEmpty
        ? _t(model.journeyTitle, isRtl)
        : (isRtl
        ? 'أسباب اختيار بيانتز لرحلتك الرقمية'
        : 'Reasons to Choose Bayanatz for Your Digital Journey');
    final String importantReads =
    isRtl ? 'قراءات مهمة' : 'Important Reads';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only the first 4 services, then "See All" (same as desktop).
          _ShowAllSection(builder: (context, showAll, toggle) {
            final bool hasMore = model.journeyItems.length > _kServicesPreview;
            final List<JourneyItemModel> items = hasMore && !showAll
                ? model.journeyItems.take(_kServicesPreview).toList()
                : model.journeyItems;
            final List<List<JourneyItemModel>> rows = [];
            for (int i = 0; i < items.length; i += 2) {
              rows.add(items.skip(i).take(2).toList());
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 30.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child:
                      _Reveal(
                        delay:     const Duration(milliseconds: 80),
                        direction: _SlideDirection.fromLeft,
                        duration:  const Duration(milliseconds: 600),
                        child: Text(sectionTitle,
                            style: StyleText.fontSize14Weight400.copyWith(
                                fontSize:   30  .sp, // +2
                                fontWeight: FontWeight.w900,
                                color:      primaryColor,
                                height:     1.4)),
                      )
                    ),
                    if (hasMore) ...[
                      const SizedBox(width: 12),
                      _SeeAllButton(
                        showAll: showAll,
                        isRtl: isRtl,
                        primaryColor: primaryColor,
                        onTap: toggle,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 16.7.h),
              ...rows.asMap().entries.map((rowEntry) {
                final int  rowIdx    = rowEntry.key;
                final bool isLastRow = rowIdx == rows.length - 1;
                return Padding(
                    padding: EdgeInsets.only(bottom: isLastRow ? 0 : gap),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize:       MainAxisSize.max,
                        children: rowEntry.value.asMap().entries.map((e) {
                          final int  cardIdx = e.key;
                          final bool isLast  = cardIdx == rowEntry.value.length - 1;
                          final int  delayMs = 100 + rowIdx * 60 + cardIdx * 90;
                          return Flexible(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(end: isLast ? 0 : gap),
                              child: _Reveal(
                                delay:     Duration(milliseconds: delayMs),
                                direction: _SlideDirection.fromBottom,
                                duration:  const Duration(milliseconds: 650),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: _ServiceCardMobile(
                                      item:           e.value,
                                      isRtl:          isRtl,
                                      primaryColor:   primaryColor,
                                      secondaryColor: secondaryColor),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ));
              }),
              ],
            );
          }),
          SizedBox(height: 35.9.h),

          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 600),
            child: Text(importantReads,
                style: StyleText.fontSize14Weight400.copyWith(
                    fontSize:   30.sp,
                    fontWeight: FontWeight.w900,
                    color:      primaryColor,
                    height:     1.4)),
          ),
          SizedBox(height: 16.7.h),

          // ✅ Wrap supports any number of blog posts on tablet too
          Wrap(
            spacing:    gap,
            runSpacing: gap,
            children: blogs.asMap().entries.map((e) => _Reveal(
              delay:     Duration(milliseconds: 100 + e.key * 110),
              direction: _SlideDirection.fromBottom,
              duration:  const Duration(milliseconds: 650),
              child: SizedBox(
                width: cardW,
                child: _BlogCardMobile(
                    post:         e.value,
                    isRtl:        isRtl,
                    primaryColor: primaryColor),
              ),
            )).toList(),
          ),
          SizedBox(height: 35.9.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY
// ═══════════════════════════════════════════════════════════════════════════════
