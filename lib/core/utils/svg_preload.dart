/// ******************* FILE INFO *******************
/// File Name: svg_preload.dart
/// Description: ONE safe way to warm flutter_svg's cache for network SVGs.
///
/// Why: `svg.cache.putIfAbsent(key, () => loader.loadBytes(null))` attaches
/// its own internal `.then` (no error handler) to the loader future. When an
/// SVG from Firebase is malformed (e.g. "XmlParserException: name expected")
/// or is not an SVG at all, that internal future fails UNCAUGHT and floods
/// the console with `DartError: XmlParserException` — even though our own
/// `.catchError` handled the original future.
///
/// Here the SVG is downloaded + parsed first inside try/catch; only a
/// successfully parsed result is put into the cache (as an already-completed
/// future), so nothing can fail inside flutter_svg's cache. URLs that fail are
/// remembered in [SvgPreload.badUrls] so widgets can show their fallback
/// directly instead of asking flutter_svg to parse the broken file again.
/// Created by: Amr Mesbah

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgPreload {
  SvgPreload._();

  /// SVG URLs that could not be downloaded or parsed this session.
  static final Set<String> badUrls = <String>{};

  /// True when [url] is known to be a broken / non-SVG file.
  static bool isBad(String url) => badUrls.contains(url);

  /// Downloads, parses and caches every http(s) URL in [urls]. Never throws.
  static Future<void> preload(List<String> urls) async {
    final valid = urls
        .where((u) =>
            u.isNotEmpty &&
            (u.startsWith('http://') || u.startsWith('https://')) &&
            !badUrls.contains(u))
        .toSet();
    await Future.wait(valid.map(_one));
  }

  static Future<void> _one(String url) async {
    final loader = SvgNetworkLoader(url);
    final Object key = loader.cacheKey(null);
    try {
      // Download + parse OUTSIDE the cache → errors are caught right here.
      final ByteData data = await loader.loadBytes(null);
      // Already-completed future → flutter_svg's internal listener can't fail.
      await svg.cache.putIfAbsent(key, () => Future<ByteData>.value(data));
    } catch (e) {
      badUrls.add(url);
      if (kDebugMode) debugPrint('⚠️ Skipped invalid SVG: $url ($e)');
    }
  }
}
