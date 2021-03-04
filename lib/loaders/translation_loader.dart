import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:universal_io/io.dart';

import '../utils/message_printer.dart';

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
    final String systemLocale = _findSystemLocale();
    MessagePrinter.info("The system locale is $systemLocale");
    return _toLocale(systemLocale);
  }

  String _findSystemLocale() {
    return Intl.canonicalizedLocale(Platform.localeName);
  }

  Locale _toLocale(final String locale) {
    final List<String> systemLocaleSplitted = locale.split(LOCALE_SEPARATOR);
    final bool noCountryCode = systemLocaleSplitted.length == 1;
    return Locale(systemLocaleSplitted.first,
        noCountryCode ? null : systemLocaleSplitted.last);
  }
}
