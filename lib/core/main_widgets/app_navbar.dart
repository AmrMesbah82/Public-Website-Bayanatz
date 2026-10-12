// ******************* FILE INFO *******************
// File Name: app_navbar.dart
// UPDATED: Navbar background now reads from model.branding.headerFooterColor ✅
//          Nav items are driven by HomeCmsCubit (navButtons from CMS model).
//          Items with status=false are filtered out and never rendered.
//          Labels come from the model's BiText (en/ar) instead of hardcoded
//          localisation strings, so CMS name edits are reflected immediately.
//          onItemTap callback preserved for admin/dashboard override.
//
//          Design sizes (ScreenUtil):
//          Desktop (≥1366) → 1366×768, Tablet (768–1365) → 1024×768,
//          Mobile  (<768)  → 375×812
//          Primary color driven by HomeCmsCubit → HomePageModel.branding.primaryColor
//          Navbar background driven by HomeCmsCubit → HomePageModel.branding.headerFooterColor

import 'package:flutter/material.dart';
import '../widgets/smart_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:website_app/core/widgets/format_heper.dart';

import '../../features/home/data/models/home_model.dart';
import '../../features/home/presentation/controller/home_cubit.dart';
import '../../features/home/presentation/controller/home_state.dart';
import '../../features/home/presentation/controller/lang_state.dart';
import '../theme/app_theme.dart';
import '../theme/app_wight.dart';
import '../theme/appcolors.dart';
// StyleText resolves the admin-selected English/Arabic font at runtime,
// so navbar labels follow the CMS font choice instead of a hardcoded Cairo.
import '../theme/new_theme.dart';
import '../responsive/site_layout.dart';

class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}


/// QA-Oct11: the desktop header looked zoomed-in at the Figma 1:1 sizes.
/// Every desktop header size (card height, logo, menu items, language box)
/// is multiplied by this factor — change it here to resize the whole header.
const double _kHdr = 0.8;

// ── SVG asset map — keyed by route ────────────────────────────────────────────
const Map<String, String> _kSvgMap = {
  '/':         'assets/drawer/home_drawer.svg',
  '/services': 'assets/drawer/services_drawer.svg',
  '/about':    'assets/drawer/about_us_drawer.svg',
  '/contact':  'assets/drawer/contact_us_drawer.svg',
  '/careers':  'assets/drawer/career_drawer.svg',
  '/jobs':     'assets/drawer/career_drawer.svg',
};

// ── Extract primary color from CMS state ─────────────────────────────────────
// NOTE: this must never fall back to a transparent color. The primary color is
// what paints the SELECTED tab's background — when the CMS state is briefly
// Loading/Initial (e.g. during a background refresh) an empty hex used to fall
// back to Colors.transparent, which made the active tab highlight disappear.
// We now fall back to the cubit's in-memory model (which defaults to #008037).
Color _primaryFromState(HomeCmsState state, [BuildContext? context]) {
  String hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.primaryColor,
    HomeCmsSaved(:final data)  => data.branding.primaryColor,
    _                          => '',
  };

  if (hex.isEmpty && context != null) {
    hex = context.read<HomeCmsCubit>().current.branding.primaryColor;
  }

  return _hexColor(hex, AppColors.primary);
}

// ✅ Extract navbar background color from CMS state (headerFooterColor)
Color _navbarBgFromState(HomeCmsState state) {
  final String hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.headerFooterColor,
    HomeCmsSaved(:final data)  => data.branding.headerFooterColor,
    _                          => '',
  };
  // Fallback to AppColors.white if not set
  return _hexColor(hex, AppColors.white);
}

// ✅ Extract secondary (branding) color from CMS state
Color _secondaryFromState(HomeCmsState state) {
  final String hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.secondaryColor,
    HomeCmsSaved(:final data)  => data.branding.secondaryColor,
    _                          => '',
  };
  return _hexColor(hex, AppColors.secondaryPrimary);
}

Color _hexColor(String hex, Color fallback) {
  final clean = hex.replaceAll('#', '');
  if (clean.length == 6) {
    final value = int.tryParse('FF$clean', radix: 16);
    if (value != null) return Color(value);
  }
  return fallback;
}

