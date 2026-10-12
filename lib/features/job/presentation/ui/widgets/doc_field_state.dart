part of '../pages/job_apply_page.dart';

class _DocFieldState {
  final String name;       // e.g. "Resume", "Cover Letter", "Portfolio"
  final String nameAr;     // BUG-200: Arabic name from the admin (Name_Ar)
  final String docType;    // "PDF" or "Link"
  final bool isRequired;   // admin's Required/Optional switch

  // ── For PDF type ──
  String? fileName;
  Uint8List? fileBytes;
  String? uploadedUrl;
  String? error;
  /// BUG-237: upload progress 0…1 while SEND is uploading this file.
  double? progress;

  // ── For Link type ──
  final TextEditingController linkController;

  _DocFieldState({
    required this.name,
    this.nameAr = '',
    required this.docType,
    this.isRequired = true,
  }) : linkController = TextEditingController();

  /// Label in the page language (BUG-200).
  String label(bool isRtl) => isRtl && nameAr.trim().isNotEmpty ? nameAr : name;

  void dispose() {
    linkController.dispose();
  }
}
