part of '../pages/contact_us_page.dart';

class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAP LINK LAUNCHER
// ═══════════════════════════════════════════════════════════════════════════════

Future<void> _launchMapLink(String mapLink) async {
  if (mapLink.isEmpty) return;
  String raw = mapLink.trim();
  if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
    raw = 'https://$raw';
  }
  final uri = Uri.tryParse(raw);
  if (uri == null || !uri.hasAuthority) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANIMATION SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════

enum _SlideDirection { fromBottom, fromLeft, fromRight, fromTop }

// ═══════════════════════════════════════════════════════════════════════════════
// BUG-102: phone check + friendly OTP error text
// ═══════════════════════════════════════════════════════════════════════════════

/// Rejects obviously fake numbers ("0000000000", "1111111…") and checks the
/// mobile format for Egypt / Saudi Arabia (same rule as the sendOTP function).
bool isPlausiblePhone(String countryCode, String raw) =>
    isPlausiblePhoneNumber(countryCode, raw); // BUG-238: shared rule

/// Maps the sendOTP error code (or an old raw "INTERNAL") to EN / AR text.
String otpErrorMessage(String code, bool ar) {
  switch (code) {
    case 'invalid-phone':
      return ar
          ? 'يرجى إدخال رقم جوال صحيح.'
          : 'Please enter a valid mobile number.';
    case 'too-many-attempts':
      return ar
          ? 'محاولات كثيرة. يرجى الانتظار قليلاً ثم المحاولة مرة أخرى.'
          : 'Too many attempts. Please wait a few minutes and try again.';
    default:
      return ar
          ? 'تعذر إرسال رمز التحقق الآن. يرجى المحاولة مرة أخرى بعد قليل.'
          : "We couldn't send the verification code right now. Please try again in a few minutes.";
  }
}

/// BUG-138: "Facebook", "LinkedIn", … from a social link's address.
String _contactSocialName(String url) {
  final u = url.toLowerCase();
  const names = <String, String>{
    'facebook': 'Facebook', 'fb.com': 'Facebook', 'instagram': 'Instagram',
    'linkedin': 'LinkedIn', 'twitter': 'X (Twitter)', 'x.com': 'X (Twitter)',
    'youtube': 'YouTube', 'youtu.be': 'YouTube', 'tiktok': 'TikTok',
    'snapchat': 'Snapchat', 'whatsapp': 'WhatsApp', 'wa.me': 'WhatsApp',
    't.me': 'Telegram', 'telegram': 'Telegram', 'github': 'GitHub',
  };
  for (final e in names.entries) {
    if (u.contains(e.key)) return e.value;
  }
  return 'Social link';
}
