part of 'locale_cubit.dart';

/// State for locale selection UI
@immutable
sealed class LocaleState {
  const LocaleState();
}

/// Loaded state with selected language code
final class LocaleSelected extends LocaleState {
  final String selectedLanguageCode;

  const LocaleSelected(this.selectedLanguageCode);
}
