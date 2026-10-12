part of '../pages/job_page.dart';

class _FilterTab extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Color primary;
  final VoidCallback onTap;
  const _FilterTab(
      {required this.label,
      required this.isSelected,
      required this.primary,
      required this.onTap});

  @override
  State<_FilterTab> createState() => _FilterTabState();
}

class _FilterTabState extends State<_FilterTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool phone = MediaQuery.sizeOf(context).width < 600;
    // BUG-204 — Figma: every department is a button 52 px tall, radius 8;
    // selected = primary with white text, others white with #808080 text.
    // BUG-257: focusable (Tab) with a visible focus tint.
    return Semantics(
      button: true,
      selected: widget.isSelected,
      child: Material(
        // Figma (iPhone): unselected chips are #F1F2ED at 50 % inside the
        // white filter box; desktop chips are white on the page.
        color: widget.isSelected
            ? widget.primary
            : (_hovered
                ? Color.lerp(Colors.white, widget.primary, 0.10)!
                : (phone ? const Color(0x80F1F2ED) : Colors.white)),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onHover: (v) => setState(() => _hovered = v),
          onTap: widget.onTap,
          focusColor: widget.primary.withOpacity(0.15),
          child: Container(
            // Figma: 52 px tall, padding 8/16, radius 8, Cairo Regular 24
            // (150 %) grey on white — white on the primary when selected.
            // QA-Oct11 #32: no `alignment` (it stretched every chip to the
            // full row width, stacking them vertically); the 40 / 52 px
            // height now comes from the vertical padding.
            padding: EdgeInsets.symmetric(
                horizontal: phone ? 16 : 16.w, vertical: phone ? 10 : 8.w),
            child: Text(
              widget.label,
              maxLines: 1,
              softWrap: false,
              style: StyleText.fontSize13Weight600.copyWith(
                fontSize: phone ? 12 : 22.sp,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color: widget.isSelected
                    ? Colors.white
                    : (_hovered ? widget.primary : const Color(0xFF6B6B6B)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Job Card ─────────────────────────────────────────────────────────────────
