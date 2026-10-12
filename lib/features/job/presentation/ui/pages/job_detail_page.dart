// ═══════════════════════════════════════════════════════════════════
// FILE: job_detail_page.dart (Public Website — Job Detail)
// Path: lib/pages/job_detail_page.dart
// FIXED: Full bilingual support (Arabic + English)
// UPDATED: Added About Company section from AboutCompanyCubit
// FIXED: Removed duplicate bullets in Requirements/Preferred Skills sections
// ═══════════════════════════════════════════════════════════════════

import 'package:website_app/core/custom/circle_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/main_widgets/app_footer.dart';
import '../../../../../core/widgets/scroll_with_footer.dart';
import '../../../../../core/main_widgets/app_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/utils/flat_codec.dart';
import '../../../data/models/job_model.dart';
import '../../../../about_us/presentation/controller/about_us_company_cubit.dart';
import '../../../../about_us/presentation/controller/about_us_company_state.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/controller/lang_state.dart';
import 'package:website_app/core/theme/new_theme.dart';
import 'package:website_app/core/widgets/format_helper.dart';

import '../widgets/job_unavailable_view.dart';
import '../widgets/job_i18n.dart';
import '../../../../../core/utils/page_meta.dart';
import '../widgets/job_pdf.dart';
import '../../../../../core/responsive/site_layout.dart';
import '../../../../../core/theme/site_tokens.dart';

part '../widgets/labels.dart';

const Color _kGreen = Color(0xFF2D8C4E);
const Color _kDivider = Color(0xFFDDE8DD);

Color _parsePrimary(HomeCmsState state) {
  final hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.primaryColor,
    HomeCmsSaved(:final data) => data.branding.primaryColor,
    _ => '',
  };
  final cl = hex.replaceAll('#', '');
  if (cl.length == 6) {
    final value = int.tryParse('FF$cl', radix: 16);
    if (value != null) return Color(value);
  }
  return _kGreen;
}

Color _parseSecondary(HomeCmsState state) {
  final hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.secondaryColor,
    HomeCmsSaved(:final data) => data.branding.secondaryColor,
    _ => '',
  };
  final cl = hex.replaceAll('#', '');
  if (cl.length == 6) {
    final value = int.tryParse('FF$cl', radix: 16);
    if (value != null) return Color(value);
  }
  return const Color(0xFFD9D9D9);
}

Color _parseBg(HomeCmsState state) {
  final hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.backgroundColor,
    HomeCmsSaved(:final data) => data.branding.backgroundColor,
    _ => '',
  };
  final cl = hex.replaceAll('#', '');
  if (cl.length == 6) {
    final value = int.tryParse('FF$cl', radix: 16);
    if (value != null) return Color(value);
  }
  return AppColors.background;
}

// ═══════════════════════════════════════════════════════════════════════════
//  BILINGUAL LABELS
// ═══════════════════════════════════════════════════════════════════════════

class JobDetailPage extends StatefulWidget {
  final String jobId;
  const JobDetailPage({super.key, required this.jobId});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  Map<String, dynamic>? _job;
  bool _loading = true;

