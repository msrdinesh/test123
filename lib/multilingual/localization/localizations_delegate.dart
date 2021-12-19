import 'package:flutter/material.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_ta.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_te.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_ka.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_mal.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_mar.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_be.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_en.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_hi.dart';

import 'language/languages.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<Languages> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [
        'en',
        'hi',
        'ta',
        'te',
        'ka',
        'mal',
        'mr',
        'be'
      ].contains(locale.languageCode);

  @override
  Future<Languages> load(Locale locale) => _load(locale);

  static Future<Languages> _load(Locale locale) async {
    print("here dinesh");
    print(locale.languageCode);
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'te':
        return LanguageTe();
      case 'hi':
        return LanguageHi();
      case 'ta':
        return LanguageTa();
      case 'ka':
        return LanguageKa();
      case 'mal':
        return LanguageMal();
      case 'mr':
        return LanguageMar();
      case 'be':
        print("bengali");
        return LanguageBe();
      default:
        return LanguageEn();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<Languages> old) => false;
}
