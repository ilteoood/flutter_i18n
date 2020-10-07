import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';
import 'package:flutter_i18n/models/loading_status.dart';
import 'package:flutter_i18n/utils/plural_translator.dart';
import 'package:flutter_i18n/utils/simple_translator.dart';
import 'package:intl/intl.dart' as intl;

export 'flutter_i18n_delegate.dart';
export 'loaders/e2e_file_translation_loader.dart';
export 'loaders/file_translation_loader.dart';
export 'loaders/namespace_file_translation_loader.dart';
export 'loaders/network_file_translation_loader.dart';
export 'loaders/translation_loader.dart';
export 'widgets/I18nPlural.dart';
export 'widgets/I18nText.dart';

typedef void MissingTranslationHandler(String key, Locale locale);

/// Facade used to hide the loading and translations logic
class FlutterI18n {
  TranslationLoader translationLoader;

  Map<dynamic, dynamic> decodedMap;
  MissingTranslationHandler missingTranslationHandler;
  final _localeStream = StreamController<Locale>();
  final _loadingStream = StreamController<LoadingStatus>();

  get loadingStream => _loadingStream.stream;

  FlutterI18n(
    TranslationLoader translationLoader, {
    MissingTranslationHandler missingTranslationHandler,
  }) {
    this.translationLoader = translationLoader ?? FileTranslationLoader();
    this._loadingStream.add(LoadingStatus.notLoaded);
    this.missingTranslationHandler =
        missingTranslationHandler ?? (key, locale) {};
  }

  /// Used to load the locale translation file
  Future<bool> load() async {
    this._loadingStream.add(LoadingStatus.loading);
    decodedMap = await translationLoader.load();
    _localeStream.add(locale);
    this._loadingStream.add(LoadingStatus.loaded);
    return true;
  }

  /// The locale used for the translation logic
  get locale => this.translationLoader.locale;

  /// Facade method to the plural translation logic
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

  /// Facade method to force the load of a new locale
  static Future refresh(
      final BuildContext context, final Locale forcedLocale) async {
    final FlutterI18n currentInstance = _retrieveCurrentInstance(context);
    currentInstance.translationLoader.forcedLocale = forcedLocale;
    await currentInstance.load();
  }

  /// Facade method to the simple translation logic
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

  /// Same as `get locale`, but this can be invoked from widgets
  static Locale currentLocale(final BuildContext context) {
    final FlutterI18n currentInstance = _retrieveCurrentInstance(context);
    return currentInstance?.translationLoader?.locale;
  }

  static FlutterI18n _retrieveCurrentInstance(BuildContext context) {
    return Localizations.of<FlutterI18n>(context, FlutterI18n);
  }

  /// Build for root widget, to support RTL languages
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

  static Stream<LoadingStatus> retrieveLoadingStream(
      final BuildContext context) {
    return _retrieveCurrentInstance(context).loadingStream;
  }

  static _findTextDirection(final Locale locale) {
    return intl.Bidi.isRtlLanguage(locale?.countryCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}
