part of '../pages/about_us_page.dart';

class _DesktopTopTabItem extends StatefulWidget {
  final int index;
  final String label;
  final String svgAsset;

  /// CMS navigation-label icon URL (from the admin app). When non-empty it
  /// takes priority over [svgAsset].
  final String iconUrl;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;
  const _DesktopTopTabItem({
    required this.index,
    required this.label,
    required this.svgAsset,
    this.iconUrl = '',
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });
  @override
  State<_DesktopTopTabItem> createState() => _DesktopTopTabItemState();
}

class _DesktopTopTabItemState extends State<_DesktopTopTabItem> {

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;
    // Tile colour (from Firebase) → contrasting icon colour.
    final Color tileColor = sel ? widget.primaryColor : widget.secondaryColor;
    final Color iconColor = _onBrandColor(tileColor);
    // BUG-184 — Figma: icon tile 48×48 (active primary radius 8, inactive a
    // LIGHT tile), label Cairo SemiBold 20 (active primary, inactive grey),
    // 2 px primary underline under the active tab.
    // BUG-214: the inactive tile was the CMS "Secondary" colour (#2D2D2D) —
    // a near-black box that hid the green icon.
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
        borderRadius: BorderRadius.circular(8.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // Figma: 48 px tile + 15 px down to the 2 px underline.
          padding: EdgeInsetsDirectional.only(start: 12.w, end: 12.w, bottom: 15.w),
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
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  // QA-Oct11 #3: an unselected tile is the selected tile
                  // at 50 % opacity (it used to vanish into the page).
                  color: tileColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: _topTabIcon(
                    iconUrl: widget.iconUrl,
                    fallback: _kTopTabFallbackIcons[
                        widget.index.clamp(0, _kTopTabFallbackIcons.length - 1)],
                    color: iconColor,
                    size: 35.sp,
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Text(
                widget.label,
                style: StyleText.fontSize14Weight400.copyWith(
                  fontSize: 20.sp, // Figma SemiBold 20/22
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: sel ? widget.primaryColor : SiteColors.description,
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
// Desktop Tab Item (left panel — Vision / Mission / Values)
// ══════════════════════════════════════════════════════════════════════════════
