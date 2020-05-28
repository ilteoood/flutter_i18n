import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';
import 'package:flutter_i18n/utils/message_printer.dart';

import 'flutter_i18n.dart';

class FlutterI18nDelegate extends LocalizationsDelegate<FlutterI18n> {
  static FlutterI18n _translationObject;
  Locale currentLocale;

  FlutterI18nDelegate({translationLoader}) {
    _translationObject = FlutterI18n(translationLoader);
  }

  @override
  bool isSupported(final Locale locale) {
    return true;
  }

  @override
  Future<FlutterI18n> load(final Locale locale) async {
    MessagePrinter.info("New locale: $locale");
    final TranslationLoader translationLoader =
        _translationObject.translationLoader;
    if (translationLoader.locale != locale) {
      translationLoader.locale = currentLocale = locale;
      await _translationObject.load();
    }
    return _translationObject;
  }

  @override
  bool shouldReload(final FlutterI18nDelegate old) {
    return this.currentLocale == null ||
        this.currentLocale == old.currentLocale;
  }
}
