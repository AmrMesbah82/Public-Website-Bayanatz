part of '../pages/job_page.dart';

class _ViewJobBtn extends StatefulWidget {
  final String jobId;
  final String label;
  final Color primary;
  const _ViewJobBtn(
      {required this.jobId, required this.label, required this.primary});

  @override
  State<_ViewJobBtn> createState() => _ViewJobBtnState();
}

class _ViewJobBtnState extends State<_ViewJobBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool phone = MediaQuery.sizeOf(context).width < 600;
    // Figma: "View Job" 210×60, radius 8 (BUG-146: Title Case).
    return Material(
      color: _hovered
          ? Color.lerp(widget.primary, Colors.black, 0.15)!
          : widget.primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onHover: (v) => setState(() => _hovered = v),
        onTap: () => context.go('/jobs/${widget.jobId}'),
        child: Container(
          // Figma: 210×60, radius 8, Cairo SemiBold 24 white.
          // Figma iPhone: 77×40, padding 10, SemiBold 14.
          constraints: BoxConstraints(
              minWidth: phone ? 77 : 210.w, minHeight: phone ? 40 : 60.w),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: phone ? 10 : 12.w),
          child: Text(
            widget.label,
            style: StyleText.fontSize14Weight400.copyWith(
              fontSize: phone ? 14 : 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