Color _lightTint(Color primary) => primary.withOpacity(0.12);

// ── Route matching ───────────────────────────────────────────────────────────
// Normalise a path so '/services', '/services/', '/Services' and
// '/services?section=x' all compare equal. Without this, a tab could fail to
// highlight simply because the URL carried a query string or trailing slash.
String _normRoute(String path) {
  var s = path.trim();
  final q = s.indexOf('?');
  if (q != -1) s = s.substring(0, q);
  final h = s.indexOf('#');
  if (h != -1) s = s.substring(0, h);
  if (s.isEmpty) return '/';
  if (!s.startsWith('/')) s = '/$s';
  if (s.length > 1 && s.endsWith('/')) s = s.substring(0, s.length - 1);
  return s.toLowerCase();
}

/// Whether [itemRoute] is the currently selected tab.
///
/// A page can deliberately declare which tab it belongs to — the blog detail
/// page lives at '/blog/:index' but passes currentRoute: '/services' so the
/// Services tab stays selected. That explicit value therefore always wins.
/// The live router location is only consulted as a secondary match, which keeps
/// the highlight correct when the URL carries a query string (e.g.
/// '/careers?tab=interns') or when a page passes nothing useful.
bool _isRouteActive(
    BuildContext context, String itemRoute, String currentRoute) {
  final String item = _normRoute(itemRoute);

  if (item == _normRoute(currentRoute)) return true;

  try {
    return item == _normRoute(GoRouterState.of(context).uri.path);
  } catch (_) {
    // No GoRouter in scope (admin/dashboard preview drives it via onItemTap).
    return false;
  }
}

// ── CMS-driven nav items, filtered by status ──────────────────────────────────
List<({String label, String route, String svgAsset})> _getVisibleNavItems(
    String languageCode, HomeCmsState cmsState) {
  // Drive the navbar DIRECTLY from the admin-configured nav buttons, so the
  // count, names, order, routes and visibility all reflect the CMS exactly.
  // Fall back to the default tabs only until the CMS has loaded (so we never
  // show extra/hardcoded tabs like "Careers" that the admin removed).
  // The MAIN navbar reads the Main-page nav items (mainPage/main), exposed on
  // the model as [mainNavButtons]. This is a SEPARATE feature from the Home
  // page nav cards ([navButtons], homePage/home_page) — editing one never
  // affects the other.
  List<NavButtonModel> navButtons = switch (cmsState) {
    HomeCmsLoaded(:final data) => data.mainNavButtons,
    HomeCmsSaved(:final data)  => data.mainNavButtons,
    _                          => const <NavButtonModel>[],
  };
  if (navButtons.isEmpty) {
    navButtons = HomePageModel.defaultModel.navButtons;
  }

  // Defensive: dedupe by route (keep the FIRST occurrence, i.e. the admin's
  // order). Older saves could contain two buttons with the same route, which
  // rendered ghost tabs (e.g. a second "Careers").
  final seenRoutes = <String>{};
  navButtons = navButtons
      .where((b) => b.route.isNotEmpty && seenRoutes.add(b.route))
      .toList();

  final bool isAr = languageCode == 'ar';

  final items = navButtons
      .where((btn) => btn.status)
      .where((btn) => btn.route.isNotEmpty)
      .map((btn) => (
            label: isAr
                ? (btn.name.ar.isNotEmpty ? btn.name.ar : btn.name.en)
                : (btn.name.en.isNotEmpty ? btn.name.en : btn.name.ar),
            route:    btn.route,
            svgAsset: _kSvgMap[btn.route] ?? 'assets/drawer/home_drawer.svg',
          ))
      .toList();

  // ── Fallback only: if the CMS doc predates the fixed 5-item nav and has NO
  // '/' button at all, expose a "Home" tab so users can get back to the home
  // page. Checked against the RAW CMS list (before the status filter) so an
  // admin who HIDES Home in edit mode is respected — nothing is re-injected.
  final bool hasHome = navButtons.any((b) => b.route == '/');
  if (!hasHome) {
    items.insert(0, (
      label:    isAr ? 'الرئيسية' : 'Home',
      route:    '/',
      svgAsset: _kSvgMap['/'] ?? 'assets/drawer/home_drawer.svg',
    ));
  }

  return items;
}

