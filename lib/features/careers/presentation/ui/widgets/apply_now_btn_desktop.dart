part of '../pages/careers_page.dart';

class _ApplyNowBtnDesktop extends StatefulWidget {
  final String label;
  final Color primary;
  final bool isTablet;
  final bool isRtl;
  const _ApplyNowBtnDesktop({
    required this.label,
    required this.primary,
    this.isTablet = false,
    required this.isRtl,
  });

  @override
  State<_ApplyNowBtnDesktop> createState() => _ApplyNowBtnDesktopState();
}

class _ApplyNowBtnDesktopState extends State<_ApplyNowBtnDesktop> {
  bool _hovered = false;

  // BUG-188 — Figma: 190×60 button, radius 12, primary, 24 px label.
  @override
  Widget build(BuildContext context) => Material(
    color: _hovered
        ? Color.alphaBlend(Colors.black.withOpacity(0.15), widget.primary)
        : widget.primary,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onHover: (v) => setState(() => _hovered = v),
      onTap: () => context.go('/jobs'),
      child: Container(
        constraints: BoxConstraints(
          minWidth: widget.isTablet ? 160.w : 190.w,
          minHeight: widget.isTablet ? 52.h : 60.w,
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Text(
          widget.label,
          style: StyleText.fontSize14Weight600.copyWith(
            fontSize: widget.isTablet ? 20.sp : 24.sp,
            // Figma: Cairo Regular 24 white.
            fontWeight: widget.isTablet ? FontWeight.w600 : FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}
