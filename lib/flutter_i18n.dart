import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/utils/plural_translator.dart';
import 'package:flutter_i18n/utils/simple_translator.dart';
import 'package:flutter_i18n/utils/translation_loader.dart';

class FlutterI18n {
  final bool _useCountryCode;
  final String _fallbackFile;
  final String _basePath;
  Locale forcedLocale;

  Locale locale;

  Map<dynamic, dynamic> decodedMap;

  FlutterI18n(this._useCountryCode,
      [this._fallbackFile, this._basePath, this.forcedLocale]);

  Future<bool> load() async {
    final TranslationLoader translationLoader = TranslationLoader(
        this._fallbackFile,
        this._basePath,
        this._useCountryCode,
        this.forcedLocale);
    decodedMap = await translationLoader.load();
    locale = translationLoader.locale;
    return true;
  }

  static String plural(final BuildContext context, final String translationKey,
      final int pluralValue) {
    final FlutterI18n currentInstance = _retrieveCurrentInstance(context);
    final PluralTranslator pluralTranslator = PluralTranslator(
        currentInstance.decodedMap, translationKey, pluralValue);
    return pluralTranslator.plural();
  }

  static Future refresh(
      final BuildContext context, final Locale forcedLocale) async {
    final FlutterI18n currentInstance = _retrieveCurrentInstance(context);
    currentInstance.forcedLocale = forcedLocale;
    await currentInstance.load();
  }

  static String translate(final BuildContext context, final String key,
      {final String fallbackKey, final Map<String, String> translationParams}) {
    final Map<dynamic, dynamic> decodedMap =
        _retrieveCurrentInstance(context).decodedMap;
    final SimpleTranslator simpleTranslator = SimpleTranslator(decodedMap, key,
        fallbackKey: fallbackKey, translationParams: translationParams);
    return simpleTranslator.translate();
  }

  static Locale currentLocale(final BuildContext context) {
    return _retrieveCurrentInstance(context).locale;
  }

  static FlutterI18n _retrieveCurrentInstance(BuildContext context) {
    return Localizations.of<FlutterI18n>(context, FlutterI18n);
  }
}
