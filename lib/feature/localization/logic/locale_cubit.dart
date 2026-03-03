import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';

part 'locale_state.dart';

/// Cubit for language selection UI state.
/// Persistence is delegated to [AppCubit].
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit({
    required AppCubit appCubit,
  })  : _appCubit = appCubit,
        super(LocaleSelected(appCubit.state.locale.languageCode));

  final AppCubit _appCubit;

  /// Select a language (UI only, not persisted until confirm)
  void selectLanguage(String languageCode) {
    emit(LocaleSelected(languageCode));
  }

  /// Persist selection and apply locale
  Future<void> confirmSelection() async {
    final code = state is LocaleSelected
        ? (state as LocaleSelected).selectedLanguageCode
        : 'ar';
    await _appCubit.changeLocale(Locale(code));
  }
}
