part of '../pages/job_page.dart';

class _JobCard extends StatefulWidget {
  final JobPostModel job;
  final _L l;
  final Color primary;
  const _JobCard({required this.job, required this.l, required this.primary});

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _hovered = false;

  /// Bilingual date — localized month name AND numerals (EN/AR).
  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return FormDateTimeHelper.formatDayMonthYear(dt, arabic: widget.l.isAr);
  }

  /// Localizes digits inside any value when the page is in Arabic.
  String _num(String text) =>
      widget.l.isAr ? FormDateTimeHelper.toArabicDigits(text) : text;

  String _pick(String en, String ar) {
    if (widget.l.isAr) return ar.isNotEmpty ? ar : en;
    return en.isNotEmpty ? en : ar;
  }

  /// BUG-111 / BUG-243 / BUG-217: range + currency (Arabic symbol in
  /// Arabic) kept together with no-break spaces.
  String get _salaryDisplay {
    final j = widget.job;
    if (j.salaryMax > 0 || j.salaryMin > 0) {
      return jobSalaryRange(j.salaryMin, j.salaryMax, j.salaryCurrency, widget.l.isAr);
    }
    return '—';
  }

  /// BUG-203 / BUG-234: On Site + Hybrid → office location, Remote → "Remote".
  String _locationText(BuildContext context) {
    final j = widget.job;
    if (j.workType == WorkType.remote) return widget.l.isAr ? 'عن بُعد' : 'Remote';
    if (j.location.trim().isEmpty) return '';
    return jobLocation(context, j.location, widget.l.isAr);
  }

  /// Employment duration — same as the detail page: "text + type" (EN/AR digits).
  String get _durationDisplay {
    final j = widget.job;
    final unit = j.employmentDurationType.localized(widget.l.isAr);
    if (j.employmentDurationText.isNotEmpty) {
      return _num('${j.employmentDurationText} $unit');
    }
    return unit;
  }

  @override
  Widget build(BuildContext context) {
    final job   = widget.job;
    final l     = widget.l;
    final title = _pick(job.title.en, job.title.ar);
    final qual  = _pick(
        job.requiredQualification.en, job.requiredQualification.ar);
    final bool phone = MediaQuery.sizeOf(context).width < 600;
    final String location = _locationText(context);
    final List<String> skills = [
      for (final s in job.requiredSkills) _pick(s.name.en, s.name.ar),
    ];

    final left = <Widget>[
      _InfoItem(
          label: l.hireDate,
          value: _formatDate(job.hiringStartDate),
          primary: widget.primary),
      _InfoItem(
          label: l.workType,
          value: job.workType.localized(l.isAr),
          primary: widget.primary),
      _InfoItem(
          label: l.employmentType,
          value: job.employmentType.localized(l.isAr),
          primary: widget.primary),
      _InfoItem(
          label: l.experienceLevel,
          value: job.experienceLevel.localized(l.isAr),
          primary: widget.primary),
      // BUG-195: admin text exactly as typed (no forced Title Case).
      _InfoItem(
          label: l.qualification,
          value: qual.isEmpty ? '—' : qual,
          primary: widget.primary),
    ];
    final right = <Widget>[
      _InfoItem(
          label: l.hireEndDate,
          value: _formatDate(job.hiringEndDate),
          primary: widget.primary),
      // Figma: pin icon + location (On Site AND Hybrid; Remote = "Remote").
      if (location.isNotEmpty)
        Row(
          children: [
            CustomSvg(
              assetPath: "assets/images/careers/location.svg",
              width: phone ? 14 : 16,
              height: phone ? 16 : 20,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                location,
                // QA-Oct11 #33: same size as every other row of the card
                // (it was 24 on phones — much bigger than the 14 px rows).
                style: StyleText.fontSize14Weight400.copyWith(
                  fontSize: phone ? 14 : 24.sp, // Figma Medium 24/32 grey
                  height: phone ? 1.4 : 32 / 24,
                  fontWeight: FontWeight.w500,
                  color: SiteColors.description,
                ),
              ),
            ),
          ],
        ),
      _InfoItem(
          label: l.employmentDuration,
          value: _durationDisplay,
          primary: widget.primary),
      _InfoItem(
          label: l.compensation,
          value: _salaryDisplay,
          primary: widget.primary),
    ];

    List<Widget> spaced(List<Widget> items) => [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: phone ? 10.h : 8.w), // Figma rows 42 apart
            items[i],
          ],
        ];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        // Figma: white card radius 15, padding 25.
        padding: phone
            ? const EdgeInsets.all(15) // Figma iPhone: radius 15, padding 15
            : EdgeInsets.fromLTRB(25.w, 17.w, 25.w, 25.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(phone ? 15 : 15.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Title + share ────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title.isEmpty ? l.untitled : title, // BUG-195: as typed
                    // Figma: Cairo Medium 30 black.
                    style: StyleText.fontSize14Weight400.copyWith(
                      fontSize: phone ? 16 : 30.sp, // Figma Medium 16 / 30
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // BUG-222: the one square share button.
                JobShareButton(
                  jobId: job.id,
                  title: title,
                  primary: widget.primary,
                  isAr: l.isAr,
                ),
              ],
            ),
            SizedBox(height: phone ? 10.h : 10.w),
            Divider(color: _kDivider, height: 1),
            SizedBox(height: phone ? 14.h : 18.w),

            // ── Info — two columns on desktop, ONE column on phones
            //    (BUG-243: the salary had only ≈170 px and "EGP" wrapped).
            if (phone)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: spaced([...left, ...right]),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Figma: the second column starts 830 px into the card body.
                  Expanded(
                    flex: 830,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: spaced(left),
                    ),
                  ),
                  Expanded(
                    flex: 520,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: spaced(right),
                    ),
                  ),
                ],
              ),

            // ── Skills (BUG-203: Figma card has the Skills chip row) ──────
            if (skills.isNotEmpty) ...[
              SizedBox(height: phone ? 14.h : 8.w),
              JobSkillsRow(
                label: l.skillsLabel,
                skills: skills,
                // Figma: "Skills:" Cairo Medium 24 grey.
                labelStyle: StyleText.fontSize15Weight600.copyWith(
                  fontSize: phone ? 14 : 24.sp, // Figma Medium 14 / 24 grey
                  fontWeight: FontWeight.w500,
                  color: SiteColors.description,
                ),
              ),
            ],
            SizedBox(height: phone ? 16.h : 15.w),

            // ── View button ───────────────────────────────────────────────
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _ViewJobBtn(
                  jobId: job.id, label: l.viewJob, primary: widget.primary),
            ),
          ],
        ),
      ),
    );
  }
}

