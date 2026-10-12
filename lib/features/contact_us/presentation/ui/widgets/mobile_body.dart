part of '../pages/contact_us_page.dart';

class _MobileBody extends StatelessWidget {
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, entityNameCtrl, subjectCtrl, messageCtrl,
      otherLanguageCtrl; // ← NEW
  final bool   submitted, isRtl;
  final bool   phoneInvalid; // BUG-102
  final String phoneCode, preferredLanguage;
  final String? selectedLocation, selectedEntityType, selectedEntitySize;
  final Color  primaryColor;
  final ValueChanged<String?>  onCodeChanged;
  final ValueChanged<String>   onLanguageChanged;
  final ValueChanged<String?>  onLocationChanged;
  final ValueChanged<String?>  onEntityTypeChanged;
  final ValueChanged<String?>  onEntitySizeChanged;
  final VoidCallback           onSend;
  final ContactUsCmsModel?     cmsData;

  const _MobileBody({
    required this.firstNameCtrl,    required this.lastNameCtrl,
    required this.emailCtrl,        required this.phoneCtrl,
    required this.entityNameCtrl,   required this.subjectCtrl,
    required this.messageCtrl,      required this.otherLanguageCtrl,
    required this.submitted,
    this.phoneInvalid = false,
    required this.phoneCode,        required this.preferredLanguage,
    required this.selectedLocation, required this.selectedEntityType,
    required this.selectedEntitySize,
    required this.onCodeChanged,    required this.onLanguageChanged,
    required this.onLocationChanged, required this.onEntityTypeChanged,
    required this.onEntitySizeChanged,
    required this.onSend,           required this.isRtl,
    required this.primaryColor,     this.cmsData,
  });

  @override
  Widget build(BuildContext context) {
    final String pageTitle   = _t(context, en: 'Contact Us',       ar: 'تواصل معنا');
    final String officeTitle = _t(context, en: 'Office Locations', ar: 'مواقع المكاتب');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Figma (iPhone): title 70 px under the header; info card 20 px
          // below; form card 15 px lower; offices 20 px after the form.
          const SizedBox(height: 60),
          Text(pageTitle,
              style: SiteText.pageTitle(context, color: primaryColor)), // BUG-178 / BUG-242
          const SizedBox(height: 20),
          _Reveal(
            delay:     const Duration(milliseconds: 100),
            direction: _SlideDirection.fromLeft,
            child: _MobileInfoCard(
                cmsData:      cmsData,
                isRtl:        isRtl,
                primaryColor: primaryColor),
          ),
          const SizedBox(height: 15),
          _Reveal(
            delay:     const Duration(milliseconds: 150),
            direction: _SlideDirection.fromBottom,
            child: _FormCard(
              firstNameCtrl:       firstNameCtrl,
              lastNameCtrl:        lastNameCtrl,
              emailCtrl:           emailCtrl,
              phoneCtrl:           phoneCtrl,
              entityNameCtrl:      entityNameCtrl,
              subjectCtrl:         subjectCtrl,
              messageCtrl:         messageCtrl,
              otherLanguageCtrl:   otherLanguageCtrl, // ← NEW
              submitted:           submitted,
              phoneCode:           phoneCode,
              phoneInvalid:        phoneInvalid,
              preferredLanguage:   preferredLanguage,
              selectedLocation:    selectedLocation,
              selectedEntityType:  selectedEntityType,
              selectedEntitySize:  selectedEntitySize,
              onCodeChanged:       onCodeChanged,
              onLanguageChanged:   onLanguageChanged,
              onLocationChanged:   onLocationChanged,
              onEntityTypeChanged: onEntityTypeChanged,
              onEntitySizeChanged: onEntitySizeChanged,
              onSend:              onSend,
              isMobile:            true,
              isRtl:               isRtl,
              primaryColor:        primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            // Figma: "Office Locations" Cairo Bold 24 / 150 % primary.
            child: Text(officeTitle,
                style: StyleText.fontSize22Weight700
                    .copyWith(color: primaryColor, fontSize: 24, height: 1.5)),
          ),
          const SizedBox(height: 8),
          // Figma: one white container (radius 8, padding 25) holding the
          // country cards 25 px apart.
          if (cmsData != null && cmsData!.officeLocations.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  for (final e in cmsData!.officeLocations.asMap().entries)
                    _Reveal(
                      delay:     Duration(milliseconds: 100 + e.key * 80),
                      direction: _SlideDirection.fromBottom,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: e.key == cmsData!.officeLocations.length - 1 ? 0 : 25),
                        child: _OfficeCardMobile(
                            office:       e.value,
                            isRtl:        isRtl,
                            primaryColor: primaryColor),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// INFO CARDS
// ═══════════════════════════════════════════════════════════════════════════════
