/// ******************* FILE INFO *******************
/// File Name: app_logo_loader.dart
/// Description: Full-page loading screen used by every page and by the
///              router while a page's code downloads. Shows the shared
///              CircleProgress (Firebase primary colour) centred on the page.
/// Created by: Amr Mesbah

import 'package:flutter/material.dart';

import '../custom/circle_progress.dart';
import '../theme/appcolors.dart';

class AppLogoLoader extends StatelessWidget {
  const AppLogoLoader({super.key, this.logoUrl, this.backgroundColor});

  /// Kept for call-site compatibility (no longer shown).
  final String? logoUrl;

  /// Page background (branding). Defaults to the site background.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: backgroundColor ?? AppColors.background,
        body:  Semantics(label: 'Loading', child: CircleProgress()),
      );
}
