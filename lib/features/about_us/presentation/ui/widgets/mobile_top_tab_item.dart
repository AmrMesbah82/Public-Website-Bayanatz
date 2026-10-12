part of '../pages/about_us_page.dart';

class _MobileTopTabItem extends StatefulWidget {
  final int index;
  final String label;
  final String svgAsset;

  /// CMS navigation-label icon URL (from the admin app). When non-empty it
  /// takes priority over [svgAsset].
  final String iconUrl;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;
  const _MobileTopTabItem({
    this.index = 0,
    required this.label,
    required this.svgAsset,
    this.iconUrl = '',
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });
  @override
  State<_MobileTopTabItem> createState() => _MobileTopTabItemState();
}

class _MobileTopTabItemState extends State<_MobileTopTabItem> {

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;
    // BUG-246: tab labels use the TAB token (15 px), not the page-title size;
    // BUG-214: light inactive tile; BUG-184: 2 px underline when active.
    return Semantics(
      button: true,
      selected: sel,
      label: widget.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: widget.onTap,
        // QA-Oct11 #13: no hover tint on the tabs.
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: sel ? widget.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                // Figma (iPhone): 48 px tile, radius 14 — primary when active,
                // 10 % #71717A otherwise.
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  // QA-Oct11 #3: unselected = selected tile at 50 %.
                  color: sel
                      ? widget.primaryColor
                      : widget.primaryColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _topTabIcon(
                    iconUrl: widget.iconUrl,
                    fallback: _kTopTabFallbackIcons[
                        widget.index.clamp(0, _kTopTabFallbackIcons.length - 1)],
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Figma: SemiBold 20 (#170F49 active); 16 here so the four
              // tabs still wrap on a phone (BUG-246).
              Text(
                widget.label,
                style: StyleText.fontSize20Weight600.copyWith(
                  fontSize: 16,
                  height: 22 / 16,
                  color: sel
                      ? const Color(0xFF170F49)
                      : SiteColors.description,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Mobile About Us Content
// ══════════════════════════════════════════════════════════════════════════════
