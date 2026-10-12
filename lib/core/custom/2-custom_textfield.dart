// ******************* FILE INFO *******************
// File Name: 2-custom_textfield.dart
// Description: The single shared text field widget. EVERY text field in
//              the app must use this widget — no raw TextField /
//              TextFormField anywhere.
//              App-wide rules baked in:
//              • NO character counter is ever shown (showCharCount ignored).
//              • NO language restriction — every field accepts Arabic AND
//                English freely (restrictByDirection ignored).
//              • Cursor + text-selection (copy) highlight always use
//                AppColors.primary — never the theme/platform yellow.
// Created by: Amr Mesbah

/// Module: core › custom

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/appcolors.dart';
import '../theme/new_theme.dart';
import '../theme/site_tokens.dart';

/// Custom text field widget — mirrors CustomDropdown API exactly.
///
/// Border rule: NO border by default; red border only when [errorText] is set.
class CustomTextField extends StatefulWidget {
  // ── Controller / Focus ───────────────────────────────────────────────────

  /// Text editing controller. If null an internal one is created.
  final TextEditingController? controller;

  /// Focus node. If null an internal one is created.
  final FocusNode? focusNode;

  // ── Content ──────────────────────────────────────────────────────────────

  /// Initial value (only used when [controller] is null).
  final String? initialValue;

  /// Placeholder text.
  final String? hint;

  /// Label displayed above the field.
  final String? label;

  /// Accessible name when the label is drawn outside this widget (BUG-257).
  final String? semanticsLabel;

  /// Error message — also triggers the red border.
  final String? errorText;

  /// Helper text displayed below the field.
  final String? helperText;

  // ── Icons ────────────────────────────────────────────────────────────────

  /// Widget shown at the start of the field.
  final Widget? prefixIcon;

  /// Widget shown at the end of the field (overrides the password-toggle eye).
  final Widget? suffixIcon;

  // ── Behaviour ────────────────────────────────────────────────────────────

  /// Whether the field is interactive.
  final bool enabled;

  /// Whether the field is read-only (tappable but not editable).
  final bool readOnly;

  /// Adds a red " *" to the label.
  final bool required;

  /// Hides text (password mode). Shows an eye-toggle unless [suffixIcon] is
  /// provided.
  final bool obscureText;

  /// Maximum number of lines. 1 = single-line (default). null = unlimited.
  final int? maxLines;

  /// Minimum number of lines for multiline fields.
  final int? minLines;

  /// Hard character limit (enforced silently — no counter is shown).
  final int? maxLength;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Input formatters (e.g. digits-only).
  final List<TextInputFormatter>? inputFormatters;

  /// Text alignment inside the field.
  final TextAlign textAlign;

  /// Text direction (useful for RTL/LTR mixed content).
  final TextDirection? textDirection;

  /// Action button on the keyboard.
  final TextInputAction? textInputAction;

  /// Auto-capitalisation strategy.
  final TextCapitalization textCapitalization;

  /// Whether to enable autocorrect.
  final bool autocorrect;

  /// Whether to show text-suggestions.
  final bool enableSuggestions;

  // ── Callbacks ────────────────────────────────────────────────────────────

  /// Called on every keystroke.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (presses the keyboard action button).
  final ValueChanged<String>? onSubmitted;

  /// Called when the field gains or loses focus.
  final ValueChanged<bool>? onFocusChanged;

  /// Called when the field is tapped (useful when [readOnly] is true).
  final VoidCallback? onTap;

  // ── Appearance ───────────────────────────────────────────────────────────

  /// Background fill color.
  final Color? fillColor;

  /// Border radius — defaults to 4.r internally.
  final BorderRadius? borderRadius;

  /// Padding inside the field container.
  final EdgeInsetsGeometry? contentPadding;

  // ── Text styles ──────────────────────────────────────────────────────────

