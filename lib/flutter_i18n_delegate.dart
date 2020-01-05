library flutter_i18n;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/message_printer.dart';

import 'flutter_i18n.dart';

class FlutterI18nDelegate extends LocalizationsDelegate<FlutterI18n> {
  final bool useCountryCode;
  final String fallbackFile;
  final String path;
  final Locale forcedLocale;
  static FlutterI18n _currentTranslationObject;

  FlutterI18nDelegate(
      {this.useCountryCode = false,
      this.fallbackFile,
      this.path = "assets/flutter_i18n",
      this.forcedLocale});

  @override
  bool isSupported(final Locale locale) {
    return true;
  }

  @override
  Future<FlutterI18n> load(final Locale locale) async {
    MessagePrinter.info("New locale: $locale");
    if (FlutterI18nDelegate._currentTranslationObject == null ||
        FlutterI18nDelegate._currentTranslationObject.locale != locale) {
      FlutterI18nDelegate._currentTranslationObject =
          FlutterI18n(useCountryCode, fallbackFile, path, this.forcedLocale);
      await FlutterI18nDelegate._currentTranslationObject.load();
    }
    return FlutterI18nDelegate._currentTranslationObject;
  }

  @override
  bool shouldReload(final LocalizationsDelegate old) {
    return _currentTranslationObject == null ||
        _currentTranslationObject.forcedLocale == null;
  }
}
