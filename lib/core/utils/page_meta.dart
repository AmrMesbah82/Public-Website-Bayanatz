// ******************* FILE INFO *******************
// File Name: page_meta.dart
// Purpose: BUG-253 — every page had the browser-tab title "Bayanatz" and the
//          Arabic site was never marked dir="rtl".
//
//  • [PageMeta.title] drives MaterialApp.title (→ document.title), computed
//    from the current route + language ("Careers — Bayanatz",
//    "Senior Flutter Developer — Jobs — Bayanatz", …).
//  • [PageMeta.setLanguage] sets <html lang="ar" dir="rtl"> / lang="en"
//    dir="ltr".

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class PageMeta {
  PageMeta._();

  static final ValueNotifier<String> title = ValueNotifier<String>('Bayanatz');

  static String _path = '/';
  static bool _ar = false;
  static String? _detailTitle;
  static String? _detailPath;

  static const Map<String, List<String>> _names = {
    '/services': ['Services', 'الخدمات'],
    '/about':    ['About Us', 'من نحن'],
    '/contact':  ['Contact Us', 'تواصل معنا'],
    '/careers':  ['Careers', 'الوظائف'],
    '/jobs':     ['Jobs', 'الوظائف المتاحة'],
    '/blog':     ['Important Reads', 'قراءات مهمة'],
  };

  static String get _brand => _ar ? 'بيانات زي' : 'Bayanatz';

  static void _recompute() {
    final segs = _path.split('/').where((s) => s.isNotEmpty).toList();
    String t;
    if (segs.isEmpty) {
      t = _ar
          ? 'بيانات زي — رواد التحول الرقمي في المنطقة'
          : "Bayanatz — MENA's Digital Transformation Pioneers";
    } else {
      final section = _names['/${segs.first}'];
      final String sectionName =
          section == null ? '' : (_ar ? section[1] : section[0]);
      final String? detail = (_detailPath == _path) ? _detailTitle : null;
      final parts = <String>[];
      if (segs.length >= 3 && segs[2] == 'apply') {
        parts.add(_ar ? 'التقديم' : 'Apply');
      } else if (segs.length >= 3 && segs[2] == 'applied') {
        parts.add(_ar ? 'تم التقديم' : 'Application sent');
      }
      if (detail != null && detail.trim().isNotEmpty) parts.add(detail.trim());
      if (sectionName.isNotEmpty) parts.add(sectionName);
      if (parts.isEmpty) parts.add(_ar ? 'الصفحة غير موجودة' : 'Page not found');
      parts.add(_brand);
      t = parts.join(' — ');
    }
    if (title.value == t) return;
    // Never notify in the middle of a build (the title rebuilds MaterialApp).
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => title.value = t);
    } else {
      title.value = t;
    }
  }

  /// Called by the router on every navigation.
  static void onLocation(String path) {
    if (path == _path) return;
    _path = path;
    _recompute();
  }

  /// A detail page (job, article) names itself once its data is loaded.
  static void setDetailTitle(String path, String detail) {
    _detailPath = path;
    _detailTitle = detail;
    _recompute();
  }

  static void setLanguage(bool ar) {
    if (kIsWeb) {
      try {
        final el = html.document.documentElement;
        el?.setAttribute('lang', ar ? 'ar' : 'en');
        el?.setAttribute('dir', ar ? 'rtl' : 'ltr');
      } catch (_) {}
    }
    if (ar == _ar) return;
    _ar = ar;
    _recompute();
  }
}
