library flutter_i18n;

import 'dart:async';

import 'package:flutter/material.dart';

import 'flutter_i18n.dart';

class FlutterI18nDelegate extends LocalizationsDelegate<FlutterI18n> {
  final bool useCountryCode;
  final String fallbackFile;
  final String path;
  static FlutterI18n _currentTranslationObject;

  FlutterI18nDelegate(
      {this.useCountryCode = false,
      this.fallbackFile,
      this.path = "assets/flutter_i18n"});

  @override
  bool isSupported(final Locale locale) {
    return true;
  }

  @override
  Future<FlutterI18n> load(final Locale locale) async {
    if (FlutterI18nDelegate._currentTranslationObject == null ||
        FlutterI18nDelegate._currentTranslationObject.locale != locale) {
      FlutterI18nDelegate._currentTranslationObject =
          FlutterI18n(useCountryCode, fallbackFile, path);
      await FlutterI18nDelegate._currentTranslationObject.load(locale);
    }
    return FlutterI18nDelegate._currentTranslationObject;
  }

  @override
  bool shouldReload(final LocalizationsDelegate old) {
    return _currentTranslationObject == null ||
        !_currentTranslationObject.forcedLocale;
  }
}
