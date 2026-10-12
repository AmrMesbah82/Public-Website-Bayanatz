part of '../pages/services_page.dart';

class _ServicesBodyDesktop extends StatefulWidget {
  final ServicePageModel    model;
  final List<BlogPostModel> blogs;
  final bool                isRtl;
  final Color               primaryColor;
  final Color               secondaryColor;
  const _ServicesBodyDesktop({
    required this.model,
    required this.blogs,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<_ServicesBodyDesktop> createState() => _ServicesBodyDesktopState();
}

class _ServicesBodyDesktopState extends State<_ServicesBodyDesktop> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final double screenW  = MediaQuery.of(context).size.width;
    final double contentW = _desktopContentWidth(context);
    final double hPad =
    ((screenW - contentW) / 2).clamp(16.0, double.infinity);
    // Figma: 15 px between service cards, 26 px between read cards.
    final double gap = 15.w;
    final double blogGap = 26.w;

    final String sectionTitle =
    _t(widget.model.journeyTitle, widget.isRtl).isNotEmpty
        ? _t(widget.model.journeyTitle, widget.isRtl)
        : (widget.isRtl
        ? 'أسباب اختيار بيانتز لرحلتك الرقمية'
        : 'Reasons to Choose Bayanatz for Your Digital Journey');
    final String importantReads =
    widget.isRtl ? 'قراءات مهمة' : 'Important Reads';

    final bool hasMore = widget.model.journeyItems.length > 4;
    final List<JourneyItemModel> visibleItems =
    hasMore && !_showAll
        ? widget.model.journeyItems.take(4).toList()
        : widget.model.journeyItems;

    final List<List<JourneyItemModel>> rows = [];
    for (int i = 0; i < visibleItems.length; i += 4) {
      rows.add(visibleItems.skip(i).take(4).toList());
    }

    // BUG-183: 3 per row; 4 reads → 2 × 2 (no lone 4th card).
    final int blogsPerRow =
        (widget.blogs.length % 3 == 1 && widget.blogs.length.isEven) ? 2 : 3;
    final double blogCardW =
        (contentW - blogGap * (blogsPerRow - 1)) / blogsPerRow;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50.w),

          // ── Title row ──────────────────────────────────────────────────
          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 650),
            child: Row(
              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  // Figma: Cairo SemiBold 36 primary, line height 150 %.
                  child: Text(sectionTitle,
                      style: SiteText.sectionTitle(context, color: widget.primaryColor)
                          .copyWith(fontSize: 36.sp, fontWeight: FontWeight.w600, height: 1.5)),
                ),
                if (hasMore)
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showAll = !_showAll),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        // BUG-182: Figma "See All ↓" 90×32, radius 8.
                        constraints: BoxConstraints(minHeight: 32.w, minWidth: 90.w),
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:        widget.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _showAll
                                  ? (widget.isRtl ? 'عرض أقل' : 'See Less')
                                  : (widget.isRtl ? 'عرض الكل' : 'See All'),
                              style: StyleText.fontSize13Weight600.copyWith(
                                color:      Colors.white,
                                fontSize:   16.sp, // Figma SemiBold 16
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            AnimatedRotation(
                              turns:    _showAll ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.arrow_downward_rounded,
                                color: Colors.white,
                                size:  16.w,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 10.w),

          // ── Service cards ──────────────────────────────────────────────
          widget.model.journeyItems.isEmpty
              ? _Reveal(
            delay:     const Duration(milliseconds: 150),
            direction: _SlideDirection.fromBottom,
            child: Container(
              height: 100.h,
              decoration: BoxDecoration(
                  color:        _kSurface,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: _kDivider)),
              child: Center(
                child: Text(
                    widget.isRtl
                        ? 'لم تتم إضافة خدمات بعد.'
                        : 'No services added yet.',
                    style: StyleText.fontSize14Weight400.copyWith(
                        fontSize:   12.sp,
                        // BUG-17: was the divider colour — nearly invisible.
                        color:      const Color(0xFF6B6B6B))),
              ),
            ),
          )
              : AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve:    Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows.asMap().entries.map((rowEntry) {
                final int  rowIdx    = rowEntry.key;
                final bool isLastRow = rowIdx == rows.length - 1;
                return Padding(
                    padding: EdgeInsets.only(bottom: isLastRow ? 0 : gap),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize:       MainAxisSize.max,
                        children: rowEntry.value
                            .asMap()
                            .entries
                            .map((e) {
                          final int  cardIdx = e.key;
                          final bool isLast  = cardIdx == rowEntry.value.length - 1;
                          final int  delayMs = 120 + rowIdx * 60 + cardIdx * 80;
                          return Flexible(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                  end: isLast ? 0 : gap),
                              child: _Reveal(
                                delay:     Duration(milliseconds: delayMs),
                                direction: _SlideDirection.fromBottom,
                                duration:  const Duration(milliseconds: 650),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: _ServiceCardDesktop(
                                      item:           e.value,
                                      isRtl:          widget.isRtl,
                                      primaryColor:   widget.primaryColor,
                                      secondaryColor: widget.secondaryColor),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ));
              }).toList(),
            ),
          ),
          SizedBox(height: 50.w),

          // ── Blog section title ─────────────────────────────────────────
          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 650),
            child: Text(importantReads,
                style: SiteText.sectionTitle(context, color: widget.primaryColor)
                    .copyWith(fontSize: 36.sp, fontWeight: FontWeight.w600, height: 1.5)),
          ),
          SizedBox(height: 8.w),

          // BUG-139: cards in one row now share the SAME height (rows of 3,
          // IntrinsicHeight + stretch) and the date / "Read More" footer sits
          // at the bottom of each card — the 3rd card's footer was 23 px
          // higher than its neighbours when its title was shorter.
          if (widget.blogs.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int start = 0; start < widget.blogs.length; start += blogsPerRow) ...[
                  if (start > 0) SizedBox(height: blogGap),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = start;
                            i < start + blogsPerRow && i < widget.blogs.length;
                            i++) ...[
                          if (i > start) SizedBox(width: blogGap),
                          _Reveal(
                            delay:     Duration(milliseconds: 100 + i * 120),
                            direction: i == 0
                                ? _SlideDirection.fromLeft
                                : i == widget.blogs.length - 1
                                ? _SlideDirection.fromRight
                                : _SlideDirection.fromBottom,
                            duration:  const Duration(milliseconds: 700),
                            child: SizedBox(
                              width: blogCardW,
                              child: _BlogCardDesktop(
                                  post:         widget.blogs[i],
                                  isRtl:        widget.isRtl,
                                  primaryColor: widget.primaryColor,
                                  width:        blogCardW),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TABLET BODY
// ═══════════════════════════════════════════════════════════════════════════════