  final TextStyle? valueStyle;
  final TextStyle? hintStyle;
  /// Placeholder font size. Null (default) = same size as the typed value.
  final double? hintFontSize;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final TextStyle? counterStyle;

  // ── Sizing (optional fixed box) ────────────────────────────────────────────

  /// Fixed width (interpreted in .w). Null → expands to parent.
  final double? width;

  /// Fixed height (interpreted in .h). Null → sizes to content.
  final double? height;

  // ── Built-in validation (opt-in) ───────────────────────────────────────────

  /// When true, an empty field shows a "required" error (use after a submit
  /// attempt). Only takes effect together with the other validation flags.
  final bool submitted;

  /// Restricts input to digits and validates the value is numeric.
  final bool onlyDigits;

  /// DEPRECATED / IGNORED — kept only for call-site compatibility.
  /// Every field accepts Arabic and English; no language restriction is
  /// ever applied.
  final bool restrictByDirection;

  /// Auto-capitalises the first letter of each word (LTR, non-digit only).
  final bool autoCapitalize;

  /// DEPRECATED / IGNORED — kept only for call-site compatibility.
  /// No character counter is ever shown anywhere in the app.
  final bool showCharCount;

  /// Branding primary color (comes from the app's CMS branding set in main).
  /// When provided it overrides [AppColors.primary] for the cursor and the
  /// text-selection highlight, so fields follow the active brand color.
  final Color? primaryColor;

  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.hint,
    this.label,
    this.semanticsLabel,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
    this.onTap,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
    this.valueStyle,
    this.hintStyle,
    this.hintFontSize,
    this.labelStyle,
    this.errorStyle,
    this.helperStyle,
    this.counterStyle,
    this.width,
    this.height,
    this.primaryColor,
    this.submitted = false,
    this.onlyDigits = false,
    this.restrictByDirection = false,
    this.autoCapitalize = false,
    this.showCharCount = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _obscured = true; // tracks password visibility toggle

