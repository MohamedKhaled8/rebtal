/// Number parsing utility for safe type conversion
/// Handles both numeric and string inputs with error handling
class NumberParser {
  /// Parses value to double
  ///
  /// Handles:
  /// - Numeric types (int, double)
  /// - String with numbers and formatting
  /// - Invalid inputs (returns 0.0)
  ///
  /// Example:
  /// ```dart
  /// NumberParser.parseDouble(5000) // 5000.0
  /// NumberParser.parseDouble("5,000 EGP") // 5000.0
  /// NumberParser.parseDouble("invalid") // 0.0
  /// ```
  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      // Remove all non-numeric characters except decimal point
      final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }

    return 0.0;
  }

  /// Parses value to integer
  ///
  /// Handles:
  /// - Numeric types (int, double)
  /// - String with numbers and formatting
  /// - Invalid inputs (returns 0)
  ///
  /// Example:
  /// ```dart
  /// NumberParser.parseInt(3) // 3
  /// NumberParser.parseInt("3 bedrooms") // 3
  /// NumberParser.parseInt("invalid") // 0
  /// ```
  static int parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      // Remove all non-numeric characters
      final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(cleaned) ?? 0;
    }

    return 0;
  }
}
