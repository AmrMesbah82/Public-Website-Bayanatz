part of '../pages/home_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hero Cards Section — dispatches to breakpoint layout
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCardsSection extends StatelessWidget {
  final HomePageModel data;
  final Color         bgColor;
  const _HeroCardsSection({required this.data, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    if (w >= _BP.tablet) return _DesktopCards(data: data, bgColor: bgColor);
    if (w >= _BP.mobile) return _TabletCards(data: data, bgColor: bgColor);
    return _MobileCards(data: data, bgColor: bgColor);
  }
}

Color _sectionColor(String hex) {
  final h = hex.replaceAll('#', '');
  if (h.length == 6) {
    final value = int.tryParse('FF$h', radix: 16);
    if (value != null) return Color(value);
  }
  return _kDefaultPrimary;
}

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP
// ─────────────────────────────────────────────────────────────────────────────

class _DesktopCards extends StatelessWidget {
  final HomePageModel data;
  final Color         bgColor;
  const _DesktopCards({required this.data, required this.bgColor});

  // BUG-181 — Figma (Home 451:17220, 1800 frame): the composition spans the
  // FULL content width. Column widths in the frame: outer 300 · inner 200 ·
  // links 318 · inner 200 · outer 300 (30 px gaps). Everything below is
  // derived from the real content width (k = width / 1440), so it never
  // squeezes into the middle and depends on the WIDTH only (BUG-191).
  static const double _frameW = 1440;

  @override
  Widget build(BuildContext context) {
    final sec     = data.sections;
    final isRtl   = context.read<LanguageCubit>().state.isArabic;
    final primary = _sectionColor(data.branding.primaryColor);

    String secDesc(int i) => i < sec.length
        ? (isRtl
        ? (sec[i].description.ar.isNotEmpty
        ? sec[i].description.ar
        : sec[i].description.en)
        : sec[i].description.en)
        : '';

    // ✅ Check section visibility from Firestore
    bool secVisible(int i) => i < sec.length ? sec[i].visibility : true;

    final double contentW = _SiteLayout.contentWidth(context);
    final double k   = contentW / _frameW;
    final double gap = 30 * k;
    final double outerW = 300 * k, innerW = 200 * k, linksW = 318 * k;

    Widget hide(int i, Widget child) => Visibility(
          visible: secVisible(i),
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: child,
        );

    Widget outer(int i, {required bool iconAfterImage, required _SlideDirection dir}) =>
        hide(i, _Reveal(
          delay:     const Duration(milliseconds: 100),
          direction: dir,
          duration:  const Duration(milliseconds: 700),
          child: _OuterCard(
            width:          outerW,
            k:              k,
            iconUrl:        i < sec.length ? sec[i].iconUrl  : '',
            imageUrl:       i < sec.length ? sec[i].imageUrl : '',
            text:           secDesc(i),
            cardColor:      primary,
            iconAfterImage: iconAfterImage,
            isRtl:          isRtl,
          ),
        ));

    Widget inner(int i, {required CrossAxisAlignment align}) => hide(i, _Reveal(
          delay:     const Duration(milliseconds: 180),
          direction: _SlideDirection.fromBottom,
          duration:  const Duration(milliseconds: 700),
          child: SizedBox(
            width: innerW,
            child: Column(
              mainAxisSize:       MainAxisSize.min,
              crossAxisAlignment: align,
              children: [
                // Figma: icon top 162 below the row top, 8 px above the image.
                SizedBox(height: 162 * k),
                _CircleIcon(
                    iconUrl:   i < sec.length ? sec[i].iconUrl : '',
                    iconColor: primary,
                    size:      50 * k),
                SizedBox(height: 8 * k),
                // Figma: white image card 200×120, radius 20.
                _SectionImage(
                    imageUrl: i < sec.length ? sec[i].imageUrl : '',
                    width:    innerW,
                    height:   150 * 1,
                    radius:   20 * k),
                SizedBox(height: 15 * k),
                // Figma: green text card 200×156, radius 20, 16 px white.
                _GreenCard(
                  width:     innerW,
                  minHeight: 156 * k,
                  text:      secDesc(i),
                  color:     primary,
                  isRtl:     isRtl,
                  k:         k,
                ),
              ],
            ),
          ),
        ));

    final buttons = data.navButtons.where((btn) => btn.status).toList();
    // Figma: first link = highlighted pill 318×64, others 258/228/212×60.
    const List<double> widths = [318, 258, 228, 212, 196, 180];

    final Widget links = SizedBox(
      width: linksW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Figma: the first quick link starts 220 px below the row top.
          SizedBox(height: 220 * k),
          for (int index = 0; index < buttons.length; index++)
            Padding(
              padding: EdgeInsets.only(bottom: 16 * k),
              child: _Reveal(
                delay: Duration(milliseconds: 200 + index * 80),
                direction: _SlideDirection.fromBottom,
                duration:  const Duration(milliseconds: 600),
                child: SizedBox(
                  width: (index < widths.length ? widths[index] : widths.last) * k,
                  child: _CmsNavBtn(
                    label: isRtl
                        ? (buttons[index].name.ar.isNotEmpty
                            ? buttons[index].name.ar
                            : buttons[index].name.en)
                        : buttons[index].name.en,
                    route:       buttons[index].route,
                    primary:     primary,
                    isRtl:       isRtl,
                    highlighted: index == 0, // BUG-180
                    height:      (index == 0 ? 64 : 60) * k,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return Container(
      color:   bgColor,
      // Figma: 42 px from the lowest card to the footer (footer adds 40).
      padding: EdgeInsets.only(bottom: 2 * k),
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: contentW,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:  MainAxisAlignment.spaceBetween,
          children: [
            outer(0, iconAfterImage: true, dir: _SlideDirection.fromLeft),
            inner(1, align: CrossAxisAlignment.start),
            links,
            inner(2, align: CrossAxisAlignment.end),
            outer(3, iconAfterImage: false, dir: _SlideDirection.fromRight),
          ],
        ),
      ),
    );
  }
}

class _OuterCard extends StatelessWidget {
  final double width;
  final double k;
  final String iconUrl;
  final String imageUrl;
  final String text;
  final Color  cardColor;
  final bool   iconAfterImage;
  final bool   isRtl;

  const _OuterCard({
    required this.width,
    required this.k,
    required this.iconUrl,
    required this.imageUrl,
    required this.text,
    required this.cardColor,
    this.iconAfterImage = false,
    this.isRtl          = false,
  });

  @override
  Widget build(BuildContext context) {
    // Figma: white image card 235×212 (radius 20) next to a 50 px icon
    // circle, green text card 300×156 (radius 20) below it.
    final double imgW = 235 * k;
    final Widget img = _SectionImage(
        imageUrl: imageUrl, width: imgW, height: 212 * k, radius: 20);
    final Widget icn =
        _CircleIcon(iconUrl: iconUrl, iconColor: cardColor, size: 50 );

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize:       MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:  MainAxisAlignment.spaceBetween,
            children: iconAfterImage ? [img, icn] : [icn, img],
          ),
          SizedBox(height: 8 * k), // Figma: image 345→557, green card at 565
          _GreenCard(
            width:     width,
            minHeight: 156 * k,
            text:      text,
            color:     cardColor,
            isRtl:     isRtl,
            k:         k,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLET  (600–1023 px) — Figma "iPad Vertical View" Home, 1224 frame
// (node 8022:41794). Content column 1144 (x 40…1184):
//   outer 300 · 15 · [ inner 200 · 114 · inner 200 ] · 15 · outer 300
// Outer column : 50 icon (on the inner edge) · 8 · white image 300×154 r8
//                · 8 · green card 300×156 r20.
// Middle       : quick links centred on top (first = #E4ECE0 pill 297×34,
//                then white 258 / 228 / 212 ×34, 10 px apart, Cairo Medium 16,
//                radius 4), 24 px below the row top; the two inner columns
//                start 162 px below the row top: 50 icon · 8 · white image
//                200×120 r8 · 15 · green card 200×156 r20.
// All values are Figma px × k (k = live content width / 1144).
// ─────────────────────────────────────────────────────────────────────────────

class _TabletCards extends StatelessWidget {
  final HomePageModel data;
  final Color         bgColor;
  const _TabletCards({required this.data, required this.bgColor});

  static const double _contentW = 1144;

  @override
  Widget build(BuildContext context) {
    final sec     = data.sections;
    final isRtl   = context.read<LanguageCubit>().state.isArabic;
    final primary = _sectionColor(data.branding.primaryColor);

    String secDesc(int i) => i < sec.length
        ? (isRtl
            ? (sec[i].description.ar.isNotEmpty
                ? sec[i].description.ar
                : sec[i].description.en)
            : sec[i].description.en)
        : '';
    String secIcon(int i)  => i < sec.length ? sec[i].iconUrl  : '';
    String secImage(int i) => i < sec.length ? sec[i].imageUrl : '';
    // ✅ Check section visibility from Firestore
    bool secVisible(int i) => i < sec.length ? sec[i].visibility : true;

    final double contentW = _SiteLayout.contentWidth(context);
    final double k        = contentW / _contentW;

    // Figma column widths / gaps.
    final double outerW = 300 * k;
    final double innerW = 200 * k;
    final double gap    = 15 * k;
    final double iconD  = 50 * k;

    Widget hide(int i, Widget child) => Visibility(
          visible: secVisible(i),
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: child,
        );

    // ── Outer column (sections 0 and 3) ──────────────────────────────────────
    Widget outer(int i, {required bool iconAtEnd, required _SlideDirection dir}) =>
        hide(i, _Reveal(
          delay:     const Duration(milliseconds: 100),
          direction: dir,
          duration:  const Duration(milliseconds: 650),
          child: SizedBox(
            width: outerW,
            child: Column(
              mainAxisSize:       MainAxisSize.min,
              // Icon sits on the column's inner edge (right on the left
              // column, left on the right one) — fixed for AR and EN.
              crossAxisAlignment:
                  iconAtEnd ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                _CircleIcon(iconUrl: secIcon(i), iconColor: primary, size: iconD),
                SizedBox(height: 8 * k),
                _SectionImage(
                    imageUrl: secImage(i),
                    width:    outerW,
                    height:   154 ,
                    radius:   8 * k),
                SizedBox(height: 8 * k),
                _GreenCard(
                  width:     outerW,
                  minHeight: 156 * k,
                  text:      secDesc(i),
                  color:     primary,
                  isRtl:     isRtl,
                  k:         k,
                ),
              ],
            ),
          ),
        ));

    // ── Inner column (sections 1 and 2) ──────────────────────────────────────
    Widget inner(int i, {required bool iconAtEnd}) => hide(i, _Reveal(
          delay:     const Duration(milliseconds: 180),
          direction: _SlideDirection.fromBottom,
          duration:  const Duration(milliseconds: 650),
          child: SizedBox(
            width: innerW,
            child: Column(
              mainAxisSize:       MainAxisSize.min,
              crossAxisAlignment:
                  iconAtEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _CircleIcon(iconUrl: secIcon(i), iconColor: primary, size: iconD),
                SizedBox(height: 8 * k),
                _SectionImage(
                    imageUrl: secImage(i),
                    width:    innerW,
                    height:   120 ,
                    radius:   8 * k),
                SizedBox(height: 15 * k),
                _GreenCard(
                  width:     innerW,
                  minHeight: 156 * k,
                  text:      secDesc(i),
                  color:     primary,
                  isRtl:     isRtl,
                  k:         k,
                ),
              ],
            ),
          ),
        ));

    // ── Quick links ──────────────────────────────────────────────────────────
    final buttons = data.navButtons.where((btn) => btn.status).toList();
    // Figma: pill 297, then 258 / 228 / 212 (inverted pyramid).
    const List<double> widths = [297, 258, 228, 212, 196, 180];
    final double btnH   = math.max(34 * k, 36);  // keep a usable tap target
    final double btnGap = 10 * k;

    final Widget links = Column(
      mainAxisSize:       MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int index = 0; index < buttons.length; index++)
          Padding(
            padding: EdgeInsets.only(
                bottom: index == buttons.length - 1 ? 0 : btnGap),
            child: _Reveal(
              delay:     Duration(milliseconds: 150 + index * 80),
              direction: _SlideDirection.fromBottom,
              duration:  const Duration(milliseconds: 600),
              child: SizedBox(
                width: (index < widths.length ? widths[index] : widths.last) * k,
                child: _CmsNavBtn(
                  label: isRtl
                      ? (buttons[index].name.ar.isNotEmpty
                          ? buttons[index].name.ar
                          : buttons[index].name.en)
                      : buttons[index].name.en,
                  route:       buttons[index].route,
                  primary:     primary,
                  isRtl:       isRtl,
                  highlighted: index == 0, // BUG-180
                  height:      btnH,
                  minHeight:   36,
                  fontSize:    math.max(13.0, 16 * k),
                  radius:      4 * k,
                  hPadding:    20 * k,
                ),
              ),
            ),
          ),
      ],
    );

    // Links start 24 px below the row top; the inner columns 162 px below it
    // (their icons share the last link's band by 28 px). With more than four
    // links the inner columns move down instead of running under them.
    final int    n      = buttons.length;
    final double linksH = n == 0 ? 0 : n * btnH + (n - 1) * btnGap;
    final double linksTop = 24 * k;
    final double innerTop =
        math.max(162 * k, linksTop + linksH - 28 * k);

    final double middleW = contentW - 2 * outerW - 2 * gap; // Figma 514

    final Widget middle = SizedBox(
      width: middleW,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(top: innerTop),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
              children: [
                inner(1, iconAtEnd: false),
                inner(2, iconAtEnd: true),
              ],
            ),
          ),
          Positioned(
            top: linksTop, left: 0, right: 0,
            child: Center(child: links),
          ),
        ],
      ),
    );

    return Container(
      color:     bgColor,
      // Figma: 65 px from the lowest card to the footer (footer adds 40).
      padding:   EdgeInsets.only(bottom: 25 * k),
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: contentW,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            outer(0, iconAtEnd: true,  dir: _SlideDirection.fromLeft),
            SizedBox(width: gap),
            middle,
            SizedBox(width: gap),
            outer(3, iconAtEnd: false, dir: _SlideDirection.fromRight),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE
// ─────────────────────────────────────────────────────────────────────────────

class _MobileCards extends StatelessWidget {
  final HomePageModel data;
  final Color         bgColor;
  const _MobileCards({required this.data, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    final double sw   = MediaQuery.of(context).size.width;
    // Figma (iPhone, 343 column): 10 px gaps, cards 265 tall, radius 8.
    const double hPad = 16;
    const double gap  = 10;

    final double colWidth   = (sw - hPad * 2 - gap) / 2;
    final double imageCardH = 265 * (sw - hPad * 2) / 343;

    final sec     = data.sections;
    final isRtl   = context.read<LanguageCubit>().state.isArabic;
    final primary = _sectionColor(data.branding.primaryColor);

    String secDesc(int i)  => i < sec.length
        ? (isRtl
        ? (sec[i].description.ar.isNotEmpty
        ? sec[i].description.ar
        : sec[i].description.en)
        : sec[i].description.en)
        : '';
    String secIcon(int i)  => i < sec.length ? sec[i].iconUrl  : '';
    String secImage(int i) => i < sec.length ? sec[i].imageUrl : '';

    // ✅ Check section visibility from Firestore
    bool secVisible(int i) => i < sec.length ? sec[i].visibility : true;

    Widget imageIconCard({
      required double width,
      required String imageUrl,
      String? iconUrl,
      bool    iconOnLeft = true,
    }) {
      const double iconSize    = 44;
      final double imageHeight = imageCardH - iconSize - 10;
      return SizedBox(
        width:  width,
        height: imageCardH,
        child: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: iconOnLeft
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            if (iconUrl != null && iconUrl.isNotEmpty)
              _CircleIcon(iconUrl: iconUrl, iconColor: primary)
            else
              SizedBox(height: iconSize, width: iconSize),
            const SizedBox(height: 10),
            _SectionImage(
              imageUrl: imageUrl,
              width:    width,
              height:   imageHeight,
              radius:   8,
            ),
          ],
        ),
      );
    }

    Widget statCard({
      required double width,
      required String text,
      required Color  color,
      String? iconUrl,
    }) {
      return Container(
        width:   width,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color:        color,
          borderRadius: BorderRadius.circular(8), // Figma iPhone radius 8
        ),
        child: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: isRtl
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              textAlign:     isRtl ? TextAlign.right : TextAlign.left,
              textDirection:
              isRtl ? TextDirection.rtl : TextDirection.ltr,
              // BUG-181: readable 15 px white text (was ≈10 px).
              style: GoogleFonts.cairo(
                fontSize:   15,
                fontWeight: FontWeight.w400,
                color:      Colors.white,
                height:     1.45,
              ),
            ),
          ],
        ),
      );
    }

    Widget fullWidthCard({
      required double width,
      required String imageUrl,
      String? iconUrl,
      required String text,
      required Color  color,
    }) {
      const double iconSize = 44;
      return SizedBox(
        height: imageCardH,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            statCard(
                width: colWidth, text: text, color: color, iconUrl: iconUrl),
            SizedBox(width: gap),
            SizedBox(
              width: colWidth,
              child: Column(
                mainAxisSize:       MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (iconUrl != null && iconUrl.isNotEmpty)
                    _CircleIcon(iconUrl: iconUrl, iconColor: primary)
                  else
                    SizedBox(height: iconSize, width: iconSize),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _SectionImage(
                      imageUrl: imageUrl,
                      width:    colWidth,
                      height:   double.infinity,
                      radius:   8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color:   bgColor,
      padding: const EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...data.navButtons
              .where((btn) => btn.status)
              .toList()
              .asMap()
              .entries
              .map((e) {
            final btn   = e.value;
            final index = e.key;
            final label = isRtl
                ? (btn.name.ar.isNotEmpty ? btn.name.ar : btn.name.en)
                : btn.name.en;
            // QA-Oct11 #6: an inverted pyramid like the desktop column —
            // the highlighted pill is the widest and every link below it is
            // a bit narrower (desktop ratios 318/258/228/212/196/180), sized
            // from the phone width so the buttons are big.
            const List<double> pyramid = [318, 258, 228, 212, 196, 180];
            final double maxW = sw - hPad * 2;
            final double topW = maxW * 0.85;
            final double btnW = topW *
                (index < pyramid.length ? pyramid[index] : pyramid.last) /
                pyramid.first;
            return _Reveal(
              delay:     Duration(milliseconds: 80 + index * 60),
              direction: _SlideDirection.fromBottom,
              duration:  const Duration(milliseconds: 550),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: btnW,
                    child: _CmsNavBtn(
                      label:       label,
                      route:       btn.route,
                      primary:     primary,
                      mobile:      true,
                      isRtl:       isRtl,
                      highlighted: index == 0, // BUG-180
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 15), // Figma: 30 px from the last link

          // ✅ Section 0
          Visibility(
            visible: secVisible(0),
            maintainSize: true, maintainAnimation: true, maintainState: true,
            child: _Reveal(
              delay:     const Duration(milliseconds: 200),
              direction: _SlideDirection.fromLeft,
              duration:  const Duration(milliseconds: 650),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    imageIconCard(
                        width:     colWidth,
                        imageUrl:  secImage(0),
                        iconUrl:   secIcon(0),
                        iconOnLeft: true),
                    SizedBox(width: gap),
                    statCard(
                        width: colWidth,
                        text:  secDesc(0),
                        color: primary),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: gap),

          // ✅ Section 1
          Visibility(
            visible: secVisible(1),
            maintainSize: true, maintainAnimation: true, maintainState: true,
            child: _Reveal(
              delay:     const Duration(milliseconds: 280),
              direction: _SlideDirection.fromRight,
              duration:  const Duration(milliseconds: 650),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    statCard(
                        width: colWidth,
                        text:  secDesc(1),
                        color: primary),
                    SizedBox(width: gap),
                    imageIconCard(
                        width:     colWidth,
                        imageUrl:  secImage(1),
                        iconUrl:   secIcon(1),
                        iconOnLeft: false),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: gap),

          // ✅ Section 2
          Visibility(
            visible: secVisible(2),
            maintainSize: true, maintainAnimation: true, maintainState: true,
            child: _Reveal(
              delay:     const Duration(milliseconds: 360),
              direction: _SlideDirection.fromBottom,
              duration:  const Duration(milliseconds: 650),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    imageIconCard(
                        width:     colWidth,
                        imageUrl:  secImage(2),
                        iconUrl:   secIcon(2),
                        iconOnLeft: true),
                    SizedBox(width: gap),
                    statCard(
                        width: colWidth,
                        text:  secDesc(2),
                        color: primary),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: gap),

          // ✅ Section 3
          Visibility(
            visible: secVisible(3),
            maintainSize: true, maintainAnimation: true, maintainState: true,
            child: _Reveal(
              delay:     const Duration(milliseconds: 440),
              direction: _SlideDirection.fromBottom,
              duration:  const Duration(milliseconds: 650),
              child: fullWidthCard(
                width:    sw - hPad * 2,
                imageUrl: secImage(3),
                iconUrl:  secIcon(3),
                text:     secDesc(3),
                color:    primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
