part of '../pages/careers_page.dart';

class _MobileBody extends StatelessWidget {
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

  const _MobileBody({
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Figma (iPhone): title 70 px under the header, intro card 20 px
          // below it, statistics 20 px lower, tabs 20, content 20.
          const SizedBox(height: 60),
          _Reveal(
            delay: const Duration(milliseconds: 60),
            direction: _SlideDirection.fromLeft,
            duration: const Duration(milliseconds: 650),
            // QA-Oct11 #8: the title starts on the card's edge (no extra
            // start inset — it looked shifted against the container).
            child: Text(
              _t('Careers', 'الوظائف', isRtl),
              style: SiteText.pageTitle(context, color: primary), // BUG-242
            ),
          ),
          const SizedBox(height: 20),
          _Reveal(
            delay: const Duration(milliseconds: 100),
            direction: _SlideDirection.fromBottom,
            duration: const Duration(milliseconds: 650),
            child: _MobileHeaderCard(
              primary: primary,
              isRtl: isRtl,
              description: isRtl
                  ? careersData.overview.description.ar
                  : careersData.overview.description.en,
              btnLabel: isRtl
                  ? careersData.overview.actionButtonLabel.ar
                  : careersData.overview.actionButtonLabel.en,
            ),
          ),
          const SizedBox(height: 20),
          _Reveal(
            delay: const Duration(milliseconds: 140),
            direction: _SlideDirection.fromBottom,
            duration: const Duration(milliseconds: 650),
            child: _MobileStatsSection(
              primary: primary,
              isRtl: isRtl,
              statistics: careersData.statistics,
            ),
          ),
          const SizedBox(height: 20),
          _Reveal(
            delay: const Duration(milliseconds: 170),
            direction: _SlideDirection.fromBottom,
            duration: const Duration(milliseconds: 600),
            child: _MobileTabBar(
              selectedTab: selectedTab,
              onTabChange: onTabChange,
              primary: primary,
              secondary: secondary,
              isRtl: isRtl,
              whyJoinIconUrl: whyJoinItems.isNotEmpty
                  ? whyJoinItems.first.iconUrl
                  : '',
              whyJoinTitle: whyJoinItems.isNotEmpty
                  ? (isRtl
                      ? whyJoinItems.first.title.ar
                      : whyJoinItems.first.title.en)
                  : '',
              internsIconUrl: internsIconUrl,
              internsTitle: internsTitle,
              teamIconUrl: teamIconUrl,
              teamTitle: teamTitle,
            ),
          ),
          const SizedBox(height: 20),
          _buildMobileTabContent(
              selectedTab, primary, secondary, isRtl),
          SizedBox(height: 28.h),
        ],
      ),
    );
  }

  Widget _buildMobileTabContent(
      int tab,
      Color primary,
      Color secondary,
      bool isRtl,
      ) {
    switch (tab) {
      case 0:
        return _MobileWhyJoinTab(
            primary: primary, isRtl: isRtl, items: whyJoinItems);
      case 1:
        return _MobileInternsTab(
            primary: primary, isRtl: isRtl, interns: interns);
      case 2:
        return _MobileOurTeamTab(
            primary: primary,
            secondary: secondary,
            isRtl: isRtl,
            teams: teams);
      default:
        return _MobileWhyJoinTab(
            primary: primary, isRtl: isRtl, items: whyJoinItems);
    }
  }
}

// ── Mobile header card ────────────────────────────────────────────────────────
