part of '../pages/contact_us_page.dart';

class _FormCard extends StatelessWidget {
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, entityNameCtrl, subjectCtrl, messageCtrl,
      otherLanguageCtrl; // ← NEW
  final bool   submitted, isMobile, isRtl;
  /// BUG-102: phone filled in but not a plausible mobile number.
  final bool   phoneInvalid;
  final String phoneCode, preferredLanguage;
  final String? selectedLocation, selectedEntityType, selectedEntitySize;
  final Color  primaryColor;
  final ValueChanged<String?>  onCodeChanged;
  final ValueChanged<String>   onLanguageChanged;
  final ValueChanged<String?>  onLocationChanged;
  final ValueChanged<String?>  onEntityTypeChanged;
  final ValueChanged<String?>  onEntitySizeChanged;
  final VoidCallback           onSend;

  const _FormCard({
    required this.firstNameCtrl,    required this.lastNameCtrl,
    required this.emailCtrl,        required this.phoneCtrl,
    required this.entityNameCtrl,   required this.subjectCtrl,
    required this.messageCtrl,      required this.otherLanguageCtrl,
    required this.submitted,
    required this.phoneCode,        required this.preferredLanguage,
    required this.selectedLocation, required this.selectedEntityType,
    required this.selectedEntitySize,
    required this.onCodeChanged,    required this.onLanguageChanged,
    required this.onLocationChanged, required this.onEntityTypeChanged,
    required this.onEntitySizeChanged,
    required this.onSend,           required this.isRtl,
    required this.primaryColor,     this.isMobile = false,
    this.phoneInvalid = false,
  });

