part of '../pages/contact_us_page.dart';

class _LeftInfoCard extends StatelessWidget {
  final ContactUsCmsModel? cmsData;
  final bool  isRtl;
  final Color primaryColor;
  const _LeftInfoCard(
      {this.cmsData, required this.isRtl, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final String emailLabel  = _t(context, en: 'Email',     ar: 'البريد الإلكتروني');
    final String followLabel = _t(context, en: 'Follow Us', ar: 'تابعنا');
    final String desc = cmsData != null
        ? _bi(context, cmsData!.subDescription)
        : _t(context,
        en: 'Achieve Your Goals Efficiently And Without Disruption Through Seamless, Uninterrupted Workflows',
        ar: 'حقق أهدافك بكفاءة ودون انقطاع من خلال سير عمل سلس ومتواصل');

    return Container(
      padding: EdgeInsets.all(25.w), // Figma: 533 wide card, padding 25, radius 15
      decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(15.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Figma info card: intro SemiBold 24 #09090B (line height 40);
          // "Email" / "Follow Us" Bold 26/30 primary; address Medium 24/30
          // grey; 40 px between the groups, 12 px label → value (tightened).
          Text(desc,
              style: StyleText.fontSize18Weight500.copyWith(
                  height: 40 / 24, color: SiteColors.title,
                  fontWeight: FontWeight.w600, fontSize: 24.sp)),
          SizedBox(height: 40.w),
          Text(emailLabel,
              style: StyleText.fontSize16Weight600.copyWith(
                  color: primaryColor, fontSize: 26.sp, height: 30 / 26,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 12.w),
          // BUG-257: focusable with Tab.
          InkWell(
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
                  fontSize:   24.sp,
                  height:     30 / 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 40.w),
          Text(followLabel,
              style: StyleText.fontSize16Weight600.copyWith(
                  color: primaryColor, fontSize: 26.sp, height: 30 / 26,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 12.w),
          _SocialRow(
              cmsData: cmsData, scaled: true, primaryColor: primaryColor),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORM CARD — UPDATED WITH "OTHER" LANGUAGE OPTION + CUSTOM TEXT FIELD
// ═══════════════════════════════════════════════════════════════════════════════
