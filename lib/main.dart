import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:website_app/features/about_us/domain/base_repository/about_us_company_repo.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:website_app/features/about_us/presentation/controller/about_us_company_cubit.dart';
import 'package:website_app/features/about_us/data/repository/about_company_repository_impl.dart';

import 'core/responsive/site_layout.dart';
import 'core/utils/page_meta.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'features/about_us/presentation/controller/about_us_cubit.dart';
import 'features/careers/presentation/controller/careers_cubit.dart';
import 'features/careers/presentation/controller/careers_section_cubit.dart';
import 'features/careers/presentation/controller/intern_cubit.dart';
import 'features/careers/presentation/controller/our_teams_cubit.dart';
import 'features/contact_us/presentation/controller/contact_us_location_cubit.dart';
import 'features/contact_us/presentation/controller/contact_us_cubit.dart';
import 'features/departments/data/repository/department_repository_impl.dart';
import 'features/departments/presentation/controller/department_cubit.dart';
import 'features/home/data/repository/home_repo_impl.dart';
import 'features/home/presentation/controller/home_cubit.dart';
import 'features/home/presentation/controller/lang_state.dart';
import 'features/job/data/repository/application_repository_impl.dart';
import 'features/job/data/repository/job_repository_impl.dart';
import 'features/job/presentation/controller/application_cubit.dart';
import 'features/job/presentation/controller/job_cubit.dart';
import 'features/services/data/repository/services_repository_impl.dart';
import 'features/services/presentation/controller/blog_cubit.dart';
import 'features/services/presentation/controller/services_cubit.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  usePathUrlStrategy(); // ← removes the # from URLs
  // BUG-117: any remaining context.push() also updates the address bar, so
  // Refresh / Share / Back always match the page that is shown.
  GoRouter.optionURLReflectsImperativeAPIs = true;
  AppTheme.setCurrentThemeColors();
  // BUG-253: page title follows the current route.
  AppRouter.router.routerDelegate.addListener(() {
    PageMeta.onLocation(
        AppRouter.router.routerDelegate.currentConfiguration.uri.path);
  });
  runApp(const BayanatzApp());
}

// BUG-161 / BUG-162 / BUG-191: the design size used to be picked ONCE from
// the first window size (View.physicalSize is not a rebuild dependency), so a
// live resize scaled the page instead of re-arranging it, and 541–767 px used
// the 375-px phone design for the desktop layout (enlarged page). The size is
// now derived from MediaQuery on every resize — see SiteLayout.

class BayanatzApp extends StatelessWidget {
  const BayanatzApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MediaQuery.sizeOf registers a dependency, so this rebuilds on every
    // window resize and ScreenUtil gets the new design size right away.
    final Size screen = MediaQuery.sizeOf(context);
    final Size designSize = SiteLayout.designSizeFor(screen);

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      useInheritedMediaQuery: true,
      // Text follows the width scale but never drops below 13 px.
      fontSizeResolver: SiteLayout.resolveFontSize,
      builder: (ctx, _) {
        return RebuildOnResize(
          token: screen,
          child: MultiBlocProvider(
          providers: [
            // ← Add LanguageCubit FIRST so it's available to all widgets
            BlocProvider<LanguageCubit>(
              create: (_) => LanguageCubit(),
            ),
            BlocProvider<HomeCmsCubit>(
              create: (_) => HomeCmsCubit(
                repository: HomeRepositoryImpl(),
                // Theme + logo (branding) come from the admin's MAIN page CMS
                mainRepository: HomeRepositoryImpl(
                  collection: 'mainPage',
                  publishedDoc: 'main',
                ),
              )..load(),
            ),
            BlocProvider<ServiceCmsCubit>(
              create: (_) => ServiceCmsCubit(
                repo: ServiceRepositoryImpl(),
              )..load(),
            ),
            BlocProvider<BlogCubit>(
              create: (_) => BlogCubit()..load(),
            ),
            BlocProvider<AboutCubit>(
              create: (_) => AboutCubit()..load(),
            ),
            BlocProvider<ContactCubit>(
              create: (_) => ContactCubit(),
            ),
            BlocProvider<ContactUsCmsCubit>(
              create: (_) => ContactUsCmsCubit()..load(),
            ),
            BlocProvider<CareersCmsCubit>(
              create: (_) => CareersCmsCubit(
                jobRepo: JobListingRepoImpl(),
                appRepo: ApplicationRepoImpl(), // your application repo implementation
              )..loadRealData(), // ← was ..load()
            ),



            BlocProvider<JobListingCubit>(
              create: (_) => JobListingCubit(repo: JobListingRepoImpl())..loadJobs(),
            ),

            BlocProvider<AboutCompanyCubit>(
              create: (_) => AboutCompanyCubit(
                repo: AboutCompanyRepoImpl(),
              )..loadAboutCompany(),
            ),

            BlocProvider<DepartmentCubit>(
              create: (_) => DepartmentCubit(
                repo: DepartmentRepoImpl(),
              )..loadDepartments(),
            ),
            BlocProvider<ApplicationCubit>(
              create: (_) => ApplicationCubit(
                repo: ApplicationRepoImpl(),
              ),
            ),



            BlocProvider<CareersSectionCubit>(
              create: (_) => CareersSectionCubit(
                sectionKey: 'whyJoinOurTeam', // default section
              )..load(),
            ),

            // ── ADD THESE TWO ──────────────────────────────────────
            BlocProvider<InternCubit>(
              create: (_) => InternCubit(),
            ),
            BlocProvider<OurTeamsCubit>(
              create: (_) => OurTeamsCubit(),
            ),

          ],
          child: BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, langState) {
              // BUG-253: <html lang/dir> follows the site language.
              PageMeta.setLanguage(langState.isArabic);
              return ValueListenableBuilder<String>(
                valueListenable: PageMeta.title,
                builder: (context, pageTitle, _) => MaterialApp.router(
                // BUG-253: one browser-tab title per page.
                title: pageTitle,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: AppTheme.isDark ? ThemeMode.dark : ThemeMode.light,
                routerConfig: AppRouter.router,
                locale: langState.locale,
                supportedLocales: const [
                  Locale('en'), // English
                  Locale('ar'), // Arabic
                ],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              ),
              );
            },
          ),
        ),
        );
      },
    );
  }
}