// ─────────────────────────────────────────────────────────────────────────────
// AppNavbar — entry point
// ─────────────────────────────────────────────────────────────────────────────

class AppNavbar extends StatelessWidget {
  final String currentRoute;

  /// Optional callback invoked when a nav item is tapped.
  /// Receives the route string of the tapped item (e.g. '/careers').
  /// When null the navbar falls back to `context.go(route)`.
  final void Function(String route)? onItemTap;

  const AppNavbar({
    super.key,
    required this.currentRoute,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, cmsState) {
        final Color primary  = _primaryFromState(cmsState, context);
        final Color navbarBg = _navbarBgFromState(cmsState); // ✅ CMS-driven bg
        final double w       = MediaQuery.of(context).size.width;

        // Tablet AND desktop (≥ 600 px): the full navbar (logo · menu ·
        // AR/ENG). Only phones (< 600 px) get the ☰ header + drawer. The menu
        // is centred and scales down (FittedBox) if a tablet is narrow, so it
        // never overflows.
        if (w >= _BP.mobile) {
          return _NavbarDesktop(
            currentRoute: currentRoute,
            primary:      primary,
            navbarBg:     navbarBg,
            cmsState:     cmsState,
            onItemTap:    onItemTap,
          );
        }
        return _NavbarMobile(
          currentRoute: currentRoute,
          primary:      primary,
          navbarBg:     navbarBg,
          cmsState:     cmsState,
          onItemTap:    onItemTap,
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP  (≥ 1024px)
// ═══════════════════════════════════════════════════════════════════════════════

class _NavbarDesktop extends StatelessWidget {
  final String                       currentRoute;
  final Color                        primary;
  final Color                        navbarBg; // ✅
  final HomeCmsState                 cmsState;
  final void Function(String route)? onItemTap;

  const _NavbarDesktop({
    required this.currentRoute,
    required this.primary,
    required this.navbarBg,
    required this.cmsState,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    // BUG-174: the header is a floating white rounded card aligned with the
    // page content column (same width + left edge as every page body and the
    // footer) — not a full-width bar glued to the top of the window.
    final double contentW = SiteLayout.contentWidth(context);

    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final navItems = _getVisibleNavItems(langState.locale.languageCode, cmsState);
        final isRtl    = langState.isArabic;

        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Padding(
            // Figma desktop frame: the header card starts 45 px from the top.
            padding: EdgeInsets.only(top: 45.w),
            child: Center(
              child: Container(
                width: contentW,
                // Figma (BAYANATZ WEB › header): white card 1400×100, radius 8,
                // logo 70×70 at +15, menu centred, language box 25 from the end.
                height: 100.w * _kHdr,
                padding: EdgeInsetsDirectional.only(start: 15.w * _kHdr, end: 25.w * _kHdr),
                decoration: BoxDecoration(
                  color:        navbarBg, // admin: Header and Footer colour
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: FocusTraversalGroup(
                  // BUG-257: logo → menu → AR/ENG are reachable with Tab.
                  child: Row(
                    children: [
                      const _BayanatzLogo(rawSize: true),
                      // Menu is centred between the logo and the language
                      // toggle, so the gap logo→menu equals menu→toggle.
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < navItems.length; i++) ...[
                                  // QA-Oct11 #1: every item carries the same
                                  // 24 px side padding as the active pill, so
                                  // the hover tint is a full pill (not a box
                                  // hugging the text). The 48 px text gap of
                                  // Figma is now 24 + 24 of padding.
                                  // QA-Oct11: 20 px gap so a hovered pill
                                  // never touches the selected pill.
                                  if (i > 0) SizedBox(width: 20.sp),
                                  _NavItem(
                                    key: ValueKey('${navItems[i].route}_${langState.locale.languageCode}'),
                                    label:        FormatHelper.capitalize(navItems[i].label),
                                    route:        navItems[i].route,
                                    currentRoute: currentRoute,
                                    primary:      primary,
                                    onItemTap:    onItemTap,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      _LanguageToggle(
                        primary:   primary,
                        secondary: _secondaryFromState(cmsState),
                        desktop:   true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}



// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE + TABLET  (< 1024px)
// ═══════════════════════════════════════════════════════════════════════════════

class _NavbarMobile extends StatelessWidget {
  final String                       currentRoute;
  final Color                        primary;
  final Color                        navbarBg; // ✅
  final HomeCmsState                 cmsState;
  final void Function(String route)? onItemTap;

  const _NavbarMobile({
    required this.currentRoute,
    required this.primary,
    required this.navbarBg,
    required this.cmsState,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final isRtl = langState.isArabic;

        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          // Figma (iPhone view): no card — the 48 px logo at the start and the
          // ☰ icon at the end, on the page background, 16 px gutters.
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 6, 0),
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _BayanatzLogo(rawSize: true),
                  // BUG-138 / BUG-257: named, focusable, 44×44 tap target.
                  _HeaderIconButton(
                    label: isRtl ? 'فتح القائمة' : 'Open menu',
                    icon:  Icons.menu_rounded,
                    color: AppColors.textButton,
                    onTap: () => _openDrawer(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openDrawer(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque:             false,
        barrierDismissible: true,
        barrierColor:       Colors.transparent,
        pageBuilder: (ctx, anim, _) => _FullScreenDrawer(
          currentRoute: currentRoute,
          primary:      primary,
          navbarBg:     navbarBg, // ✅ pass to drawer
          cmsState:     cmsState,
          onItemTap:    onItemTap,
        ),
        transitionsBuilder: (ctx, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

/// 44×44 focusable icon button used by the ☰ / ✕ header controls.
class _HeaderIconButton extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final Color        color;
  final Color?       background;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:  label,
      excludeSemantics: true,
      child: Material(
        color: background ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            width:  44,
            height: 44,
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }
}

// ─── Full-Screen Drawer (mobile) ──────────────────────────────────────────────

class _FullScreenDrawer extends StatefulWidget {
  final String                       currentRoute;
  final Color                        primary;
  final Color                        navbarBg; // ✅ for top bar background
  final HomeCmsState                 cmsState;
  final void Function(String route)? onItemTap;

  const _FullScreenDrawer({
    required this.currentRoute,
    required this.primary,
    required this.navbarBg,
    required this.cmsState,
    this.onItemTap,
  });

  @override
  State<_FullScreenDrawer> createState() => _FullScreenDrawerState();
}

class _FullScreenDrawerState extends State<_FullScreenDrawer> {
  bool _closing = false;

  void _close() {
    if (_closing) return;
    _closing = true;
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // BUG-163: when the window is widened to the desktop header the menu
    // closes by itself (it used to stay open and grow ×2.6).
    if (MediaQuery.sizeOf(context).width >= _BP.tablet) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _close());
    }

    final String currentRoute = widget.currentRoute;
    final Color primary = widget.primary;
    // BUG-244: ONE surface colour for the whole panel (header + list).
    final Color surface = widget.navbarBg;

    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final navItems    = _getVisibleNavItems(langState.locale.languageCode, widget.cmsState);
        final isRtl       = langState.isArabic;
        final Color lightTint = _lightTint(primary);

        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: surface,
            body: SafeArea(
              child: FocusTraversalGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Top bar ────────────────────────────────────────────
                  Container(
                    color: surface,
                    padding: const EdgeInsets.fromLTRB(24, 18, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _BayanatzLogo(rawSize: true),
                        // BUG-163: the close button shows ✕ (it showed ☰).
                        _HeaderIconButton(
                          label:      isRtl ? 'إغلاق القائمة' : 'Close menu',
                          icon:       Icons.close_rounded,
                          color:      primary,
                          background: lightTint,
                          onTap:      _close,
                        ),
                      ],
                    ),
                  ),
                  // QA-Oct11 #7: no divider under the drawer header.

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _LanguageToggle(
                          primary:   primary,
                          secondary: _secondaryFromState(widget.cmsState),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Nav list ──────────────────────────────────────────
                  Expanded(
                    child: ListView(
                      key:     ValueKey(langState.locale.languageCode),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: navItems.map((e) {
                        final bool isActive =
                            _isRouteActive(context, e.route, currentRoute);
                        return Padding(
                          key: ValueKey(
                              '${e.route}_${langState.locale.languageCode}'),
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Material(
                            color: isActive ? primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                Navigator.of(context).pop();
                                if (widget.onItemTap != null) {
                                  widget.onItemTap!(e.route);
                                } else {
                                  context.go(e.route);
                                }
                              },
                              child: Container(
                                width:   double.infinity,
                                constraints: const BoxConstraints(minHeight: 48),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      e.svgAsset,
                                      width:  20,
                                      height: 20,
                                      colorFilter: ColorFilter.mode(
                                        isActive ? Colors.white : AppColors.textButton,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      e.label,
                                      textDirection: isRtl
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                      style: StyleText.fontSize14Weight400.copyWith(
                                        fontSize:   16,
                                        fontWeight: isActive
                                            ? AppFontWeights.semiBold
                                            : AppFontWeights.regular,
                                        color: isActive ? Colors.white : AppColors.text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _BayanatzLogo extends StatelessWidget {
  final bool rawSize;
  const _BayanatzLogo({this.rawSize = false});

  @override
  Widget build(BuildContext context) {
    // BUG-175: Figma logo is 70 px in the 100 px header card (was ≈38 px).
    // Phones / tablets: 42 px (fixed, never scaled by the window width).
    final bool desktop = MediaQuery.sizeOf(context).width >= _BP.tablet;
    // Figma: 70×70 in the desktop header card; 48 px on phones / tablets.
    final double sz = desktop ? 70.w * _kHdr : 48;

    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, state) {
        final String logoUrl = switch (state) {
          HomeCmsLoaded(:final data) => data.branding.logoUrl,
          HomeCmsSaved(:final data)  => data.branding.logoUrl,
          _                          => '',
        };

        // BUG-68 / BUG-18: SVG or bitmap logo, bundled logo if it fails.
        final Widget logoWidget = logoUrl.isNotEmpty
            ? SmartNetworkImage(
          logoUrl,
          width:  sz,
          height: sz,
          fit:    BoxFit.contain,
          fallback: Image(
            image:  const AssetImage("assets/images/logo.jpg"),
            width:  sz,
            height: sz,
            fit:    BoxFit.contain,
          ),
        )
            : Image(
          image:  const AssetImage("assets/images/logo.jpg"),
          width:  sz,
          height: sz,
          fit:    BoxFit.contain,
        );

        // BUG-138 / BUG-257: named + keyboard-focusable link to Home.
        return Semantics(
          link: true,
          label: 'Bayanatz home',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => context.go('/'),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: logoWidget,
            ),
          ),
        );
      },
    );
  }
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatefulWidget {
  final String                       label;
  final String                       route;
  final String                       currentRoute;
  final Color                        primary;
  final bool                         compact;
  final void Function(String route)? onItemTap;

  const _NavItem({
    super.key,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.primary,
    this.compact   = false,
    this.onItemTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color hoverBg = _lightTint(widget.primary);
    final bool isActive =
        _isRouteActive(context, widget.route, widget.currentRoute);

    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        // BUG-257: InkWell = focusable with Tab, activates with Enter/Space,
        // and shows a visible focus ring.
        return Semantics(
          link: true,
          selected: isActive,
          child: InkWell(
            onTap: () {
              if (widget.onItemTap != null) {
                widget.onItemTap!(widget.route);
              } else {
                context.go(widget.route);
              }
            },
            onHover: (v) => setState(() => _hovered = v),
            borderRadius: BorderRadius.circular(8.r),
            focusColor: hoverBg,
            hoverColor: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              // Figma: active item = primary pill, 50 tall, 16 px padding,
              // radius 8; Cairo SemiBold 22 #2D2D2D (white on the pill).
              // Figma: inactive items are bare text; the active item is a
              // 50 px primary pill with 24 px side padding, radius 8.
              height: widget.compact ? null : 50.w * _kHdr,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                // QA-Oct11 #1: same padding hovered / selected / idle.
                horizontal: widget.compact ? 8.w : 24.w * _kHdr,
                vertical:   widget.compact ? 6.h : 0,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? widget.primary
                    : (_hovered ? hoverBg : hoverBg.withOpacity(0)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                widget.label,
                textDirection: langState.isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                // Figma: Cairo SemiBold 22 #2D2D2D (white on the pill).
                style: StyleText.fontSize14Weight600.copyWith(
                  fontSize:   widget.compact ? 14.sp : 22.sp * _kHdr,
                  height:     1.0,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? Colors.white
                      : (_hovered ? widget.primary : const Color(0xFF2D2D2D)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Language Toggle ──────────────────────────────────────────────────────────

class _LanguageToggle extends StatelessWidget {
  final Color primary;
  final Color secondary;
  /// Desktop header: Figma box 108×50 (scaled with the page). Drawer: fixed px.
  final bool desktop;
  const _LanguageToggle({
    required this.primary,
    required this.secondary,
    this.desktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        // Figma "language": #F1F2ED box 108×50, radius 6; active language =
        // primary pill 42×30 radius 6 with white 14 px SemiBold.
        // BUG-257: each option stays a focusable target.
        // Figma: box 108×50; AR slot at +2, ENG pill (42×30) at +56.
        // QA-Oct11 #2 / #26: the selected pill keeps the SAME gap to the box
        // edge on its side as on top (10 px all round) — it used to sit 2 px
        // from the start edge (flush against the right edge in Arabic).
        final double boxH = desktop ? 50.w * _kHdr : 50;
        final double inset = desktop ? 10.w * _kHdr : 10;
        return Container(
          height: boxH,
          padding: EdgeInsets.symmetric(horizontal: inset),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(desktop ? 6.r : 6),
            color:        const Color(0xFFF1F2ED),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LangBtn(
                label:     'AR',
                semantics: 'العربية',
                active:    state.isArabic,
                primary:   primary,
                desktop:   desktop,
                onTap:     () =>
                    context.read<LanguageCubit>().setLanguage('ar'),
              ),
              SizedBox(width: desktop ? 8.w : 8),
              _LangBtn(
                label:     'ENG',
                semantics: 'English',
                active:    state.isEnglish,
                primary:   primary,
                desktop:   desktop,
                onTap:     () =>
                    context.read<LanguageCubit>().setLanguage('en'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String       label;
  final String       semantics;
  final bool         active;
  final Color        primary;
  final bool         desktop;
  final VoidCallback onTap;

  const _LangBtn({
    required this.label,
    required this.semantics,
    required this.active,
    required this.primary,
    required this.onTap,
    this.desktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final double pillW = desktop ? 42.w * _kHdr : 42;
    final double pillH = desktop ? 30.w * _kHdr : 30;
    return Semantics(
      button:   true,
      selected: active,
      label:    semantics,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        focusColor: primary.withOpacity(0.18),
        child: SizedBox(
          height: desktop ? 50.w * _kHdr : 50,
          child: Center(
            // Figma: the pill is exactly 42×30 (it stretched to the full
            // 50 px box because an aligned Container fills its parent).
            child: Container(
              constraints: BoxConstraints(minWidth: pillW),
              height: pillH,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: desktop ? 8.w : 8),
              decoration: BoxDecoration(
                color:        active ? primary : Colors.transparent,
                borderRadius: BorderRadius.circular(desktop ? 6.r : 6),
              ),
              child: Text(
                label,
                // Figma: Cairo SemiBold 14 / 160 %, #797979 when inactive.
                style: StyleText.fontSize14Weight600.copyWith(
                  fontSize:   desktop ? 14.sp : 14,
                  height:     1.0,
                  fontWeight: FontWeight.w600,
                  color:      active ? Colors.white : const Color(0xFF797979),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