  @override
  void initState() {
    super.initState();

    // Controller
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue);
      _ownsController = true;
    }

    // Focus node
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _focusNode.addListener(_onFocusChange);

    if (_needsTextListener) {
      _controller.addListener(_onTextChange);
    }
  }

  void _onFocusChange() {
    setState(() {}); // rebuild so suffix eye-icon tint can update if needed
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  void _onTextChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ── Controller swapped by the parent ────────────────────────────────────
    // Some pages dispose their controllers and create NEW ones when
    // re-seeding from a freshly loaded model. We must follow the new
    // instance — keeping the cached (now disposed) one crashes with
    // "A TextEditingController was used after being disposed".
    if (widget.controller != oldWidget.controller) {
      if (_needsTextListener) {
        try {
          _controller.removeListener(_onTextChange);
        } catch (_) {
          // old controller may already be disposed by the parent
        }
      }
      if (_ownsController) _controller.dispose();
      _ownsController = false;
      if (widget.controller != null) {
        _controller = widget.controller!;
      } else {
        _controller = TextEditingController(text: widget.initialValue);
        _ownsController = true;
      }
      if (_needsTextListener) _controller.addListener(_onTextChange);
    }

    // ── Focus node swapped by the parent ────────────────────────────────────
    if (widget.focusNode != oldWidget.focusNode) {
      try {
        _focusNode.removeListener(_onFocusChange);
      } catch (_) {}
      if (_ownsFocusNode) _focusNode.dispose();
      _ownsFocusNode = false;
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
      } else {
        _focusNode = FocusNode();
        _ownsFocusNode = true;
      }
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    // The external controller/focus node may have been disposed by its owner
    // before this widget unmounts (e.g. page re-seed + navigation) — guard.
    try {
      _focusNode.removeListener(_onFocusChange);
    } catch (_) {}
    if (_ownsFocusNode) _focusNode.dispose();
    if (_needsTextListener) {
      try {
        _controller.removeListener(_onTextChange);
      } catch (_) {}
    }
    if (_ownsController) _controller.dispose();
    super.dispose();
  }


  /// One-line field: value AND placeholder use exactly the same line box as
  /// the dropdown text (SiteField.centred), so all three sit on the same
  /// vertical middle. This works now that one-line fields no longer go
  /// through InputDecorator (which added its own vertical offset on web —
  /// the real reason text sat ~4 px low, whatever line height was used).
  TextStyle _centred(TextStyle s) => _fillsHeight ? SiteField.centred(s) : s;

  /// One-line field layout: the Container paints the box; inside it the
  /// input and the placeholder are two plain text lines stacked on top of
  /// each other and centred vertically by the same Align. No InputDecorator,
  /// no content padding, no baseline juggling → text is centred within the
  /// real field height, and placeholder == typed text alignment.
  Widget _singleLine(
    Widget input, {
    required TextStyle valueStyle,
    required TextStyle hintStyle,
    Widget? prefix,
    Widget? suffix,
  }) {
    final StrutStyle strut =
        StrutStyle.fromTextStyle(valueStyle, forceStrutHeight: true);
    // Placeholder uses the value's font size so both share one line box.
    final TextStyle hint = hintStyle.copyWith(
        fontSize: widget.hintFontSize ?? valueStyle.fontSize);
    final Widget body = Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        if ((widget.hint ?? '').isNotEmpty)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (_, v, __) => v.text.isEmpty
                ? IgnorePointer(
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        widget.hint!,
                        style: hint,
                        strutStyle: strut,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: widget.textAlign,
                        textDirection: widget.textDirection,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        input,
      ],
    );
    if (prefix == null && suffix == null) return body;
    return Row(
      children: [
        if (prefix != null) ...[prefix, SizedBox(width: 8.w)],
        Expanded(child: body),
        if (suffix != null) ...[SizedBox(width: 8.w), suffix],
      ],
    );
  }

  /// One-line field with a fixed height → fills that height (see TextField).
  bool get _fillsHeight =>
      widget.height != null && !_isMultiline && !widget.obscureText;

  bool get _isMultiline =>
      (widget.maxLines ?? 1) != 1 || widget.minLines != null;

  // ── Opt-in helpers ─────────────────────────────────────────────────────────

  /// Effective character limit: explicit [maxLength] only. The counter is
  /// NEVER shown (app-wide rule) so [showCharCount] adds no implicit limit.
  int? get _effectiveMaxLength => widget.maxLength;

  bool get _hasValidation => widget.submitted || widget.onlyDigits;

  bool get _needsTextListener => _hasValidation;

  /// Resolves the error to display: explicit [errorText] wins, otherwise the
  /// built-in validation (only active when a validation flag is set).
  ///
  /// NOTE: There is deliberately NO language validation here — every field
  /// accepts Arabic and English text freely.
  String? get _resolvedError {
    final explicit = widget.errorText;
    if (explicit != null && explicit.isNotEmpty) return explicit;
    if (!_hasValidation) return null;

    final text = _controller.text;
    final isEmpty = text.trim().isEmpty;
    // BUG-122: the message language follows the PAGE (Directionality), not
    // the field's own text direction — the Arabic Apply form showed English
    // "This field is required." because its fields don't pass textDirection
    // (and the phone field is forced LTR).
    final isRtl = (Directionality.maybeOf(context) ?? widget.textDirection) ==
        TextDirection.rtl;

    if (widget.submitted && isEmpty) {
      return isRtl ? 'هذا الحقل مطلوب' : 'This field is required.';
    }
    if (widget.onlyDigits &&
        text.isNotEmpty &&
        !RegExp(r'^\d+$').hasMatch(text)) {
      return isRtl ? 'يُسمح بالأرقام فقط.' : 'Only numbers are allowed.';
    }
    return null;
  }

  /// Builds input formatters from the opt-in flags, then appends any caller
  /// supplied [inputFormatters].
  ///
  /// NOTE: No Arabic-only / English-only formatters — both languages are
  /// always allowed.
  List<TextInputFormatter>? get _resolvedFormatters {
    final list = <TextInputFormatter>[];
    if (widget.autoCapitalize &&
        widget.textDirection != TextDirection.rtl &&
        !widget.onlyDigits) {
      list.add(_CapitalizeTextFormatter());
    }
    if (widget.onlyDigits) {
      list.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (widget.inputFormatters != null) list.addAll(widget.inputFormatters!);
    return list.isEmpty ? null : list;
  }

  // Effective obscure: only applies when the prop is true AND not multiline
  bool get _effectiveObscure =>
      widget.obscureText && !_isMultiline && _obscured;

  TextStyle _valueStyle(bool isDisabled) =>
      widget.valueStyle ??
      StyleText.fontSize14Weight400.copyWith(
        color: isDisabled ? AppColors.text.withOpacity(0.4) : AppColors.text,
      );

  TextStyle _hintStyle() =>
      widget.hintStyle ??
      StyleText.fontSize18Weight500.copyWith(color: SiteColors.placeholder);

  /// Wraps the TextField in the one-line layout when [_fillsHeight].
  Widget _maybeSingleLine(
    Widget field, {
    required TextStyle valueStyle,
    required TextStyle hintStyle,
    Widget? prefix,
    Widget? suffix,
  }) =>
      _fillsHeight
          ? _singleLine(field,
              valueStyle: valueStyle,
              hintStyle: hintStyle,
              prefix: prefix,
              suffix: suffix)
          : field;

  @override
  Widget build(BuildContext context) {
    final resolvedError = _resolvedError;
    final hasError = resolvedError != null && resolvedError.isNotEmpty;
    final radius = widget.borderRadius ?? BorderRadius.circular(4.r);
    final isDisabled = !widget.enabled;

    // Branding primary (from the app's CMS branding via [primaryColor]) drives
    // the cursor + selection highlight; falls back to the theme primary.
    final Color brandPrimary = widget.primaryColor ?? AppColors.primary;

    // ── Suffix icon resolution ─────────────────────────────────────────────
    // Priority: explicit suffixIcon > password-toggle eye > nothing
    Widget? resolvedSuffix = widget.suffixIcon;
    if (resolvedSuffix == null && widget.obscureText && !_isMultiline) {
      resolvedSuffix = GestureDetector(
        onTap: () => setState(() => _obscured = !_obscured),
        child: Icon(
          _obscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20.sp,
          color: hasError
              ? AppColors.red
              : isDisabled
              ? AppColors.text.withOpacity(0.3)
              : AppColors.text.withOpacity(0.5),
        ),
      );
    }

    // ── Content padding ────────────────────────────────────────────────────
    // Every field: 10.sp inner padding (SiteField).
    final effectivePadding =
        widget.contentPadding ?? EdgeInsets.symmetric(horizontal: 12.sp , vertical: 1.sp);
    final Color fieldFill = isDisabled
        ? (widget.fillColor ?? AppColors.card).withOpacity(0.5)
        : widget.fillColor ?? AppColors.card;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──────────────────────────────────────────────────────────
        if (widget.label != null) ...[
          // BUG-233 / BUG-236 / BUG-186: ONE label widget for every field
          // (text, phone, link, upload): 16 SemiBold #2D2D2D + red " *".
          requiredLabel(
            widget.label!,
            required: widget.required,
            style: widget.labelStyle,
          ),
          const SizedBox(height: 8),
        ],

        // ── Field ──────────────────────────────────────────────────────────
        // A one-line field is ONE 36.sp box (SiteField.height) painted by
        // this Container — fill, radius and the red error border — with the
        // text vertically centred and 10.sp padding. (The InputDecoration
        // `constraints` approach painted only the text line on web.)
        Container(
          width: widget.width?.w,
          height: _fillsHeight ? SiteField.height : widget.height?.h,
          padding: _fillsHeight
              ? EdgeInsets.symmetric(horizontal: SiteField.padding)
              : null,
          alignment: _fillsHeight ? AlignmentDirectional.centerStart : null,
          decoration: _fillsHeight
              ? BoxDecoration(
                  color: fieldFill,
                  borderRadius: radius,
                  border: hasError
                      ? Border.all(color: SiteColors.error, width: 1.5)
                      : null,
                )
              : null,
          child: Theme(
            // ── Cursor / selection color rule ───────────────────────────────
            // Flutter derives the blinking cursor color, the text-selection
            // (copy) highlight, and the drag handles from
            // TextSelectionThemeData — NOT from TextField params alone on
            // every platform. Force all three to AppColors.primary here so
            // they never fall back to the theme primary (yellow).
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: brandPrimary,
                selectionColor: brandPrimary.withOpacity(0.3),
                selectionHandleColor: brandPrimary,
              ),
            ),
            // BUG-257: the input is announced by its label, not "Text Here".
            child: Semantics(
              label: widget.semanticsLabel ?? widget.label,
              child: _maybeSingleLine(TextField(

              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              obscureText: _effectiveObscure,
              // BUG-223: a one-line field is a real single-line <input>
              // (maxLines: 1). `expands` + maxLines:null turned every Name /
              // Email / Phone field into a <textarea> (Safari scroll thumb,
              // Enter swallowed the following characters). The full height
              // now comes from InputDecoration.constraints instead (BUG-165).
              maxLines: _fillsHeight ? 1 : (widget.obscureText ? 1 : widget.maxLines),
              minLines: _fillsHeight ? null : widget.minLines,
              expands: false,
              maxLength: _fillsHeight ? null : _effectiveMaxLength,
              cursorColor: brandPrimary,
              keyboardType: _isMultiline
                  ? TextInputType.multiline
                  : (widget.keyboardType ??
                  (widget.onlyDigits ? TextInputType.number : null)),
              inputFormatters: _fillsHeight
                  ? [
                      ...?_resolvedFormatters,
                      FilteringTextInputFormatter.deny(RegExp(r'[\n\r]')),
                      if (_effectiveMaxLength != null)
                        LengthLimitingTextInputFormatter(_effectiveMaxLength),
                    ]
                  : _resolvedFormatters,
              textAlign: widget.textAlign,
              textDirection: widget.textDirection,
              // BUG-223: Enter in a one-line field moves to the next field.
              textInputAction: widget.textInputAction ??
                  (_isMultiline ? null : TextInputAction.next),
              textCapitalization: widget.textCapitalization,
              autocorrect: widget.autocorrect,
              enableSuggestions: widget.enableSuggestions,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onTap: widget.onTap,
              style: _centred(_valueStyle(isDisabled)),
              // NEVER show the built-in counter (app-wide rule)
              buildCounter: _effectiveMaxLength != null
                  ? (_,
                  {required currentLength,
                    required isFocused,
                    maxLength}) =>
              const SizedBox.shrink()
                  : null,
              // A one-line field with a fixed height fills that WHOLE height
              // (text centred), exactly like the dropdowns next to it — before,
              // only the text line was painted and the box looked shorter.
              textAlignVertical: null,
              // QA-Oct11: value + hint share ONE fixed line box (the same as
              // the dropdown Text), so both sit on the box's middle.
              strutStyle: _fillsHeight
                  ? StrutStyle.fromTextStyle(
                      _centred(_valueStyle(isDisabled)),
                      forceStrutHeight: true,
                    )
                  : null,
              // One-line fields have NO InputDecorator (see _singleLine).
              decoration: _fillsHeight ? null : InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.sp , vertical: 20.sp),
                filled: true,
                // No hover overlay tint on desktop/web
                hoverColor: Colors.transparent,
                fillColor: fieldFill,

                // ── No border rule ────────────────────────────────────────────
                // Default / focused / disabled → no border at all.
                // Error → red border.
                border: hasError
                    ? OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: const BorderSide(color: SiteColors.error, width: 1.5),
                )
                    : OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide.none,
                ),
                enabledBorder: hasError
                    ? OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: const BorderSide(color: SiteColors.error, width: 1.5),
                )
                    : OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide.none,
                ),
                focusedBorder: hasError
                    ? OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: const BorderSide(color: SiteColors.error, width: 1.5),
                )
                    : OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide.none,
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: const BorderSide(color: SiteColors.error, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: const BorderSide(color: SiteColors.error, width: 1.5),
                ),
                // ─────────────────────────────────────────────────────────────

                hintText: widget.hint,
                // BUG-129 / BUG-136: readable placeholder (≥ 4.5:1).
                hintStyle: _centred((widget.hintStyle ??
                    StyleText.fontSize18Weight500.copyWith(
                      color: SiteColors.placeholder,
                    )).copyWith(fontSize: widget.hintFontSize)),

                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                  padding: EdgeInsetsDirectional.only(
                      start: _fillsHeight ? 0 : SiteField.padding, end: 8.w),
                  child: widget.prefixIcon,
                )
                    : null,
                prefixIconConstraints: const BoxConstraints(),

                suffixIcon: resolvedSuffix != null
                    ? Padding(
                  padding: EdgeInsetsDirectional.only(
                      start: 8.w, end: _fillsHeight ? 0 : SiteField.padding),
                  child: resolvedSuffix,
                )
                    : null,
                suffixIconConstraints: const BoxConstraints(),

                // Suppress built-in error / helper — we render our own
                errorText: null,
                helperText: null,
                counterText: '',
              ),
            ),
              valueStyle: _centred(_valueStyle(isDisabled)),
              hintStyle: _centred(_hintStyle()),
              prefix: widget.prefixIcon,
              suffix: resolvedSuffix,
            ),
            ),
          ),
        ),

        // ── Error / Helper row (NO counter — app-wide rule) ────────────────
        if (hasError || widget.helperText != null) ...[
          // BUG-131: the same gap under every field and dropdown.
          const SizedBox(height: SiteText.errorGap),
          hasError
              ? Text(
            resolvedError!,
            style: widget.errorStyle ?? customFieldErrorStyle(),
          )
              : Text(
            widget.helperText!,
            style: widget.helperStyle ??
                StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text.withOpacity(0.5),
                ),
          ),
          // BUG-131: breathing room before the next label (was ≈2 px).
          if (hasError) const SizedBox(height: 4),
        ],
      ],
    );
  }
}

