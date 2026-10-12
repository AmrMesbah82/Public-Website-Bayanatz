part of '../pages/blog_detail_page.dart';

class _BlogImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final double radius;
  final Color  fallbackColor;
  final Color  primaryColor;

  const _BlogImage({
    required this.url,
    required this.width,
    required this.height,
    required this.radius,
    required this.fallbackColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width:  width,
        height: height,
        child: url.isNotEmpty
            // BUG-251: SmartNetworkImage also draws raster-in-SVG uploads
            // (blank in Safari with SvgPicture). BUG-190: cover the box.
            ? SmartNetworkImage(
          url,
          width:  width,
          height: height,
          fit:    BoxFit.cover,
          fallback: Container(color: fallbackColor),
        )
            : Container(
          color: fallbackColor,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: primaryColor,
              size:  width * 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BLOG NAV BUTTON
// ═══════════════════════════════════════════════════════════════════════════════
