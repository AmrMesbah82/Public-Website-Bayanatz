part of '../pages/services_page.dart';

class _BlogCardDesktop extends StatefulWidget {
  final BlogPostModel post;
  final bool          isRtl;
  final Color         primaryColor;
  /// Card width (the parent row uses IntrinsicHeight, so no LayoutBuilder).
  final double?       width;
  const _BlogCardDesktop({
    required this.post,
    this.isRtl = false,
    required this.primaryColor,
    this.width,
  });
  @override
  State<_BlogCardDesktop> createState() => _BlogCardDesktopState();
}

class _BlogCardDesktopState extends State<_BlogCardDesktop> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final String dateStr = _formatDate(widget.post.createdAt, widget.isRtl); // BUG-145

    // BUG-183 — Figma: white card radius 15; title Cairo SemiBold 20
    // primary; LARGE image (161×167, radius 8) on the right; date 12 px grey;
    // "Read More" 81×34.
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration:   const Duration(milliseconds: 200),
        decoration: BoxDecoration(
            color:        _kSurface,
            borderRadius: BorderRadius.circular(15.r)),
        child: Padding(
          // Figma: card 450×250, padding 20, image 161×167 (radius 12) at
          // the end, 28 px between the text column and the image.
          padding: EdgeInsets.all(20.w),
          child: Builder(builder: (context) {
            final double inner = (widget.width ?? 450.w) - 40.w;
            final double imgW = math.min(161.w, inner * 0.4);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize:       MainAxisSize.max,
                    mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_tb(widget.post.question, widget.isRtl),
                              style: StyleText.fontSize12Weight500.copyWith(
                                  fontSize:   20.sp, // Figma SemiBold 20/150 %
                                  height:     1.5,
                                  color:      widget.primaryColor,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 10.w),
                          Builder(builder: (_) {
                            final shortDesc =
                                _tb(widget.post.shortDescription, widget.isRtl);
                            if (shortDesc.trim().isEmpty) return const SizedBox.shrink();
                            return Text(
                              shortDesc,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign:
                                  widget.isRtl ? TextAlign.right : TextAlign.left,
                              // BUG-245: same description token as the service cards.
                              style: AppTextStyles.font14BlackCairoRegular.copyWith(
                                  color:      SiteColors.description,
                                  fontWeight: FontWeight.w500, // Figma Medium 16/150 %
                                  height:     1.5,
                                  fontSize:   16.sp),
                            );
                          }),
                        ],
                      ),
                      SizedBox(height: 10.w),
                      Row(
                        children: [
                          Expanded(
                            child: Text(dateStr,
                                // Figma: SemiBold 12/150 % (grey, AA contrast).
                                style: AppTextStyles.font14BlackCairoRegular.copyWith(
                                    color:      SiteColors.meta,
                                    fontWeight: FontWeight.w600,
                                    height:     1.5,
                                    fontSize:   12.sp)),
                          ),
                          _ReadMoreBtnDesktop(
                              isRtl:        widget.isRtl,
                              primaryColor: widget.primaryColor,
                              postId: widget.post.id),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 28.w),
                _svgBlogImage(
                    url:          widget.post.imageUrl,
                    width:        imgW,
                    height:       imgW * 167 / 161,
                    radius:       12.w,
                    primaryColor: widget.primaryColor),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ─── Read-more buttons ────────────────────────────────────────────────────────
