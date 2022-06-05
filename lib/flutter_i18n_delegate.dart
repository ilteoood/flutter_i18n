import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/utils/message_printer.dart';

import 'flutter_i18n.dart';

/// Translation delegate that manage the new locale received from the framework
class FlutterI18nDelegate extends LocalizationsDelegate<FlutterI18n> {
  static FlutterI18n? _translationObject;
  Locale? currentLocale;

  FlutterI18nDelegate(
      {translationLoader,
      MissingTranslationHandler? missingTranslationHandler,
      String keySeparator = "."}) {
    _translationObject = FlutterI18n(
      translationLoader,
      keySeparator,
      missingTranslationHandler: missingTranslationHandler,
    );
  }

  @override
  bool isSupported(final Locale locale) {
    return true;
  }

  @override
  Future<FlutterI18n> load(final Locale locale) async {
    MessagePrinter.info("New locale: $locale");
    final TranslationLoader translationLoader =
        _translationObject!.flutterI18nInstance.translationLoader!;
    if (translationLoader.locale != locale ||
        _translationObject!.flutterI18nInstance.decodedMap == null ||
        _translationObject!.flutterI18nInstance.decodedMap!.isEmpty) {
      translationLoader.locale = currentLocale = locale;
      await _translationObject!.load();
    }
    return _translationObject!;
  }

  @override
  bool shouldReload(final FlutterI18nDelegate old) {
    return this.currentLocale == null ||
        this.currentLocale == old.currentLocale;
  }
}
