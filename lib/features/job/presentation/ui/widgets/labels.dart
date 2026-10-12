part of '../pages/job_detail_page.dart';

class _Labels {
  final bool isArabic;
  const _Labels(this.isArabic);

  String get hireDate => isArabic ? 'تاريخ التوظيف:' : 'Hire Date:';
  String get hireEndDate =>
      isArabic ? 'تاريخ انتهاء التوظيف:' : 'Hire End Date:';
  String get workType => isArabic ? 'نوع العمل:' : 'Work Type:';
  String get location => isArabic ? 'الموقع:' : 'Location:'; // BUG-234
  String get employmentType => isArabic ? 'نوع التوظيف:' : 'Employment Type:';
  String get employmentDuration =>
      isArabic ? 'مدة التوظيف:' : 'Employment Duration:';
  String get experienceLevel =>
      isArabic ? 'مستوى الخبرة:' : 'Experience Level:';
  String get compensationRange =>
      isArabic ? 'نطاق الراتب:' : 'Compensation Range:'; // BUG-201
  String get requiredQualification =>
      isArabic ? 'المؤهل المطلوب:' : 'Required Qualification:';
  String get skills => isArabic ? 'المهارات:' : 'Skills:';
  String get aboutThisPosition =>
      isArabic ? 'نبذة عن الوظيفة' : 'About This Position';
  String get aboutCompany => isArabic ? 'نبذة عن الشركة' : 'About Company';
  String get requirements => isArabic ? 'المتطلبات' : 'Requirements';
  String get preferredSkills =>
      isArabic ? 'المهارات المفضلة' : 'Preferred Skills';
  String get benefits => isArabic ? 'المزايا' : 'Benefits';
  String get share => isArabic ? 'مشاركة' : 'Share';
  String get downloadPdf => isArabic ? 'تنزيل PDF' : 'Download PDF'; // BUG-263
  String get apply => isArabic ? 'تقديم' : 'Apply';
  String get linkCopied => isArabic ? 'تم نسخ الرابط!' : 'Link Copied!';
  String get jobNotFound => isArabic ? 'الوظيفة غير موجودة' : 'Job not found';
}
