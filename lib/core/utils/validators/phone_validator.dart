class PhoneValidator {
  /// Validates and formats Egyptian phone numbers to E.164 format
  static String? formatToE164(String phone) {
    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');

    // Handle Egyptian numbers
    if (cleaned.startsWith('20')) {
      // Already has country code
      if (cleaned.length == 12) {
        return '+$cleaned';
      }
    } else if (cleaned.startsWith('0')) {
      // Remove leading 0 and add country code
      cleaned = cleaned.substring(1);
      if (cleaned.length == 10) {
        return '+20$cleaned';
      }
    } else if (cleaned.length == 10) {
      // No leading 0, just add country code
      return '+20$cleaned';
    }

    return null; // Invalid format
  }

  /// Validates if phone number is in correct format
  static bool isValid(String phone) {
    return formatToE164(phone) != null;
  }

  /// Formats phone number for display (e.g., +20 123 456 7890)
  static String formatForDisplay(String phone) {
    final e164 = formatToE164(phone);
    if (e164 == null) return phone;

    // Format as +20 XXX XXX XXXX
    if (e164.length == 13) {
      return '${e164.substring(0, 3)} ${e164.substring(3, 6)} ${e164.substring(6, 9)} ${e164.substring(9)}';
    }

    return e164;
  }

  /// Extracts country code from E.164 formatted number
  static String getCountryCode(String phone) {
    final e164 = formatToE164(phone);
    if (e164 != null && e164.startsWith('+20')) {
      return '+20';
    }
    return '+20'; // Default to Egypt
  }
}