  // ── Helper: builds one custom radio dot + label widget ──
  Widget _radioItem({
    required String lang,
    required String displayLabel,
    required String preferredLanguage,
    required Color  primaryColor,
    required bool   isMobile,
    required ValueChanged<String> onLanguageChanged,
  }) {
    final bool selected = preferredLanguage == lang;
    // BUG-257: radios are focusable with Tab and announced as radio buttons.
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: displayLabel,
      excludeSemantics: true,
      child: InkWell(
      onTap: () => onLanguageChanged(lang),
      borderRadius: BorderRadius.circular(6),
      focusColor: primaryColor.withOpacity(0.15),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width:  18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? primaryColor : const Color(0xFF8A8A8A),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                child: Container(
                  width:  10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 6),
            Text(
              displayLabel,
              style: StyleText.fontSize13Weight400.copyWith(
                color:    selected ? SiteColors.textStrong : SiteColors.description,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // ── Helper: two fields side-by-side on desktop, stacked on mobile ──
  Widget _pair(Widget a, Widget b) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [a, const SizedBox(height: 12), b],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        SizedBox(width: 19.w), // Figma: 19 px between the two columns
        Expanded(child: b),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Figma: radius 8 on the iPhone frame, 15 on desktop.
    final double rad = isMobile ? 8 : 15.r;

    // BUG-146: Title Case like every other heading / button on the site.
    final String title             = _t(context, en: 'Get in Touch',       ar: 'تواصل معنا');
    final String prefLangLabel     = _t(context, en: 'Preferred Language', ar: 'اللغة المفضلة');
    final String firstNameLabel    = _t(context, en: 'First Name',         ar: 'الاسم الأول');
    final String lastNameLabel     = _t(context, en: 'Last Name',          ar: 'اسم العائلة');
    final String emailLabel        = _t(context, en: 'Email',              ar: 'البريد الإلكتروني');
    final String phoneLabel        = _t(context, en: 'Phone Number',       ar: 'رقم الهاتف');
    final String locationLabel     = _t(context, en: 'Location',           ar: 'الموقع');
    // BUG-128: the one optional field says so.
    final String entityNameLabel   = _t(context, en: "Entity's Name (Optional)", ar: 'اسم الجهة (اختياري)');
    final String entityTypeLabel   = _t(context, en: "Entity's Type",      ar: 'نوع الجهة');
    final String entitySizeLabel   = _t(context, en: "Entity's Size",      ar: 'حجم الجهة');
    final String subjectLabel      = _t(context, en: 'Subject',            ar: 'الموضوع');
    final String msgLabel          = _t(context, en: 'Message',            ar: 'الرسالة');
    // BUG-129: field-specific hints instead of "Text Here" everywhere.
    final String firstNameHint     = _t(context, en: 'e.g. Ahmed',                 ar: 'مثال: أحمد');
    final String lastNameHint      = _t(context, en: 'e.g. Hassan',                ar: 'مثال: حسن');
    final String emailHint         = _t(context, en: 'e.g. name@company.com',      ar: 'مثال: name@company.com');
    final String entityNameHint    = _t(context, en: 'e.g. Bayanatz',              ar: 'مثال: بيانات زي');
    final String subjectHint       = _t(context, en: 'What is your message about?', ar: 'ما موضوع رسالتك؟');
    final String messageHint       = _t(context, en: 'Tell us how we can help (at least 30 characters)', ar: 'أخبرنا كيف يمكننا مساعدتك (30 حرفًا على الأقل)');
    final String phoneInvalidMsg   = _t(context, en: 'Please enter a valid mobile number.', ar: 'يرجى إدخال رقم جوال صحيح.');
    final String sendLabel         = _t(context, en: 'Send',               ar: 'إرسال');
    final String selectLocation    = _t(context, en: 'Select Location',    ar: 'اختر الموقع');
    final String selectType        = _t(context, en: 'Select Type',        ar: 'اختر النوع');
    final String selectSize        = _t(context, en: 'Select Size',        ar: 'اختر الحجم');
    final String otherLangHint     = _t(context, en: 'e.g. French, Spanish…', ar: 'مثال: الفرنسية، الإسبانية…');
    final String otherLangRequired = _t(context, en: 'Please enter your preferred language', ar: 'يرجى إدخال لغتك المفضلة');

    final TextDirection dir   = isRtl ? TextDirection.rtl : TextDirection.ltr;
    final TextAlign     align = isRtl ? TextAlign.right   : TextAlign.left;

    // ── Build dropdown items for entity type ──
    final entityTypes = isRtl
        ? ContactFormConstants.entityTypesAr
        : ContactFormConstants.entityTypesEn;
    final entityTypeItems = entityTypes
        .map((t) => {'key': t, 'value': t})
        .toList();

    // ── Build dropdown items for entity size ──
    final entitySizes = isRtl
        ? ContactFormConstants.entitySizesAr
        : ContactFormConstants.entitySizes;
    final entitySizeItems = entitySizes
        .map((s) => {'key': s, 'value': s})
        .toList();

    // ── Build dropdown items for location (countries) ──
    final countries = isRtl
        ? ContactFormConstants.countriesAr
        : ContactFormConstants.countriesEn;
    final countryItems = countries
        .map((c) => {'key': c, 'value': c})
        .toList();

    // ── Standard language keys (ar / en) — whatever ContactFormConstants provides,
    //    but strip any pre-existing "other" key so we never duplicate it ──
    final List<String> standardLanguageKeys = ContactFormConstants
        .preferredLanguages
        .where((k) => k != _kOtherLanguage)
        .toList();

    final langLabels = isRtl
        ? ContactFormConstants.preferredLanguageLabelsAr
        : ContactFormConstants.preferredLanguageLabelsEn;

    final String otherRadioLabel = isRtl ? 'أخرى' : 'Other';
    final bool showOtherField    = preferredLanguage == _kOtherLanguage;
    final bool otherFieldError   =
        showOtherField && submitted && otherLanguageCtrl.text.trim().isEmpty;

    // Figma form card (837 wide): padding 50 at the sides, 33 top, 42 bottom.
    final Widget rowGap = SizedBox(height: isMobile ? 7.5.sp : 20.w);
    return Container(
      padding: isMobile
          ? const EdgeInsets.all(15) // Figma iPhone: padding 15, radius 8
          : EdgeInsets.only(left: 50.w, right: 50.w, top: 33.w, bottom: 42.w),
      decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(rad)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Title ──
          // BUG-186: Figma "GET IN TOUCH" 26 Bold #1C1A1A.
          Text(title,
              style: StyleText.fontSize22Weight700.copyWith(
                  fontSize:      isMobile ? 20 : 26.sp, // Figma Bold 20 / 26
                  color:         const Color(0xFF1C1A1A))),
          SizedBox(height: isMobile ? 8.h : 30.w),

          // ─────────────────────────────────────────────────────────
          // Preferred Language
          //   Row 1: standard radios (ar / en …)
          //   Row 2: "Other" radio  +  inline text field (same row)
          // ─────────────────────────────────────────────────────────
          _FormLabel(label: prefLangLabel),
          SizedBox(height: isMobile ? 10.h : 8.w),

          // Row — all language radios + "Other" radio + inline text field in ONE flat Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (final lang in standardLanguageKeys) ...[
                _radioItem(
                  lang:              lang,
                  displayLabel:      langLabels[lang] ?? lang,
                  preferredLanguage: preferredLanguage,
                  primaryColor:      primaryColor,
                  isMobile:          isMobile,
                  onLanguageChanged: onLanguageChanged,
                ),
                SizedBox(width: isMobile ? 14.w : 20.w),
              ],
              // "Other" radio
              _radioItem(
                lang:              _kOtherLanguage,
                displayLabel:      otherRadioLabel,
                preferredLanguage: preferredLanguage,
                primaryColor:      primaryColor,
                isMobile:          isMobile,
                onLanguageChanged: onLanguageChanged,
              ),
              SizedBox(width: 10.w),
              // Inline text field — only takes remaining space when visible
              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve:    Curves.easeInOut,
                  child: showOtherField
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomValidatedTextFieldMaster(
                        hint:          otherLangHint,
                        controller:    otherLanguageCtrl,
                        submitted:     otherFieldError,
                        height:        42,
                        primaryColor:  primaryColor,
                        textDirection: dir,
                        textAlign:     align,
                        fillColor:     Colors.white,
                      ),
                    ],
                  )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 7.5.sp : 20.w),

          // ── First Name / Last Name (mobile: stacked) ──
          _pair(
            CustomValidatedTextFieldMaster(
              label:         firstNameLabel,
              required:      true,
              hint:          firstNameHint,
              controller:    firstNameCtrl,
              submitted:     submitted,
              primaryColor:  primaryColor,
              textDirection: dir,
              textAlign:     align,
            ),
            CustomValidatedTextFieldMaster(
              label:         lastNameLabel,
              required:      true,
              hint:          lastNameHint,
              controller:    lastNameCtrl,
              submitted:     submitted,
              primaryColor:  primaryColor,
              textDirection: dir,
              textAlign:     align,
            ),
          ),
          rowGap,

          // ── Email / Phone (mobile: stacked; phone keeps code+number row) ──
          _pair(
            CustomValidatedTextFieldMaster(
              label:        emailLabel,
              required:     true,
              primaryColor: primaryColor,
              hint: emailHint,
              controller:    emailCtrl,
              submitted:     submitted,
              isEmail:       true, // BUG-14
              textDirection: dir,
              textAlign:     align,
            ),
            _PhoneField(
              label:         phoneLabel,
              controller:    phoneCtrl,
              submitted:     submitted,
              errorText:     phoneInvalid ? phoneInvalidMsg : null,
              isMobile:      isMobile,
              selectedCode:  phoneCode,
              onCodeChanged: onCodeChanged,
              isRtl:         isRtl,
              primaryColor:  primaryColor,
            ),
          ),
          rowGap,

          // ── Location / Entity Name (mobile: stacked) ──
          _pair(
            _DropdownField(
              label:        locationLabel,
              hint:         selectLocation,
              value:        selectedLocation,
              items:        countryItems,
              onChanged:    onLocationChanged,
              submitted:    submitted,
              isRtl:        isRtl,
              isMobile:     isMobile,
              primaryColor: primaryColor,
              isSearchable: true,
              required:     true,
            ),
            CustomValidatedTextFieldMaster(
              label:         entityNameLabel,
              hint:          entityNameHint,
              controller:    entityNameCtrl,
              submitted:     false, // optional
              primaryColor:  primaryColor,
              textDirection: dir,
              textAlign:     align,
            ),
          ),
          rowGap,

          // ── Entity Type / Entity Size (mobile: stacked) ──
          _pair(
            _DropdownField(
              label:        entityTypeLabel,
              hint:         selectType,
              value:        selectedEntityType,
              items:        entityTypeItems,
              onChanged:    onEntityTypeChanged,
              submitted:    submitted, // BUG-55: required on Send → show why
              required:     true,
              isRtl:        isRtl,
              isMobile:     isMobile,
              primaryColor: primaryColor,
            ),
            _DropdownField(
              label:        entitySizeLabel,
              hint:         selectSize,
              value:        selectedEntitySize,
              items:        entitySizeItems,
              onChanged:    onEntitySizeChanged,
              submitted:    submitted, // BUG-55
              required:     true,
              isRtl:        isRtl,
              isMobile:     isMobile,
              primaryColor: primaryColor,
            ),
          ),

          rowGap,

          // ── Subject (full width) ──
          CustomValidatedTextFieldMaster(
              primaryColor:  primaryColor,
              label:         subjectLabel,
              required:      true,
              hint:          subjectHint,
              controller:    subjectCtrl,
              submitted:     submitted,
              height:        42,
              minLength:     10,
              textDirection: dir,
              textAlign:     align),

          rowGap,

          // ── Message (full width) ──
          CustomValidatedTextFieldMaster(
              primaryColor:  primaryColor,
              label:         msgLabel,
              required:      true,
              hint:          messageHint,
              controller:    messageCtrl,
              submitted:     submitted,
              height:        isMobile ? 96 : 84, // Figma 84
              maxLines:      4,
              minLength:     30,
              textDirection: dir,
              textAlign:     align),

          SizedBox(height: isMobile ? 13.h : 22.w),

          // ── Send Button ── Figma: full width, 38 px tall, radius 4,
          // Cairo SemiBold 24 white (44 px minimum on phones).
          SizedBox(
            width:  double.infinity,
            height: isMobile ? 48 : 38.w,
            child: ElevatedButton(
              onPressed: onSend,
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isMobile ? 8 : 4)),
                  elevation: 0),
              child: Text(sendLabel,
                  style: StyleText.fontSize16Weight600
                      // QA-Oct11 #4: smaller Send label (was 24).
                      .copyWith(color: Colors.white, fontSize: isMobile ? 15 : 18.sp,
                          fontWeight: FontWeight.w600, height: 1.0)),
            ),
          ),
          if (isMobile) SizedBox(height: 7.h),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FORM HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

/// Simple label widget for form fields
