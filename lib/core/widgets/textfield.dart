/// ******************* FILE INFO *******************
/// File Name: textfield.dart
/// Description: DEPRECATED SHIM — CustomValidatedTextFieldMaster is now a thin
///              wrapper around the single shared text field in
///              lib/core/custom/2-custom_textfield.dart. Keeps the legacy API
///              (submitted / minLength / onlyDigits validation) while delegating
///              ALL rendering to the shared custom widget.
/// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import '../theme/site_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../custom/2-custom_textfield.dart' as custom;
import '../theme/appcolors.dart';
import '../theme/new_theme.dart';

class CustomValidatedTextFieldMaster extends StatefulWidget {
  final String? label;
  final String hint;
  final TextEditingController controller;
  final double height;
  final double? width;
  final int maxLines;
  final bool enabled;

  /// IGNORED — no character counter in the shared design.
  final bool showCharCount;
  final ValueChanged<String>? onChanged;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final bool onlyDigits;
  final bool submitted;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;

  /// Kept for call-site compatibility — ignored (shared design is borderless).
  final Color? primaryColor;

  final int maxLength;
  final int minLength;

  /// BUG-14: when true, a non-empty value must look like an e-mail address.
  final bool isEmail;

  /// BUG-128: adds a red " *" to the label.
  final bool required;

  /// Extra error from the page (e.g. BUG-102 invalid phone number). The
  /// built-in "required" / length errors win over it.
  final String? errorText;

  const CustomValidatedTextFieldMaster({
    super.key,
    this.label,
    required this.hint,
    required this.controller,
    this.height = 38, // BUG-165: one field height (text = dropdown = phone)
    this.width,
    this.maxLines = 1,
    this.enabled = true,
    this.showCharCount = false,
    this.onChanged,
    this.textDirection = TextDirection.ltr,
    this.textAlign = TextAlign.start,
    this.onlyDigits = false,
    this.submitted = false,
    this.textStyle,
    this.hintStyle,
    this.fillColor,
    this.primaryColor,
    this.maxLength = 500,
    this.minLength = 0,
    this.isEmail = false,
    this.required = false,
    this.errorText,
  });

  @override
  State<CustomValidatedTextFieldMaster> createState() =>
      _CustomValidatedTextFieldMasterState();
}

class _CustomValidatedTextFieldMasterState
    extends State<CustomValidatedTextFieldMaster> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(CustomValidatedTextFieldMaster oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final bool isMultiline = widget.maxLines > 1;
    final String text = widget.controller.text;
    final bool isEmpty = text.trim().isEmpty;
    final bool isTooShort =
        !isEmpty && widget.minLength > 0 && text.trim().length < widget.minLength;
    final bool isNotDigits = widget.onlyDigits &&
        text.isNotEmpty &&
        !RegExp(r'^\d+$').hasMatch(text);

    String? errorText;
    if (widget.submitted && isEmpty) {
      errorText = widget.textDirection == TextDirection.rtl
          ? 'هذا الحقل مطلوب'
          : 'This field is required.';
    } else if (widget.submitted && isTooShort) {
      errorText = widget.textDirection == TextDirection.rtl
          ? 'الحد الأدنى ${widget.minLength} حرف'
          : 'Minimum ${widget.minLength} characters required.';
    } else if (widget.submitted &&
        widget.isEmail &&
        !isEmpty &&
        !isValidEmail(text)) {
      // BUG-14: "not-an-email" used to pass.
      errorText = widget.textDirection == TextDirection.rtl
          ? 'يرجى إدخال بريد إلكتروني صحيح'
          : 'Please enter a valid email.';
    } else if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      errorText = widget.errorText;
    } else if (isNotDigits) {
      errorText = widget.textDirection == TextDirection.rtl
          ? 'يُسمح بالأرقام فقط.'
          : 'Only numbers are allowed.';
    }

    final Color resolvedFill = widget.fillColor ??
        (lightMode ? const Color(0xFFF1F2ED) : AppColors.background);

    // Every field: 10.sp inner padding (SiteField).
    final EdgeInsetsGeometry contentPadding = isMultiline
        ? EdgeInsets.all(SiteField.padding)
        : EdgeInsets.symmetric(horizontal: SiteField.padding);

    final field = custom.CustomTextField(
      controller: widget.controller,

      hint: widget.hint,
      label: null,
      semanticsLabel: widget.label,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      width: widget.width,
      height: isMultiline ? null : widget.height,
      textDirection: widget.textDirection,
      textAlign: widget.textAlign,
      onlyDigits: widget.onlyDigits,
      keyboardType:
          widget.onlyDigits ? TextInputType.number : TextInputType.text,
      onChanged: widget.onChanged,
      fillColor: resolvedFill,
      contentPadding: EdgeInsets.symmetric(vertical: 12.sp , horizontal:12.sp),
      errorText: errorText,
      primaryColor: widget.primaryColor,
      valueStyle: widget.textStyle ??
          StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text, fontSize: 14.sp),
      // BUG-129 / BUG-136: field-specific hint in a readable grey.
      hintStyle: widget.hintStyle ??
          StyleText.fontSize14Weight400
              .copyWith(color: SiteColors.placeholder),
      inputFormatters: [
        LengthLimitingTextInputFormatter(widget.maxLength),
      ],
    );

    if (widget.label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        custom.requiredLabel(
          widget.label!,
          required: widget.required,
          textDirection: widget.textDirection,
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}

/// BUG-14: shared e-mail format check (contact form + validation on Send).
bool isValidEmail(String value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(value.trim());
