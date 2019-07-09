library flutter_i18n;

import 'dart:async';

import 'package:flutter/material.dart';

import 'flutter_i18n.dart';

class FlutterI18nDelegate extends LocalizationsDelegate<FlutterI18n> {
  final bool useCountryCode;
  final String fallbackFile;
  final String path;
  final Locale defaultLocale;

  FlutterI18n _currentTranslationObject;

  FlutterI18nDelegate(
      {this.useCountryCode = false,
      this.fallbackFile,
      this.path = "assets/flutter_i18n",
      this.defaultLocale});

  @override
  bool isSupported(final Locale locale) {
    return true;
  }

  @override
  Future<FlutterI18n> load(final Locale locale) async {
    if (_currentTranslationObject == null ||
        _currentTranslationObject.locale != locale) {
      _currentTranslationObject =
          FlutterI18n(useCountryCode, fallbackFile, path);
      await _currentTranslationObject.load(defaultLocale);
    }
    return _currentTranslationObject;
  }

  @override
  bool shouldReload(final LocalizationsDelegate old) {
    return _currentTranslationObject == null ||
        !_currentTranslationObject.forcedLocale;
  }
}
