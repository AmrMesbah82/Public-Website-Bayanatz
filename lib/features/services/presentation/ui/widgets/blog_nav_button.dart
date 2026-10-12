part of '../pages/blog_detail_page.dart';

class _BlogNavButton extends StatefulWidget {
  final String       label;
  final bool         isSelected;
  final VoidCallback onTap;
  final bool         isMobile;
  final Color        primary;
  final Color        secondary;

  const _BlogNavButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isMobile,
    required this.primary,
    required this.secondary,
  });

  @override
  State<_BlogNavButton> createState() => _BlogNavButtonState();
}

class _BlogNavButtonState extends State<_BlogNavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // Derive a soft tinted hover background using Color.lerp instead of opacity
    final Color hoverBg = Color.lerp(Colors.white, widget.primary, 0.10)!;

    final Color bgColor = widget.isSelected
        ? widget.primary
        : (_hovered ? hoverBg : Colors.white);

    final Color textColor = widget.isSelected
        ? Colors.white
        : (_hovered ? widget.primary : AppColors.text);

    // BUG-189 / BUG-169: chip 46 px tall (44 on phones), radius 8, 16 px
    // SemiBold; long titles wrap inside the chip instead of being cut.
    // BUG-257: focusable with Tab.
    return Semantics(
      button: true,
      selected: widget.isSelected,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onHover: (v) => setState(() => _hovered = v),
          onTap: widget.onTap,
          child: Container(
            // QA-Oct11 #5 / #36: the chips sit in a horizontally scrolling
            // row, so each title stays on ONE line (no max width).
            constraints: BoxConstraints(
              // Figma: 50 px tall, padding 15, radius 8, Cairo Bold 18/20.
              minHeight: widget.isMobile ? 44 : 50.w,
            ),
            alignment: Alignment.center,
            padding: widget.isMobile
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                : EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.w),
            child: Text(
              widget.label,
              maxLines: 1,
              softWrap: false,
              style: StyleText.fontSize12Weight500.copyWith(
                color:      textColor,
                fontSize:   widget.isMobile ? 10 : 14.sp,
                height:     widget.isMobile ? null : 20 / 18,
                fontWeight: widget.isMobile ? FontWeight.w600 : FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
