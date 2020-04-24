library flutter_i18n;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';
import 'package:flutter_i18n/utils/message_printer.dart';

import 'flutter_i18n.dart';

class FlutterI18nDelegate extends LocalizationsDelegate<FlutterI18n> {
  final TranslationLoader translationLoader;
  static FlutterI18n _currentTranslationObject;

  FlutterI18nDelegate({
    this.translationLoader,
  });

  @override
  bool isSupported(final Locale locale) {
    return true;
  }

  @override
  Future<FlutterI18n> load(final Locale locale) async {
    MessagePrinter.info("New locale: $locale");
    if (FlutterI18nDelegate._currentTranslationObject == null ||
        FlutterI18nDelegate._currentTranslationObject.locale != locale) {
      translationLoader.locale = locale;
      FlutterI18nDelegate._currentTranslationObject =
          FlutterI18n(translationLoader);
      await FlutterI18nDelegate._currentTranslationObject.load();
    }
    return FlutterI18nDelegate._currentTranslationObject;
  }

  @override
  bool shouldReload(final LocalizationsDelegate old) {
    return _currentTranslationObject == null ||
        _currentTranslationObject.locale == null;
  }
}
