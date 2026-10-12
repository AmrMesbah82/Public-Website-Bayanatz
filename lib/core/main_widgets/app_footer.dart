// ******************* FILE INFO *******************
// File Name: app_footer.dart
// UPDATED: Footer background now reads from model.branding.headerFooterColor
// FIXED: _socialIcons / _socialIconsRaw now filter by l.visibility ✅
//        Toggling visibility OFF in admin hides the icon in the footer.
// Description: AppFooter driven by HomePageModel via HomeCmsCubit.
// Created by: Amr Mesbah

import 'package:website_app/core/utils/svg_preload.dart';
import 'package:flutter/material.dart';
import '../widgets/smart_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/home/data/models/home_model.dart';
import '../../features/home/presentation/controller/home_cubit.dart';
import '../../features/home/presentation/controller/home_state.dart';
import '../../features/home/presentation/controller/lang_state.dart';
import '../theme/app_wight.dart';
import '../theme/new_theme.dart';
import '../responsive/site_layout.dart';



class _BP {
  static const double mobile = 600; // BUG-162: same breakpoints as every page
  static const double tablet = 1024;
}

const Color _kFallbackPrimary    = Color(0xFF008037);
// BUG-167: Figma footer is a WHITE card (#F5F5F5 grey was the fallback).
const Color _kFallbackFooterBg   = Color(0xFFFFFFFF); // fallback if headerFooterColor is empty

// BUG-143: one name per page everywhere. Footer labels are CMS text, so a
// label that points at a known page always shows that page's canonical name
// (the same one the page tab and the admin use).
const Map<String, BiText> _kCanonicalNames = {
  '/careers?tab=why-join-our-team': BiText(en: 'Why Join Our Team', ar: 'لماذا تنضم إلى فريقنا'),
  '/careers?tab=our-team':          BiText(en: 'Our Team',          ar: 'فريقنا'),
  '/careers?tab=interns':           BiText(en: 'Our Interns',       ar: 'المتدربون'),
  '/about?tab=terms-and-conditions':BiText(en: 'Terms and Conditions', ar: 'الشروط والأحكام'),
  '/about?tab=privacy-policy':      BiText(en: 'Privacy Policy',    ar: 'سياسة الخصوصية'),
  '/about?tab=our-strategy':        BiText(en: 'Our Strategy',      ar: 'استراتيجيتنا'),
};

String _normFooterRoute(String r) {
  var s = r.trim().toLowerCase();
  if (s.length > 1 && s.endsWith('/')) s = s.substring(0, s.length - 1);
  return s;
}

bool _isLegalRoute(String r) {
  final s = _normFooterRoute(r);
  return s.contains('terms') || s.contains('privacy');
}

FooterLabelModel _canonicalLabel(FooterLabelModel l) {
  final canon = _kCanonicalNames[_normFooterRoute(l.route)];
  return canon == null ? l : l.copyWith(label: canon);
}

