import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/services/local_db/hive/locals_box.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  static const _key = 'language_code';

  LanguageCubit() : super(const LanguageState()) {
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    final saved = LocalsDB.instance.getWithKey(_key);
    if (saved is String && saved.isNotEmpty) {
      emit(LanguageState(locale: Locale(saved)));
      return;
    }

    final systemLocale = PlatformDispatcher.instance.locale;
    final code = _supportedCode(systemLocale.languageCode);
    emit(LanguageState(locale: Locale(code)));
  }

  Future<void> setLanguage(String code) async {
    final locale = Locale(code);
    await LocalsDB.instance.putWithKey(_key, code);
    emit(LanguageState(locale: locale));
  }

  String _supportedCode(String code) {
    const supported = ['en', 'es'];
    return supported.contains(code) ? code : 'en';
  }
}
