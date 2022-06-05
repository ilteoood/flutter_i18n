import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n_instance.dart';
import 'package:flutter_i18n/models/loading_status.dart';
import 'package:intl/intl.dart' as intl;

export 'flutter_i18n_delegate.dart';
export 'loaders/e2e_file_translation_loader.dart';
export 'loaders/file_translation_loader.dart';
export 'loaders/namespace_file_translation_loader.dart';
export 'loaders/network_file_translation_loader.dart';
export 'loaders/translation_loader.dart';
export 'widgets/I18nPlural.dart';
export 'widgets/I18nText.dart';

typedef void MissingTranslationHandler(String key, Locale? locale);

/// Facade used to hide the loading and translations logic
class FlutterI18n {
  late FlutterI18nInstance flutterI18nInstance;

  FlutterI18n(
    TranslationLoader? translationLoader,
    String keySeparator, {
    MissingTranslationHandler? missingTranslationHandler,
  }) {
    this.flutterI18nInstance = FlutterI18nInstance(
        translationLoader, keySeparator,
        missingTranslationHandler: missingTranslationHandler);
  }

  /// Used to load the locale translation file
  Future<bool> load() async {
    return this.flutterI18nInstance.load();
  }

  /// The locale used for the translation logic
  get locale => this.flutterI18nInstance.translationLoader!.locale;

  /// Facade method to the plural translation logic
  static String plural(final BuildContext context, final String translationKey,
      final int pluralValue) {
    final FlutterI18n currentInstance = retrieveCurrentInstance(context)!;
    return currentInstance.flutterI18nInstance
        .plural(translationKey, pluralValue);
  }

  /// Facade method to force the load of a new locale
  static Future refresh(
      final BuildContext context, final Locale? forcedLocale) async {
    final FlutterI18n currentInstance = retrieveCurrentInstance(context)!;
    return currentInstance.flutterI18nInstance.refresh(forcedLocale);
  }

  /// Facade method to the simple translation logic
  static String translate(final BuildContext context, final String key,
      {final String? fallbackKey,
      final Map<String, String>? translationParams}) {
    final FlutterI18n currentInstance = retrieveCurrentInstance(context)!;
    return currentInstance.flutterI18nInstance.translate(key,
        fallbackKey: fallbackKey, translationParams: translationParams);
  }

  /// Same as `get locale`, but this can be invoked from widgets
  static Locale? currentLocale(final BuildContext context) {
    final FlutterI18n? currentInstance = retrieveCurrentInstance(context);
    return currentInstance?.flutterI18nInstance.currentLocale();
  }

  static FlutterI18n? retrieveCurrentInstance(BuildContext context) {
    return Localizations.of<FlutterI18n>(context, FlutterI18n);
  }

  /// Build for root widget, to support RTL languages
  static Widget Function(BuildContext, Widget?) rootAppBuilder() {
    Widget appBuilder(BuildContext context, Widget? child) {
      final instance = retrieveCurrentInstance(context);

      return StreamBuilder<Locale?>(
        initialData: instance?.locale,
        stream: instance?.flutterI18nInstance.retrieveLocaleStream(),
        builder: (context, snapshot) {
          return Directionality(
            textDirection: _findTextDirection(snapshot.data),
            child: child!,
          );
        },
      );
    }

    return appBuilder;
  }

  /// Used to retrieve the loading status stream
  static Stream<LoadingStatus> retrieveLoadingStream(
      final BuildContext context) {
    return retrieveCurrentInstance(context)!.flutterI18nInstance.loadingStream;
  }

  /// Used to check if the translation file is still loading
  static Stream<bool> retrieveLoadedStream(final BuildContext context) {
    return retrieveCurrentInstance(context)!.flutterI18nInstance.isLoadedStream;
  }

  static TextDirection _findTextDirection(final Locale? locale) {
    return intl.Bidi.isRtlLanguage(locale?.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}
