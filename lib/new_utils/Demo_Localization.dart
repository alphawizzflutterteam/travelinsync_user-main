import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DemoLocalization {
  DemoLocalization(this.locale);

  final Locale locale;
  static DemoLocalization? of(BuildContext context) {
    return Localizations.of<DemoLocalization>(context, DemoLocalization);
  }


  static late Map<String, String> _localizedValues;

  Future<void> load() async {
    String jsonStringValues =
    await rootBundle.loadString('lib/language/${locale.languageCode}.json');
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));

  }
  String? translate(String key) {
    return _localizedValues[key];
  }

  // static member to have simple access to the delegate from Material App
  static const LocalizationsDelegate<DemoLocalization> delegate =
  _DemoLocalizationsDelegate();
}

class _DemoLocalizationsDelegate
    extends LocalizationsDelegate<DemoLocalization> {
  const _DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en','ne' ]
        .contains(locale.languageCode);
  }

  @override
  Future<DemoLocalization> load(Locale locale) async {
    DemoLocalization localization = new DemoLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<DemoLocalization> old) => false;
}
String? getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(context)!.translate(key);
}
Future<Locale> setLocale(String languageCode1) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString('languageCode', languageCode1);
  return _locale(languageCode1);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode1 = _prefs.getString('languageCode') ?? "en";
  return _locale(languageCode1);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case "en":
      return Locale("en", 'US');
    case "ne":
      return Locale("ne", 'NPL');
    default:
      return Locale("en", 'US');
  }
}