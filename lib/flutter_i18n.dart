import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:intl/intl_standalone.dart';

class FlutterI18n {
  static const String TRANSLATIONS_BASE_PATH = "assets/flutter_i18n";
  final bool _useCountryCode;
  final String _fallbackFile;

  Locale locale;

  Map<String, dynamic> decodedMap;

  FlutterI18n(this._useCountryCode, [this._fallbackFile]);

  Future<bool> load() async {
    try {
      await _loadCurrentTranslation();
    } catch (e) {
      await _loadFallback();
    }
    return true;
  }

  Future _loadCurrentTranslation([final Locale locale]) async {
    this.locale = locale != null ? locale : await _findCurrentLocale();
    await _loadFile(_composeFileName());
  }

  Future _loadFallback() async {
    try {
      await _loadFile(_fallbackFile);
    } catch (e) {
      decodedMap = Map();
    }
  }

  Future _loadFile(final String fileName) async {
    var localeString =
        await rootBundle.loadString('$TRANSLATIONS_BASE_PATH/$fileName.json');
    decodedMap = json.decode(localeString);
  }

  Future<Locale> _findCurrentLocale() async {
    final String systemLocale = await findSystemLocale();
    final List<String> systemLocaleSplitted = systemLocale.split("_");
    return Future(
        () => Locale(systemLocaleSplitted[0], systemLocaleSplitted[1]));
  }

  static Future refresh(final BuildContext context, final String languageCode,
      {final String countryCode}) async {
    final Locale forcedLocale = new Locale(languageCode, countryCode);
    final FlutterI18n currentInstance = retrieveCurrentInstance(context);
    await currentInstance._loadCurrentTranslation(forcedLocale);
  }

  static String translate(final BuildContext context, final String key,
      [final Map<String, String> translationParams]) {
    String translation = _translateWithKeyFallback(context, key);
    if (translationParams != null) {
      translation = _replaceParams(translation, translationParams);
    }
    return translation;
  }

  static String _replaceParams(
      String translation, final Map<String, String> translationParams) {
    for (final String paramKey in translationParams.keys) {
      translation = translation.replaceAll(
          new RegExp('{$paramKey}'), translationParams[paramKey]);
    }
    return translation;
  }

  static String _translateWithKeyFallback(BuildContext context, String key) {
    final Map<String, dynamic> decodedStrings =
        retrieveCurrentInstance(context).decodedMap;
    final List<String> splittedKey = key.split(".");
    String translation = _decodeFromMap(decodedStrings, splittedKey);
    if (translation == null) {
      translation = key;
    }
    return translation;
  }

  static FlutterI18n retrieveCurrentInstance(BuildContext context) {
    return Localizations.of<FlutterI18n>(context, FlutterI18n);
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
    return null;
  }

  String _composeFileName() {
    return "${locale.languageCode}${_composeCountryCode()}";
  }

  String _composeCountryCode() {
    String countryCode = "";
    if (_useCountryCode && locale.countryCode != null) {
      countryCode = "_${locale.countryCode}";
    }
    return countryCode;
  }
}
