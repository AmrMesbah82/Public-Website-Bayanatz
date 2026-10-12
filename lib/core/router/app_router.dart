import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../main_widgets/not_found_page.dart';



// BUG-256: every page except Home is loaded on demand (deferred), so the
// first download only carries the shell + Home instead of the whole site.
import '../../features/about_us/presentation/ui/pages/about_us_page.dart'
    deferred as about_page;
import '../../features/careers/presentation/ui/pages/careers_page.dart'
    deferred as careers_page;
import '../../features/contact_us/presentation/ui/pages/contact_us_page.dart'
    deferred as contact_page;
import '../../features/home/presentation/ui/pages/home_page.dart';
import '../../features/job/presentation/ui/pages/job_apply_page.dart'
    deferred as apply_page;
import '../../features/job/presentation/ui/pages/job_apply_success_page.dart'
    deferred as applied_page;
import '../../features/job/presentation/ui/pages/job_detail_page.dart'
    deferred as job_detail_page;
import '../../features/job/presentation/ui/pages/job_page.dart'
    deferred as jobs_page;
import '../../features/services/presentation/ui/pages/blog_detail_page.dart'
    deferred as blog_page;
import '../../features/services/presentation/ui/pages/services_page.dart'
    // A deferred import must hide every extension the library declares.
    deferred as services_page hide BilingualTextL10n;




// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE + ANGLE + FADE PAGE TRANSITION
// ═══════════════════════════════════════════════════════════════════════════════

enum SlideDirection { fromRight, fromLeft, fromBottom }

CustomTransitionPage<T> animatedPage<T>({
  required LocalKey key,
  required Widget child,
  SlideDirection slideDirection = SlideDirection.fromRight,
  Duration duration = const Duration(milliseconds: 650),
  Curve curve = Curves.easeOutCubic,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      final Offset beginOffset = switch (slideDirection) {
        SlideDirection.fromRight  => const Offset(0.12, 0.0),
        SlideDirection.fromLeft   => const Offset(-0.12, 0.0),
        SlideDirection.fromBottom => const Offset(0.0, 0.08),
      };

      final slideAnim = Tween<Offset>(begin: beginOffset, end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: curve));

      final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
        ),
      );

      final skewSign = slideDirection == SlideDirection.fromLeft ? 1.0 : -1.0;
      final skewAnim = Tween<double>(begin: skewSign * 0.05, end: 0.0)
          .animate(CurvedAnimation(parent: animation, curve: curve));

      final scaleAnim = Tween<double>(begin: 0.97, end: 1.0)
          .animate(CurvedAnimation(parent: animation, curve: curve));

      final exitFade = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
      );

      return FadeTransition(
        opacity: exitFade,
        child: FadeTransition(
          opacity: fadeAnim,
          child: SlideTransition(
            position: slideAnim,
            child: AnimatedBuilder(
              animation: animation,
              builder: (_, child) => Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0008)
                  ..rotateY(skewAnim.value)
                  ..scale(scaleAnim.value),
                alignment: Alignment.center,
                child: child,
              ),
              child: pageChild,
            ),
          ),
        ),
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// DEFERRED PAGE — loads a page's code chunk once, then shows the page
// ═══════════════════════════════════════════════════════════════════════════════

class _DeferredPage extends StatefulWidget {
  const _DeferredPage({required this.id, required this.load, required this.builder});

  final String id;
  final Future<void> Function() load;
  final Widget Function() builder;

  static final Map<String, Future<void>> _loads = {};

  @override
  State<_DeferredPage> createState() => _DeferredPageState();
}

class _DeferredPageState extends State<_DeferredPage> {
  late final Future<void> _future =
      _DeferredPage._loads.putIfAbsent(widget.id, widget.load);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done && !snap.hasError) {
          return widget.builder();
        }
        if (snap.hasError) {
          return const NotFoundPage();
        }
        return const ColoredBox(
          color: Color(0xFFF1F2ED),
          child: Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: Color(0xFF008037)),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROUTER
