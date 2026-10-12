// ******************* FILE INFO *******************
// File Name: tinted_network_icon.dart
// Purpose: BUG-227 / BUG-214 — CMS icons (SVG) recoloured for a state
//          (e.g. white glyph on the green "selected" tile).
//
//  Many uploaded SVGs carry a full-canvas background shape
//  (<rect width="24" height="24" fill="white"/>, a clip rect, …). Tinting the
//  WHOLE picture with BlendMode.srcIn turned that background into a solid
//  square, so the selected Value tile showed a blank white square and the
//  selected "Our Strategy" tab a blank green one.
//
//  This widget downloads the SVG once, removes shapes that cover the whole
//  canvas, and tints only what is left (the glyph). Bitmaps are shown as-is.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import 'smart_network_image.dart';

class TintedNetworkIcon extends StatelessWidget {
  const TintedNetworkIcon({
    super.key,
    required this.url,
    required this.size,
    this.color,
    this.fallback,
  });

  final String url;
  final double size;

  /// Glyph colour; null keeps the icon's own colours.
  final Color? color;
  final Widget? fallback;

  static final Map<String, Future<String?>> _cache = {};

  static double? _num(String? v) =>
      v == null ? null : double.tryParse(v.replaceAll(RegExp(r'[^0-9.\-]'), ''));

  /// Removes <rect>/<path>-free background shapes that cover the full canvas.
  static String stripBackground(String svg) {
    double? w, h;
    final vb = RegExp(r'viewBox\s*=\s*"([^"]+)"').firstMatch(svg);
    if (vb != null) {
      final p = vb.group(1)!.trim().split(RegExp(r'[\s,]+'));
      if (p.length == 4) {
        w = double.tryParse(p[2]);
        h = double.tryParse(p[3]);
      }
    }
    w ??= _num(RegExp(r'<svg[^>]*\swidth\s*=\s*"([^"]+)"').firstMatch(svg)?.group(1));
    h ??= _num(RegExp(r'<svg[^>]*\sheight\s*=\s*"([^"]+)"').firstMatch(svg)?.group(1));
    if (w == null || h == null) return svg;
    final double cw = w, ch = h;
    return svg.replaceAllMapped(RegExp(r'<rect\b[^>]*/>|<rect\b[^>]*>\s*</rect>'), (m) {
      final tag = m.group(0)!;
      final rw = _num(RegExp(r'\swidth\s*=\s*"([^"]+)"').firstMatch(tag)?.group(1));
      final rh = _num(RegExp(r'\sheight\s*=\s*"([^"]+)"').firstMatch(tag)?.group(1));
      final isFull = rw != null && rh != null && rw >= cw * 0.95 && rh >= ch * 0.95;
      return isFull ? '' : tag;
    });
  }

  static Future<String?> _load(String url) => _cache.putIfAbsent(url, () async {
        try {
          final res = await http.get(Uri.parse(url));
          if (res.statusCode != 200) return null;
          final body = utf8.decode(res.bodyBytes, allowMalformed: true);
          if (!body.contains('<svg')) return null;
          return stripBackground(body);
        } catch (_) {
          return null;
        }
      });

  @override
  Widget build(BuildContext context) {
    final Widget fb = fallback ?? SizedBox(width: size, height: size);
    if (url.trim().isEmpty) return fb;
    if (!SmartNetworkImage.looksLikeSvg(url)) {
      return SmartNetworkImage(url, width: size, height: size, fallback: fb);
    }
    return FutureBuilder<String?>(
      future: _load(url),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return SizedBox(width: size, height: size);
        }
        final svg = snap.data;
        if (svg == null) {
          return SmartNetworkImage(
            url,
            width: size,
            height: size,
            fallback: fb,
            svgColorFilter:
                color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
          );
        }
        return SvgPicture.string(
          svg,
          width: size,
          height: size,
          fit: BoxFit.contain,
          colorFilter:
              color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
        );
      },
    );
  }
}
