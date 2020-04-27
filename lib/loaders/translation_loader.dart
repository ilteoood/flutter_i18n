import 'package:flutter/widgets.dart';
import 'package:intl/intl_standalone.dart';

import '../utils/message_printer.dart';

abstract class TranslationLoader {
  static const String LOCALE_SEPARATOR = "_";

  Future<Map> load();

  Future<String> loadString(final String fileName, final String extension);

  Locale get locale;

  set locale(Locale locale);

  Future<Locale> findCurrentLocale() async {
    final String systemLocale = await findSystemLocale();
    MessagePrinter.info("The system locale is $systemLocale");
    return _toLocale(systemLocale);
  }

  Locale _toLocale(final String locale) {
    final List<String> systemLocaleSplitted = locale.split(LOCALE_SEPARATOR);
    final bool noCountryCode = systemLocaleSplitted.length == 1;
    return Locale(systemLocaleSplitted.first,
        noCountryCode ? null : systemLocaleSplitted.last);
  }
}
