part of '../pages/services_page.dart';

class _ServicesHeaderMobile extends StatelessWidget {
  final ServicePageModel model;
  final bool isRtl;
  final Color primaryColor;
  const _ServicesHeaderMobile(
      {required this.model,
        required this.isRtl,
        required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final String title = _t(model.title, isRtl).isNotEmpty
        ? _t(model.title, isRtl)
        : (isRtl ? 'الخدمات' : 'Services');
    final String desc = _t(model.shortDescription, isRtl).isNotEmpty
        ? _t(model.shortDescription, isRtl)
        : (isRtl
        ? 'تقدم بيانتز مجموعة من الخدمات المصممة لدعم مبادرات التحول الرقمي في مؤسستك.'
        : 'Bayanatz offers a range of services designed to support digital transformation initiatives within your organization.');

    return Padding(
      // Figma (iPhone): title Bold 36 70 px under the header; description
      // Cairo Regular 16 #213D34, line height ≈ 30.
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: SiteText.pageTitle(context, color: primaryColor)), // BUG-242
          const SizedBox(height: 10),
          Text(desc,
              style: AppTextStyles.font14BlackRegularCairo.copyWith(
                  fontSize:   16,
                  height:     1.875,
                  fontWeight: FontWeight.w400,
                  color:      const Color(0xFF213D34))),
        ],
      ),
    );
  }
}

// ─── Body dispatcher ──────────────────────────────────────────────────────────
