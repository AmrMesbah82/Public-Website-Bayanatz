// ******************* FILE INFO *******************
// File Name: job_pdf.dart
// Purpose: BUG-263 — the browser's Print / Save as PDF only captures one
//          screenshot page of the canvas-drawn site (no real text). The job
//          page now offers "Download PDF": a real, multi-page PDF with
//          selectable text (EN + AR), built from the job data.

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class JobPdfSection {
  final String title;
  final List<String> lines;
  const JobPdfSection(this.title, this.lines);
}

Future<void> downloadJobPdf({
  required String title,
  required List<MapEntry<String, String>> facts,
  required String skillsLabel,
  required List<String> skills,
  required List<JobPdfSection> sections,
  required String benefitsLabel,
  required List<MapEntry<String, String>> benefits,
  required bool isRtl,
}) async {
  final regular =
      pw.Font.ttf(await rootBundle.load('google_fonts/Cairo-Regular.ttf'));
  final bold = pw.Font.ttf(await rootBundle.load('google_fonts/Cairo-Bold.ttf'));
  const green = PdfColor.fromInt(0xFF008037);
  const grey = PdfColor.fromInt(0xFF4B5563);
  final dir = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

  final doc = pw.Document(
    title: title,
    author: 'Bayanatz',
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  pw.Widget heading(String t) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
        child: pw.Text(t,
            style: pw.TextStyle(
                fontSize: 15, fontWeight: pw.FontWeight.bold, color: green)),
      );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: dir,
      margin: const pw.EdgeInsets.all(36),
      maxPages: 50,
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.center,
        child: pw.Text('Bayanatz · ${ctx.pageNumber}/${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: grey)),
      ),
      build: (ctx) => [
        pw.Text(isRtl ? 'بيانات زي' : 'Bayanatz',
            style: pw.TextStyle(
                fontSize: 11, fontWeight: pw.FontWeight.bold, color: green)),
        pw.SizedBox(height: 6),
        pw.Text(title,
            style: pw.TextStyle(
                fontSize: 22, fontWeight: pw.FontWeight.bold, color: green)),
        pw.SizedBox(height: 10),
        for (final f in facts)
          if (f.value.trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.RichText(
                textDirection: dir,
                text: pw.TextSpan(children: [
                  pw.TextSpan(
                      text: '${f.key} ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: f.value),
                ]),
              ),
            ),
        if (skills.isNotEmpty) ...[
          heading(skillsLabel),
          pw.Text(skills.join(' · ')),
        ],
        for (final s in sections)
          if (s.lines.isNotEmpty) ...[
            heading(s.title),
            for (final line in s.lines)
              pw.Bullet(
                text: line,
                style: const pw.TextStyle(fontSize: 11, color: grey),
              ),
          ],
        if (benefits.isNotEmpty) ...[
          heading(benefitsLabel),
          for (final b in benefits)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.RichText(
                textDirection: dir,
                text: pw.TextSpan(children: [
                  pw.TextSpan(
                      text: b.key,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  if (b.value.trim().isNotEmpty) pw.TextSpan(text: ' — ${b.value}'),
                ]),
              ),
            ),
        ],
      ],
    ),
  );

  await Printing.layoutPdf(
    name: title.isEmpty ? 'Bayanatz job' : title,
    onLayout: (format) async => doc.save(),
  );
}
