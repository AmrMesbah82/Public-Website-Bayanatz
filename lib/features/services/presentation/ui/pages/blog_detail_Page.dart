// ******************* FILE INFO *******************
// File Name: blog_detail_page.dart
// Updated: All blog data now sourced from Firebase via BlogCubit / BlogPostModel.
//          Branding colors still come from HomeCmsCubit.
//          Supports bilingual (EN / AR), all block types (paragraph,
//          numbering, bulletPoint), responsive Mobile + Desktop layouts.
//          Full article content is always shown (no Read More / Read Less).
//          All rendered text is passed through FormatHelper.capitalize.
//          BLOG IMAGE: SVG-only — no Image.network fallback ✅

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:website_app/core/theme/new_theme.dart';

import '../../../../../core/main_widgets/app_footer.dart';
import '../../../../../core/widgets/scroll_with_footer.dart';
import '../../../../../core/main_widgets/app_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/text.dart';
import '../../../../../core/widgets/format_heper.dart';
import '../../../../../core/widgets/format_helper.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/controller/lang_state.dart';
import '../../../data/models/blog_model.dart';
import '../../controller/blog_cubit.dart';
import '../../controller/blog_state.dart';
import '../../../../../core/widgets/smart_network_image.dart';
import '../../../../../core/theme/site_tokens.dart';
import '../../../../../core/responsive/site_layout.dart';
import '../../../../../core/utils/page_meta.dart';

part '../widgets/services_helpers.dart';
part '../widgets/mobile_body.dart';
part '../widgets/desktop_body.dart';
part '../widgets/block_list.dart';
part '../widgets/blog_image.dart';
part '../widgets/blog_nav_button.dart';

// BUG-251: used from part files — referenced here so an IDE
// "Optimize Imports" cannot drop the import.
typedef _KeepSmartNetworkImage = SmartNetworkImage;
typedef _KeepSiteLayout = SiteLayout;

// ── Fallback colors ───────────────────────────────────────────────────────────
const Color _kFallbackPrimary   = Color(0xFF2D8C4E);
const Color _kFallbackSecondary = Color(0xFFE8F5EE);
const Color _kDivider           = Color(0xFFDDE8DD);
const Color _kSurface           = Color(0xFFFFFFFF);
const Color _kFallbackBackground = Color(0xFFF1F2ED);

Color _parseColor(String hex, {Color fallback = _kFallbackPrimary}) {
  final h = hex.replaceAll('#', '');
  if (h.length == 6) {
    final value = int.tryParse('FF$h', radix: 16);
    if (value != null) return Color(value);
  }
  return fallback;
}

class BlogDetailPage extends StatefulWidget {
  /// Pass a post id to open a specific post directly.
  /// If null, the first published post is shown.
  final String? initialPostId;

  const BlogDetailPage({super.key, this.initialPostId});

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  String? _selectedPostId;

