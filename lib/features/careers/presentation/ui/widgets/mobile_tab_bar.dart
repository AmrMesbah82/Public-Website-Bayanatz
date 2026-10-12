part of '../pages/careers_page.dart';

class _MobileTabBar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChange;
  final Color primary;
  final Color secondary;
  final bool isRtl;
  final String whyJoinIconUrl;
  final String whyJoinTitle;
  final String internsIconUrl;
  final String internsTitle;
  final String teamIconUrl;
  final String teamTitle;
  const _MobileTabBar({
    required this.selectedTab,
    required this.onTabChange,
    required this.primary,
    required this.secondary,
    required this.isRtl,
    this.whyJoinIconUrl = '',
    this.whyJoinTitle = '',
    this.internsIconUrl = '',
    this.internsTitle = '',
    this.teamIconUrl = '',
    this.teamTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    // Figma (iPhone): 35 px light tiles (10 % #71717A, radius 8), labels
    // Cairo 14 — active SemiBold black, others Medium grey.
    const double boxSize = 35;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final bool selected = selectedTab == i;
          final String tabIconUrl = switch (i) {
            0 => whyJoinIconUrl,
            1 => internsIconUrl,
            2 => teamIconUrl,
            _ => '',
          };
          final String tabLabelOverride = switch (i) {
            0 => whyJoinTitle,
            1 => internsTitle,
            2 => teamTitle,
            _ => '',
          };
          return GestureDetector(
            onTap: () => onTabChange(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsetsDirectional.only(end: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected ? primary : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: boxSize,
                    height: boxSize,
                    decoration: BoxDecoration(
                      // BUG-214: light inactive tile (never the dark secondary).
                      color: const Color(0x1A71717A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: tabIconUrl.isNotEmpty
                          ? TintedNetworkIcon( // BUG-227
                              url: tabIconUrl,
                              size: 22,
                              color: primary,
                            )
                          : SvgPicture.asset(
                              _tabs[i].icon,
                              width: 22,
                              height: 22,
                              colorFilter: ColorFilter.mode(
                                primary,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tabLabelOverride.isNotEmpty
                        ? tabLabelOverride
                        : _tabs[i].label(isRtl),
                    style: StyleText.fontSize13Weight400.copyWith(
                      fontSize: 14,
                      height: 22 / 14,
                      fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? Colors.black : SiteColors.description,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE TAB: WHY JOIN OUR TEAM  (Firebase data via CareersSectionItem)
// ═══════════════════════════════════════════════════════════════════════════════
