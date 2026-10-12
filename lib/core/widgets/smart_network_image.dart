// ******************* FILE INFO *******************
// File Name: smart_network_image.dart
// Purpose: BUG-68 / BUG-18 — logos and Home section images can now be PNG /
//          JPG / WebP as well as SVG. Everything used to be drawn with
//          SvgPicture.network, which can't draw a bitmap.
//
//          • URL path ends in .svg  → SvgPicture.network (bitmap fallback)
//          • anything else          → Image.network (SVG fallback, because
//            older uploads were SVGs stored under a ".png" name)
//          • both fail / empty URL  → [fallback] (e.g. the bundled logo), so a
//            blocked Storage request (BUG-18, ERR_BLOCKED_BY_ORB) never shows a
//            broken-image icon.

//
//  BUG-251: Safari cannot paint a bitmap that is EMBEDDED in an SVG
//  (<image href="data:image/png;base64,…">) once flutter_svg draws it on the
//  canvas — the Home tiles, Important Reads images and the Contact
//  confirmation image were blank white boxes. Such "raster-in-SVG" files are
//  now detected and the embedded PNG/JPG/WebP is drawn directly with
//  Image.memory (works in every browser). Real vector SVGs are unchanged.

import 'package:website_app/core/utils/svg_preload.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class SmartNetworkImage extends StatelessWidget {
  const SmartNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallback,
    this.svgColorFilter,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Shown while loading fails or when [url] is empty.
  final Widget? fallback;

  /// Tint for SVGs only (bitmaps are shown as-is).
  final ColorFilter? svgColorFilter;

  static final Map<String, Future<Uint8List?>> _rasterCache = {};

  /// The bitmap inside a raster-only SVG wrapper, or null for a real SVG.
  static Future<Uint8List?> embeddedRaster(String url) =>
      _rasterCache.putIfAbsent(url, () async {
        try {
          final res = await http.get(Uri.parse(url));
          if (res.statusCode != 200) return null;
          final body = utf8.decode(res.bodyBytes, allowMalformed: true);
          if (!body.contains('<svg')) return null;
          // Real vector content → keep flutter_svg.
          if (RegExp(r'<(path|text|polygon|polyline|circle|ellipse|line)\b')
              .hasMatch(body)) {
            return null;
          }
          final m = RegExp(
            r'''href\s*=\s*["']data:image/(?:png|jpe?g|webp|gif);base64,([^"']+)["']''',
          ).firstMatch(body);
          if (m == null) return null;
          return base64.decode(m.group(1)!.replaceAll(RegExp(r'\s'), ''));
        } catch (_) {
          return null;
        }
      });

  static bool looksLikeSvg(String url) {
    final path = Uri.decodeComponent(url.split('?').first).toLowerCase();
    return path.endsWith('.svg');
  }

  Widget get _fallback => fallback ?? SizedBox(width: width, height: height);

  Widget _svg({Widget? onError}) => SvgPreload.isBad(url)
      ? (onError ?? _fallback) // known-broken SVG: don't re-parse it
      : SvgPicture.network(
        url,
        width: width,
        height: height,
        fit: fit,
        colorFilter: svgColorFilter,
        placeholderBuilder: (_) => SizedBox(width: width, height: height),
        errorBuilder: (_, __, ___) => onError ?? _fallback,
      );

  Widget _bitmap({Widget? onError}) => Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => onError ?? _fallback,
      );

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return _fallback;
    if (!looksLikeSvg(url)) return _bitmap(onError: _svg());
    return FutureBuilder<Uint8List?>(
      future: embeddedRaster(url),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return SizedBox(width: width, height: height);
        }
        final bytes = snap.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _svg(onError: _fallback),
          );
        }
        return _svg(onError: _bitmap());
      },
    );
  }
}
