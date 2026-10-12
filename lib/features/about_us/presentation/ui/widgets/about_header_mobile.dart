part of '../pages/about_us_page.dart';

class _AboutHeaderMobile extends StatelessWidget {
  final AboutPageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _AboutHeaderMobile({
    required this.model,
    required this.isRtl,
    required this.primaryColor,
  });
  @override
  Widget build(BuildContext context) {
    final String title = _ab(model.title, isRtl).isNotEmpty
        ? _ab(model.title, isRtl)
        : (isRtl ? 'من نحن' : 'About Us');
    return Padding(
      // Figma (iPhone): title 70 px under the header, tabs 26 px below.
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Text(
        title, // BUG-144: show the CMS text as typed (desktop does too)
        style: SiteText.pageTitle(context, color: primaryColor), // BUG-242
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY
// ══════════════════════════════════════════════════════════════════════════════
