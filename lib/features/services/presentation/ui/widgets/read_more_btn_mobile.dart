part of '../pages/services_page.dart';

class _ReadMoreBtnMobile extends StatelessWidget {
  final VoidCallback onTap;
  final String       label;
  final Color        primaryColor;
  const _ReadMoreBtnMobile({
    required this.onTap,
    this.label = 'Read More',
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Figma: 81×34, radius 6, Cairo Medium 14 white (44 px tap height).
      child: Container(
        constraints: const BoxConstraints(minWidth: 81, minHeight: 34),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
            color:        primaryColor,
            borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: StyleText.fontSize12Weight600.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white)),
      ),
    );
  }
}
