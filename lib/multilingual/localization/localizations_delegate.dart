import 'package:flutter/material.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_ar.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_en.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_hi.dart';

import 'language/languages.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<Languages> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [
        'en',
        'ar',
        'hi'
      ].contains(locale.languageCode);

  @override
  Future<Languages> load(Locale locale) => _load(locale);

  static Future<Languages> _load(Locale locale) async {
    print("here dinesh");
    print(locale.languageCode);
    switch (locale.languageCode) {
      case 'en':
        print("why am i here");
        return LanguageEn();
      case 'ar':
        return LanguageAr();
      case 'hi':
        print("here I am ");
        return LanguageHi();
      default:
        return LanguageEn();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<Languages> old) => false;
}
