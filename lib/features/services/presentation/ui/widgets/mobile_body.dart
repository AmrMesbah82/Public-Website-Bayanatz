part of '../pages/blog_detail_page.dart';

class _MobileBody extends StatelessWidget {
  final List<BlogPostModel>  posts;
  final BlogPostModel        selected;
  final bool                 isRtl;
  final Color                primary;
  final Color                secondary;
  final ValueChanged<String> onTabChange;

  const _MobileBody({
    required this.posts,
    required this.selected,
    required this.isRtl,
    required this.primary,
    required this.secondary,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // BUG-169: the chips WRAP inside the screen (the strip was cut at
          // the right edge — "…government applic" — with no scroll hint and
          // no gap between chips).
          // QA-Oct11 #36: ONE row that scrolls sideways (no stacking).
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: posts.asMap().entries.map((e) {
                return Padding(
                  padding: EdgeInsetsDirectional.only(
                      end: e.key == posts.length - 1 ? 0 : 8),
                  child: _BlogNavButton(
                    label: 
                      _tb(e.value.descriptionTitle, isRtl).isNotEmpty
                          ? _tb(e.value.descriptionTitle, isRtl)
                          : _tb(e.value.question, isRtl),
                    
                    isSelected: selected.id == e.value.id,
                    onTap:      () => onTabChange(e.value.id),
                    isMobile:   true,
                    primary:    primary,
                    secondary:  secondary,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Same content + order as desktop: question title ABOVE the white
          // card, then descriptionTitle → shortDescription → date → image →
          // article blocks.
          Text(
            _tb(selected.question, isRtl),
            style: StyleText.fontSize14Weight400.copyWith(
              fontSize:   22,
              height:     1.3,
              fontWeight: FontWeight.w700,
              color:      primary,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 10.sp,vertical: 10.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── descriptionTitle (desktop: Bold, SiteColors.title) ──
                  if (_tb(selected.descriptionTitle, isRtl).isNotEmpty) ...[
                    Text(
                      _tb(selected.descriptionTitle, isRtl),
                      style: StyleText.fontSize14Weight400.copyWith(
                        fontSize:   18,
                        height:     1.45,
                        fontWeight: FontWeight.w700,
                        color:      SiteColors.title,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // ── Short description ────────────────────────────────
                  Text(
                    _tb(selected.shortDescription, isRtl),
                    style: StyleText.fontSize14Weight400.copyWith(
                      fontSize:   16,
                      height:     1.7,
                      color:      SiteColors.description,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Date (desktop: SemiBold, SiteColors.meta) ────────
                  Text(
                    FormatHelper.capitalize(
                        _formatDate(selected.createdAt, isRtl)),
                    style: StyleText.fontSize14Weight400.copyWith(
                      fontSize:   12,
                      fontWeight: FontWeight.w600,
                      color:      SiteColors.meta,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Intro image — full card width, desktop ratio 602:233 ──
                  LayoutBuilder(builder: (context, c) => _BlogImage(
                        url:           selected.imageUrl,
                        width:         c.maxWidth,
                        height:        c.maxWidth * 233 / 602,
                        radius:        10,
                        fallbackColor: secondary,
                        primaryColor:  primary,
                      )),

                  // ── Full article content — always shown (no Read More / Read Less)
                  const SizedBox(height: 20),
                  _BlockList(
                    blocks:   selected.blocks,
                    isRtl:    isRtl,
                    fontSize: 16,
                    isMobile: true,
                    primary:  primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY
// ═══════════════════════════════════════════════════════════════════════════════
