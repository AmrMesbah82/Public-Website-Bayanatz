part of '../pages/about_us_page.dart';

class _AboutHeaderDesktop extends StatelessWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _AboutHeaderDesktop({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
  });
  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width,
        contentW = _desktopContentWidth(context);
    final double hPad = ((screenW - contentW) / 2).clamp(16.0, double.infinity);
    final String title = _ab(model.title, isRtl).isNotEmpty
        ? _ab(model.title, isRtl)
        : (isRtl ? 'من نحن' : 'About Us');
    return Padding(
      // Figma: title 70 px under the header, tabs 30 px under the title.
      // QA-Oct11 #3: real vertical gap between the title and the tab row.
      padding: EdgeInsets.only(left: hPad, right: hPad, top: 52.w, bottom: 30.w),
      child: Text(
        title,
        style: SiteText.pageTitle(context, color: primaryColor), // BUG-178
      ),
    );
  }
}
