class AuthValidator {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'auth_name_required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'auth_email_required';
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value.trim())) {
      return 'auth_email_invalid';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'auth_password_required';
    }
    if (value.length < 6) {
      return 'auth_password_too_short';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'auth_phone_required';
    }
    return null;
  }
}
