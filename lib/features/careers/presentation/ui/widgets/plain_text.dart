part of '../pages/careers_page.dart';

class _PlainText extends StatelessWidget {
  final String text;
  final double fontSize;
  final double height;
  const _PlainText(this.text, {this.fontSize = 13, this.height = 1.65});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: StyleText.fontSize15Weight400.copyWith(
      fontSize: fontSize,
      height: height,
      fontWeight: FontWeight.w500,
      color: SiteColors.description, // BUG-188 / BUG-136
    ),
  );
}

// ── Desktop Apply Now button ──────────────────────────────────────────────────
