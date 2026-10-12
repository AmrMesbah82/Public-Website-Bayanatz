part of '../pages/about_us_page.dart';

class _ValueGridCard extends StatefulWidget {
  final String title;
  final String iconUrl;
  final bool isSelected;
  final Color primaryColor;
  final double width;
  final double iconSize;
  final double fontSize;
  final double padding;
  final VoidCallback onTap;
  final bool rowLayout;
  /// Figma desktop tile: 85 px square, radius 12, shadow 10 % black blur 30,
  /// Bold text #2D2D2D.
  final bool figmaTile;
  const _ValueGridCard({
    required this.title,
    required this.iconUrl,
    required this.isSelected,
    required this.primaryColor,
    required this.width,
    required this.iconSize,
    required this.fontSize,
    required this.padding,
    required this.onTap,
    this.rowLayout = false,
    this.figmaTile = false,
  });
  @override
  State<_ValueGridCard> createState() => _ValueGridCardState();
}

class _ValueGridCardState extends State<_ValueGridCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool sel = widget.isSelected;
    final Color hoverBg = _hoverTint(widget.primaryColor);

    // ✅ FIX: only apply white colorFilter when the card is selected
    // so the real icon image is visible on non-selected cards
    final Widget iconWidget = widget.iconUrl.isNotEmpty
        ? _netImg(
      url: widget.iconUrl,
      width: widget.iconSize,
      height: widget.iconSize,
      fit: BoxFit.contain,
      // BUG-227: white GLYPH on the green selected tile (the background
      // shape is stripped first, so it no longer becomes a white square).
      colorFilter: _isSvgUrl(widget.iconUrl)
          ? ColorFilter.mode(sel ? Colors.white : widget.primaryColor, BlendMode.srcIn)
          : null,
    )
        : Icon(
      Icons.star_outline,
      size: widget.iconSize,
      color: sel ? Colors.white : widget.primaryColor,
    );

    final Widget titleWidget = Text(
      FormatHelper.capitalize(widget.title),
      textAlign: widget.rowLayout ? TextAlign.start : TextAlign.center,
      // BUG-228: full title, wrapping over 2–3 lines — never "…".
      maxLines: 3,
      style: StyleText.fontSize14Weight400.copyWith(
        fontSize: widget.fontSize,
        fontWeight: widget.figmaTile ? FontWeight.w700 : FontWeight.w600,
        color: sel
            ? Colors.white
            : (_hovered
                ? widget.primaryColor
                : (widget.figmaTile ? SiteColors.textStrong : Colors.black87)),
        height: widget.figmaTile ? 1.2 : 1.3,
      ),
    );

    return Semantics(
      button: true,
      selected: sel,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (v) => setState(() => _hovered = v),
        borderRadius: BorderRadius.circular(10.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.rowLayout ? null : widget.width,
          // BUG-228: no fixed height — the row gives every tile the height
          // of its tallest neighbour.
          constraints: widget.rowLayout
              ? null
              : BoxConstraints(minHeight: widget.figmaTile ? 85.w : 90.r),
          padding: EdgeInsets.all(widget.padding),
          decoration: BoxDecoration(
            color: sel
                ? widget.primaryColor
                : (_hovered ? hoverBg : Colors.white),
            borderRadius: BorderRadius.circular(widget.figmaTile ? 12.r : 10.r),
            boxShadow: widget.figmaTile
                ? const [BoxShadow(color: Color(0x1A000000), blurRadius: 30)]
                : sel
                    ? [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
                    : [],
            border: Border.all(
              color: _hovered && !sel
                  ? widget.primaryColor.withOpacity(0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: widget.rowLayout
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconWidget,
              SizedBox(width: 6.w),
              Expanded(child: titleWidget),
            ],
          )
              : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconWidget,
              SizedBox(height: 6.h),
              titleWidget,
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Tablet Tab Item
// ══════════════════════════════════════════════════════════════════════════════
