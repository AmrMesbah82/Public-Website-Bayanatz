import 'package:flutter/material.dart';
import 'package:website_app/core/custom/circle_progress.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/custom_svg.dart';
import '../../../../../core/main_widgets/app_footer.dart';
import '../../../../../core/widgets/scroll_with_footer.dart';
import '../../../../../core/main_widgets/app_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/controller/lang_state.dart';
import '../../../data/models/job_model.dart';
import '../../controller/job_cubit.dart';
import '../../controller/job_state.dart';
import 'package:website_app/core/theme/new_theme.dart';
import 'package:website_app/core/widgets/format_heper.dart';
import 'package:website_app/core/widgets/format_helper.dart';
import '../../../../../core/responsive/site_layout.dart';
import '../../../../../core/theme/site_tokens.dart';
import '../widgets/job_i18n.dart';
import '../../../../departments/presentation/controller/department_cubit.dart';

part '../widgets/localization_helper.dart';
part '../widgets/filter_tab.dart';
part '../widgets/job_card.dart';
part '../widgets/info_item.dart';
part '../widgets/view_job_btn.dart';

const Color _kGreen      = Color(0xFF2D8C4E);
// Imports used only from part files — referenced here so an IDE
// "Optimize Imports" cannot drop them.
const Type _kKeepSkillsRow = JobSkillsRow;
const Color _kKeepTokens = SiteColors.primary;
const Color _kDivider    = Color(0xFFDDE8DD);

// ─── Helper: parse hex color from Firebase branding ──────────────────────────

Color _parseColor(String hex, {required Color fallback}) {
  final h = hex.replaceAll('#', '');
  if (h.length == 6) {
    final value = int.tryParse('FF$h', radix: 16);
    if (value != null) return Color(value);
  }
  return fallback;
}

// ─── Hardcoded department EN → AR map ────────────────────────────────────────

const Map<String, String> _kDeptAr = {
  'Design':      'تصميم',
  'Engineering': 'هندسة',
  'Marketing':   'تسويق',
  'HR':          'موارد بشرية',
  'Finance':     'مالية',
};

// ─── Localization strings ─────────────────────────────────────────────────────

class JobListingsPage extends StatefulWidget {
  const JobListingsPage({super.key});

  @override
  State<JobListingsPage> createState() => _JobListingsPageState();
}

