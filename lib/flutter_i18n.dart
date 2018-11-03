import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:intl/intl_standalone.dart';

class FlutterI18n {
  static const String TRANSLATIONS_BASE_PATH = "assets/flutter_i18n";
  static RegExp parameterRegexp = new RegExp("{(.+)}");
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

  static String plural(final BuildContext context, final String translationKey,
      final int pluralValue) {
    final FlutterI18n currentInstance = _retrieveCurrentInstance(context);
    final Map<String, dynamic> decodedSubMap =
        _calculateSubmap(currentInstance.decodedMap, translationKey);
    final String correctKey =
        _findCorrectKey(decodedSubMap, translationKey, pluralValue);
    final String parameterName =
        _findParameterName(decodedSubMap[correctKey.split(".").last]);
    return translate(context, correctKey,
        Map.fromIterables([parameterName], [pluralValue.toString()]));
  }

  static String _findCorrectKey(Map<String, dynamic> decodedSubMap,
      String translationKey, final int pluralValue) {
    final List<String> splittedKey = translationKey.split(".");
    translationKey = splittedKey.removeLast();
    List<int> possiblePluralValues = decodedSubMap.keys
        .where((mapKey) => mapKey.startsWith(translationKey))
        .where((mapKey) => mapKey.split("-").length == 2)
        .map((mapKey) => int.tryParse(mapKey.split("-")[1]))
        .where((mapKeyPluralValue) => mapKeyPluralValue != null)
        .where((mapKeyPluralValue) => mapKeyPluralValue <= pluralValue)
        .toList();
    possiblePluralValues.sort();
    final String lastKeyPart =
        "$translationKey-${possiblePluralValues.length > 0 ? possiblePluralValues.last : ''}";
    splittedKey.add(lastKeyPart);
    return splittedKey.join(".");
  }

  static Map<String, dynamic> _calculateSubmap(
      Map<String, dynamic> decodedMap, final String translationKey) {
    final List<String> translationKeySplitted = translationKey.split(".");
    translationKeySplitted.removeLast();
    translationKeySplitted.forEach((listKey) => decodedMap =
        decodedMap != null && decodedMap[listKey] != null
            ? decodedMap[listKey]
            : new Map());
    return decodedMap;
  }

  static String _findParameterName(final String translation) {
    String parameterName = "";
    if (translation != null && parameterRegexp.hasMatch(translation)) {
      final Match match = parameterRegexp.firstMatch(translation);
      parameterName = match.groupCount > 0 ? match.group(1) : "";
    }
    return parameterName;
  }

  static Future refresh(final BuildContext context, final String languageCode,
      {final String countryCode}) async {
    final Locale forcedLocale = new Locale(languageCode, countryCode);
    final FlutterI18n currentInstance = _retrieveCurrentInstance(context);
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

  static String _translateWithKeyFallback(
      final BuildContext context, final String key) {
    final Map<String, dynamic> decodedStrings =
        _retrieveCurrentInstance(context).decodedMap;
    String translation = _decodeFromMap(decodedStrings, key);
    if (translation == null) {
      translation = key;
    }
    return translation;
  }

  static FlutterI18n _retrieveCurrentInstance(BuildContext context) {
    return Localizations.of<FlutterI18n>(context, FlutterI18n);
  }

  static String _decodeFromMap(
      Map<String, dynamic> decodedStrings, final String key) {
    final Map<String, dynamic> subMap = _calculateSubmap(decodedStrings, key);
    final String lastKeyPart = key.split(".").last;
    return subMap[lastKeyPart];
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
