import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/utils/translation_loader.dart';

class FlutterI18n {
  static RegExp _parameterRegexp = new RegExp("{(.+)}");
  final bool _useCountryCode;
  final String _fallbackFile;
  final String _basePath;
  Locale forcedLocale;

  Locale locale;

  Map<dynamic, dynamic> decodedMap;

  FlutterI18n(this._useCountryCode,
      [this._fallbackFile, this._basePath, this.forcedLocale]);

  Future<bool> load() async {
    final TranslationLoader translationLoader = TranslationLoader(
        this._fallbackFile,
        this._basePath,
        this._useCountryCode,
        this.forcedLocale);
    decodedMap = await translationLoader.load();
    return true;
  }

  static String plural(final BuildContext context, final String translationKey,
      final int pluralValue) {
    final FlutterI18n currentInstance = _retrieveCurrentInstance(context);
    final Map<dynamic, dynamic> decodedSubMap =
        _calculateSubmap(currentInstance.decodedMap, translationKey);
    final String correctKey =
        _findCorrectKey(decodedSubMap, translationKey, pluralValue);
    final String parameterName =
        _findParameterName(decodedSubMap[correctKey.split(".").last]);
    return translate(context, correctKey,
        translationParams:
            Map.fromIterables([parameterName], [pluralValue.toString()]));
  }

  static String _findCorrectKey(Map<dynamic, dynamic> decodedSubMap,
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

  static Map<dynamic, dynamic> _calculateSubmap(
      Map<dynamic, dynamic> decodedMap, final String translationKey) {
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
    if (translation != null && _parameterRegexp.hasMatch(translation)) {
      final Match match = _parameterRegexp.firstMatch(translation);
      parameterName = match.groupCount > 0 ? match.group(1) : "";
    }
    return parameterName;
  }

  static Future refresh(
      final BuildContext context, final Locale forcedLocale) async {
    final FlutterI18n currentInstance = _retrieveCurrentInstance(context);
    currentInstance.forcedLocale = forcedLocale;
    await currentInstance.load();
  }

  static String translate(final BuildContext context, final String key,
      {final String fallbackKey, final Map<String, String> translationParams}) {
    String translation = _translateWithKeyFallback(context, key, fallbackKey);
    if (translationParams != null) {
      translation = _replaceParams(translation, translationParams);
    }
    return translation;
  }

  static Locale currentLocale(final BuildContext context) {
    return _retrieveCurrentInstance(context).locale;
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
      final BuildContext context, final String key, final String fallbackKey) {
    final Map<dynamic, dynamic> decodedStrings =
        _retrieveCurrentInstance(context).decodedMap;
    return [
      _decodeFromMap(decodedStrings, key),
      _decodeFromMap(decodedStrings, fallbackKey ?? ""),
      fallbackKey,
      key
    ].firstWhere((translation) => translation != null);
  }

  static FlutterI18n _retrieveCurrentInstance(BuildContext context) {
    return Localizations.of<FlutterI18n>(context, FlutterI18n);
  }

  static String _decodeFromMap(
      Map<dynamic, dynamic> decodedStrings, final String key) {
    final Map<dynamic, dynamic> subMap = _calculateSubmap(decodedStrings, key);
    final String lastKeyPart = key.split(".").last;
    return subMap[lastKeyPart];
  }
}
