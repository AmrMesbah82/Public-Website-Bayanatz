part of '../pages/home_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHARED PRIMITIVE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _CircleIcon extends StatelessWidget {
  final String iconUrl;
  final Color? iconColor;
  /// Diameter; defaults to the Figma 50 px (desktop) / 44 px (phone).
  final double? size;

  const _CircleIcon({
    required this.iconUrl,
    this.iconColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    // BUG-232 / BUG-181 — Figma: service icons in 50×50 white circles with a
    // clearly visible glyph; sized with the layout (was 36 px / 12 px glyph).
    final bool mobile = MediaQuery.sizeOf(context).width < 600;
    final double d = size ?? (mobile ? 44 : 50.w);
    return Container(
      width: d, height: d,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: ClipOval(
        child: _smartImage(
          url:         iconUrl,
          width:       d * 0.96,
          height:      d * 0.96,
          fit:         BoxFit.contain,
          colorFilter: iconColor,
          fallback:
          Icon(Icons.image_outlined, size: d * 0.5, color: Colors.grey),
        ),
      ),
    );
  }
}

class _SocialIconBox extends StatelessWidget {
  final String iconUrl;
  final String url;
  final Color  primary;
  final double size;

  const _SocialIconBox({
    required this.iconUrl,
    required this.url,
    required this.primary,
    this.size = 32.0,
  });

  Future<void> _openUrl() async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: url.isNotEmpty ? _openUrl : null,
      child: Container(
        width: size.w, height: size.h,
        decoration: BoxDecoration(
            border:       Border.all(color: primary, width: 1.w),
            borderRadius: BorderRadius.circular(8.r)),
        child: Center(
          child: _smartImage(
            url:      iconUrl,
            width:    (size * 0.5).w,
            height:   (size * 0.5).h,
            fit:      BoxFit.contain,
            fallback: Icon(Icons.link,
                size: (size * 0.5).sp, color: primary),
          ),
        ),
      ),
    );
  }
}

class _SectionImage extends StatelessWidget {
  final String  imageUrl;
  final double? width;
  final double  height;
  final double? radius;

  const _SectionImage({
    required this.imageUrl,
    this.width,
    required this.height,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    // BUG-181 — Figma: images sit on WHITE cards with radius 20 (they were
    // bare images on light-grey squares).
    final r = radius ?? 20.0;

    return Container(
      width: width, height: height,
      padding: EdgeInsets.all(height * 0.06),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(r),
      ),
      alignment: Alignment.center,
      child: imageUrl.isEmpty
          ? null
          : ClipRRect(
              borderRadius: BorderRadius.circular(r * 0.6),
              // BUG-68 / BUG-251: PNG/JPG/WebP and raster-in-SVG uploads.
              child: _SmartNetworkImage(
                imageUrl,
                width:  width,
                height: height,
                fit:    BoxFit.contain,
              ),
            ),
    );
  }
}

class _GreenCard extends StatelessWidget {
  final double? width;
  final double? height;
  final double? minHeight;
  final String  text;
  final Color   color;
  final double? fontSize;
  final bool    isRtl;
  /// Figma → screen factor of the desktop composition (null = 1 / phone px).
  final double? k;

  const _GreenCard({
    this.width,
    this.height,
    this.minHeight,
    required this.text,
    required this.color,
    this.fontSize,
    this.isRtl = false,
    this.k,
  });

  @override
  Widget build(BuildContext context) {
    // Figma: green text cards, radius 20, padding 15, Cairo Regular 16 white
    // (Figma "auto" line height ≈ 1.875 for Cairo).
    final double kk = k ?? 1;
    return Container(
      width:   width,
      height:  height,
      constraints: minHeight != null ? BoxConstraints(minHeight: minHeight!) : null,
      padding: EdgeInsets.all(k != null ? 15 * kk : 16),
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(8 * kk),
      ),
      child: Text(
        text,
        textAlign:     isRtl ? TextAlign.right : TextAlign.left,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        style: GoogleFonts.cairo(
          fontSize:   fontSize ?? (k != null ? math.max(13.0, 16 * kk) : 16),
          fontWeight: FontWeight.w400,
          color:      Colors.white,
          height:     k != null ? 1.875 : 1.5,
        ),
      ),
    );
  }
}
