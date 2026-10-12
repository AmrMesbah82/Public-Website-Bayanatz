// ******************* FILE INFO *******************
// File Name: circle_progress.dart
// Description: THE loading indicator of the whole website. Every loader
//              (page loading, buttons, dialogs, image placeholders) uses
//              this widget, so all spinners look the same.
//              Colour: the PRIMARY colour from Firebase (admin › main page ›
//              branding.primaryColor, via HomeCmsCubit). It rebuilds when
//              the branding arrives. Fallback: AppColors.primary.
//              Pass [color] only where the spinner sits ON a primary-coloured
//              button (white spinner, otherwise invisible).
// Created by: Amr Mesbah

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/home/presentation/controller/home_cubit.dart';
import '../theme/appcolors.dart';

class CircleProgress extends StatelessWidget {
  const CircleProgress({
    super.key,
    this.size,
    this.strokeWidth = 2.0,
    this.color,
    this.center = true,
  });

  /// Diameter. Default 50.sp (full-page loader size).
  final double? size;
  final double strokeWidth;

  /// Override colour (e.g. white on a primary button). Null → Firebase primary.
  final Color? color;

  /// Wrap in a Center (default). False for inline use inside buttons/rows.
  final bool center;

  /// Firebase branding primary colour (null when unavailable).
  static Color? brandPrimary(BuildContext context) {
    try {
      // watch → rebuilds when the branding loads / changes.
      context.watch<HomeCmsCubit>();
      final String hex =
          context.read<HomeCmsCubit>().current.branding.primaryColor;
      final clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        final v = int.tryParse('FF$clean', radix: 16);
        if (v != null) return Color(v);
      }
      if (clean.length == 8) {
        final v = int.tryParse(clean, radix: 16);
        if (v != null) return Color(v);
      }
    } catch (_) {/* no HomeCmsCubit in scope */}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? brandPrimary(context) ?? AppColors.primary;
    final double d = size ?? 50.sp;
    final Widget spinner = SizedBox(
      height: d,
      width: d,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(c),
        backgroundColor: c.withOpacity(0.15),
        strokeWidth: strokeWidth,
      ),
    );
    return center ? Center(child: spinner) : spinner;
  }
}
