part of '../pages/about_us_page.dart';

class _ValueDetailPanel extends StatelessWidget {
  final AboutValueItem value;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  /// Desktop: Figma detail card (white, 1 px primary border, radius 15,
  /// padding 20, 15 px gaps; 32 px icon, title Medium 16 #2D2D2D, text
  /// Medium 14 / 140 % grey).
  final bool figmaDesktop;
  const _ValueDetailPanel({
    required this.value,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
    this.figmaDesktop = false,
  });

  Widget _desktop(BuildContext context) {
    final String title = _ab(value.title, isRtl),
        shortDesc = _ab(value.shortDescription, isRtl),
        fullDesc = _ab(value.description, isRtl);
    final String text = shortDesc.isNotEmpty ? shortDesc : fullDesc;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: primaryColor, width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          value.iconUrl.isNotEmpty
              ? _netImg(
                  url: value.iconUrl,
                  width: 32.w,
                  height: 28.w,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                )
              : Icon(Icons.star_outline, size: 28.w, color: primaryColor),
          SizedBox(height: 15.w),
          if (title.isNotEmpty)
            Text(
              FormatHelper.capitalize(title),
              style: StyleText.fontSize14Weight700.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: SiteColors.textStrong,
              ),
            ),
          if (text.isNotEmpty) ...[
            SizedBox(height: 15.w),
            Text(
              text,
              style: StyleText.fontSize12Weight500.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: SiteColors.description,
                height: 1.4,
              ),
            ),
          ],
          if (shortDesc.isNotEmpty && fullDesc.isNotEmpty) ...[
            SizedBox(height: 10.w),
            Text(
              fullDesc,
              style: StyleText.fontSize12Weight500.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: SiteColors.description,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (figmaDesktop) return _desktop(context);
    final String title = _ab(value.title, isRtl),
        shortDesc = _ab(value.shortDescription, isRtl),
        fullDesc = _ab(value.description, isRtl);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            // BUG-214: light tint behind the icon — never the dark CMS
            // "Secondary" colour (#2D2D2D) with an inner light box.
            decoration: BoxDecoration(
              color: Color.lerp(primaryColor, Colors.white, 0.88),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: value.iconUrl.isNotEmpty
              // ✅ FIX: no colorFilter — render the real uploaded image
                  ? _netImg(
                url: value.iconUrl,
                width: 28.r,
                height: 28.r,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
              )
                  : Icon(Icons.star_outline, size: 20.sp, color: primaryColor),
            ),
          ),
          SizedBox(height: 10.h),
          if (title.isNotEmpty) ...[
            Text(
              FormatHelper.capitalize(title),
              style: StyleText.fontSize14Weight700.copyWith(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 8.h),
          ],
          if (shortDesc.isNotEmpty) ...[
            Text(
              shortDesc,
              style: StyleText.fontSize12Weight500.copyWith(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: SiteColors.textStrong,
                height: 1.6,
              ),
            ),
            SizedBox(height: 10.h),
          ],
          if (fullDesc.isNotEmpty)
            Text(
              fullDesc,
              style: StyleText.fontSize11Weight400.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: SiteColors.description,
                height: 1.7,
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// VALUES GRID — DESKTOP
// ══════════════════════════════════════════════════════════════════════════════
