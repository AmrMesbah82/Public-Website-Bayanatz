// ******************* FILE INFO *******************
// File Name: job_apply_success_page.dart
// Purpose: BUG-260 — the Apply confirmation has its own address
//          (/jobs/<id>/applied) and two ways out ("Browse more jobs",
//          "Back to home"), so it is no longer a dead end and Back never
//          reopens the filled form. BUG-146: Title-case heading.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/main_widgets/app_footer.dart';
import '../../../../../core/main_widgets/app_navbar.dart';
import '../../../../../core/responsive/site_layout.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/site_tokens.dart';
import '../../../../../core/widgets/scroll_with_footer.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/controller/lang_state.dart';

class JobApplySuccessPage extends StatelessWidget {
  final String jobId;
  const JobApplySuccessPage({super.key, required this.jobId});

  static Color _hex(String hex, Color fallback) {
    final cl = hex.replaceAll('#', '');
    if (cl.length == 6) {
      final v = int.tryParse('FF$cl', radix: 16);
      if (v != null) return Color(v);
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final (String primaryHex, String bgHex) = switch (homeState) {
          HomeCmsLoaded(:final data) =>
            (data.branding.primaryColor, data.branding.backgroundColor),
          HomeCmsSaved(:final data) =>
            (data.branding.primaryColor, data.branding.backgroundColor),
          _ => ('', ''),
        };
        final Color primary = _hex(primaryHex, SiteColors.primary);
        final Color bgColor = _hex(bgHex, AppColors.background);
        final bool isRtl = context.watch<LanguageCubit>().state.isArabic;
        String t(String en, String ar) => isRtl ? ar : en;
        final bool mobile = SiteLayout.isMobile(context);

        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bgColor,
            body: Column(
              children: [
                const AppNavbar(currentRoute: '/careers'),
                Expanded(
                  child: ScrollWithFooter(
                    footer: const AppFooter(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: SiteLayout.sidePadding(context),
                          vertical: 48.h),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(mobile ? 24 : 52.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/images/success_send.svg',
                              height: mobile ? 110 : 182.h,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              t("You've Officially Applied — and We're Excited to Learn More About You!",
                                  'لقد تقدّمت رسمياً — ونحن متحمسون للتعرف عليك أكثر!'),
                              textAlign: TextAlign.center,
                              style: SiteText.sectionTitle(context,
                                  color: SiteColors.textStrong),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              t('Your application has been successfully received. Our team will review your submission and contact you if your qualifications match our current opportunities. Thank you for considering Bayanatz as the next step in your career.',
                                  'تم استلام طلبك بنجاح. سيقوم فريقنا بمراجعة طلبك والتواصل معك إذا كانت مؤهلاتك تتناسب مع الفرص المتاحة لدينا. شكراً لاختيارك بيانات زي محطةً لمسيرتك المهنية.'),
                              textAlign: TextAlign.center,
                              style: SiteText.body(context),
                            ),
                            SizedBox(height: 32.h),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 16,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () => context.go('/jobs'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 28),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(t('Browse More Jobs', 'تصفح المزيد من الوظائف'),
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: () => context.go('/'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: primary,
                                      side: BorderSide(color: primary),
                                      padding: const EdgeInsets.symmetric(horizontal: 28),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(t('Back to Home', 'العودة إلى الرئيسية'),
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
