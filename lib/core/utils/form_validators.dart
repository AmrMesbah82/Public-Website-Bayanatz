// ******************* FILE INFO *******************
// File Name: form_validators.dart
// Purpose: BUG-238 — ONE phone / year rule for the Contact AND Apply forms
//          (Apply accepted "0000" and graduation year 1800 while Contact
//          rejected the same phone).

/// Plausible mobile number for [countryCode] (digits only, a leading 0 of a
/// national number is ignored). Rejects too short / too long numbers and
/// numbers made of one repeated digit ("0000000000").
bool isPlausiblePhoneNumber(String countryCode, String raw) {
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('0')) digits = digits.substring(1);
  if (digits.length < 7 || digits.length > 14) return false;
  if (RegExp(r'^(\d)\1+$').hasMatch(digits)) return false;
  if (countryCode == '+20') return RegExp(r'^1[0125]\d{8}$').hasMatch(digits);
  if (countryCode == '+966') return RegExp(r'^5\d{8}$').hasMatch(digits);
  return true;
}

/// Graduation year between 1950 and (current year + 6).
bool isValidGraduationYear(String raw) {
  final v = int.tryParse(raw.trim());
  if (v == null) return false;
  return v >= 1950 && v <= DateTime.now().year + 6;
}

String phoneInvalidMessage(bool ar) => ar
    ? 'يرجى إدخال رقم جوال صحيح.'
    : 'Please enter a valid mobile number.';

String yearInvalidMessage(bool ar) => ar
    ? 'يرجى إدخال سنة بين 1950 و ${DateTime.now().year + 6}.'
    : 'Please enter a year between 1950 and ${DateTime.now().year + 6}.';

/// Wraps a phone code / number so it is always laid out left-to-right
/// ("+20", not "20+") inside an RTL page (BUG-224).
String ltrIsolate(String s) => '‎$s‎';

/// BUG-256 / BUG-224: phone-code labels are shown as "EG +20" instead of
/// "🇪🇬 +20" — the flag emoji forced a 709 KB colour-emoji font download on
/// first load just to draw the flag. Regional-indicator pairs become their
/// two ISO letters; the result is wrapped in an LTR isolate.
String phoneCodeLabel(String raw) {
  final buf = StringBuffer();
  for (final r in raw.runes) {
    if (r >= 0x1F1E6 && r <= 0x1F1FF) {
      buf.writeCharCode(0x41 + (r - 0x1F1E6));
    } else {
      buf.writeCharCode(r);
    }
  }
  return ltrIsolate(buf.toString().trim());
}
