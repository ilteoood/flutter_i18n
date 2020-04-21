import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';
import 'package:flutter_i18n/utils/plural_translator.dart';
import 'package:flutter_i18n/utils/simple_translator.dart';

export 'flutter_i18n_delegate.dart';
export 'loaders/e2e_file_translation_loader.dart';
export 'loaders/file_translation_loader.dart';
export 'loaders/namespace_file_translation_loader.dart';
export 'loaders/network_file_translation_loader.dart';
export 'loaders/translation_loader.dart';
export 'widgets/I18nText.dart';

class FlutterI18n {
  TranslationLoader translationLoader;

  Map<dynamic, dynamic> decodedMap;

  FlutterI18n(TranslationLoader translationLoader) {
    this.translationLoader = translationLoader ?? FileTranslationLoader();
  }

  Future<bool> load() async {
    decodedMap = await translationLoader.load();
    return true;
  }

  get locale => this.translationLoader.locale;

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
    currentInstance.translationLoader.locale = forcedLocale;
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
    return _retrieveCurrentInstance(context).translationLoader.locale;
  }

  static FlutterI18n _retrieveCurrentInstance(BuildContext context) {
    return Localizations.of<FlutterI18n>(context, FlutterI18n);
  }
}
