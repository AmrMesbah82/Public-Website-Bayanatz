part of '../pages/home_page.dart';

// ── CMS nav button ────────────────────────────────────────────────────────────

class _CmsNavBtn extends StatefulWidget {
  final String label;
  final String route;
  final Color  primary;
  final bool   mobile;
  final bool   isRtl;
  /// BUG-180: the first quick link is the highlighted #E4ECE0 pill.
  final bool   highlighted;
  final double? height;
  /// Optional overrides (tablet Figma: Cairo Medium 16, radius 4, 34 tall).
  final double? fontSize;
  final double? radius;
  final double? hPadding;
  /// Smallest height the button may shrink to (default 48 tap target).
  final double  minHeight;

  const _CmsNavBtn({
    required this.label,
    required this.route,
    required this.primary,
    this.mobile      = false,
    this.isRtl       = false,
    this.highlighted = false,
    this.height,
    this.fontSize,
    this.radius,
    this.hPadding,
    this.minHeight = 48,
  });

  @override
  State<_CmsNavBtn> createState() => _CmsNavBtnState();
}

class _CmsNavBtnState extends State<_CmsNavBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // BUG-180 — Figma: every quick link uses the SAME text (Cairo Medium 22
    // primary); first item = #E4ECE0 pill, others white, radius 10.
    // Figma (iPhone): highlighted pill Medium 20 with 80 px padding, the
    // other links Medium 16 with 15 px padding — both 48 px tall.
    final textStyle = GoogleFonts.cairo(
      fontSize:   widget.fontSize ??
          (widget.mobile ? (widget.highlighted ? 20 : 16) : 22.sp),
      fontWeight: FontWeight.w500,
      color:      _hovered ? Colors.black : widget.primary,
    );
    final Color base = widget.highlighted ? const Color(0xFFE4ECE0) : Colors.white;
    Color _lightTint(Color primary) => primary.withOpacity(0.12);
    final BorderRadius br = BorderRadius.circular(widget.radius ?? 10);
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: Material(
        color: _hovered ? _lightTint(widget.primary) : base,
        borderRadius: br,
        child: InkWell(
          borderRadius: br,
          onHover: (v) => setState(() => _hovered = v),
          onTap: widget.route.isNotEmpty
              ? () => context.go(widget.route)
              : null,
          child: Container(
            height: widget.height != null
                ? (widget.height! < widget.minHeight
                    ? widget.minHeight
                    : widget.height)
                : (widget.mobile ? 48 : 60.h),
            // QA-Oct11 #6: phone buttons now get their width from the
            // inverted-pyramid column, so the pill no longer needs 80 px.
            padding: EdgeInsets.symmetric(
                horizontal: widget.hPadding ?? (widget.mobile ? 15 : 18.w)),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(widget.label, style: textStyle, maxLines: 1),
            ),
          ),
        ),
      ),
    );
  }
}
