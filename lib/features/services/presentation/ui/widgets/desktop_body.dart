part of '../pages/blog_detail_page.dart';

class _DesktopBody extends StatelessWidget {
  final List<BlogPostModel>  posts;
  final BlogPostModel        selected;
  final bool                 isRtl;
  final Color                primary;
  final Color                secondary;
  final ValueChanged<String> onTabChange;

  const _DesktopBody({
    required this.posts,
    required this.selected,
    required this.isRtl,
    required this.primary,
    required this.secondary,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    // BUG-189: the article column = the page content column (it was
    // 1374.w — wider than the window — so the chip row ran off the edge).
    final double pageW = SiteLayout.contentWidth(context);

    return SizedBox(
      width: pageW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Figma (article, desktop): chips 68 px under the header, title
          // Cairo Bold 40 primary ABOVE the white card, card padding 25.
          SizedBox(height: 68.w),

          // ── Tab buttons ────────────────────────────────────────────────
          // Figma: chips left-aligned at the content edge, 28 px apart;
          // they WRAP instead of running off (BUG-189).
          // QA-Oct11 #5: ONE row that scrolls sideways (no second line).
          SizedBox(
            width: pageW,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: posts.asMap().entries.map((e) {
                return Padding(
                  padding: EdgeInsetsDirectional.only(
                      end: e.key == posts.length - 1 ? 0 : 28.w),
                  child: _BlogNavButton(
                    label:
                        _tb(e.value.descriptionTitle, isRtl).isNotEmpty
                            ? _tb(e.value.descriptionTitle, isRtl)
                            : _tb(e.value.question, isRtl),
                    isSelected: selected.id == e.value.id,
                    onTap:      () => onTabChange(e.value.id),
                    isMobile:   false,
                    primary:    primary,
                    secondary:  secondary,
                  ),
                );
              }).toList(),
            ),
            ),
          ),

          SizedBox(height: 34.w),

          // Question as the article title (Figma: Bold 40 primary).
          SizedBox(
            width: pageW,
            child: Text(
              _tb(selected.question, isRtl),
              style: AppTextStyles.font28BlackSemiBoldCairo.copyWith(
                fontSize:   40.sp,
                height:     1.2,
                fontWeight: FontWeight.w700,
                color:      primary,
              ),
            ),
          ),
          SizedBox(height: 10.w),

          // ── Article body ───────────────────────────────────────────────
          Container(
            // BUG-190: Figma white card, radius 15.
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.r),
            ),
            width: pageW,
            child: Padding(
              padding: EdgeInsets.all(25.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Intro row: text left, image right ──────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // descriptionTitle — Figma Bold 24/35 #09090B
                            Text(
                              _tb(selected.descriptionTitle, isRtl),
                              style: AppTextStyles.font14BlackCairo.copyWith(
                                fontSize:   24.sp,
                                height:     35 / 24,
                                fontWeight: FontWeight.w700,
                                color:      SiteColors.title,
                              ),
                            ),
                            SizedBox(height: 12.w),
                            // shortDescription — Figma Regular 18/30 grey
                            Text(
                              _tb(selected.shortDescription, isRtl),
                              style: AppTextStyles.font12BlackCairoRegular
                                  .copyWith(
                                fontSize: 18.sp,
                                height:   30 / 18,
                                color:    SiteColors.description,
                              ),
                            ),
                            SizedBox(height: 28.w),
                            // date — Figma SemiBold 14 grey
                            Text(
                              FormatHelper.capitalize(
                                  _formatDate(selected.createdAt, isRtl)),
                              style: AppTextStyles.font10BlackCairoRegular
                                  .copyWith(
                                fontSize:   14.sp,
                                fontWeight: FontWeight.w600,
                                color:      SiteColors.meta,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15.w),

                      // Figma intro image 602×233, radius 12.
                      _BlogImage(
                        url:           selected.imageUrl,
                        width:         602.w,
                        height:        233.w,
                        radius:        12,
                        fallbackColor: secondary,
                        primaryColor:  primary,
                      ),
                    ],
                  ),

                  // ── Blocks: always shown (no read more/less) ───────────
                  SizedBox(height: 50.w),
                  _BlockList(
                    blocks:   selected.blocks,
                    isRtl:    isRtl,
                    fontSize: 24.sp, // Figma 24 px, line height 180 %
                    isMobile: false,
                    primary:  primary,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20.w),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BLOCK LIST — renders all BlogDescriptionBlocks
// ═══════════════════════════════════════════════════════════════════════════════