/// BUG-131: ONE error style for text fields, dropdowns, the phone picker
/// and the upload boxes — 13 px, one red (#D32F2F).
TextStyle customFieldErrorStyle() => SiteText.error();

/// BUG-128: label with a red " *" for required fields — used by fields that
/// draw their own label (phone, dropdowns, legacy shim).
Widget requiredLabel(String label,
    {bool required = false, TextStyle? style, TextDirection? textDirection}) {
  // BUG-186: Figma form labels are 16 px SemiBold #2D2D2D.
  final base = style ??
      StyleText.fontSize14Weight400.copyWith(
        fontSize:   16.sp, // Figma form labels: Cairo SemiBold 16 #2D2D2D
        fontWeight: FontWeight.w600,
        color:      SiteColors.textStrong,
      );
  return Text.rich(
    TextSpan(
      text: label,
      style: base,
      children: required
          ? [TextSpan(text: ' *', style: base.copyWith(color: SiteColors.error))]
          : const [],
    ),
    textDirection: textDirection,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Private input formatters (self-contained — no external dependencies)
// ─────────────────────────────────────────────────────────────────────────────

/// Capitalises the first letter of every word.
class _CapitalizeTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) return newValue;

    final capitalizedText = newValue.text.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (word.length == 1) return word.toUpperCase();
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return TextEditingValue(
      text: capitalizedText,
      selection: TextSelection.collapsed(offset: capitalizedText.length),
    );
  }
}