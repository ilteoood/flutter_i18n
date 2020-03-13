import 'package:flutter/widgets.dart';
import 'package:intl/intl_standalone.dart';

import '../utils/message_printer.dart';

abstract class TranslationLoader {
  Future<Map> load();

  Locale get locale;

  set locale(Locale locale);

  Future<Locale> findCurrentLocale() async {
    final String systemLocale = await findSystemLocale();
    MessagePrinter.info("The system locale is $systemLocale");
    final List<String> systemLocaleSplitted = systemLocale.split("_");
    final bool noCountryCode = systemLocaleSplitted.length == 1;
    return Future(() => Locale(systemLocaleSplitted.first,
        noCountryCode ? null : systemLocaleSplitted.last));
  }
}