  @override
  void initState() {
    super.initState();
    _selectedPostId = widget.initialPostId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogCubit>().load();
      context.read<HomeCmsCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final Color primary = switch (homeState) {
          HomeCmsLoaded(:final data) =>
              _parseColor(data.branding.primaryColor),
          HomeCmsSaved(:final data) =>
              _parseColor(data.branding.primaryColor),
          _ => _kFallbackPrimary,
        };

        final Color secondary = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
              data.branding.secondaryColor,
              fallback: _kFallbackSecondary),
          HomeCmsSaved(:final data) => _parseColor(
              data.branding.secondaryColor,
              fallback: _kFallbackSecondary),
          _ => _kFallbackSecondary,
        };

        // Page background comes from the admin (branding.backgroundColor).
        final Color background = switch (homeState) {
          HomeCmsLoaded(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: _kFallbackBackground),
          HomeCmsSaved(:final data) => _parseColor(
              data.branding.backgroundColor,
              fallback: _kFallbackBackground),
          _ => _kFallbackBackground,
        };

        return BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            final bool isRtl = langState.isArabic;

            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: BlocBuilder<BlogCubit, BlogState>(
                builder: (context, blogState) {
                  // ── Loading ─────────────────────────────────────
                  if (blogState is BlogLoading) {
                    return Scaffold(
                      backgroundColor: background,
                      body: Column(
                        children: [
                          AppNavbar(currentRoute: '/services'),
                          Expanded(child: Center(child: CircularProgressIndicator(color: primary))),
                          const AppFooter(),
                        ],
                      ),
                    );
                  }

                  // ── Error ───────────────────────────────────────
                  if (blogState is BlogError) {
                    return Scaffold(
                      backgroundColor: background,
                      body: Column(
                        children: [
                          AppNavbar(currentRoute: '/services'),
                          Expanded(
                            child: Center(
                              child: Text(
                                blogState.message,
                                style: StyleText.fontSize14Weight400.copyWith(color: Colors.red),
                              ),
                            ),
                          ),
                          const AppFooter(),
                        ],
                      ),
                    );
                  }

                  // ── Data ready ──────────────────────────────────
                  final List<BlogPostModel> posts =
                  blogState is BlogLoaded
                      ? blogState.posts.where((p) => p.status == 'published').toList()
                      : [];

                  if (posts.isEmpty) {
                    return Scaffold(
                      backgroundColor: background,
                      body: Column(
                        children: [
                          AppNavbar(currentRoute: '/services'),
                          Expanded(
                            child: Center(
                              child: Text(
                                isRtl ? 'لا توجد مقالات منشورة.' : 'No published posts.',
                                style: StyleText.fontSize14Weight400.copyWith(color: Colors.black54),
                              ),
                            ),
                          ),
                          const AppFooter(),
                        ],
                      ),
                    );
                  }

                  // BUG-252: an unknown /blog/<id> shows "Article not found"
                  // (like /jobs/<bad id>) instead of silently opening the
                  // first article.
                  if (_selectedPostId != null &&
                      !posts.any((p) => p.id == _selectedPostId)) {
                    return Scaffold(
                      backgroundColor: background,
                      body: Column(
                        children: [
                          AppNavbar(currentRoute: '/services'),
                          Expanded(
                            child: ScrollWithFooter(
                              footer: const AppFooter(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 64),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 560),
                                    child: Column(
                                      children: [
                                        Icon(Icons.article_outlined,
                                            size: 64, color: primary),
                                        const SizedBox(height: 16),
                                        Text(
                                          isRtl
                                              ? 'المقال غير موجود'
                                              : 'Article not found',
                                          textAlign: TextAlign.center,
                                          style: SiteText.sectionTitle(context,
                                              color: SiteColors.textStrong),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          isRtl
                                              ? 'ربما تم نقل هذا المقال أو حذفه.'
                                              : 'This article may have been moved or removed.',
                                          textAlign: TextAlign.center,
                                          style: SiteText.body(context),
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton(
                                          onPressed: () => context.go('/services'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primary,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            minimumSize: const Size(160, 48),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          child: Text(isRtl
                                              ? 'العودة إلى الخدمات'
                                              : 'Back to Services'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Resolve selected post
                  final BlogPostModel selectedPost = posts.firstWhere(
                        (p) => p.id == _selectedPostId,
                    orElse: () => posts.first,
                  );

                  // BUG-253: the tab title names the article (after build).
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    PageMeta.setDetailTitle(
                        GoRouterState.of(context).uri.path,
                        _tb(selectedPost.question, isRtl));
                  });

                  final double w = MediaQuery.of(context).size.width;
                  final bool isMobile = w < _BP.mobile;

                  return Scaffold(
                    backgroundColor: background,
                    body: Column(
                      children: [
                        // ✅ Navbar — fixed at top
                        AppNavbar(currentRoute: '/services'),

                        // ✅ Content — scrolls
                        Expanded(
                          child: ScrollWithFooter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                isMobile
                                    ? _MobileBody(
                                  posts: posts,
                                  selected: selectedPost,
                                  isRtl: isRtl,
                                  primary: primary,
                                  secondary: secondary,
                                  onTabChange: (id) => setState(() {
                                    _selectedPostId = id;
                                  }),
                                )
                                    : _DesktopBody(
                                  posts: posts,
                                  selected: selectedPost,
                                  isRtl: isRtl,
                                  primary: primary,
                                  secondary: secondary,
                                  onTabChange: (id) => setState(() {
                                    _selectedPostId = id;
                                  }),
                                ),
                              ],
                            ),
                            // BUG-65: footer scrolls with the page (was pinned).
                            footer: const AppFooter(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE BODY
// ═══════════════════════════════════════════════════════════════════════════════
