part of '../pages/contact_us_page.dart';

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool   submitted, isMobile, isRtl;
  final String selectedCode, label;
  final ValueChanged<String?> onCodeChanged;
  final Color  primaryColor;
  /// BUG-102: "Please enter a valid mobile number."
  final String? errorText;

  const _PhoneField({
    required this.controller,
    required this.submitted,
    required this.selectedCode,
    required this.onCodeChanged,
    required this.isRtl,
    required this.label,
    required this.primaryColor,
    this.isMobile = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final bool numberHasError = (errorText != null && errorText!.isNotEmpty) ||
        (submitted && controller.text.trim().isEmpty);
    // BUG-247: fixed picker width + Expanded number box, so the row spans
    // the full field width (a loose Flexible left a gap at the end).
    // Figma: country code 130 (desktop) / 102 (iPhone) wide.
    // QA-Oct11 #17: wide enough for "EG +20" / "SA +966" without "…".
    final double codeW =
        isMobile ? 120 : 140.w.clamp(130.0, 170.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BUG-128: required marker. BUG-132: same label gap as other fields.
        _FormLabel(label: label, required: true),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: codeW,
              // BUG-224: the picker follows the page direction (flag + code at
              // the start, arrow at the end — mirrored in Arabic). The code
              // itself stays "+20" via an LTR isolate.
              child: CustomDropdownFormFieldInvMaster(
                selectedValue: selectedCode,
                items: [
                  for (final c in _phoneCodes)
                    {'key': c['key']!, 'value': phoneCodeLabel(c['value']!)},
                ],
                primaryColor:  primaryColor,
                onChanged:     onCodeChanged,
                widthIcon:  16,
                heightIcon: 16,
                height: 42,
                borderRadius: 4,
                // BUG-225: red border together with the number box on error.
                showErrorBorder: numberHasError,
                hint: Text(
                    isRtl ? 'الرمز' : 'Code',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: SiteColors.placeholder)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomValidatedTextFieldMaster(
                // BUG-129: field-specific hint.
                hint:          '01xxxxxxxxx',
                label:         null,
                controller:    controller,
                submitted:     submitted,
                errorText:     errorText,
                primaryColor:  primaryColor,
                height:        42,
                onlyDigits:    true,
                textDirection: TextDirection.ltr,
                textAlign:     isRtl ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OFFICE CARDS
// ═══════════════════════════════════════════════════════════════════════════════
