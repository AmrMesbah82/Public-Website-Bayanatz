part of '../pages/contact_us_page.dart';

class _DesktopBody extends StatelessWidget {
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

  const _DesktopBody({
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
    final double screenW  = MediaQuery.of(context).size.width;
    final double contentW = SiteLayout.contentWidth(context); // Figma 1400
    final double hPad     = ((screenW - contentW) / 2).clamp(16.0, double.infinity);

    final String pageTitle   = _t(context, en: 'Contact Us',       ar: 'تواصل معنا');
    final String officeTitle = _t(context, en: 'Office Locations', ar: 'مواقع المكاتب');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Figma: title 70 px under the header, cards 105 px below it.
          SizedBox(height: 52.w),
          _Reveal(
            delay:     const Duration(milliseconds: 80),
            direction: _SlideDirection.fromLeft,
            duration:  const Duration(milliseconds: 650),
            // BUG-178: one page-title style (Figma H1 Bold 64 primary).
            child: Text(pageTitle,
                style: SiteText.pageTitle(context, color: primaryColor)),
          ),
          SizedBox(height: 34.w),
          _Reveal(
            delay:     const Duration(milliseconds: 130),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 650),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Figma: info card 533 wide, 28 px gap, form card 837.
                  SizedBox(
                      // iPad frame: a narrower info card (≈ 333).
                      width: SiteLayout.isTablet(context) ? 333.w : 533.w,
                      child: _LeftInfoCard(
                          cmsData:      cmsData,
                          isRtl:        isRtl,
                          primaryColor: primaryColor)),
                  SizedBox(width: 28.w),
                  Expanded(
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
                        isRtl:               isRtl,
                        primaryColor:        primaryColor,
                      )),
                ],
              ),
            ),
          ),
          SizedBox(height: 40.w),
          _Reveal(
            delay:     const Duration(milliseconds: 180),
            direction: _SlideDirection.fromBottom,
            duration:  const Duration(milliseconds: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BUG-187: "Office Locations" 32 Bold; a WHITE container
                // holding one equal card per country.
                // Figma: "Office Locations" Cairo Bold 32, line height 150 %.
                Text(officeTitle,
                    style: SiteText.sectionTitle(context, color: primaryColor)
                        .copyWith(height: 1.5)),
                if (cmsData != null &&
                    cmsData!.officeLocations.isNotEmpty) ...[
                  // Figma: white container radius 20, padding 25, cards
                  // 3 per row with 50 px between them.
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(25.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: Colors.white),
                    // QA-Oct11 #15: the cards share the row width — one
                    // office takes the whole width, two take half each,
                    // three a third; a 4th+ office starts a new row that is
                    // shared the same way (no empty space at the end).
                    child: LayoutBuilder(builder: (context, c) {
                      final double gap = 50.w;
                      const int perRow = 3;
                      final offices = cmsData!.officeLocations;
                      final rows = <List<ContactOfficeLocation>>[
                        for (int i = 0; i < offices.length; i += perRow)
                          offices.sublist(
                              i,
                              i + perRow > offices.length
                                  ? offices.length
                                  : i + perRow),
                      ];
                      return Column(
                        children: [
                          for (int r = 0; r < rows.length; r++)
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: r == rows.length - 1 ? 0 : gap),
                              child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    for (int k = 0; k < rows[r].length; k++) ...[
                                      if (k > 0) SizedBox(width: gap),
                                      Expanded(
                                        child: _OfficeCard(
                                            office:       rows[r][k],
                                            isRtl:        isRtl,
                                            primaryColor: primaryColor),
                                      ),
                                    ],
                                  ],
                                ),
                            ),
                        ],
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 20.w),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY
// ═══════════════════════════════════════════════════════════════════════════════
