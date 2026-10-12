part of '../pages/careers_page.dart';

class _DesktopBody extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChange;
  final Color primary;
  final Color secondary;
  final bool isRtl;
  final CareersCmsModel careersData;
  final List<CareersSectionItem> whyJoinItems;
  final List<InternModel> interns;
  final List<OurTeamItem> teams;
  final String internsIconUrl;
  final String internsTitle;
  final String teamIconUrl;
  final String teamTitle;

  const _DesktopBody({
    required this.selectedTab,
    required this.onTabChange,
    required this.primary,
    required this.secondary,
    required this.isRtl,
    required this.careersData,
    required this.whyJoinItems,
    required this.interns,
    required this.teams,
    this.internsIconUrl = '',
    this.internsTitle = '',
    this.teamIconUrl = '',
    this.teamTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    // Figma "iPad Vertical View" reuses the desktop components (only the
    // column is narrower), so tablets get the desktop sizes too.
    const bool isTablet = false;
    final double hPad = _desktopHPad(screenW);

    // Figma (Careers, desktop 1800 frame): title 70 px under the header,
    // intro card 105 px below it, statistics 30 px lower, tabs 40, content 40.
    final double topSpace = isTablet ? 28.h : 52.w;
    final double sectionGap = isTablet ? 18.h : 30.w;
    final double bottomSpace = isTablet ? 40.h : 20.w;
    final double cardPad = isTablet ? 18.w : 25.w;
    final double headerFz = isTablet ? 12.sp : 14.sp;
    // Figma: intro text Cairo Medium 24 grey, line height 43; statistics
    // Playfair Display ExtraBold 40 primary + Cairo SemiBold 16 grey.
    final double plainFz = isTablet ? 18.sp : 24.sp;
    final double statValFz = isTablet ? 24.sp : 40.sp;
    final double statDescFz = isTablet ? 14.sp : 16.sp;
    final double tabFz = isTablet ? 17.sp : 20.sp;
    final double tabIconSz = isTablet ? 24.r : 30.w; // Figma 30 px glyph
    final double tabIconBox = isTablet ? 44.r : 48.w;

    final String overviewDesc = isRtl
        ? careersData.overview.description.ar
        : careersData.overview.description.en;
    final String btnLabel = isRtl
        ? careersData.overview.actionButtonLabel.ar
        : careersData.overview.actionButtonLabel.en;
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topSpace),

          _Reveal(
            delay: const Duration(milliseconds: 60),
            direction: _SlideDirection.fromLeft,
            duration: const Duration(milliseconds: 650),
            // BUG-142: the intro paragraph sits 10.sp inside its white card,
            // so the title gets the same inset → one left edge.
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 10.sp),
              // BUG-178: shared page-title style.
              child: Text(
                _t('Careers', 'الوظائف', isRtl),
                style: SiteText.pageTitle(context, color: primary),
              ),
            ),
          ),
          SizedBox(height: isTablet ? sectionGap : 34.w),

          _Reveal(
            delay: const Duration(milliseconds: 110),
            direction: _SlideDirection.fromBottom,
            duration: const Duration(milliseconds: 650),
            // BUG-188 — Figma: white card radius 15, 24 px text, 190×60
            // button (radius 12, 24 px label) at the bottom-right.
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 20.w : 25.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (overviewDesc.isNotEmpty)
                    _PlainText(overviewDesc,
                        fontSize: plainFz, height: isTablet ? 1.65 : 43 / 24),
                  SizedBox(height: isTablet ? 16.h : 10.w),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      if (btnLabel.isNotEmpty)
                        _ApplyNowBtnDesktop(
                          label: btnLabel,
                          primary: primary,
                          isTablet: isTablet,
                          isRtl: isRtl,
                        ),
                      // const Spacer(),
                      // customButton(
                      //   title: isArabic ? "قدم الان " : "apply now",
                      //   color: primary,
                      //   textStyle: StyleText.fontSize28Weight600.copyWith(
                      //     fontSize: 14.sp,
                      //     fontWeight: FontWeight.w600,
                      //     color: Colors.white,
                      //   ),
                      //   function: () {
                      //     navigateTo(context, JobListingsPage());
                      //   },
                      //   width: 100.w,
                      //   height: 36.h,
                      //   radius: 8.r,
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: sectionGap),

          if (careersData.statistics.isNotEmpty)
            _Reveal(
              delay: const Duration(milliseconds: 150),
              direction: _SlideDirection.fromBottom,
              duration: const Duration(milliseconds: 650),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? cardPad : 17.w, // + 8 per item = 25
                  vertical: isTablet ? 14.h : 25.w,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Column(
                  children: () {
                    const int maxPerRow = 5;
                    final stats = careersData.statistics;
                    final List<Widget> rows = [];
                    for (int i = 0; i < stats.length; i += maxPerRow) {
                      final chunk = stats.sublist(
                        i, (i + maxPerRow).clamp(0, stats.length),
                      );
                      rows.add(
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: chunk.map((s) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isRtl ? s.title.ar : s.title.en,
                                    maxLines: 1,
                                    style: isTablet
                                        ? StyleText.fontSize28Weight600.copyWith(
                                            fontSize: statValFz,
                                            fontWeight: FontWeight.w700,
                                            color: primary,
                                          )
                                        : GoogleFonts.playfairDisplay(
                                            fontSize: statValFz,
                                            fontWeight: FontWeight.w800,
                                            color: primary,
                                          ),
                                  ),
                                  SizedBox(height: isTablet ? 4.h : 8.w),
                                  Text(
                                    isRtl ? s.shortDescription.ar : s.shortDescription.en,
                                    style: StyleText.fontSize10Weight400.copyWith(
                                      fontSize: statDescFz,
                                      height: isTablet ? 1.5 : 1.875,
                                      fontWeight: isTablet ? null : FontWeight.w600,
                                      color: SiteColors.description,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )).toList(),
                        ),
                      );
                      if (i + maxPerRow < stats.length) {
                        rows.add(SizedBox(height: 16.h));
                      }
                    }
                    return rows;
                  }(),
                ),
              ),
            ),
          SizedBox(height: isTablet ? sectionGap : 40.w),

          // ── Tab Bar ────────────────────────────────────────────────────
          _Reveal(
            delay: const Duration(milliseconds: 180),
            direction: _SlideDirection.fromBottom,
            duration: const Duration(milliseconds: 600),
            // Figma: the tab bar is 1143 wide, centred, with its divider.
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 0 : 128.w),
              // Only the selected tab is underlined — no line under the
              // rest of the bar.
              child: Wrap(
              alignment: WrapAlignment.center,
              children: List.generate(_tabs.length, (i) {
                final bool selected = selectedTab == i;
                // Admin-controlled icon/label overrides:
                //   tab 0 → "Why Join Our Team" section item 0
                //   tab 1 → "Our Interns" section header
                final String tabIconUrl = switch (i) {
                  0 => whyJoinItems.isNotEmpty
                      ? whyJoinItems.first.iconUrl
                      : '',
                  1 => internsIconUrl,
                  2 => teamIconUrl,
                  _ => '',
                };
                final String tabLabelOverride = switch (i) {
                  0 => whyJoinItems.isNotEmpty
                      ? (isRtl
                          ? whyJoinItems.first.title.ar
                          : whyJoinItems.first.title.en)
                      : '',
                  1 => internsTitle,
                  2 => teamTitle,
                  _ => '',
                };
                // BUG-143: the tab said "Why Join Our Team?" while the footer
                // and admin say "Why Join Our Team" — one name, no "?".
                final String cleanOverride =
                    tabLabelOverride.trim().replaceFirst(RegExp(r'[?؟]\s*$'), '');
                return Semantics(
                  button: true,
                  selected: selected,
                  child: InkWell(
                    onTap: () => onTabChange(i),
                    // QA-Oct11 #30: no grey hover / press box on the tabs.
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin:
                      EdgeInsets.symmetric(horizontal: isTablet ? 6.w : 0),
                      padding: isTablet
                          ? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)
                          : EdgeInsets.only(left: 35.w, right: 35.w, bottom: 15.w),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selected
                                ? primary
                                : Colors.transparent,
                            width: 2, // Figma 2 px underline
                          ),
                        ),
                      ),
                      // One row of tabs (Figma): each tab hugs its content —
                      // a full-width Row made every tab wrap onto its own line.
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 200),
                            width: tabIconBox,
                            height: tabIconBox,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(isTablet ? 8.r : 14.r),
                              // BUG-137: primary icon on a DARK secondary
                              // tile was 2.58:1 → light brand tint instead.
                              // BUG-184 / BUG-214: light inactive tile.
                              // Figma: the same light tile for every tab.
                              color: isTablet && selected
                                  ? primary
                                  : const Color(0x1A71717A), // Figma 10 % #71717A
                            ),
                            child: Center(
                              child: tabIconUrl.isNotEmpty
                                  ? TintedNetworkIcon(
                                      url: tabIconUrl,
                                      size: tabIconSz,
                                      color: isTablet && selected ? Colors.white : primary,
                                    )
                                  : SvgPicture.asset(
                                      _tabs[i].icon,
                                      width: tabIconSz,
                                      height: tabIconSz,
                                      fit: BoxFit.scaleDown,
                                      colorFilter: ColorFilter.mode(
                                        isTablet && selected ? Colors.white : primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(width: isTablet ? 10.w : 30.w),
                          Text(
                            cleanOverride.isNotEmpty
                                ? cleanOverride
                                : _tabs[i].label(isRtl),
                            style:
                            StyleText.fontSize14Weight400.copyWith(
                              fontSize: tabFz,
                              // Figma: active SemiBold #170F49, others Medium grey.
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected
                                  ? (isTablet ? primary : const Color(0xFF170F49))
                                  : SiteColors.description,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            ),
          ),
          SizedBox(height: isTablet ? sectionGap : 40.w),

          _buildDesktopTabContent(
              selectedTab, primary, secondary, isTablet, isRtl),

          SizedBox(height: bottomSpace),
        ],
      ),
    );
  }

  Widget _buildDesktopTabContent(
      int tab,
      Color primary,
      Color secondary,
      bool isTablet,
      bool isRtl,
      ) {
    switch (tab) {
      case 0:
        return _DesktopWhyJoinTab(
          primary: primary,
          isTablet: isTablet,
          isRtl: isRtl,
          items: whyJoinItems,
        );
      case 1:
        return _DesktopInternsTab(
          primary: primary,
          isTablet: isTablet,
          isRtl: isRtl,
          interns: interns,
        );
      case 2:
        return _DesktopOurTeamTab(
          primary: primary,
          secondary: secondary,
          isTablet: isTablet,
          isRtl: isRtl,
          teams: teams,
        );
      default:
        return _DesktopWhyJoinTab(
          primary: primary,
          isTablet: isTablet,
          isRtl: isRtl,
          items: whyJoinItems,
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP TAB: WHY JOIN OUR TEAM  (Firebase data via CareersSectionItem)
// ═══════════════════════════════════════════════════════════════════════════════
