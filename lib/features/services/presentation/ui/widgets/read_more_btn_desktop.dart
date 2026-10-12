part of '../pages/services_page.dart';

class _ReadMoreBtnDesktop extends StatefulWidget {
  final bool  isRtl;
  final Color primaryColor;
  final String postId;
  const _ReadMoreBtnDesktop({
    this.isRtl = false,
    required this.primaryColor,
    required this.postId,
  });
  @override
  State<_ReadMoreBtnDesktop> createState() => _ReadMoreBtnDesktopState();
}

class _ReadMoreBtnDesktopState extends State<_ReadMoreBtnDesktop> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color hoverColor =
    Color.lerp(widget.primaryColor, Colors.black, 0.2)!;

    // BUG-183: Figma "Read More" 81×34, radius 6, 14 px. BUG-257: focusable.
    return Material(
      color: _hovered ? hoverColor : widget.primaryColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onHover: (v) => setState(() => _hovered = v),
        onTap: () => context.go('/blog/${widget.postId}'),
        child: Container(
          // Figma: 81×34, radius 6, Cairo Medium 14 white.
          constraints: BoxConstraints(minWidth: 81.w, minHeight: 34.w),
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          alignment: Alignment.center,
          child: Text(
              widget.isRtl ? 'اقرأ المزيد' : 'Read More',
              style: AppTextStyles.font12WhiteCairo.copyWith(
                  fontSize:   14.sp,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
