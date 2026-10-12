// ═══════════════════════════════════════════════════════════════════
// FILE: job_apply_page.dart (Public Website — Apply Form)
// Path: lib/pages/job_apply_page.dart
// UPDATED: Full AR/EN bilingual support with RTL layout
// UPDATED: Phone field now matches contact page implementation with country dropdown + number field
// UPDATED: Cover letter field now validates as proper URL/link format
// UPDATED: Resume upload now accepts PDF files only with validation
// UPDATED: Send button shows CircularProgressIndicator only (no full-screen overlay)
// UPDATED: Required documents are now DYNAMIC — read from admin's requiredDocuments array
//          PDF type → file upload box | Link type → URL text field
// ═══════════════════════════════════════════════════════════════════

import 'package:website_app/core/custom/circle_progress.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:website_app/core/custom_svg.dart';
import 'package:website_app/core/custom/1-custom_dropdwon.dart';
import 'package:website_app/core/custom/2-custom_textfield.dart';

import '../../../../../core/main_widgets/app_footer.dart';
import '../../../../../core/widgets/scroll_with_footer.dart';
import '../../../../../core/main_widgets/app_navbar.dart';
import '../../../../../core/theme/appcolors.dart';
import '../../../../../core/theme/new_theme.dart';
import '../../../../../core/theme/site_tokens.dart';
import '../../../../../core/responsive/site_layout.dart';
import '../../../../../core/utils/form_validators.dart';
import '../widgets/job_i18n.dart';
import '../../../../../core/utils/page_meta.dart';
import '../../../../../core/utils/flat_codec.dart';
import '../../../data/models/job_model.dart';
import '../widgets/job_unavailable_view.dart';
import '../../../../home/presentation/controller/home_cubit.dart';
import '../../../../home/presentation/controller/home_state.dart';
import '../../../../home/presentation/controller/lang_state.dart';
import 'package:website_app/core/widgets/format_helper.dart';

part '../widgets/doc_field_state.dart';
part '../widgets/phone_field.dart';
part '../widgets/url_validated_text_field.dart';

// Imports used only from part files — referenced here so an IDE
// "Optimize Imports" cannot drop them.
const String Function(String) _kPhoneLabel = phoneCodeLabel;

const Color _kGreen = Color(0xFF2D8C4E);
const Color _kDivider = Color(0xFFDDE8DD);

Color _parsePrimary(HomeCmsState state) {
  final hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.primaryColor,
    HomeCmsSaved(:final data) => data.branding.primaryColor,
    _ => '',
  };
  final cl = hex.replaceAll('#', '');
  if (cl.length == 6) {
    final value = int.tryParse('FF$cl', radix: 16);
    if (value != null) return Color(value);
  }
  return _kGreen;
}

Color _parseBg(HomeCmsState state) {
  final hex = switch (state) {
    HomeCmsLoaded(:final data) => data.branding.backgroundColor,
    HomeCmsSaved(:final data) => data.branding.backgroundColor,
    _ => '',
  };
  final cl = hex.replaceAll('#', '');
  if (cl.length == 6) {
    final value = int.tryParse('FF$cl', radix: 16);
    if (value != null) return Color(value);
  }
  return AppColors.background;
}

/// BUG-237: largest accepted PDF (Storage rules enforce the same limit).
const int _kMaxPdfBytes = 10 * 1024 * 1024;

// ── Bilingual helper (top-level, no context needed) ──────────────────────────
String _t(String en, String ar, bool isRtl) => isRtl ? ar : en;

// Phone (< 600): form field titles 12.sp, placeholders 10.sp.
// Null on tablet / desktop → the shared field defaults are kept.
bool _jobIsPhone(BuildContext c) => MediaQuery.sizeOf(c).width < 600;
TextStyle? _jobLabelStyle(BuildContext c) => _jobIsPhone(c)
    ? StyleText.fontSize14Weight400.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: SiteColors.textStrong,
      )
    : null;
double? _jobHintSize(BuildContext c) => _jobIsPhone(c) ? 10.sp : null;

const List<Map<String, String>> _kCountryCodes = [
  {'key': '+20', 'value': '🇪🇬 +20'},
  {'key': '+234', 'value': '🇳🇬 +234'},
  {'key': '+212', 'value': '🇲🇦 +212'},
  {'key': '+213', 'value': '🇩🇿 +213'},
  {'key': '+216', 'value': '🇹🇳 +216'},
  {'key': '+249', 'value': '🇸🇩 +249'},
  {'key': '+251', 'value': '🇪🇹 +251'},
  {'key': '+254', 'value': '🇰🇪 +254'},
  {'key': '+27', 'value': '🇿🇦 +27'},
  {'key': '+966', 'value': '🇸🇦 +966'},
  {'key': '+971', 'value': '🇦🇪 +971'},
  {'key': '+965', 'value': '🇰🇼 +965'},
  {'key': '+974', 'value': '🇶🇦 +974'},
  {'key': '+973', 'value': '🇧🇭 +973'},
  {'key': '+968', 'value': '🇴🇲 +968'},
  {'key': '+962', 'value': '🇯🇴 +962'},
  {'key': '+961', 'value': '🇱🇧 +961'},
  {'key': '+963', 'value': '🇸🇾 +963'},
  {'key': '+964', 'value': '🇮🇶 +964'},
  {'key': '+967', 'value': '🇾🇪 +967'},
  {'key': '+970', 'value': '🇵🇸 +970'},
  {'key': '+90', 'value': '🇹🇷 +90'},
  {'key': '+98', 'value': '🇮🇷 +98'},
  {'key': '+44', 'value': '🇬🇧 +44'},
  {'key': '+33', 'value': '🇫🇷 +33'},
  {'key': '+49', 'value': '🇩🇪 +49'},
  {'key': '+1', 'value': '🇺🇸 +1'},
  {'key': '+91', 'value': '🇮🇳 +91'},
  {'key': '+86', 'value': '🇨🇳 +86'},
  {'key': '+81', 'value': '🇯🇵 +81'},
  {'key': '+61', 'value': '🇦🇺 +61'},
  {'key': '+64', 'value': '🇳🇿 +64'},
];

