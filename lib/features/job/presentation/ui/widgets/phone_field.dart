part of '../pages/job_apply_page.dart';

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool submitted, isRtl;
  final String selectedCode, label;
  final ValueChanged<String?> onCodeChanged;
  final Color primaryColor;
  /// BUG-238: "Please enter a valid mobile number."
  final String? errorText;

  const _PhoneField({
    required this.controller,
    required this.submitted,
    required this.selectedCode,
    required this.onCodeChanged,
    required this.isRtl,
    required this.label,
    required this.primaryColor,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final bool numberHasError = (errorText != null && errorText!.isNotEmpty) ||
        (submitted && controller.text.trim().isEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BUG-233: EXACTLY the label widget, style and gap of CustomTextField
        // (requiredLabel + 8 px), so "Phone" and "Email" share one baseline
        // and their boxes one top edge. BUG-128: required "*".
        requiredLabel(label, required: true, style: _jobLabelStyle(context)),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (context, c) {
          // BUG-116 / BUG-133: the picker never takes more than 40 % of the
          // row (the number box was 37 px wide on phones).
          // QA-Oct11 #17: the code showed "NG +…" — 130 px minimum so the
          // country + code are always shown in full.
          final double maxCode = 150.w < 130.0 ? 130.0 : 150.w;
          final double codeW =
              (c.maxWidth * 0.4).clamp(130.0, maxCode).toDouble();
          // BUG-224: the picker follows the page direction (mirrored in
          // Arabic: code at the start/right, arrow at the end/left); the
          // code text itself stays "+20" through an LTR isolate.
          final Widget dropdown = SizedBox(
            width: codeW,
            child: CustomDropdown<String>(
              value: selectedCode,
              items: _kCountryCodes
                  .map((c) => DropdownItem<String>(
                      value: c['key']!, label: phoneCodeLabel(c['value']!)))
                  .toList(),
              onChanged: (v) => onCodeChanged(v),
              hint: isRtl ? 'الرمز' : 'Code',
              fillColor: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
              itemHeight: 42.h,
              // BUG-165 / BUG-233: exactly the text-field height.
              fieldHeight: 42.h,
              // BUG-225: red with the number box, never theme yellow.
              showErrorBorder: numberHasError,
              triggerPadding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
              valueStyle: StyleText.fontSize12Weight400
                  .copyWith(
                  color: AppColors.text,
                  // Phone: same 10.sp as the field hints.
                  fontSize: _jobHintSize(context) ?? 14.sp),
              hintStyle: StyleText.fontSize12Weight400
                  .copyWith(
                  color: SiteColors.placeholder,
                  fontSize: _jobHintSize(context) ?? 14.sp),
            ),
          );

          final Widget input = Expanded(
            child: CustomTextField(
              hint: '01xxxxxxxxx', // BUG-129
              semanticsLabel: label,
              controller: controller,
              submitted: submitted,
              errorText: errorText,
              height: 42,
              fillColor: Colors.white,
              hintFontSize: _jobHintSize(context),
              onlyDigits: true,
              textDirection: TextDirection.ltr,
              textAlign: isRtl ? TextAlign.right : TextAlign.start,
            ),
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dropdown,
              const SizedBox(width: 8),
              input,
            ],
          );
        }),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  URL VALIDATED TEXT FIELD — FOR LINK-TYPE DOCUMENTS
// ═══════════════════════════════════════════════════════════════════════════════
