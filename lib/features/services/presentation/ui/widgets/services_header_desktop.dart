part of '../pages/services_page.dart';

class _ServicesHeaderDesktop extends StatelessWidget {
  final ServicePageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _ServicesHeaderDesktop(
      {required this.model,
        required this.isRtl,
        required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final double screenW  = MediaQuery.of(context).size.width;
    final double contentW = _desktopContentWidth(context);
    final double hPad =
    ((screenW - contentW) / 2).clamp(16.0, double.infinity);

    final String title = _t(model.title, isRtl).isNotEmpty
        ? _t(model.title, isRtl)
        : (isRtl ? 'الخدمات' : 'Services');
    final String desc = _t(model.shortDescription, isRtl).isNotEmpty
        ? _t(model.shortDescription, isRtl)
        : (isRtl
        ? 'تقدم بيانتز مجموعة من الخدمات المصممة لدعم مبادرات التحول الرقمي في مؤسستك.'
        : 'Bayanatz offers a range of services designed to support digital transformation initiatives within your organization.');

    // Figma (Services, desktop): title Cairo Bold 64 #008037 70 px under the
    // header; description Cairo SemiBold 24, Figma "auto" line height
    // (≈ 45 px), grey (#797979 in Figma → #666666 for 4.5:1 contrast).
    return Padding(
      padding: EdgeInsets.only(left: hPad, right: hPad, top: 52.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BUG-178: one page-title style on every page.
          Text(title, style: SiteText.pageTitle(context, color: primaryColor)),
          SizedBox(height: 12.w),
          Text(desc,
              // BUG-136: description grey with ≥ 4.5:1 contrast.
              style: AppTextStyles.font14BlackRegularCairo.copyWith(
                  fontSize:   24.sp,
                  height:     1.875,
                  fontWeight: FontWeight.w600,
                  color:      SiteColors.description)),
        ],
      ),
    );
  }
}
