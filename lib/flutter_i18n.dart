import 'dart:async';

import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';
import 'package:flutter_i18n/utils/plural_translator.dart';
import 'package:flutter_i18n/utils/simple_translator.dart';
import 'package:intl/intl.dart' as intl;

import 'utils/message_printer.dart';

export 'flutter_i18n_delegate.dart';
export 'loaders/e2e_file_translation_loader.dart';
export 'loaders/file_translation_loader.dart';
export 'loaders/namespace_file_translation_loader.dart';
export 'loaders/network_file_translation_loader.dart';
export 'loaders/translation_loader.dart';
export 'widgets/I18nPlural.dart';
export 'widgets/I18nText.dart';

typedef void MissingTranslationHandler(String key, Locale locale);

class FlutterI18n {
  TranslationLoader translationLoader;

  Map<dynamic, dynamic> decodedMap;
  MissingTranslationHandler missingTranslationHandler;
  final _localeStream = StreamController<Locale>();

  FlutterI18n(
    TranslationLoader translationLoader, {
    MissingTranslationHandler missingTranslationHandler,
  }) {
    this.translationLoader = translationLoader ?? FileTranslationLoader();
    this.missingTranslationHandler =
        missingTranslationHandler ?? (key, locale) {};
    MessagePrinter.setMustPrintMessage(!Foundation.kReleaseMode);
  }

  Future<bool> load() async {
    decodedMap = await translationLoader.load();
    _localeStream.add(locale);
    return true;
  }

  get locale => this.translationLoader.locale;

  static String plural(final BuildContext context, final String translationKey,
      final int pluralValue) {
    final FlutterI18n currentInstance = _retrieveCurrentInstance(context);
    final PluralTranslator pluralTranslator = PluralTranslator(
      currentInstance.decodedMap,
      translationKey,
      pluralValue,
      missingKeyTranslationHandler: (key) {
        currentInstance.missingTranslationHandler(key, currentInstance.locale);
      },
    );
    return pluralTranslator.plural();
  }

  static Future refresh(
      final BuildContext context, final Locale forcedLocale) async {
    final FlutterI18n currentInstance = _retrieveCurrentInstance(context);
    currentInstance.translationLoader.forcedLocale = forcedLocale;
    await currentInstance.load();
  }

  static String translate(final BuildContext context, final String key,
      {final String fallbackKey, final Map<String, String> translationParams}) {
    final FlutterI18n currentInstance = _retrieveCurrentInstance(context);
    final Map<dynamic, dynamic> decodedMap = currentInstance.decodedMap;
    final SimpleTranslator simpleTranslator = SimpleTranslator(
      decodedMap,
      key,
      fallbackKey: fallbackKey,
      translationParams: translationParams,
      missingKeyTranslationHandler: (key) {
        currentInstance.missingTranslationHandler(key, currentInstance.locale);
      },
    );
    return simpleTranslator.translate();
  }

  static Locale currentLocale(final BuildContext context) {
    final FlutterI18n currentInstance = _retrieveCurrentInstance(context);
    return currentInstance?.translationLoader?.locale;
  }

  static FlutterI18n _retrieveCurrentInstance(BuildContext context) {
    return Localizations.of<FlutterI18n>(context, FlutterI18n);
  }

  static rootAppBuilder() {
    return (BuildContext context, Widget child) {
      return StreamBuilder<Locale>(
          stream: _retrieveCurrentInstance(context)?._localeStream?.stream,
          builder: (BuildContext context, AsyncSnapshot<Locale> snapshot) {
            return Directionality(
              textDirection: _findTextDirection(snapshot.data),
              child: child,
            );
          });
    };
  }

  static _findTextDirection(final Locale locale) {
    return intl.Bidi.isRtlLanguage(locale?.countryCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}
