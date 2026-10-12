part of '../pages/job_page.dart';

bool _phone(BuildContext c) => MediaQuery.sizeOf(c).width < 600;

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  /// Branding primary color from CMS model data (falls back to _kGreen).
  final Color? primary;
  const _InfoItem({required this.label, required this.value, this.primary});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            // Figma: label Cairo Medium 24 grey, value SemiBold 24 primary.
            style: StyleText.fontSize14Weight500.copyWith(
              fontSize: _phone(context) ? 12 : 22.sp, // Figma − 2
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: SiteColors.description,
            ),
          ),
          TextSpan(
            // BUG-195: shown exactly as typed in the admin.
            text: value,
            style: StyleText.fontSize14Weight600.copyWith(
              fontSize: _phone(context) ? 12 : 22.sp,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: primary ?? _kGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── View Job Button ──────────────────────────────────────────────────────────