// ═══════════════════════════════════════════════════════════════════════════════
//  DYNAMIC DOCUMENT STATE — tracks each required document's upload / link
// ═══════════════════════════════════════════════════════════════════════════════

class JobApplyPage extends StatefulWidget {
  final String jobId;
  const JobApplyPage({super.key, required this.jobId});
  @override
  State<JobApplyPage> createState() => _JobApplyPageState();
}

class _JobApplyPageState extends State<JobApplyPage> {
  Map<String, dynamic>? _job;
  /// BUG-99: visitors may no longer read this job (removed / draft …).
  bool _noLongerAvailable = false;
  bool _loadingJob = true,
      _submitting = false,
      _formSubmitted = false;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  String _countryCode = '+20';


  /// BUG-116: phone layout (one field per row) — set in build().
  bool _isPhone = false;

  /// Two fields side by side on desktop / tablet, stacked on phones.
  Widget _pair(Widget a, Widget b) {
    if (_isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [a, SizedBox(height: 10.h), b],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        SizedBox(width: 20.w), // Figma: 20 px between the two fields
        Expanded(child: b),
      ],
    );
  }

  // ── Dynamic document fields — built from admin requiredDocuments ──
  List<_DocFieldState> _docFields = [];

  @override
  void initState() {
    super.initState();
    _loadJob();
  }

  Future<void> _loadJob() async {
    final DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await FirebaseFirestore.instance
          .collection('jobListings')
          .doc(widget.jobId)
          .get(const GetOptions(source: Source.server));
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() {
          _loadingJob = false;
          _noLongerAvailable = e.code == 'permission-denied';
        });
      }
      return;
    } catch (_) {
      if (mounted) setState(() => _loadingJob = false);
      return;
    }
    if (!mounted) return;
    if (doc.exists && doc.data() != null) {
      // Admin writes the FLAT VERSIONED format — decode to the nested map this
      // page reads (title/requiredDocuments/requiredSkills/…).
      final data = FlatCodec.decode(doc.data()!, JobPostModel.flatTemplate);
      setState(() {
        _job = data;
        _loadingJob = false;
        _buildDocFields(data);
      });
      // BUG-253: "Apply — <job> — Jobs — Bayanatz".
      final bool ar = context.read<LanguageCubit>().state.isArabic;
      PageMeta.setDetailTitle('/jobs/${widget.jobId}/apply',
          _biText(data['title'] as Map<String, dynamic>?, ar));
    } else {
      setState(() => _loadingJob = false);
    }
  }

  /// Reads the requiredDocuments array from the job doc and creates
  /// a _DocFieldState for each one.
  /// Fallback: if requiredDocuments is empty or missing, default to
  /// Resume (PDF) + Cover Letter (Link) for backward compatibility.
  void _buildDocFields(Map<String, dynamic> jobData) {
    final rawDocs = jobData['requiredDocuments'] as List<dynamic>? ?? [];

    if (rawDocs.isEmpty) {
      // ── Fallback — legacy jobs without requiredDocuments ──
      _docFields = [
        _DocFieldState(name: 'Resume', nameAr: 'السيرة الذاتية', docType: 'PDF'),
        _DocFieldState(
            name: 'Cover Letter', nameAr: 'خطاب التغطية', docType: 'Link'),
      ];
      return;
    }

    _docFields = rawDocs.map((d) {
      final map = d as Map<String, dynamic>;
      final name = map['name'] as String? ?? 'Document';
      // BUG-200: the Arabic name entered in the admin (Name_Ar).
      final nameAr = map['nameAr'] as String? ?? '';
      final type = map['docType'] as String? ?? 'PDF';
      // Older docs without the flag default to required.
      final required = map['isRequired'] as bool? ?? true;
      return _DocFieldState(
          name: name, nameAr: nameAr, docType: type, isRequired: required);
    }).toList();

  }

  String _biText(Map<String, dynamic>? map, bool isRtl) {
    if (map == null) return '';
    return isRtl ? (map['ar'] ?? '') : (map['en'] ?? '');
  }

  String _str(String key) => _job?[key] as String? ?? '';

  /// Bilingual date — localized month name AND numerals (EN/AR).
  String _fmtDate(String? iso, bool isRtl) {
    if (iso == null || iso.isEmpty) return '—';
    final dt = DateTime.tryParse(iso)?.toLocal(); // BUG-277: stored in UTC
    if (dt == null) return iso;
    return FormDateTimeHelper.formatDayMonthYear(dt, arabic: isRtl);
  }

  /// Localizes digits inside any value when the page is in Arabic.
  String _num(String text, bool isRtl) =>
      isRtl ? FormDateTimeHelper.toArabicDigits(text) : text;

  // ── PDF-only file picker for a specific doc field ──────────────────────────
  Future<void> _pickFile(int index) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final ext = file.name.split('.').last.toLowerCase();

      // BUG-237: check the CONTENT, not only the extension — reject empty
      // files, files that are not really PDFs (no "%PDF" header) and files
      // bigger than the 10 MB limit.
      final Uint8List? bytes = file.bytes;
      String? error;
      if (ext != 'pdf') {
        error = 'pdf_only';
      } else if (bytes == null || bytes.isEmpty || file.size == 0) {
        error = 'empty';
      } else if (bytes.length > _kMaxPdfBytes) {
        error = 'too_big';
      } else if (bytes.length < 5 ||
          bytes[0] != 0x25 || bytes[1] != 0x50 ||
          bytes[2] != 0x44 || bytes[3] != 0x46) {
        error = 'not_pdf';
      }
      if (error != null) {
        setState(() {
          _docFields[index].error = error;
          _docFields[index].fileName = null;
          _docFields[index].fileBytes = null;
        });
        return;
      }

      setState(() {
        _docFields[index].fileName = file.name;
        _docFields[index].fileBytes = file.bytes;
        _docFields[index].error = null;
      });
    }
  }

  /// Remove a picked file from a doc field
  void _removeFile(int index) {
    setState(() {
      _docFields[index].fileName = null;
      _docFields[index].fileBytes = null;
      _docFields[index].uploadedUrl = null;
      _docFields[index].error = null;
    });
  }

  /// Upload a single PDF doc field to Firebase Storage
  Future<String?> _uploadDocFile(_DocFieldState doc) async {
    if (doc.fileBytes == null || doc.fileName == null) return null;
    final safeName = doc.name.replaceAll(' ', '_').toLowerCase();
    final ref = FirebaseStorage.instance.ref(
      'applications/${widget.jobId}/${DateTime.now().millisecondsSinceEpoch}_${safeName}_${doc.fileName}',
    );
    // BUG-237: show the upload progress instead of a bare spinner.
    final uploadTask = ref.putData(
      doc.fileBytes!,
      SettableMetadata(contentType: 'application/pdf'),
    );
    final sub = uploadTask.snapshotEvents.listen((snap) {
      if (!mounted || snap.totalBytes <= 0) return;
      setState(() => doc.progress = snap.bytesTransferred / snap.totalBytes);
    }, onError: (_) {});
    try {
      final task = await uploadTask;
      return await task.ref.getDownloadURL();
    } catch (_) {
      return null;
    } finally {
      await sub.cancel();
    }
  }

  // ── URL Validation Helper ──────────────────────────────────────────────────
  bool _isValidUrl(String url) {
    if (url.isEmpty) return true;

    String testUrl = url.trim();
    if (!testUrl.startsWith('http://') && !testUrl.startsWith('https://')) {
      testUrl = 'https://$testUrl';
    }

    final uri = Uri.tryParse(testUrl);
    if (uri == null) return false;

    return uri.hasScheme && uri.hasAuthority && uri.host.contains('.');
  }

  /// BUG-104: one application per e-mail and job — the e-mail (normalised)
  /// is the document id, so a second submission is refused by the rules.
  static String _applicantKey(String email) => email
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9@._+\-]'), '_');

  static bool _isValidEmail(String v) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(v.trim());

  void _toast(String en, String ar, bool isRtl) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_t(en, ar, isRtl))),
    );
  }

  /// BUG-239: set synchronously on the FIRST tap, so a double-click can
  /// never start a second upload / write.
  bool _inFlight = false;

  bool get _phoneInvalid =>
      _phoneCtrl.text.trim().isNotEmpty &&
      !isPlausiblePhoneNumber(_countryCode, _phoneCtrl.text);

  bool get _yearInvalid =>
      _yearCtrl.text.trim().isNotEmpty && !isValidGraduationYear(_yearCtrl.text);

  Future<void> _submit(bool isRtl) async {
    if (_inFlight || _submitting) return;
    setState(() => _formSubmitted = true);

    // ── Validate required personal fields ──
    // BUG-164: inline validation only (red borders + messages) — no grey
    // full-width SnackBar. BUG-238: the same phone / year rules as Contact.
    if (_firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        !_isValidEmail(_emailCtrl.text) ||
        _phoneCtrl.text.trim().isEmpty ||
        _phoneInvalid ||
        _yearCtrl.text.trim().isEmpty ||
        _yearInvalid) {
      return;
    }

    // ── Validate required doc fields (respect admin's Required/Optional switch) ──
    // BUG-164: every problem is shown inline under its field.
    for (final doc in _docFields) {
      final missing = doc.docType == 'PDF'
          ? doc.fileBytes == null
          : doc.linkController.text.trim().isEmpty;
      if (doc.isRequired && missing) return;
      if (doc.docType == 'Link') {
        final link = doc.linkController.text.trim();
        if (link.isNotEmpty && !_isValidUrl(link)) return;
      }
      if (doc.docType == 'PDF' && doc.error != null) return;
    }

    _inFlight = true;
    setState(() => _submitting = true);

    // ── Upload all PDF doc fields ──
    for (final doc in _docFields) {
      if (doc.docType == 'PDF' && doc.fileBytes != null) {
        doc.uploadedUrl = await _uploadDocFile(doc);
        if (!mounted) return;
        if (doc.uploadedUrl == null || doc.uploadedUrl!.isEmpty) {
          _inFlight = false;
          setState(() => _submitting = false);
          _toast("We couldn't upload ${doc.name}. Please try again.",
              'تعذر رفع ${doc.nameAr.isNotEmpty ? doc.nameAr : doc.name}. يرجى المحاولة مرة أخرى.',
              isRtl);
          return;
        }
      }
    }

    final jobTitle = _biText(_job?['title'] as Map<String, dynamic>?, isRtl);

    // ── Build resumeUrl + coverLetterUrl for backward-compatible fields ──
    // Also build a dynamic documents array for full flexibility
    String resumeUrl = '';
    String resumeName = '';
    String coverLetterUrl = '';
    String coverLetterName = '';

    final List<Map<String, String>> documentsArray = [];

    for (final doc in _docFields) {
      final docName = doc.name;
      String url = '';
      String fileName = '';

      if (doc.docType == 'PDF') {
        url = doc.uploadedUrl ?? '';
        fileName = doc.fileName ?? '';
      } else {
        url = doc.linkController.text.trim();
        fileName = url.isNotEmpty ? 'Link' : '';
      }

      documentsArray.add({
        'name': docName,
        'docType': doc.docType,
        'url': url,
        'fileName': fileName,
      });

      // ── Backward compat: map known names to legacy fields ──
      final lowerName = docName.toLowerCase();
      if (lowerName == 'resume' || lowerName == 'cv') {
        resumeUrl = url;
        resumeName = fileName;
      } else if (lowerName == 'cover letter' || lowerName == 'cover_letter') {
        coverLetterUrl = url;
        coverLetterName = fileName;
      }
    }

    final applicantKey = _applicantKey(_emailCtrl.text);
    final submitFailed = await FirebaseFirestore.instance
        .collection('jobListings')
        .doc(widget.jobId)
        .collection('applications')
        .doc(applicantKey)
        .set({
      'jobId': widget.jobId,
      'applicantKey': applicantKey, // BUG-104
      'jobTitle': jobTitle,
      'department': _str('department'),
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'countryCode': _countryCode,
      'phone': _phoneCtrl.text.trim(),
      'yearOfGraduation': _yearCtrl.text.trim(),
      // ── Legacy fields (backward compat) ──
      'resumeUrl': resumeUrl,
      'resumeName': resumeName,
      'coverLetterUrl': coverLetterUrl,
      'coverLetterName': coverLetterName,
      // ── NEW: full dynamic documents array ──
      'documents': documentsArray,
      'status': 'Applied',
      'tag': '',
      'technicalSkills': 0,
      'communicationSkills': 0,
      'experienceBackground': 0,
      'cultureFit': 0,
      'leadershipPotential': 0,
      'comments': '',
      'applicationDate': DateTime.now().toIso8601String(),
      'workType': _str('workType'),
      'employmentType': _str('employmentType'),
      'experienceLevel': _str('experienceLevel'),
      'salaryRange':
      '${(_job?['salaryMin'] as num?)?.toInt() ?? 0} - ${(_job?['salaryMax'] as num?)?.toInt() ?? 0}',
      'currency': _str('salaryCurrency'),
      // BUG-120: the admin "Location" column showed "-" for every row.
      'jobLocation': _str('location'),
      'employmentDuration':
      '${_str('employmentDurationText')} ${_str('employmentDurationType')}',
      'requiredQualification': _biText(
        _job?['requiredQualification'] as Map<String, dynamic>?,
        isRtl,
      ),
      'requiredSkills':
      (_job?['requiredSkills'] as List<dynamic>? ?? [])
          .map(
            (s) =>
            _biText(s['name'] as Map<String, dynamic>?, isRtl),
      )
          .join(', '),
    }).then<Object?>((_) => null).onError((e, __) => e);
    if (!mounted) return;
    if (submitFailed != null) {
      _inFlight = false;
      setState(() => _submitting = false);
      // BUG-104: the rules refuse a second document with the same e-mail.
      final duplicate = submitFailed is FirebaseException &&
          submitFailed.code == 'permission-denied';
      duplicate
          ? _toast('You have already applied to this job with this email.',
              'لقد تقدّمت بالفعل لهذه الوظيفة بهذا البريد الإلكتروني.', isRtl)
          : _toast("We couldn't send your application. Please try again.",
              'تعذر إرسال طلبك. يرجى المحاولة مرة أخرى.', isRtl);
      return;
    }
    await FirebaseFirestore.instance
        .collection('jobListings')
        .doc(widget.jobId)
        .update({'totalApplications': FieldValue.increment(1)})
        .catchError((_) {});
    if (!mounted) return;
    // BUG-260: a dedicated success address — Back no longer reopens the
    // filled form, and the page offers a way back to jobs / home.
    context.go('/jobs/${widget.jobId}/applied');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _yearCtrl.dispose();
    for (final doc in _docFields) {
      doc.dispose();
    }
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCmsCubit, HomeCmsState>(
      builder: (context, homeState) {
        final primary = _parsePrimary(homeState);
        final bgColor = _parseBg(homeState);
        final isRtl = context.watch<LanguageCubit>().state.isArabic;

        if (_loadingJob)
          return Scaffold(
            backgroundColor: bgColor, // branding background from model
            body: Column(
              children: [
                AppNavbar(currentRoute: '/careers'),
                const Expanded(child: CircleProgress()),
                const AppFooter(),
              ],
            ),
          );

        // BUG-99: removed / ended / draft jobs no longer show the form.
        if (_job == null) {
          return JobUnavailableView(
            reason: _noLongerAvailable
                ? JobUnavailableReason.closed
                : JobUnavailableReason.notFound,
          );
        }
        final openState = jobOpenStateOfMap(_job!);
        if (openState != JobOpenState.open) {
          return JobUnavailableView(
            reason: openState == JobOpenState.notStarted
                ? JobUnavailableReason.notStarted
                : JobUnavailableReason.closed,
            opensOn: DateTime.tryParse(_str('hiringStartDate'))?.toLocal(), // BUG-277
          );
        }

        // BUG-116 / BUG-134: phones get one field per row and 16 px margins.
        final double screenW = MediaQuery.sizeOf(context).width;
        _isPhone = screenW < 600;
        final double contentW = SiteLayout.contentWidth(context);

        final title = _biText(_job?['title'] as Map<String, dynamic>?, isRtl);

        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bgColor, // branding background from model
            body: Column(
              children: [
                AppNavbar(currentRoute: '/careers'),
                Expanded(
                  child: ScrollWithFooter(
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          SizedBox(height: _isPhone ? 60 : 52.w),
                          Center(
                            child: SizedBox(
                              width: contentW,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // BUG-178 / BUG-242: shared page-title style.
                                  Text(
                                    _t('Applying For Job', 'التقديم على وظيفة', isRtl),
                                    style: SiteText.pageTitle(context, color: primary),
                                  ),
                                  SizedBox(height: _isPhone ? 24.h : 38.w),
                                  // Figma: white card, radius 15, padding 50.
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(_isPhone ? 15 : 50.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildJobSummary(title, primary, bgColor, isRtl),
                                        SizedBox(height: _isPhone ? 28.h : 50.w),
                                        // Figma: #F1F2ED form box, radius 15, padding 20.
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF1F2ED),
                                            borderRadius: BorderRadius.circular(_isPhone ? 8.r : 15.r),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: _isPhone ? 15.w : 20.w,
                                              vertical: _isPhone ? 15.h : 20.w,
                                            ),
                                            child: Column(
                                              children: [
                                                _buildPersonalInfo(primary, isRtl),
                                                SizedBox(height: _isPhone ? 28.h : 20.w),
                                                _buildProfileInfo(primary, isRtl),
                                                SizedBox(height: _isPhone ? 24.h : 4.w),
                                                _buildSendButton(primary, isRtl),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: _isPhone ? 64.h : 20.w),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // BUG-65: footer scrolls with the page (was pinned).
                    footer: const AppFooter(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  JOB SUMMARY
  // ═══════════════════════════════════════════════════════════════════════════

  /// BUG-234: "Cairo, Egypt" for On Site / Hybrid jobs, "Remote" for remote.
  String _locationValue(bool isRtl) {
    final wt = WorkTypeExt.fromString(_str('workType'));
    if (wt == WorkType.remote) return _t('Remote', 'عن بُعد', isRtl);
    return jobLocation(context, _str('location'), isRtl);
  }

  Widget _buildJobSummary(
      String title, Color primary, Color bgColor, bool isRtl) {
    final skills = ((_job?['requiredSkills'] as List<dynamic>?) ?? [])
        .map((s) => _biText(s['name'] as Map<String, dynamic>?, isRtl))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    final String location = _locationValue(isRtl);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Figma: Cairo Medium 30 black, then the info rows (Medium/SemiBold 24).
        Text(
          title.isEmpty ? _t('Untitled', 'بدون عنوان', isRtl) : title,
          style: SiteText.cardTitle(context, color: Colors.black).copyWith(
              fontSize: _isPhone ? 16 : 30.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: _isPhone ? 12.h : 20.w),
        Divider(color: _kDivider, thickness: 1),
        SizedBox(height: _isPhone ? 12.h : 20.w),
        _summaryRow(
          _t('Hire Date:', 'تاريخ التوظيف:', isRtl), // BUG-201
          _fmtDate(_str('hiringStartDate'), isRtl),
          _t('Hire End Date:', 'تاريخ انتهاء التوظيف:', isRtl),
          _fmtDate(_str('hiringEndDate'), isRtl),
          primary,
        ),
        SizedBox(height: _isPhone ? 8.h : 8.w),
        _summaryRow(
          _t('Work Type:', 'نوع العمل:', isRtl),
          WorkTypeExt.fromString(_str('workType')).localized(isRtl),
          location.isEmpty ? '' : _t('Location:', 'الموقع:', isRtl),
          location,
          primary,
        ),
        SizedBox(height: _isPhone ? 8.h : 8.w),
        _summaryRow(
          _t('Employment Type:', 'نوع التوظيف:', isRtl),
          EmploymentTypeExt.fromString(_str('employmentType')).localized(isRtl),
          _t('Employment Duration:', 'مدة التوظيف:', isRtl),
          _num(
            '${_str('employmentDurationText')} '
            '${EmploymentDurationExt.fromString(_str('employmentDurationType')).localized(isRtl)}',
            isRtl,
          ),
          primary,
        ),
        SizedBox(height: _isPhone ? 8.h : 8.w),
        _summaryRow(
          _t('Experience Level:', 'مستوى الخبرة:', isRtl),
          ExperienceLevelExt.fromString(_str('experienceLevel')).localized(isRtl),
          _t('Compensation Range:', 'نطاق الراتب:', isRtl), // BUG-201
          // BUG-111: the salary always carries its currency.
          jobSalaryRange(_job?['salaryMin'] as num?, _job?['salaryMax'] as num?,
              _str('salaryCurrency'), isRtl),
          primary,
        ),
        SizedBox(height: _isPhone ? 8.h : 8.w),
        _summaryText(
          _t('Required Qualification:', 'المؤهل المطلوب:', isRtl),
          _biText(
            _job?['requiredQualification'] as Map<String, dynamic>?,
            isRtl,
          ),
          primary,
        ),
        if (skills.isNotEmpty) ...[
          SizedBox(height: _isPhone ? 12.h : 8.w),
          // BUG-206 / BUG-250: shared chip style, label on the first row.
          JobSkillsRow(
            label: _t('Skills:', 'المهارات:', isRtl),
            skills: skills,
            compact: _isPhone,
            labelStyle: StyleText.fontSize13Weight500.copyWith(
              fontSize: _isPhone ? 14 : 24.sp,
              fontWeight: FontWeight.w500,
              color: SiteColors.description,
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  PERSONAL INFORMATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// BUG-207: Figma section titles — Cairo SemiBold 32 primary.
  Widget _sectionTitle(String text, Color primary) => Text(
        text,
        style: SiteText.sectionTitle(context, color: primary)
            .copyWith(fontWeight: FontWeight.w600),
      );

  Widget _buildPersonalInfo(Color primary, bool isRtl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(_t('Personal Information', 'المعلومات الشخصية', isRtl), primary),
        SizedBox(height: _isPhone ? 16.h : 20.w),
        // BUG-116: stacked on phones. BUG-128: every required field shows
        // "*". BUG-129: field-specific hints. BUG-165 / BUG-233: one height
        // and one label style for every field (phone included).
        _pair(
          CustomTextField(
            label: _t('First Name', 'الاسم الأول', isRtl),
            required: true,
            hint: _t('e.g. Ahmed', 'مثال: أحمد', isRtl),
            controller: _firstNameCtrl,
            height: 42,
            fillColor: Colors.white,
            labelStyle: _jobLabelStyle(context),
            hintFontSize: _jobHintSize(context),
            submitted: _formSubmitted,
          ),
          CustomTextField(
            label: _t('Last Name', 'اسم العائلة', isRtl),
            required: true,
            hint: _t('e.g. Hassan', 'مثال: حسن', isRtl),
            controller: _lastNameCtrl,
            height: 42,
            fillColor: Colors.white,
            labelStyle: _jobLabelStyle(context),
            hintFontSize: _jobHintSize(context),
            submitted: _formSubmitted,
          ),
        ),
        SizedBox(height: _isPhone ? 12.h : 20.w),
        _pair(
          CustomTextField(
            label: _t('Email', 'البريد الإلكتروني', isRtl),
            required: true,
            hint: _t('e.g. name@example.com', 'مثال: name@example.com', isRtl),
            controller: _emailCtrl,
            height: 42,
            fillColor: Colors.white,
            labelStyle: _jobLabelStyle(context),
            hintFontSize: _jobHintSize(context),
            submitted: _formSubmitted,
            keyboardType: TextInputType.emailAddress,
            errorText: _formSubmitted &&
                    _emailCtrl.text.trim().isNotEmpty &&
                    !_isValidEmail(_emailCtrl.text)
                ? _t('Please enter a valid email.',
                    'يرجى إدخال بريد إلكتروني صحيح', isRtl)
                : null,
          ),
          _PhoneField(
            label: _t('Phone', 'رقم الهاتف', isRtl), // Figma
            controller: _phoneCtrl,
            submitted: _formSubmitted,
            errorText: _formSubmitted && _phoneInvalid
                ? phoneInvalidMessage(isRtl)
                : null,
            selectedCode: _countryCode,
            onCodeChanged: (v) {
              if (v != null) setState(() => _countryCode = v);
            },
            isRtl: isRtl,
            primaryColor: primary,
          ),
        ),
        SizedBox(height: _isPhone ? 12.h : 20.w),
        _pair(
          CustomTextField(
            label: _t('Year Of Graduation', 'سنة التخرج', isRtl),
            required: true,
            hint: _t('e.g. 2021', 'مثال: 2021', isRtl),
            controller: _yearCtrl,
            height: 42,
            fillColor: Colors.white,
            labelStyle: _jobLabelStyle(context),
            hintFontSize: _jobHintSize(context),
            onlyDigits: true,
            maxLength: 4,
            submitted: _formSubmitted,
            // BUG-238: 1950 … current year + 6.
            errorText: _formSubmitted && _yearInvalid
                ? yearInvalidMessage(isRtl)
                : null,
          ),
          const SizedBox(), // Figma: Year Of Graduation alone on its row
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  PROFILE INFORMATION — DYNAMIC DOCUMENTS FROM ADMIN
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProfileInfo(Color primary, bool isRtl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(_t('Profile Information', 'معلومات الملف الشخصي', isRtl), primary),
        SizedBox(height: _isPhone ? 16.h : 20.w),

        // ── Dynamically render each required document ──
        ...List.generate(_docFields.length, (i) {
          final doc = _docFields[i];
          if (doc.docType == 'PDF') {
            return _buildPdfUploadField(i, doc, primary, isRtl);
          } else {
            return _buildLinkField(i, doc, primary, isRtl);
          }
        }),
      ],
    );
  }

  /// BUG-236 / BUG-200: one label for every document — Arabic name in
  /// Arabic, red "*" when required, "(Optional)" otherwise, same style for
  /// PDF and Link documents.
  String _docLabel(_DocFieldState doc, bool isRtl) => doc.isRequired
      ? doc.label(isRtl)
      : '${doc.label(isRtl)} (${_t('Optional', 'اختياري', isRtl)})';

  String _docErrorText(String? code, bool isRtl) {
    switch (code) {
      case 'empty':
        return _t('This file is empty. Please choose another PDF.',
            'هذا الملف فارغ. يرجى اختيار ملف PDF آخر.', isRtl);
      case 'too_big':
        return _t('The file is larger than 10 MB. Please upload a smaller PDF.',
            'حجم الملف أكبر من 10 ميجابايت. يرجى رفع ملف PDF أصغر.', isRtl);
      case 'not_pdf':
        return _t('This file is not a valid PDF. Please upload a PDF file only.',
            'هذا الملف ليس ملف PDF صالحًا. يرجى رفع ملف PDF فقط.', isRtl);
      case 'pdf_only':
        return _t('Invalid file type. Please upload a PDF file only.',
            'نوع الملف غير صالح. يرجى رفع ملف PDF فقط.', isRtl);
      default:
        return _t('This field is required.', 'هذا الحقل مطلوب', isRtl);
    }
  }

  /// Builds a PDF upload box for a given document requirement
  Widget _buildPdfUploadField(
      int index, _DocFieldState doc, Color primary, bool isRtl) {
    // "Required" error only when the admin flagged this doc as required
    final bool missingRequired =
        _formSubmitted && doc.isRequired && doc.fileName == null;
    final bool hasError = doc.error != null || missingRequired;
    final double? progress = _submitting ? doc.progress : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ── (BUG-128 / BUG-236)
        requiredLabel(_docLabel(doc, isRtl),
            required: doc.isRequired, style: _jobLabelStyle(context)),
        const SizedBox(height: 8),
        // ── Upload box ──
        Stack(
          children: [
            Semantics(
              button: true,
              label: _docLabel(doc, isRtl),
              child: InkWell(
              onTap: doc.fileName != null ? null : () => _pickFile(index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                // Figma: white drop zone 260 px tall, radius 8.
                constraints: BoxConstraints(minHeight: _isPhone ? 150.h : 260.w),
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasError ? SiteColors.error : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: doc.fileName != null
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, color: primary, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      doc.fileName!,
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize12Weight400.copyWith(
                        fontSize: 14.sp,
                        color: SiteColors.textStrong,
                      ),
                    ),
                    // BUG-237: upload progress.
                    if (progress != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 220,
                        child: LinearProgressIndicator(
                          value: progress,
                          color: primary,
                          backgroundColor: SiteColors.page,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${(progress * 100).round()}%',
                          style: SiteText.meta(context)),
                    ],
                  ],
                )
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomSvg(
                      assetPath: "assets/images/upload-image.svg",
                      width: _isPhone ? 40 : 100.w, // Figma 100
                      height: _isPhone ? 40 : 100.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: _isPhone ? 6 : 13.w),
                    // BUG-207: Figma "Drag & Drop files here" · "Or" · "Browse Files".
                    Text(
                      _t('Drag & Drop files here', 'اسحب وأفلت الملفات هنا', isRtl),
                      // Figma: Cairo Medium 20 #2D2D2D.
                      style: StyleText.fontSize12Weight400.copyWith(
                        fontSize: _isPhone ? 15.sp : 20.sp,
                        fontWeight: FontWeight.w500,
                        color: SiteColors.textStrong,
                      ),
                    ),
                    SizedBox(height: _isPhone ? 2 : 10.w),
                    Text(_t('Or', 'أو', isRtl),
                        style: _isPhone
                            ? SiteText.meta(context)
                            : SiteText.meta(context, color: SiteColors.textStrong)
                                .copyWith(fontSize: 20.sp)),
                    SizedBox(height: _isPhone ? 6 : 10.w),
                    // Figma: "Browse Files" 200×37, radius 10, Medium 20 white.
                    Container(
                      width: MediaQuery.sizeOf(context).width*.3,
                      constraints: BoxConstraints(
                          minWidth: _isPhone ? 0 : 200.w,
                          minHeight: _isPhone ? 0 : 37.w),
                      alignment: _isPhone ? null : Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: _isPhone ? 8 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(_isPhone ? 6 : 10.r),
                      ),
                      child: Text(
                        _t('Browse Files', 'استعراض الملفات', isRtl),
                        style: StyleText.fontSize12Weight600.copyWith(
                          fontSize: _isPhone ? 14.sp : 20.sp,
                          fontWeight: _isPhone ? FontWeight.w600 : FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // BUG-237: the limits are shown up front.
                    Text(_t('PDF only · max 10 MB', 'PDF فقط · بحد أقصى 10 ميجابايت', isRtl),
                        style: SiteText.meta(context)),
                  ],
                ),
              ),
              ),
            ),
            // ── Remove button ──
            if (doc.fileName != null && !_submitting)
              PositionedDirectional(
                top: 8,
                end: 8,
                child: Semantics(
                  button: true,
                  label: _t('Remove file', 'إزالة الملف', isRtl),
                  child: InkWell(
                    onTap: () => _removeFile(index),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: SiteColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
        // ── Error message (BUG-131: same style as every other field) ──
        if (hasError) ...[
          const SizedBox(height: SiteText.errorGap),
          Text(_docErrorText(doc.error, isRtl), style: customFieldErrorStyle()),
        ],
        SizedBox(height: 16.h),
      ],
    );
  }

  /// Builds a URL text field for a given document requirement (Link type)
  Widget _buildLinkField(
      int index, _DocFieldState doc, Color primary, bool isRtl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UrlValidatedTextField(
          label: _docLabel(doc, isRtl),
          isRequired: doc.isRequired,
          hint: _t('Insert Link', 'أدخل الرابط', isRtl), // Figma
          controller: doc.linkController,
          submitted: _formSubmitted,
          primaryColor: primary,
          isRtl: isRtl,
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SEND BUTTON
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSendButton(Color primary, bool isRtl) {
    // BUG-239: disabled while sending. BUG-146: "Send" (Title Case, like the
    // Contact form). BUG-207: Figma 26 px label. BUG-257: focusable button.
    return SizedBox(
      width: MediaQuery.sizeOf(context).width*.4,
      height: _isPhone ? 52 : 57.w, // Figma 57
      child: ElevatedButton(
        onPressed: (_submitting || _inFlight) ? null : () => _submit(isRtl),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          disabledBackgroundColor: primary.withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _submitting
            ? const SizedBox(
                width: 22,
                height: 22,
                // White: sits on the primary Send button.
                child: CircleProgress(
                    size: 22, strokeWidth: 2, color: Colors.white, center: false),
              )
            : Text(
                _t('Send', 'إرسال', isRtl),
                // Figma: Cairo Bold 26 #F5F5F5.
                style: StyleText.fontSize16Weight700.copyWith(
                  fontSize: _isPhone ? 20 : 26.sp,
                  fontWeight: FontWeight.w700,
                  color: _isPhone ? Colors.white : const Color(0xFFF5F5F5),
                ),
              ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  SUMMARY HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _summaryRow(
      String l1,
      String v1,
      String l2,
      String v2,
      Color primary,
      ) {
    if (_isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (l1.isNotEmpty) _summaryText(l1, v1, primary),
          if (l2.isNotEmpty) ...[
            const SizedBox(height: 6),
            _summaryText(l2, v2, primary),
          ],
        ],
      );
    }
    // Figma: second column 830 px into the 1300 px card body.
    return Row(
      children: [
        Expanded(
            flex: 830,
            child: l1.isNotEmpty ? _summaryText(l1, v1, primary) : const SizedBox()),
        Expanded(
            flex: 470,
            child: l2.isNotEmpty ? _summaryText(l2, v2, primary) : const SizedBox()),
      ],
    );
  }

  Widget _summaryText(String label, String value, Color primary) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            // Figma: label Medium 24 grey, value SemiBold 24 primary.
            style: StyleText.fontSize13Weight500.copyWith(
              fontSize: _isPhone ? 14 : 24.sp,
              height: _isPhone ? 20 / 14 : 1.4,
              fontWeight: FontWeight.w500,
              color: SiteColors.description,
            ),
          ),
          TextSpan(
            text: value,
            style: StyleText.fontSize13Weight600.copyWith(
              height: _isPhone ? 20 / 14 : 1.4,
              fontSize: _isPhone ? 14 : 24.sp,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PHONE FIELD WIDGET — MATCHES CONTACT PAGE IMPLEMENTATION
// ═══════════════════════════════════════════════════════════════════════════════
