import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:intl/intl_standalone.dart';

class FlutterI18n {
  static const String TRANSLATIONS_BASE_PATH = "assets/flutter_i18n";
  bool useCountryCode;

  Locale locale;

  Map<String, dynamic> decodedMap;

  FlutterI18n(this.useCountryCode);

  Future<bool> load() async {
    try {
      await _findCurrentLocale();
      var localeString = await rootBundle
          .loadString('$TRANSLATIONS_BASE_PATH/${_composeFileName()}.json');
      decodedMap = json.decode(localeString);
    } catch (e) {
      decodedMap = new Map();
    }
    return true;
  }

  void _findCurrentLocale() async {
    final String systemLocale = await findSystemLocale();
    final List<String> systemLocaleSplitted = systemLocale.split("_");
    this.locale = new Locale(systemLocaleSplitted[0], systemLocaleSplitted[1]);
  }

  static String translate(final BuildContext context, final String key) {
    final Map<String, dynamic> decodedStrings =
        Localizations.of<FlutterI18n>(context, FlutterI18n).decodedMap;
    final List<String> splittedKey = key.split(".");
    String translation = _decodeFromMap(decodedStrings, splittedKey);
    if (translation == null) {
      translation = key;
    }
    return translation;
  }

  static String _decodeFromMap(
      Map<String, dynamic> decodedStrings, final List<String> splittedKey) {
    for (final String keyPart in splittedKey) {
      final currentDecodedString = decodedStrings[keyPart];
      if (currentDecodedString == null)
        break;
      else if (currentDecodedString is String)
        return currentDecodedString;
      else
        decodedStrings = currentDecodedString;
    }
  }

  String _composeFileName() {
    return "${locale.languageCode}${_composeCountryCode()}";
  }

  String _composeCountryCode() {
    String countryCode = "";
    if (useCountryCode && locale.countryCode != null) {
      countryCode = "_${locale.countryCode}";
    }
    return countryCode;
  }
}
