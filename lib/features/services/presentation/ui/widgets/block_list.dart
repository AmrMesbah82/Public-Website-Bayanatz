part of '../pages/blog_detail_page.dart';

class _BlockList extends StatelessWidget {
  final List<BlogDescriptionBlock> blocks;
  final bool   isRtl;
  final double fontSize;
  final bool   isMobile;
  final Color  primary; // ✅ passed in so bullet uses CMS color

  const _BlockList({
    required this.blocks,
    required this.isRtl,
    required this.fontSize,
    required this.isMobile,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    int numberingCounter = 0;

    // Numbering/bullet blocks are split on line breaks so a multi-line paste
    // (a list copied from Word, etc.) renders one numbered/bulleted line per
    // row instead of a single prefix + mashed text. Numbering continues across
    // consecutive numbering blocks and resets on a paragraph or bullet block.
    final List<Widget> children = [];

    for (final block in blocks) {
      final String text = _tb(block.content, isRtl);

      switch (block.type) {

      // ── Paragraph ───────────────────────────────────────────────
        case BlogBlockType.paragraph:
          numberingCounter = 0;
          if (text.trim().isEmpty) break;
          children.add(Padding(
            padding: EdgeInsets.only(
                top: isMobile ? 0 : 24.w, bottom: isMobile ? 10 : 0),
            child: Text(
              text,
              style: StyleText.fontSize14Weight400.copyWith(
                fontSize:   fontSize,
                height:     isMobile ? 1.7 : 1.8, // Figma 180 %
                color:      SiteColors.description, // BUG-136 / BUG-245
              ),
            ),
          ));

      // ── Numbered list item(s) ────────────────────────────────────
        case BlogBlockType.numbering:
          for (final line in _lines(text)) {
            numberingCounter++;
            final int idx = numberingCounter;
            children.add(Padding(
              padding: EdgeInsets.only(bottom: isMobile ? 10 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$idx.  ',
                    style: StyleText.fontSize14Weight400.copyWith(
                      fontSize:   fontSize,
                      height:     isMobile ? 1.7 : 1.8, // Figma 180 %
                      fontWeight: FontWeight.w700,
                      color:      SiteColors.title,
                    ),
                  ),
                  Expanded(
                    child: _richLine(
                      line,
                      StyleText.fontSize14Weight400.copyWith(
                        fontSize:   fontSize,
                        height:     isMobile ? 1.7 : 1.8, // Figma 180 %
                        fontWeight: FontWeight.w500,
                        color:      SiteColors.description,
                      ),
                    ),
                  ),
                ],
              ),
            ));
          }

      // ── Bullet point(s) ──────────────────────────────────────────
        case BlogBlockType.bulletPoint:
          numberingCounter = 0;
          for (final line in _lines(text)) {
            children.add(Padding(
              padding: EdgeInsets.only(bottom: isMobile ? 10 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top:   isMobile ? 6.0 : 6.h,
                      right: isRtl ? 0 : (isMobile ? 8.0 : 8.w),
                      left:  isRtl ? (isMobile ? 8.0 : 8.w) : 0,
                    ),
                    child: Container(
                      width:  isMobile ? 6.0 : 6.w,
                      height: isMobile ? 6.0 : 6.w,
                      decoration: BoxDecoration(
                        color: primary, // ✅ uses CMS primary color
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _richLine(
                      line,
                      StyleText.fontSize14Weight400.copyWith(
                        fontSize:   fontSize,
                        height:     isMobile ? 1.7 : 1.8, // Figma 180 %
                        fontWeight: FontWeight.w500,
                        color:      SiteColors.description,
                      ),
                    ),
                  ),
                ],
              ),
            ));
          }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// BUG-190: "Enhanced customer experience: …" — the term before the first
  /// colon is shown bold in the dark text colour (Figma), the rest grey.
  Widget _richLine(String line, TextStyle base) {
    final int c = line.indexOf(':');
    if (c <= 0 || c > 80) return Text(line, style: base);
    return Text.rich(TextSpan(children: [
      TextSpan(
        text: line.substring(0, c + 1),
        style: base.copyWith(fontWeight: FontWeight.w600, color: SiteColors.textStrong),
      ),
      TextSpan(text: line.substring(c + 1), style: base),
    ]));
  }

  // Splits block text into non-empty trimmed lines.
  List<String> _lines(String text) => text
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
}

// ═══════════════════════════════════════════════════════════════════════════════
// BLOG IMAGE — ✅ SVG-only, no Image.network fallback
// ═══════════════════════════════════════════════════════════════════════════════