  /// BUG-99: the job exists but visitors may no longer read it (removed,
  /// draft, inactive) — the rules answer permission-denied.
  bool _noLongerAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadJob();
    context.read<AboutCompanyCubit>().loadAboutCompany();
  }

  Future<void> _loadJob() async {
    final DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await FirebaseFirestore.instance
          .collection('jobListings')
          .doc(widget.jobId)
          .get(const GetOptions(source: Source.server));
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _noLongerAvailable = e.code == 'permission-denied';
        });
      }
      return;
    } catch (_) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    if (!mounted) return;
    if (doc.exists && doc.data() != null) {
      setState(() {
        // Admin writes the FLAT VERSIONED format — decode to the nested map
        // this page reads (title/aboutThisPosition/requiredSkills/…).
        _job = FlatCodec.decode(doc.data()!, JobPostModel.flatTemplate);
        _loading = false;
      });
      // BUG-253: "Senior Flutter Developer — Jobs — Bayanatz".
      _publishTitle();
    } else {
      setState(() => _loading = false);
    }
  }

  /// BUG-263: real, multi-page PDF of the job with selectable text.
  Future<void> _downloadPdf(_Labels labels, bool isRtl) async {
    if (_job == null) return;
    List<String> lines(String key) => _biText(_job![key] as Map<String, dynamic>?, isRtl)
        .split('\n')
        .map((l) => l.trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''))
        .where((l) => l.isNotEmpty)
        .toList();
    final skills = (_job!['requiredSkills'] as List<dynamic>? ?? [])
        .map((s) => _biText(s['name'] as Map<String, dynamic>?, isRtl))
        .where((s) => s.isNotEmpty)
        .toList();
    final benefits = (_job!['benefits'] as List<dynamic>? ?? []).map((b) {
      final m = b as Map<String, dynamic>;
      return MapEntry(
        _biText(m['title'] as Map<String, dynamic>?, isRtl),
        _biText(m['shortDescription'] as Map<String, dynamic>?, isRtl),
      );
    }).where((e) => e.key.isNotEmpty).toList();
    await downloadJobPdf(
      title: _biText(_job!['title'] as Map<String, dynamic>?, isRtl),
      facts: [
        MapEntry(labels.hireDate, _fmtDate(_str('hiringStartDate'), isRtl)),
        MapEntry(labels.hireEndDate, _fmtDate(_str('hiringEndDate'), isRtl)),
        MapEntry(labels.workType,
            WorkTypeExt.fromString(_str('workType')).localized(isRtl)),
        MapEntry(labels.location, _location(isRtl)),
        MapEntry(labels.employmentType,
            EmploymentTypeExt.fromString(_str('employmentType')).localized(isRtl)),
        MapEntry(labels.experienceLevel,
            ExperienceLevelExt.fromString(_str('experienceLevel')).localized(isRtl)),
        MapEntry(labels.compensationRange, _salary(isRtl)),
        MapEntry(labels.requiredQualification,
            _biText(_job!['requiredQualification'] as Map<String, dynamic>?, isRtl)),
      ],
      skillsLabel: labels.skills,
      skills: skills,
      sections: [
        JobPdfSection(labels.aboutThisPosition, lines('aboutThisPosition')),
        JobPdfSection(labels.requirements, lines('requirements')),
        JobPdfSection(labels.preferredSkills, lines('preferredSkills')),
      ],
      benefitsLabel: labels.benefits,
      benefits: benefits,
      isRtl: isRtl,
    );
  }

  void _publishTitle() {
    if (_job == null || !mounted) return;
    final bool ar = context.read<LanguageCubit>().state.isArabic;
    PageMeta.setDetailTitle(
        '/jobs/${widget.jobId}', _biText(_job!['title'] as Map<String, dynamic>?, ar));
  }

  String _biText(Map<String, dynamic>? map, bool isRtl) {
    if (map == null) return '';
    return isRtl ? (map['ar'] ?? '') : (map['en'] ?? '');
  }

  String _str(String key) => _job?[key] as String? ?? '';

  /// BUG-141: same inner padding for every card (one text edge).
  double get _cardPad => MediaQuery.sizeOf(context).width < 600 ? 16 : 24.sp;

  // BUG-110: dates and values were always English on the Arabic page.
  String _fmtDate(String? iso, bool isRtl) {
    if (iso == null || iso.isEmpty) return '—';
    final dt = DateTime.tryParse(iso)?.toLocal(); // BUG-277: stored in UTC
    if (dt == null) return iso;
    return FormDateTimeHelper.formatDayMonthYear(dt, arabic: isRtl);
  }

  String _num(String text, bool isRtl) =>
      isRtl ? FormDateTimeHelper.toArabicDigits(text) : text;

  /// BUG-111: the salary always carries its currency (as on the Jobs list).
  String _salary(bool isRtl) => jobSalaryRange(
        _job!['salaryMin'] as num?,
        _job!['salaryMax'] as num?,
        _str('salaryCurrency'),
        isRtl,
      );

  /// BUG-234: On Site / Hybrid → office location, Remote → "Remote".
  String _location(bool isRtl) {
    if (WorkTypeExt.fromString(_str('workType')) == WorkType.remote) {
      return isRtl ? 'عن بُعد' : 'Remote';
    }
    return jobLocation(context, _str('location'), isRtl);
  }

  /// Apply button — Figma "Apply →". BUG-221: one fixed height.
  /// BUG-257: real focusable button.
  /// QA-Oct11 #37: the ONE height of the bottom row (Apply, share, PDF).
  double _actionHeight() =>
      MediaQuery.sizeOf(context).width < 600 ? JobShareButton.size + 8 : 60.w;

  Widget _applyButton(_Labels labels, Color primary) {
    final bool phone = MediaQuery.sizeOf(context).width < 600;
    // Figma: "Apply →" 200×60, radius 10, Cairo Medium 25 white.
    return SizedBox(
      height: _actionHeight(),
      child: ElevatedButton(
        onPressed: () => context.go('/jobs/${widget.jobId}/apply'),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: phone ? 20 : 50.w),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(phone ? 8 : 10.r)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labels.apply,
              style: StyleText.fontSize14Weight400.copyWith(
                fontSize: phone ? 16 : 25.sp,
                fontWeight: phone ? FontWeight.w700 : FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(width: phone ? 8 : 20.w),
            // QA-Oct11 #40: arrow_forward is mirrored by Flutter in RTL, so
            // it points LEFT in Arabic (arrow_back was mirrored to the right).
            Icon(Icons.arrow_forward,
                size: phone ? 18 : 25.w, color: Colors.white),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final primary = _parsePrimary(homeState);
        // ignore: unused_local_variable
        final secondary = _parseSecondary(homeState);
        final bgColor = _parseBg(homeState);
        final isRtl = context.watch<LanguageCubit>().state.isArabic;
        final labels = _Labels(isRtl);

        if (_loading) {
          return Scaffold(
            backgroundColor: bgColor,
            body: const CircleProgress(),
          );
        }

        // BUG-109: unknown id → branded page (header, footer, link to jobs).
        // BUG-99: removed / ended / draft jobs no longer open from a link.
        if (_job == null) {
          return JobUnavailableView(
            reason: _noLongerAvailable
                ? JobUnavailableReason.closed
                : JobUnavailableReason.notFound,
          );
        }
        final openState = jobOpenStateOfMap(_job!);
        if (openState == JobOpenState.closed) {
          return const JobUnavailableView(reason: JobUnavailableReason.closed);
        }
        if (openState == JobOpenState.notStarted) {
          return JobUnavailableView(
            reason: JobUnavailableReason.notStarted,
            opensOn: DateTime.tryParse(_str('hiringStartDate'))?.toLocal(), // BUG-277
          );
        }

        // BUG-134: phones got a 1000.w column (title at x≈4). 16 px margins.
        final double screenW = MediaQuery.sizeOf(context).width;
        final bool isPhone = screenW < 600;
        final double contentW = SiteLayout.contentWidth(context);
        // BUG-141: one inner left edge for every card's text.
        // Figma: the job card has 50 px padding on desktop.
        final double cardPad = isPhone ? 15 : 50.w;

        final title = _biText(_job!['title'] as Map<String, dynamic>?, isRtl);
        final about = _biText(
          _job!['aboutThisPosition'] as Map<String, dynamic>?,
          isRtl,
        );
        final requirements = _biText(
          _job!['requirements'] as Map<String, dynamic>?,
          isRtl,
        );
        final preferred = _biText(
          _job!['preferredSkills'] as Map<String, dynamic>?,
          isRtl,
        );
        final qualification = _biText(
          _job!['requiredQualification'] as Map<String, dynamic>?,
          isRtl,
        );
        final skills = (_job!['requiredSkills'] as List<dynamic>? ?? [])
            .map((s) => _biText(s['name'] as Map<String, dynamic>?, isRtl))
            .where((s) => s.isNotEmpty)
            .toList();
        final benefits = (_job!['benefits'] as List<dynamic>? ?? []);

        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bgColor,
            body: Column(
              children: [
                // ✅ Navbar — fixed at top
                AppNavbar(currentRoute: '/careers'),

                // ✅ Content — scrolls
                Expanded(
                  child: ScrollWithFooter(
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          SizedBox(height: isPhone ? 60 : 38.w),

                          // ── Centered content column ──
                          Center(
                            child: SizedBox(
                              width: contentW,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Title ── BUG-195: as typed.
                                  // QA-Oct11 #10 / #34: no Apply button next
                                  // to the title (phone and desktop) — Apply
                                  // stays at the bottom of the card.
                                  Text(
                                    title,
                                    style: SiteText.pageTitle(context, color: primary),
                                  ),
                                  SizedBox(height: isPhone ? 24.h : 38.w),

                                  // ── ONE white card (Figma 451:15249) ──
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(cardPad),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Figma: Cairo Medium 30 black.
                                        Text(
                                          title,
                                          // Figma: Medium 30 (desktop) / 16 (iPhone), black.
                                          style: SiteText.cardTitle(context, color: Colors.black)
                                              .copyWith(
                                                  fontSize: isPhone ? 16 : 30.sp,
                                                  fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(height: isPhone ? 12.h : 20.w),
                                        Divider(color: _kDivider, height: 1),
                                        SizedBox(height: isPhone ? 16.h : 20.w),
                                        _infoRow(
                                          labels.hireDate,
                                          _fmtDate(_str('hiringStartDate'), isRtl),
                                          labels.hireEndDate,
                                          _fmtDate(_str('hiringEndDate'), isRtl),
                                          primary,
                                        ),
                                        SizedBox(height: isPhone ? 10.h : 8.w),
                                        _infoRow(
                                          labels.workType,
                                          WorkTypeExt.fromString(_str('workType')).localized(isRtl),
                                          _location(isRtl).isEmpty ? '' : labels.location,
                                          _location(isRtl),
                                          primary,
                                        ),
                                        SizedBox(height: isPhone ? 10.h : 8.w),
                                        _infoRow(
                                          labels.employmentType,
                                          EmploymentTypeExt.fromString(_str('employmentType')).localized(isRtl),
                                          labels.employmentDuration,
                                          _num(
                                            EmploymentDurationExt.fromString(_str('employmentDurationType')) == EmploymentDuration.open
                                                ? EmploymentDuration.open.localized(isRtl)
                                                : '${_str('employmentDurationText')} ${EmploymentDurationExt.fromString(_str('employmentDurationType')).localized(isRtl)}',
                                            isRtl,
                                          ),
                                          primary,
                                        ),
                                        SizedBox(height: isPhone ? 10.h : 8.w),
                                        _infoRow(
                                          labels.experienceLevel,
                                          ExperienceLevelExt.fromString(_str('experienceLevel')).localized(isRtl),
                                          labels.compensationRange,
                                          _salary(isRtl),
                                          primary,
                                        ),
                                        SizedBox(height: isPhone ? 10.h : 8.w),
                                        _singleInfo(
                                          labels.requiredQualification,
                                          qualification,
                                          primary,
                                        ),
                                        if (skills.isNotEmpty) ...[
                                          SizedBox(height: isPhone ? 14.h : 8.w),
                                          // BUG-206 / BUG-250: shared chip
                                          // style, label on the first chip row.
                                          JobSkillsRow(
                                            label: labels.skills,
                                            skills: skills,
                                            // Figma: "Skills:" Medium 24 grey.
                                            labelStyle: StyleText.fontSize14Weight600.copyWith(
                                              fontSize: isPhone ? 14 : 24.sp,
                                              fontWeight: FontWeight.w500,
                                              color: SiteColors.description,
                                            ),
                                          ),
                                        ],
                                        SizedBox(height: isPhone ? 24.h : 25.w),

                                        // BUG-205: Figma sections — no extra
                                        // "About Company" block.
                                        if (about.isNotEmpty)
                                          _textSection(labels.aboutThisPosition, about, primary),
                                        if (requirements.isNotEmpty)
                                          _textSection(labels.requirements, requirements, primary),
                                        if (preferred.isNotEmpty)
                                          _textSection(labels.preferredSkills, preferred, primary),
                                        if (benefits.isNotEmpty)
                                          _benefitsSection(labels, benefits, primary, isRtl, isPhone),

                                        // ── Bottom buttons ── BUG-221: inside
                                        // the card, on the same edges as the
                                        // section boxes above, one height.
                                        // BUG-222: the shared square share
                                        // button ("Copy link").
                                        SizedBox(height: isPhone ? 8.h : 5.w), // + 25 box margin = Figma 30
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                JobShareButton(
                                                  jobId: widget.jobId,
                                                  title: _biText(_job!['title'] as Map<String, dynamic>?, false),
                                                  primary: primary,
                                                  isAr: isRtl,
                                                  // QA-Oct11 #37: same height as Apply.
                                                  dimension: _actionHeight(),
                                                ),
                                                const SizedBox(width: 8),
                                                // BUG-263: printable PDF.
                                                Tooltip(
                                                  message: labels.downloadPdf,
                                                  child: SizedBox.square(
                                                    // QA-Oct11 #37: same height as Apply.
                                                    dimension: _actionHeight(),
                                                    child: OutlinedButton(
                                                      onPressed: () => _downloadPdf(labels, isRtl),
                                                      style: OutlinedButton.styleFrom(
                                                        padding: EdgeInsets.zero,
                                                        foregroundColor: primary,
                                                        side: BorderSide(color: primary),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8)),
                                                      ),
                                                      child: Semantics(
                                                        label: labels.downloadPdf,
                                                        child: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            _applyButton(labels, primary),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: isPhone ? 64.h : 20.w),
                                ],
                              ),
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
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _infoRow(String l1, String v1, String l2, String v2, Color primary) {
    // Phones: one value per line (nothing squeezed into half a row).
    if (MediaQuery.sizeOf(context).width < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (l1.isNotEmpty) _singleInfo(l1, v1, primary),
          if (l2.isNotEmpty) ...[
            const SizedBox(height: 8),
            _singleInfo(l2, v2, primary),
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Figma: the second column starts 830 px into the 1300 px card body.
        Expanded(
            flex: 830,
            child: l1.isNotEmpty ? _singleInfo(l1, v1, primary) : const SizedBox()),
        Expanded(
            flex: 470,
            child: l2.isNotEmpty ? _singleInfo(l2, v2, primary) : const SizedBox()),
      ],
    );
  }

  Widget _singleInfo(String label, String value, Color primary) {
    final bool phone = MediaQuery.sizeOf(context).width < 600;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            // Figma: label Medium 24 grey, value SemiBold 24 primary.
            style: StyleText.fontSize14Weight500.copyWith(
              fontSize: phone ? 14 : 24.sp,
              height: phone ? 20 / 14 : 1.4,
              fontWeight: FontWeight.w500,
              color: SiteColors.description,
            ),
          ),
          // BUG-195: admin text exactly as typed (no forced Title Case).
          TextSpan(
            text: value,
            style: StyleText.fontSize14Weight600.copyWith(
              fontSize: phone ? 14 : 24.sp,
              height: phone ? 20 / 14 : 1.4,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  /// BUG-205 — Figma section: #F1F2ED box (radius 15) inside the white card,
  /// heading Cairo Bold primary, body as a bullet list.
  Widget _sectionBox({required String title, required Color primary, required List<Widget> children}) {
    final bool phone = MediaQuery.sizeOf(context).width < 600;
    return Container(
      width: double.infinity,
      // Figma: #F1F2ED box, radius 15, padding 25, 25 px apart; heading
      // Cairo Bold 32 primary, 15 px above the list.
      margin: EdgeInsets.only(bottom: phone ? 20.h : 25.w),
      padding: EdgeInsets.all(phone ? 15 : 25.w),
      decoration: BoxDecoration(
        color: SiteColors.page,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: SiteText.sectionTitle(context, color: primary)),
          SizedBox(height: phone ? 12.h : 15.w),
          ...children,
        ],
      ),
    );
  }

  /// BUG-226: one bullet row = bullet + Expanded text, so wrapped lines
  /// align with the first word (hanging indent); body colour/size token.
  Widget _bullet(String text) {
    final bool phone = MediaQuery.sizeOf(context).width < 600;
    // Figma: Cairo Medium 20, line height 30, grey.
    final TextStyle style = StyleText.fontSize14Weight400.copyWith(
      fontSize: phone ? 14 : 20.sp,
      fontWeight: FontWeight.w500,
      height: phone ? 1.6 : 1.5,
      color: SiteColors.description,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: phone ? 6.h : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: style),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }

  Widget _textSection(String title, String content, Color primary) {
    final lines = content
        .split('\n')
        .map((l) => l.trim().replaceFirst(RegExp(r'^[•\-\*]\s*'), ''))
        .where((l) => l.isNotEmpty)
        .toList();
    return _sectionBox(
      title: title,
      primary: primary,
      children: [for (final line in lines) _bullet(line)],
    );
  }

  /// BUG-220: on phones each benefit stacks (title, then the full-width
  /// description) instead of a 120 px right column.
  Widget _benefitsSection(_Labels labels, List<dynamic> benefits, Color primary,
      bool isRtl, bool isPhone) {
    // Figma benefits: title SemiBold 24/150 % #2D2D2D in a 450 px column,
    // description Regular 20/150 % grey; 25 px around each row.
    final TextStyle titleStyle = StyleText.fontSize14Weight600.copyWith(
      fontSize: isPhone ? 16 : 24.sp,
      height: isPhone ? null : 1.5,
      fontWeight: isPhone ? FontWeight.w700 : FontWeight.w600,
      color: SiteColors.textStrong,
    );
    final TextStyle descStyle = StyleText.fontSize14Weight400.copyWith(
      fontSize: isPhone ? 15 : 20.sp,
      fontWeight: isPhone ? FontWeight.w500 : FontWeight.w400,
      height: isPhone ? 1.6 : 1.5,
      color: SiteColors.description,
    );
    return _sectionBox(
      title: labels.benefits,
      primary: primary,
      children: [
        for (final b in benefits)
          Builder(builder: (context) {
            final bMap = b as Map<String, dynamic>;
            final bTitle = _biText(bMap['title'] as Map<String, dynamic>?, isRtl);
            final bDesc =
                _biText(bMap['shortDescription'] as Map<String, dynamic>?, isRtl);
            return Padding(
              padding: isPhone
                  ? EdgeInsets.only(bottom: 14.h)
                  : EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.w),
              child: isPhone
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bTitle, style: titleStyle),
                        if (bDesc.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(bDesc, style: descStyle),
                        ],
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 450.w, child: Text(bTitle, style: titleStyle)),
                        Expanded(child: Text(bDesc, style: descStyle)),
                      ],
                    ),
            );
          }),
      ],
    );
  }
}