// ═══════════════════════════════════════════════════════════════════════════════

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    // BUG-56: unknown URLs showed a raw "GoException: no routes for location"
    // developer page. Common wrong paths are redirected; anything else gets a
    // branded, bilingual "Page not found" with the site header and a Home
    // button.
    redirect: (context, state) {
      const aliases = {
        '/contact-us': '/contact',
        '/about-us':   '/about',
        '/career':     '/careers',
        '/home':       '/',
        '/service':    '/services',
      };
      final path = state.uri.path.toLowerCase();
      final target = aliases[path.endsWith('/') && path.length > 1
          ? path.substring(0, path.length - 1)
          : path];
      return target;
    },
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [

      // ── Public pages ───────────────────────────────────────────────────────

      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: const HomePage(),
        ),
      ),

      GoRoute(
        path: '/services',
        name: 'services',
        pageBuilder: (context, state) {
          final String? section = state.uri.queryParameters['section'];
          return animatedPage(
            key:   state.pageKey,
            child: _DeferredPage(
              id: 'services',
              load: () => services_page.loadLibrary(),
              builder: () => services_page.ServicesPage(scrollTo: section),
            ),
          );
        },
      ),

      GoRoute(
        path: '/about',
        name: 'about',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: _DeferredPage(
            id: 'about',
            load: () => about_page.loadLibrary(),
            builder: () => about_page.AboutPage(),
          ),
        ),
      ),

      GoRoute(
        path: '/contact',
        name: 'contact',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: _DeferredPage(
            id: 'contact',
            load: () => contact_page.loadLibrary(),
            builder: () => contact_page.ContactPage(),
          ),
        ),
      ),

      GoRoute(
        path: '/careers',
        name: 'careers',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: _DeferredPage(
            id: 'careers',
            load: () => careers_page.loadLibrary(),
            builder: () => careers_page.CareersPage(),
          ),
        ),
      ),

      GoRoute(
        path: '/jobs',
        name: 'jobs',
        pageBuilder: (context, state) => animatedPage(
          key:   state.pageKey,
          child: _DeferredPage(
            id: 'jobs',
            load: () => jobs_page.loadLibrary(),
            builder: () => jobs_page.JobListingsPage(),
          ),
        ),
      ),

      GoRoute(
        path: '/blog/:index',
        name: 'blog',
        pageBuilder: (context, state) {
          // BUG-83: the URL carries the post id (/blog/<id>) but it was
          // parsed as an int and never passed on, so the page always showed
          // the FIRST Important Read. Pass the id through.
          final postId = state.pathParameters['index'];
          return animatedPage(
            key:   state.pageKey,
            child: _DeferredPage(
              id: 'blog',
              load: () => blog_page.loadLibrary(),
              builder: () => blog_page.BlogDetailPage(
                initialPostId: (postId == null || postId.isEmpty) ? null : postId,
              ),
            ),
          );
        },
      ),


      // Add these routes in your website_app's GoRouter:

      GoRoute(
        path: '/jobs/:jobId',
        name: 'job-detail',
        pageBuilder: (context, state) {
          final jobId = state.pathParameters['jobId'] ?? '';
          return animatedPage(
            key: state.pageKey,
            child: _DeferredPage(
              id: 'job',
              load: () => job_detail_page.loadLibrary(),
              builder: () => job_detail_page.JobDetailPage(jobId: jobId),
            ),
          );
        },
      ),

      // BUG-260: dedicated confirmation address after a successful apply.
      GoRoute(
        path: '/jobs/:jobId/applied',
        name: 'job-applied',
        pageBuilder: (context, state) {
          final jobId = state.pathParameters['jobId'] ?? '';
          return animatedPage(
            key: state.pageKey,
            child: _DeferredPage(
              id: 'applied',
              load: () => applied_page.loadLibrary(),
              builder: () => applied_page.JobApplySuccessPage(jobId: jobId),
            ),
          );
        },
      ),

      GoRoute(
        path: '/jobs/:jobId/apply',
        name: 'job-apply',
        pageBuilder: (context, state) {
          final jobId = state.pathParameters['jobId'] ?? '';
          return animatedPage(
            key: state.pageKey,
            child: _DeferredPage(
              id: 'apply',
              load: () => apply_page.loadLibrary(),
              builder: () => apply_page.JobApplyPage(jobId: jobId),
            ),
          );
        },
      ),



    ],
  );
}