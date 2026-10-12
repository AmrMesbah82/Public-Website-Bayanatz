part of '../pages/about_us_page.dart';

class _DesktopRightPanel extends StatelessWidget {
  final AboutPageModel model;
  final int tabIndex;
  final bool isRtl;
  final Color primaryColor, secondaryColor;
  const _DesktopRightPanel({
    required this.model,
    required this.tabIndex,
    required this.isRtl,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (tabIndex == 2) {
      final otherValues = model.values.length > 1
          ? model.values.sublist(1)
          : <AboutValueItem>[];
      return _ValuesGridDesktop(
        values: otherValues,
        isRtl: isRtl,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      );
    }
    final AboutSection section = tabIndex == 0 ? model.vision : model.mission;
    return Container(
      width: double.infinity,
      height: double.infinity,
      // Figma detail panel (876×454): white, radius 15, padding 25; text
      // Cairo SemiBold 18 grey, line height 35, 481 px wide; illustration
      // 220×254 centred vertically, 50 px after the text.
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              _ab(section.description, isRtl),
              style: StyleText.fontSize14Weight400.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: SiteColors.description,
                height: 35 / 18,
              ),
            ),
          ),
          if (section.svgUrl.isNotEmpty) ...[
            SizedBox(width: 50.w),
            Align(
              alignment: Alignment.center,
              // ✅ FIX: no colorFilter — render the real uploaded image
              child: _netImg(
                url: section.svgUrl,
                width: 220.w,
                height: 254.w,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(width: 25.w),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// VALUE DETAIL PANEL
// ══════════════════════════════════════════════════════════════════════════════
