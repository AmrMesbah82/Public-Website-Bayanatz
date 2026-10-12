part of '../pages/contact_us_page.dart';

class _MobileInfoCard extends StatelessWidget {
  final ContactUsCmsModel? cmsData;
  final bool  isRtl;
  final Color primaryColor;
  const _MobileInfoCard(
      {this.cmsData, required this.isRtl, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final String emailLabel  = _t(context, en: 'Email',     ar: 'البريد الإلكتروني');
    final String followLabel = _t(context, en: 'Follow Us', ar: 'تابعنا');
    final String desc = cmsData != null
        ? _bi(context, cmsData!.subDescription)
        : _t(context,
        en: 'Achieve Your Goals Efficiently And Without Disruption',
        ar: 'حقق أهدافك بكفاءة ودون انقطاع من خلال سير عمل سلس ومتواصل');

    return Container(
      width:   double.infinity,
      // Figma (iPhone info card): radius 8, padding 10; intro SemiBold 16
      // #09090B; "Email" / "Follow Us" Bold 16/30 primary; address Medium
      // 14/30 grey; ≈ 20 px between the groups.
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(desc,
              style: StyleText.fontSize12Weight600.copyWith(
                  height: 1.6, color: SiteColors.title, fontSize: 16)), // BUG-186
          const SizedBox(height: 20),
          Text(emailLabel,
              style: StyleText.fontSize15Weight600.copyWith(
                  color: primaryColor, fontSize: 16, height: 30 / 16,
                  fontWeight: FontWeight.w700)),
          GestureDetector(
            onTap: () async {
              final email = cmsData?.email ?? 'info@bayanatz.com';
              final uri   = Uri(scheme: 'mailto', path: email);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                cmsData?.email ?? 'info@bayanatz.com',
                style: StyleText.fontSize13Weight400.copyWith(
                  color:      SiteColors.description,
                  fontSize:   14,
                  height:     30 / 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(followLabel,
              style: StyleText.fontSize15Weight600.copyWith(
                  color: primaryColor, fontSize: 16, height: 30 / 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _SocialRow(
              cmsData: cmsData, scaled: false, primaryColor: primaryColor),
        ],
      ),
    );
  }
}
