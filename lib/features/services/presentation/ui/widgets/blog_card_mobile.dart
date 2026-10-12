part of '../pages/services_page.dart';

class _BlogCardMobile extends StatelessWidget {
  final BlogPostModel post;
  final bool          isRtl;
  final Color         primaryColor;
  const _BlogCardMobile({
    required this.post,
    this.isRtl = false,
    required this.primaryColor,
  });

  // Localize Western digits (0-9) to Arabic-Indic (٠-٩).
  String _arDigits(String s) {
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final buf = StringBuffer();
    for (final ch in s.split('')) {
      final code = ch.codeUnitAt(0);
      buf.write(code >= 48 && code <= 57 ? ar[code - 48] : ch);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final String dateStr = _formatDate(post.createdAt, isRtl); // BUG-145

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color:        _kSurface,
          borderRadius: BorderRadius.circular(15)),
      // Figma (iPhone read card): radius 15, padding 10; image 96 px tall
      // (radius 12); title SemiBold 20/150 % primary; text Medium 16 grey;
      // date SemiBold 12; "Read More" 81×34.
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width:  double.infinity,
                height: 96,
                child: post.imageUrl.isNotEmpty
                    ? SmartNetworkImage( // BUG-251
                  post.imageUrl,
                  width:  double.infinity,
                  height: 96,
                  fit:    BoxFit.cover,
                  fallback: Container(color: _kGreenLight),
                )
                    : Container(color: _kGreenLight),
              ),
            ),
            const SizedBox(height: 10),
            Text(_tb(post.question, isRtl),
                style: StyleText.fontSize14Weight600.copyWith(
                    fontSize: 20,
                    color:  primaryColor,
                    height: 1.5)),
            Text(_tb(post.shortDescription, isRtl),
                style: StyleText.fontSize10Weight400.copyWith(
                    fontSize:   16,
                    fontWeight: FontWeight.w500,
                    color:      SiteColors.description,
                    height:     1.5)),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(dateStr,
                    style: StyleText.fontSize12Weight400.copyWith(
                        fontSize:   12,
                        fontWeight: FontWeight.w600,
                        height:     1.5,
                        color:      SiteColors.meta)),
                const Spacer(),
                _ReadMoreBtnMobile(
                  label:        isRtl ? 'اقرأ المزيد' : 'Read More',
                  onTap:        () => context.go('/blog/${post.id}'),
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Blog Card – Desktop ──────────────────────────────────────────────────────
