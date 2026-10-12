part of '../pages/about_us_page.dart';

class _DesktopTabItem extends StatefulWidget {
  final String label, iconUrl, selectedDesc;
  final bool isSelected;
  final Color primaryColor, secondaryColor;
  final VoidCallback onTap;
  const _DesktopTabItem({
    required this.label,
    required this.iconUrl,
    required this.selectedDesc,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.secondaryColor,
  });
  @override
  State<_DesktopTabItem> createState() => _DesktopTabItemState();
}

class _DesktopTabItemState extends State<_DesktopTabItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // BUG-214: never a dark tile — light tint when not selected.
    // Figma: the 48×48 icon tile is the same light grey on every card
    // (selected or not) with the glyph in the primary colour.
    const Color iconBg = Color(0x1A797979);
    final Color hoverBg = _hoverTint(widget.primaryColor);

    // BUG-185 — Figma: white card radius 15; the SELECTED card has a 2 px
    // primary border with its excerpt inside; title Cairo Bold 24 primary,
    // text 18 px. BUG-229: constant outer size of the border (no jump).
    return Semantics(
      button: true,
      selected: widget.isSelected,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (v) => setState(() => _hovered = v),
        borderRadius: BorderRadius.circular(15.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.all(25.w), // Figma: 25 px padding, radius 15
          decoration: BoxDecoration(
            color: widget.isSelected
                ? _kSurface
                : (_hovered ? hoverBg : _kSurface),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: widget.isSelected ? widget.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: widget.iconUrl.isNotEmpty
                          ? _netImg(
                        url: widget.iconUrl,
                        width: 26.w,
                        height: 26.w,
                        fit: BoxFit.contain,
                        // BUG-227: white GLYPH when selected (background
                        // shapes are stripped before tinting).
                        colorFilter: ColorFilter.mode(
                            widget.primaryColor, BlendMode.srcIn),
                      )
                          : Icon(
                        Icons.image_outlined,
                        size: 24.r,
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 13.w),
                  Flexible(
                    child: Text(
                      widget.label,
                      style: StyleText.fontSize18Weight500.copyWith(
                        fontSize: 24.sp, // Figma Bold 24 primary
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.isSelected && widget.selectedDesc.isNotEmpty) ...[
                SizedBox(height: 20.w),
                Text(
                  widget.selectedDesc,
                  maxLines: 3, // Figma: 3-line excerpt
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize13Weight400.copyWith(
                    fontSize: 18.sp, // Figma SemiBold 18/30
                    fontWeight: FontWeight.w600,
                    height: 30 / 18,
                    color: SiteColors.description,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Desktop Right Panel
// ══════════════════════════════════════════════════════════════════════════════
