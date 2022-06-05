import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';
import 'package:flutter_i18n/models/loading_status.dart';
import 'package:flutter_i18n/utils/plural_translator.dart';
import 'package:flutter_i18n/utils/simple_translator.dart';

export 'flutter_i18n_delegate.dart';
export 'loaders/e2e_file_translation_loader.dart';
export 'loaders/file_translation_loader.dart';
export 'loaders/namespace_file_translation_loader.dart';
export 'loaders/network_file_translation_loader.dart';
export 'loaders/translation_loader.dart';
export 'widgets/I18nPlural.dart';
export 'widgets/I18nText.dart';

typedef void MissingTranslationHandler(String key, Locale? locale);

/// Instance called by the facade
class FlutterI18nInstance {
  TranslationLoader? translationLoader;
  late MissingTranslationHandler missingTranslationHandler;
  String? keySeparator;

  Map<dynamic, dynamic>? decodedMap;

  final _localeStream = StreamController<Locale?>.broadcast();

  // ignore: close_sinks
  final _loadingStream = StreamController<LoadingStatus>.broadcast();

  Stream<LoadingStatus> get loadingStream => _loadingStream.stream;

  Stream<bool> get isLoadedStream => loadingStream
      .map((loadingStatus) => loadingStatus == LoadingStatus.loaded);

  FlutterI18nInstance(
    TranslationLoader? translationLoader,
    String keySeparator, {
    MissingTranslationHandler? missingTranslationHandler,
  }) {
    this.translationLoader = translationLoader ?? FileTranslationLoader();
    this._loadingStream.add(LoadingStatus.notLoaded);
    this.missingTranslationHandler =
        missingTranslationHandler ?? (key, locale) {};
    this.keySeparator = keySeparator;
  }

  /// Used to load the locale translation file
  Future<bool> load() async {
    this._loadingStream.add(LoadingStatus.loading);
    decodedMap = await translationLoader!.load();
    _localeStream.add(locale);
    this._loadingStream.add(LoadingStatus.loaded);
    return true;
  }

  /// The locale used for the translation logic
  get locale => this.translationLoader!.locale;

  /// Method for the plural translation logic
  String plural(final String translationKey, final int pluralValue) {
    final PluralTranslator pluralTranslator = PluralTranslator(
      this.decodedMap,
      translationKey,
      this.keySeparator,
      pluralValue,
      missingKeyTranslationHandler: (key) {
        this.missingTranslationHandler(key, this.locale);
      },
    );
    return pluralTranslator.plural();
  }

  /// Method to force the load of a new locale
  Future refresh(final Locale? forcedLocale) async {
    this.translationLoader!.forcedLocale = forcedLocale;
    await this.load();
  }

  /// Method for the simple translation logic
  String translate(final String key,
      {final String? fallbackKey,
      final Map<String, String>? translationParams}) {
    final SimpleTranslator simpleTranslator = SimpleTranslator(
      this.decodedMap,
      key,
      this.keySeparator,
      fallbackKey: fallbackKey,
      translationParams: translationParams,
      missingKeyTranslationHandler: (key) {
        this.missingTranslationHandler(key, this.locale);
      },
    );
    return simpleTranslator.translate();
  }

  /// Same as `get locale`, but this can be invoked from widgets
  Locale? currentLocale() {
    return this.translationLoader?.locale;
  }

  /// Used to retrieve the loading status stream
  Stream<LoadingStatus> retrieveLoadingStream() {
    return this.loadingStream;
  }

  /// Used to retrieve the locale stream
  Stream<Locale?> retrieveLocaleStream() {
    return this._localeStream.stream;
  }

  /// Used to check if the translation file is still loading
  Stream<bool> retrieveLoadedStream() {
    return this.isLoadedStream;
  }
}
