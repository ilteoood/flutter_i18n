import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/utils/message_printer.dart';

/// Contains the common loading logic
abstract class TranslationLoader {
  static const String LOCALE_SEPARATOR = "_";

  /// Load method to implement
  Future<Map> load();

  Locale? _forcedLocale, _locale;

  /// Used to force the locale to load
  set forcedLocale(Locale? forcedLocale) => _forcedLocale = forcedLocale;

  /// Currently locale used by the library
  Locale? get locale => _forcedLocale ?? _locale;

  /// New locale to load, due to system language change
  set locale(Locale? locale) => _locale = locale;

  /// Return the device current locale
  Future<Locale> findDeviceLocale() async {
    final systemLocale = ui.window.locale;
    MessagePrinter.info("The system locale is $systemLocale");
    return Future.value(systemLocale);
  }
}
