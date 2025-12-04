/// Text normalization utility for flexible search matching
/// Handles Arabic character variations and text cleanup
class TextNormalizer {
  /// Normalizes text for search comparison
  ///
  /// Handles:
  /// - Arabic character variations (أإآ→ا, ة→ه, ى→ي, etc.)
  /// - Diacritics removal (Tashkeel)
  /// - Punctuation removal
  /// - Space normalization
  /// - Case normalization
  ///
  /// Example:
  /// ```dart
  /// TextNormalizer.normalize("الجونة") // "الجونه"
  /// TextNormalizer.normalize("El-Gouna") // "el gouna"
  /// ```
  static String normalize(String text) {
    if (text.isEmpty) return text;

    String result = text.toLowerCase();

    // Arabic character normalization
    result = result.replaceAll(RegExp(r'[أإآ]'), 'ا');
    result = result.replaceAll('ة', 'ه');
    result = result.replaceAll('ى', 'ي');
    result = result.replaceAll('ؤ', 'و');
    result = result.replaceAll('ئ', 'ي');

    // Remove Arabic diacritics (Tashkeel)
    result = result.replaceAll(RegExp(r'[\u064B-\u065F]'), '');

    // Remove punctuation and special characters, replace with space
    result = result.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), ' ');

    // Collapse multiple spaces into single space
    result = result.replaceAll(RegExp(r'\s+'), ' ');

    // Trim leading/trailing spaces
    result = result.trim();

    return result;
  }

  /// Checks if normalized text contains normalized query
  static bool contains(String text, String query) {
    if (query.isEmpty) return true;
    if (text.isEmpty) return false;

    return normalize(text).contains(normalize(query));
  }

  /// Checks if normalized text equals normalized query
  static bool equals(String text, String query) {
    return normalize(text) == normalize(query);
  }
}