class _JobListingsPageState extends State<JobListingsPage> {
  /// Selected department raw EN key. null = "All".
  String? _selectedDept;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<JobListingCubit>();
    if (cubit.state is JobListingInitial || cubit.allJobs.isEmpty) {
      cubit.loadJobs();
    }
    // ✅ Ensure HomeCmsCubit is loaded (branding colors)
    context.read<HomeCmsCubit>().load();
  }

  List<JobPostModel> _getActiveJobs(List<JobPostModel> all) {
    // BUG-103: a job the admin shows as "Scheduled" (hiring starts later) was
    // listed because its STORED status was still "Active". Same rule as the
    // admin now: status + hiring window + max applications (jobOpenStateOf).
    return all.where((j) {
      if (j.publishStatus == 'draft') return false;
      return j.openState == JobOpenState.open;
    }).toList();
  }

  /// Returns localized display label + raw EN key for each unique department.
  /// Uses hardcoded [_kDeptAr] map for Arabic translation.
  List<_DeptItem> _departments(List<JobPostModel> active, bool isAr) {
    final keys = <String>{};
    for (final j in active) {
      if (j.department.isNotEmpty) keys.add(j.department);
    }

    final items = keys.map((key) {
      // BUG-217: Arabic name from admin › Departments (Name_Ar) first.
      String display = jobDepartment(context, key, isAr);
      if (isAr && display == key) {
        // Try exact match first, then case-insensitive fallback
        display = _kDeptAr[key] ??
            _kDeptAr.entries
                .firstWhere(
                  (e) => e.key.toLowerCase() == key.toLowerCase(),
              orElse: () => MapEntry(key, key),
            )
                .value;
      }
      return (display: display, key: key);
    }).toList()
      ..sort((a, b) => a.display.compareTo(b.display));

    return items;
  }

  List<JobPostModel> _applyFilter(List<JobPostModel> active) {
    if (_selectedDept == null) return active;
    return active
        .where((j) =>
    j.department.toLowerCase() == _selectedDept!.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // BUG-134: on phones the title and "All" chip touched the screen edge
    // (≈4 px). Same 16 px side margin as the other pages.
    final double screenW = MediaQuery.sizeOf(context).width;
    final bool isPhone = screenW < 600;
    // Same content column as the header / footer (was 1392.w — wider than
    // the window at 1440 px).
    final double contentW = SiteLayout.contentWidth(context);

    // ✅ Wrap with HomeCmsCubit BlocBuilder for dynamic background color
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {

        final Color backgroundColor = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: AppColors.background),
          HomeCmsSaved(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: AppColors.background),
          _ => AppColors.background,
        };

        // ✅ Accent/text color driven by the CMS branding (mainPage/main model),
        // NOT a hardcoded green. Falls back to the old green until branding loads.
        final Color primaryColor = switch (homeState) {
          HomeCmsLoaded(:final data) =>
              _parseColor(data.branding.primaryColor, fallback: _kGreen),
          HomeCmsSaved(:final data) =>
              _parseColor(data.branding.primaryColor, fallback: _kGreen),
          _ => _kGreen,
        };

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final l = _L(langState.isArabic);

            return BlocBuilder<JobListingCubit, JobListingState>(
              builder: (context, state) {

                // ── Loading ──────────────────────────────────────────────────
                if (state is JobListingInitial || state is JobListingLoading) {
                  return Scaffold(
                    backgroundColor: backgroundColor,
                    body: Column(
                      children: [
                        Material(
                          color: backgroundColor,
                          elevation: 0,
                          child: AppNavbar(currentRoute: '/careers'),
                        ),
                        Expanded(
                          child: const CircleProgress(),
                        ),
                        const AppFooter(),
                      ],
                    ),
                  );
                }

                // ── Extract jobs ─────────────────────────────────────────────
                List<JobPostModel> allJobs = [];
                if (state is JobListingLoaded) {
                  allJobs = state.jobs;
                } else if (state is JobListingError && state.lastJobs != null) {
                  allJobs = state.lastJobs!;
                } else {
                  allJobs = context.read<JobListingCubit>().allJobs;
                }

                // Rebuild when admin › Departments arrive: the Arabic names
                // come from DepartmentCubit, which loads AFTER the first
                // build — without this the filter kept the English names.
                try {
                  context.watch<DepartmentCubit>();
                } catch (_) {/* no DepartmentCubit (admin preview) */}

                final activeJobs  = _getActiveJobs(allJobs);
                final departments = _departments(activeJobs, l.isAr);

                // Reset stale selection
                if (_selectedDept != null &&
                    !departments.any((d) => d.key == _selectedDept)) {
                  _selectedDept = null;
                }

                final filteredJobs = _applyFilter(activeJobs);

                return Directionality(
                  textDirection: l.dir,
                  child: Scaffold(
                    backgroundColor: backgroundColor,
                    body: Column(
                      children: [
                        Material(
                          color: backgroundColor,
                          elevation: 0,
                          child: AppNavbar(currentRoute: '/careers'),
                        ),
                        Expanded(
                          child: ScrollWithFooter(
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: isPhone ? 60 : 52.w),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: SizedBox(
                                            width: contentW,
                                            child: Text(
                                              l.heroTitle,
                                              textAlign: l.isAr ? TextAlign.right : TextAlign.left,
                                              // BUG-242 / BUG-178: shared page-title style
                                              // (Jobs used a 48–55 px display size).
                                              // Jobs page: all text − 2 px.
                                              style: () {
                                                final t = SiteText.pageTitle(context, color: primaryColor);
                                                return t.copyWith(fontSize: (t.fontSize ?? 64) - 2);
                                              }(),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: isPhone ? 20 : 42.w),
                                        Center(
                                          child: SizedBox(
                                            width: contentW,
                                            // BUG-218: the filter WRAPS onto a second line —
                                            // every department reachable with mouse, wheel,
                                            // keyboard or touch (it was a cut-off scroll row).
                                            // BUG-204: separate white buttons, 30 px apart.
                                            // Figma (iPhone): the chips sit in one white
                                            // box (radius 8, padding 10, 10 px gaps).
                                            child: Container(
                                              padding: EdgeInsets.all(isPhone ? 10 : 0),
                                              decoration: isPhone
                                                  ? BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(8))
                                                  : null,
                                              // QA-Oct11 #32 / #38: ONE horizontal
                                              // row of departments that scrolls
                                              // sideways when it does not fit.
                                              child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                for (final w in <Widget>[
                                                _FilterTab(
                                                  label: l.allLabel,
                                                  isSelected: _selectedDept == null,
                                                  primary: primaryColor,
                                                  onTap: () => setState(() => _selectedDept = null),
                                                ),
                                                ...departments.map(
                                                      (dept) => _FilterTab(
                                                    label: dept.display,
                                                    isSelected: _selectedDept == dept.key,
                                                    primary: primaryColor,
                                                    onTap: () => setState(() => _selectedDept = dept.key),
                                                  ),
                                                ),
                                                ])
                                                  Padding(
                                                    padding: EdgeInsetsDirectional.only(
                                                        end: isPhone ? 10 : 30.w), // Figma 30
                                                    child: w,
                                                  ),
                                              ],
                                            ),
                                            ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: isPhone ? 35 : 40.w),
                                        Center(
                                          child: SizedBox(
                                            width: contentW,
                                            child: Text(
                                              l.sectionTitle,
                                              textAlign: l.isAr ? TextAlign.right : TextAlign.left,
                                              // Figma: Cairo Bold 36 grey.
                                              style: SiteText.sectionTitle(context,
                                                  color: SiteColors.description)
                                                  // Figma: Bold 36 desktop, Bold 20 iPhone.
                                                  .copyWith(fontSize: isPhone ? 18 : 34.sp),
                                            ),
                                          ),
                                        ),
                                        // Space between the section title and the first job card.
                                        SizedBox(height: isPhone ? 20 : 30.w),
                                        if (state is JobListingError)
                                          Center(
                                            child: SizedBox(
                                              width: contentW,
                                              child: Container(
                                                margin: EdgeInsets.only(bottom: 16.h),
                                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFEBEE),
                                                  borderRadius: BorderRadius.circular(8.r),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.error_outline, color: const Color(0xFFE53935), size: 18.sp),
                                                    SizedBox(width: 10.w),
                                                    Expanded(
                                                      child: Text(
                                                        l.errorMsg,
                                                        style: StyleText.fontSize14Weight400.copyWith(fontSize: 10.sp, color: const Color(0xFFE53935)),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => context.read<JobListingCubit>().loadJobs(),
                                                      child: Text(
                                                        l.retry,
                                                        style: StyleText.fontSize12Weight600.copyWith(
                                                          fontSize: 10.sp,
                                                          fontWeight: FontWeight.w600,
                                                          color: primaryColor,
                                                          decoration: TextDecoration.underline,
                                                          decorationColor: primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        // ── Job list (or empty illustration) ──────────────
                                        // BUG-125: the empty list showed only an
                                        // illustration — now a message + Contact link.
                                        if (filteredJobs.isEmpty)
                                          Center(
                                            child: SizedBox(
                                              width: contentW,
                                              child: Column(
                                                children: [
                                                  CustomSvg(assetPath: "assets/null.svg", width: 200.sp, height: 200.sp,),
                                                  SizedBox(height: 12.h),
                                                  Text(
                                                    _selectedDept == null ? l.noJobsAll : l.noJobsDept(_selectedDept!),
                                                    textAlign: TextAlign.center,
                                                    style: StyleText.fontSize16Weight600.copyWith(
                                                      fontSize: 14.sp,
                                                      color: AppColors.text,
                                                    ),
                                                  ),
                                                  SizedBox(height: 6.h),
                                                  Text(
                                                    l.checkBackSoon,
                                                    textAlign: TextAlign.center,
                                                    style: StyleText.fontSize14Weight400.copyWith(
                                                      fontSize: 11.sp,
                                                      color: AppColors.secondaryText,
                                                    ),
                                                  ),
                                                  SizedBox(height: 12.h),
                                                  TextButton(
                                                    onPressed: () => context.go('/contact'),
                                                    child: Text(
                                                      l.contactUs,
                                                      style: StyleText.fontSize14Weight600.copyWith(
                                                        fontSize: 12.sp,
                                                        color: primaryColor,
                                                        decoration: TextDecoration.underline,
                                                        decorationColor: primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        else
                                          Center(
                                            child: SizedBox(
                                              width: contentW,
                                              child: Column(
                                                children: [
                                                  for (final job in filteredJobs) ...[
                                                    _JobCard(
                                                      job: job,
                                                      l: l,
                                                      primary: primaryColor,
                                                    ),
                                                    SizedBox(height: isPhone ? 16.h : 25.w),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        SizedBox(height: isPhone ? 64.h : 20.w),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // BUG-65: footer scrolls with the page (was pinned).
                            footer: const AppFooter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─── Filter Tab ───────────────────────────────────────────────────────────────
