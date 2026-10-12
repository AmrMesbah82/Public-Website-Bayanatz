part of '../pages/home_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final HomePageModel data;
  final Color         bgColor;
  const _HeroSection({required this.data, required this.bgColor});

  Color get _primary =>
      _hexColor(data.branding.primaryColor, fallback: _kDefaultPrimary);

  @override
  Widget build(BuildContext context) {
    final double w       = MediaQuery.of(context).size.width;
    final bool   isMobile = w < _BP.mobile;
    final isAr            = context.read<LanguageCubit>().state.isArabic;

    final String titleText = data.title.l(context);
    final String descText  = data.shortDescription.l(context);

    // Figma (Home, desktop): "Bayanatz" Cairo Bold 64 #008037, centred,
    // 73 px under the header; subtitle Work Sans Regular 26 #213D34, 97 px
    // below the title top, sitting directly on the cards row.
    final TextStyle titleStyle = GoogleFonts.cairo(
      fontSize:      isMobile ? 40 : 64.sp, // Figma: 40 on the iPhone frame
      fontWeight:    AppFontWeights.bold,
      color:         _primary,
      height:        isAr ? 1.35 : 1.2,
    );

    // Work Sans has no Arabic glyphs — Arabic keeps Cairo.
    final TextStyle descStyle = (isAr ? GoogleFonts.cairo : GoogleFonts.workSans)(
      fontSize:      isMobile ? 16 : 26.sp,
      fontWeight:    AppFontWeights.regular,
      color:         const Color(0xFF213D34),
      height:        isAr ? 1.5 : 1.17,
    );

    // BUG-231: Arabic (Cairo) glyphs have deeper descenders, so the gap is
    // larger in Arabic — never less than ≈14 px of clear space.
    final double gap = isMobile ? (isAr ? 16 : 10) : (isAr ? 26.w : 20.w);

    return Container(
      color:  bgColor,
      width:  w,
      padding: isMobile
          // Figma: title 70 px under the header, buttons 50 px under the subtitle.
          ? const EdgeInsets.fromLTRB(16, 60, 16, 50)
          // Figma: "Bayanatz" 73 px under the header on desktop, 70 px on
          // the iPad vertical frame (1224).
          : EdgeInsets.only(
              left: 36.w, right: 36.w, top: w < _BP.tablet ? 52.w : 55.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints:
            BoxConstraints(maxWidth: w - (isMobile ? 40 : 72.w)),
            child: Text(
              titleText,
              textAlign:     TextAlign.center,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style:         titleStyle,
            ),
          ),
          SizedBox(height: gap),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: isMobile ? w - 40 : SiteLayout.contentWidth(context)),
            child: Text(
              descText,
              textAlign:     TextAlign.center,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style:         descStyle,
            ),
          ),
        ],
      ),
    );
  }
}