List<FooterColumnModel> _syncedFooterColumns(HomePageModel model) {
  // Footer column titles/visibility follow the MAIN navbar items
  // (mainNavButtons / mainPage/main), NOT the Home page nav cards.
  final navByRoute = <String, NavButtonModel>{
    for (final btn in model.mainNavButtons)
      if (btn.route.isNotEmpty) btn.route: btn,
  };
  final List<FooterColumnModel> result = [];
  final List<FooterLabelModel> legal = [];
  for (final col in model.footerColumns) {
    final nav = col.route.isNotEmpty ? navByRoute[col.route] : null;
    if (nav != null && !nav.status) continue;
    // BUG-167: Terms / Privacy get their own group (Figma "Terms") instead
    // of being listed under About Us.
    final keep = <FooterLabelModel>[];
    for (final l in col.labels) {
      if (_isLegalRoute(l.route)) {
        legal.add(_canonicalLabel(l));
      } else {
        keep.add(_canonicalLabel(l));
      }
    }
    if (_isLegalRoute(col.route)) {
      legal.insertAll(0, keep);
      continue;
    }
    result.add(col.copyWith(
      title:  nav?.name ?? col.title,
      labels: keep,
    ));
  }

  // BUG-167: Figma footer = Services · About Us · Terms · Contact Us · Careers.
  final bool hasServices =
      result.any((c) => _normFooterRoute(c.route) == '/services');
  final servicesNav = navByRoute['/services'];
  if (!hasServices && (servicesNav == null || servicesNav.status)) {
    result.add(FooterColumnModel(
      id:    'footer_services',
      route: '/services',
      title: servicesNav?.name ?? const BiText(en: 'Services', ar: 'الخدمات'),
    ));
  }
  if (legal.isEmpty) {
    legal.addAll(const [
      FooterLabelModel(
        id: 'footer_terms', route: '/about?tab=terms-and-conditions',
        label: BiText(en: 'Terms and Conditions', ar: 'الشروط والأحكام')),
      FooterLabelModel(
        id: 'footer_privacy', route: '/about?tab=privacy-policy',
        label: BiText(en: 'Privacy Policy', ar: 'سياسة الخصوصية')),
    ]);
  }
  result.add(FooterColumnModel(
    id:     'footer_terms_group',
    route:  '/about?tab=terms-and-conditions',
    title:  const BiText(en: 'Terms and Conditions', ar: 'الشروط والأحكام'),
    labels: legal,
  ));

  int rank(FooterColumnModel c) {
    final r = _normFooterRoute(c.route);
    if (r.startsWith('/services')) return 0;
    if (_isLegalRoute(r)) return 2;
    if (r.startsWith('/about')) return 1;
    if (r.startsWith('/contact')) return 3;
    if (r.startsWith('/careers') || r.startsWith('/jobs')) return 4;
    return 5;
  }
  final indexed = result.asMap().entries.toList()
    ..sort((x, y) {
      final d = rank(x.value) - rank(y.value);
      return d != 0 ? d : x.key - y.key;
    });
  return [for (final e in indexed) e.value];
}

String _bi(BiText b, bool isRtl) {
  final v = isRtl ? b.ar : b.en;
  return v.isNotEmpty ? v : b.en;
}

Color _hexColor(String hex, Color fallback) {
  final clean = hex.replaceAll('#', '');
  if (clean.length == 6) {
    final value = int.tryParse('FF$clean', radix: 16);
    if (value != null) return Color(value);
  }
  return fallback;
}

String _staticCopyright(bool isRtl) {
  final year = DateTime.now().year.toString();
  return isRtl
      // BUG-49 / BUG-81: brand is "Bayanatz" (was "Bayanat", "ALL RIGHT
      // RESERVED"); the Arabic line now uses the same brand name as the site.
      ? '© $year بيانات زي. جميع الحقوق محفوظة.'
      : '© $year Bayanatz. All rights reserved.';
}

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, state) {
        final HomePageModel model = switch (state) {
          HomeCmsLoaded(:final data) => data,
          HomeCmsSaved(:final data)  => data,
          _                          => HomePageModel.defaultModel,
        };

        final Color primary    = _hexColor(model.branding.primaryColor,      _kFallbackPrimary);
        // ✅ Footer background from CMS branding
        final Color footerBg   = _hexColor(model.branding.headerFooterColor, _kFallbackFooterBg);
        final List<FooterColumnModel> columns = _syncedFooterColumns(model);

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final bool isRtl = langState.isArabic;
            final double screenWidth = MediaQuery.of(context).size.width;

            // Phones (< 600) use the iPhone footer (icons between lines,
            // Terms link, copyright); tablet + desktop share the responsive
            // desktop design.
            final Widget footer = screenWidth < _BP.mobile
                ? _FooterMobile(
                    model: model, columns: columns,
                    primary: primary, footerBg: footerBg, isRtl: isRtl,
                  )
                : _FooterDesktop(
                    model: model, columns: columns,
                    primary: primary, footerBg: footerBg, isRtl: isRtl,
                    screenWidth: screenWidth,
                  );

            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: footer,
            );
          },
        );
      },
    );
  }
}

