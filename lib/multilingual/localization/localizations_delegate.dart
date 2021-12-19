import 'package:flutter/material.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_ta.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_te.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_ka.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_mal.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_mar.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_be.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_en.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_hi.dart';
import 'package:cornext_mobile/multilingual/localization/language/language_xy.dart';

import 'language/languages.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<Languages> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [
        'en',
        'hin',
        'ta',
        'te',
        'ka',
        'mal',
        'max',
        'be',
        'xy'
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
      case 'hin':
        return LanguageHi();
      case 'ta':
        return LanguageTa();
      case 'ka':
        return LanguageKa();
      case 'mal':
        return LanguageMal();
      case 'max':
        print("you are in marati");
        return LanguageMar();
      case 'xy':
        print("you are in xy");
        return LanguageXy();
      case 'be':
        return LanguageBe();
      default:
        return LanguageEn();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<Languages> old) => false;
}
