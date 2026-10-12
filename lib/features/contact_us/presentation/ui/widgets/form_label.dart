part of '../pages/contact_us_page.dart';

class _FormLabel extends StatelessWidget {
  final String label;
  final bool required; // BUG-128: red " *"
  const _FormLabel({required this.label, this.required = false});
  @override
  Widget build(BuildContext context) => custom.requiredLabel(
    label,
    required: required,
    // BUG-186: Figma labels 16 SemiBold #2D2D2D.
    style: StyleText.fontSize14Weight400.copyWith(
        color: SiteColors.textStrong, fontSize: 16.sp, fontWeight: FontWeight.w600),
  );
}