// ─── DESKTOP ──────────────────────────────────────────────────────────────────

class _FooterDesktop extends StatelessWidget {
  final HomePageModel model;
  final List<FooterColumnModel> columns;
  final Color primary;
  final Color footerBg; // ✅ from branding.headerFooterColor
  final bool isRtl;
  final double screenWidth;

  const _FooterDesktop({
    required this.model,
    required this.columns,
    required this.primary,
    required this.footerBg,
    required this.isRtl,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Figma (BAYANATZ WEB › footer): white card 1440×287 (20 px wider than
    // the 1400 content column on each side), top corners 32. Logo 74×74 at
    // (30, 30); the five link columns span x 150 → 1295 with equal gaps;
    // a 1 px primary line at y 183 (x 145 → 1295); social icons 40×40
    // centred under it, copyright Regular 18 ending 50 px from the edge.
    //
    // RESPONSIVE (same design on every screen):
    //  • wide (≥ 1024): exactly the Figma desktop layout.
    //  • narrower: same card, logo, link columns, line, icons, copyright —
    //    the columns WRAP onto more lines instead of squeezing, the logo
    //    sits above the columns on phones, and the icons + copyright stack
    //    (centred) when there is no room for them side by side.
    final bool wide  = screenWidth >= _BP.tablet;
    final bool phone = screenWidth < _BP.mobile;
    final double gutter = phone ? 16 : 20;
    final double cardW = wide
        ? SiteLayout.contentWidth(context) + 40.w
        : screenWidth - gutter * 2;
    final double sidePad  = wide ? 145.w : gutter;
    final double startPad = wide ? 30.w : gutter;
    final double logoSize = wide ? 74 : (phone ? 56 : 64);

    final Widget logo = _LogoBox(
        logoUrl: model.branding.logoUrl, primary: primary, size: logoSize);

    Widget column(FooterColumnModel col) => _FooterColumnWidget(
          column:     col,
          titleColor: const Color(0xFF2D2D2D),
          primary:    primary,
          isRtl:      isRtl,
        );

    final Widget links = wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final col in columns) Flexible(child: column(col)),
            ],
          )
        : !phone
        // Tablet: ALL columns on ONE line. Each column is only as wide as
        // its own text; the remaining space is divided equally BETWEEN the
        // columns (no fixed column width). Flexible lets a column shrink and
        // wrap its labels only if the line is really too short.
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < columns.length; i++) ...[
                if (i > 0) const SizedBox(width: 8), // minimum gap
                Flexible(child: column(columns[i])),
              ],
            ],
          )
        // Phones: the columns flow side by side and only start a new line
        // when the current one is full.
        : Wrap(
            spacing: phone ? 24 : 40,
            runSpacing: phone ? 20 : 24,
            children: [
              for (final col in columns)
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: phone ? 130 : 150),
                  child: column(col),
                ),
            ],
          );

    final Widget top = phone
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [logo, const SizedBox(height: 20), links],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              logo,
              SizedBox(width: wide ? 46.w : 20),
              Expanded(child: links),
            ],
          );

    final Widget icons = Wrap(
      alignment: WrapAlignment.center,
      // Figma gap 15 (each icon already has a 2 px focus margin).
      spacing: 0,
      runSpacing: 8,
      children: _socialIcons(model.socialLinks, primary, gap: 11),
    );
    final Widget copyright = Text(
      _staticCopyright(isRtl),
      textAlign: wide ? TextAlign.end : TextAlign.center,
      style: GoogleFonts.cairo(
        color:      const Color(0xFF2D2D2D),
        fontWeight: AppFontWeights.regular,
        fontSize:   wide ? 18.sp : (phone ? 14 : 16),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: wide ? 40.w : 32),
      child: Center(
        child: Container(
          width: cardW,
          padding: EdgeInsetsDirectional.only(
              top: wide ? 30.w : gutter, bottom: wide ? 40.w : 28),
          decoration: BoxDecoration(
            color: footerBg, // CMS "Header and Footer" colour (white default)
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(wide ? 32.r : 24),
              topEnd:   Radius.circular(wide ? 32.r : 24),
            ),
          ),
          child: FocusTraversalGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  // y 30 → 183 in Figma (logo 74, columns up to 99 tall).
                  constraints: BoxConstraints(minHeight: wide ? 153.w : 0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                        start: startPad, end: sidePad),
                    child: top,
                  ),
                ),
                SizedBox(height: wide ? 0 : 24),
                Padding(
                  padding: EdgeInsetsDirectional.only(
                      start: sidePad, end: sidePad),
                  child: Divider(color: primary, thickness: 1, height: 1),
                ),
                SizedBox(height: wide ? 24.w : 20),
                // BUG-166 / BUG-140: social icons centred on the card, the
                // copyright at the end — separate slots, never overlapping.
                // Narrower: icons, then the copyright, both centred.
                wide
                    ? Padding(
                        padding: EdgeInsetsDirectional.only(end: 50.w),
                        child: Row(
                          children: [
                            const Expanded(child: SizedBox()),
                            icons,
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: copyright,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: gutter),
                        child: Column(
                          children: [
                            icons,
                            const SizedBox(height: 14),
                            copyright,
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── MOBILE ───────────────────────────────────────────────────────────────────

class _FooterMobile extends StatelessWidget {
  final HomePageModel model;
  final List<FooterColumnModel> columns;
  final Color primary;
  final Color footerBg; // ✅ from branding.headerFooterColor
  final bool isRtl;

  const _FooterMobile({
    required this.model,
    required this.columns,
    required this.primary,
    required this.footerBg,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Figma (iPhone footer): lines either side of the 40 px icons
          // (15 px apart), then "Terms and Conditions" and the copyright,
          // both Cairo Medium 14 (dark / grey), centred.
          Row(
            children: [
              Expanded(child: Divider(color: primary.withOpacity(0.5), thickness: 1)),
              const SizedBox(width: 12),
              ..._socialIconsRaw(model.socialLinks, primary),
              Expanded(child: Divider(color: primary.withOpacity(0.5), thickness: 1)),
            ],
          ),
          const SizedBox(height: 11),
          // BUG-108: phones showed one random link ("Vision"). Figma (iPhone
          // view, Footer 7126:41848) has exactly one link under the social
          // icons: "Terms and Conditions" — so that is the one shown here.
          Builder(builder: (context) {
            FooterLabelModel? terms;
            for (final col in columns) {
              for (final l in col.labels) {
                final r = l.route.toLowerCase();
                final en = l.label.en.toLowerCase();
                if (r.contains('terms') || en.contains('terms')) {
                  terms ??= l;
                }
              }
            }
            final String label = terms != null
                ? _bi(terms.label, isRtl)
                : (isRtl ? 'الشروط والأحكام' : 'Terms and Conditions');
            final String route = (terms != null && terms.route.isNotEmpty)
                ? terms.route
                : '/about?tab=terms-and-conditions';
            return Center(
              child: _FooterLink(label: label, route: route, primary: primary),
            );
          }),
          const SizedBox(height: 2),
          Text(
            _staticCopyright(isRtl),
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize:   14,
              fontWeight: FontWeight.w500,
              color:      const Color(0xFF666666), // Figma #797979 (AA)
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Footer Column ────────────────────────────────────────────────────────────

class _FooterColumnWidget extends StatefulWidget {
  final FooterColumnModel column;
  final Color titleColor;
  final Color primary;
  final bool isRtl;

  const _FooterColumnWidget({
    required this.column,
    required this.titleColor,
    required this.primary,
    required this.isRtl,
  });

  @override
  State<_FooterColumnWidget> createState() => _FooterColumnWidgetState();
}

class _FooterColumnWidgetState extends State<_FooterColumnWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final String title = _bi(widget.column.title, widget.isRtl);
    final bool tappable = widget.column.route.isNotEmpty;
    // BUG-167 — Figma: headings Cairo Bold 16 #2D2D2D.
    final Widget heading = AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 180),
      style: GoogleFonts.cairo(
        fontSize:   16.sp,
        height:     1.5, // Figma 16/24
        fontWeight: FontWeight.w700,
        color: _hovered ? widget.primary : widget.titleColor,
      ),
      child: Text(title),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // BUG-257: focusable with Tab, opens with Enter.
        tappable
            ? Semantics(
                link: true,
                child: InkWell(
                  onTap: () => _navigateTo(context, widget.column.route),
                  onHover: (v) => setState(() => _hovered = v),
                  hoverColor: Colors.transparent,
                  focusColor: widget.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                  child: heading,
                ),
              )
            : heading,
        SizedBox(height: 5.w),
        ...widget.column.labels.map((lbl) => _FooterLink(
          label:   _bi(lbl.label, widget.isRtl),
          route:   lbl.route.isNotEmpty ? lbl.route : widget.column.route,
          primary: widget.primary,
        )),
      ],
    );
  }
}

// ─── Footer Link ──────────────────────────────────────────────────────────────

class _FooterLink extends StatefulWidget {
  final String  label;
  final String? route;
  final Color   primary;

  const _FooterLink({
    required this.label,
    required this.primary,
    this.route,
  });

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  void _handleTap(BuildContext context) {
    final route = widget.route;
    if (route == null || route.isEmpty) return;
    final uri = Uri.tryParse(route);
    if (uri == null) { context.go(route); return; }
    final String path        = uri.path;
    final String queryString = uri.query;
    final currentPath        = GoRouterState.of(context).uri.path;
    // BUG-117: push() kept the OLD address in the bar (Refresh/Share/Back
    // went to the wrong page). go() changes the URL; the pages read their
    // tab from the query, so the same page with a new ?tab= switches tab.
    if (queryString.isNotEmpty) {
      context.go('$path?$queryString');
    } else {
      if (currentPath == path) { context.push(path); } else { context.go(path); }
    }
  }

  @override
  Widget build(BuildContext context) {
    // BUG-167: links Cairo Regular 15 #2D2D2D. BUG-257: focusable (Tab).
    return Semantics(
      link: true,
      child: InkWell(
        onTap: () => _handleTap(context),
        onHover: (v) => setState(() => _hovered = v),
        hoverColor: Colors.transparent,
        focusColor: widget.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        child: Text(
          widget.label,
          style: GoogleFonts.cairo(
            fontSize:        15.sp,
            fontWeight:      AppFontWeights.regular,
            height:          25 / 15, // Figma 15/20 + 5 px between links
            color:           _hovered ? widget.primary : const Color(0xFF2D2D2D),
            decoration:      _hovered ? TextDecoration.underline : null,
            decorationColor: widget.primary,
          ),
        ),
      ),
    );
  }
}

// ─── Logo box ─────────────────────────────────────────────────────────────────

class _LogoBox extends StatelessWidget {
  final String logoUrl;
  final Color  primary;
  final double size;

  const _LogoBox({
    required this.logoUrl,
    required this.primary,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  size.w,
      height: size.h,
      child: logoUrl.isNotEmpty
          ? SmartNetworkImage( // BUG-68 / BUG-18
        logoUrl,
        width:   size.w,
        height:  size.h,
        fit:     BoxFit.contain,   // ← was BoxFit.cover (clips sides)
        fallback: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
      )
          : Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
    );
  }
}

// ─── Social icon helpers ──────────────────────────────────────────────────────

/// ✅ filters by l.visibility — hidden icons won't appear in footer
List<Widget> _socialIcons(
    List<SocialLinkModel> links,
    Color borderColor, {
      double gap = 10,
    }) {
  return links
      .where((l) => l.visibility && (l.iconUrl.isNotEmpty || l.url.isNotEmpty))
      .map((l) => Padding(
    padding: EdgeInsetsDirectional.only(end: gap.w),
    child: _SocialIconWidget(link: l, borderColor: borderColor, size: 32),
  ))
      .toList();
}

/// ✅ same visibility filter for mobile
// Kept for the raw icon style; not used by the single responsive footer.
// ignore: unused_element
List<Widget> _socialIconsRaw(List<SocialLinkModel> links, Color borderColor) {
  return links
      .where((l) => l.visibility && (l.iconUrl.isNotEmpty || l.url.isNotEmpty))
      .expand((l) => [
    _SocialIconWidget(link: l, borderColor: borderColor, size: 32, raw: true),
    const SizedBox(width: 11), // + 2 px focus margin each side ≈ Figma 15
  ])
      .toList();
}

class _SocialIconWidget extends StatelessWidget {
  final SocialLinkModel link;
  final Color           borderColor;
  final double          size;
  final bool            raw;

  const _SocialIconWidget({
    required this.link,
    required this.borderColor,
    required this.size,
    this.raw = false,
  });

  double get _ic => raw ? size * 0.47 : (size * 0.47).w;

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = link.iconUrl.isNotEmpty &&
            !SvgPreload.isBad(link.iconUrl)
        ? SvgPicture.network(
      link.iconUrl,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.link, size: _ic, color: borderColor),
      width:  20.w,
      height: 20.w,
      fit:    BoxFit.contain,
      // Show the uploaded logo in its own colors — tinting it with srcIn
      // flattens a multi-color logo into a solid brand-color blob.
      placeholderBuilder: (_) => SizedBox(width: _ic, height: _ic),
    )
        : Icon(Icons.link, size: _ic, color: borderColor);

    // BUG-166: Figma social icons are 40×40.
    final box = Container(
      width:  raw ? 40 : 40.w,
      height: raw ? 40 : 40.w,
      decoration: BoxDecoration(
        border:       Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(raw ? 8 : 8.r),
      ),
      child: Center(child: iconWidget),
    );

    // BUG-138 / BUG-257: icon-only buttons need a name for screen readers
    // and must be reachable with Tab.
    final String name = _socialName(link.url);
    return link.url.isNotEmpty
        ? Semantics(
      link: true,
      label: name,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        focusColor: borderColor.withOpacity(0.15),
        onTap: () async {
          String rawUrl = link.url.trim();
          if (!rawUrl.startsWith('http://') && !rawUrl.startsWith('https://')) {
            rawUrl = 'https://$rawUrl';
          }

          final uri = Uri.tryParse(rawUrl);
          if (uri == null || !uri.hasAuthority) return; // ✅ guard empty/invalid URLs

          final canLaunch = await canLaunchUrl(uri);
          if (!canLaunch) return;

          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication, // ✅ works reliably on web
            webOnlyWindowName: '_blank',
          );
        },
        // BUG-257: 44×44 tap target around the 40×40 Figma icon.
        child: Padding(padding: const EdgeInsets.all(2), child: box),
      ),
    )
        : box;
  }
}

/// BUG-138: "Facebook", "LinkedIn", … from the link's address.
String _socialName(String url) {
  final u = url.toLowerCase();
  const names = {
    'facebook': 'Facebook', 'fb.com': 'Facebook', 'instagram': 'Instagram',
    'linkedin': 'LinkedIn', 'twitter': 'X (Twitter)', 'x.com': 'X (Twitter)',
    'youtube': 'YouTube', 'youtu.be': 'YouTube', 'tiktok': 'TikTok',
    'snapchat': 'Snapchat', 'whatsapp': 'WhatsApp', 'wa.me': 'WhatsApp',
    'telegram': 't.me', 'github': 'GitHub', 'behance': 'Behance',
  };
  for (final e in names.entries) {
    if (u.contains(e.key)) return e.value == 't.me' ? 'Telegram' : e.value;
  }
  return 'Social link';
}

void _navigateTo(BuildContext context, String route) {
  final uri = Uri.tryParse(route);
  if (uri == null) { context.go(route); return; }
  if (uri.query.isNotEmpty) {
    context.go('${uri.path}?${uri.query}'); // BUG-117: URL must change
  } else {
    context.go(uri.path);
  }
}