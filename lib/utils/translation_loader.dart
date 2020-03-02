import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:intl/intl_standalone.dart';
import 'package:yaml/yaml.dart';

import './message_printer.dart';

class TranslationLoader {
  final String _fallbackFile;
  final String _basePath;
  final bool _useCountryCode;
  final Locale _forcedLocale;
  Locale _locale;
  Map<dynamic, dynamic> _decodedMap;

  TranslationLoader(
      [this._fallbackFile,
      this._basePath,
      this._useCountryCode,
      this._forcedLocale]);

  Future<Map> load() async {
    try {
      await _loadCurrentTranslation(this._forcedLocale);
    } catch (e) {
      MessagePrinter.debug('Error loading translation $e');
      await _loadFallback();
    }
    return _decodedMap;
  }

  Future _loadCurrentTranslation(final Locale locale) async {
    this._locale = locale != null ? locale : await _findCurrentLocale();
    MessagePrinter.info("The current locale is ${this._locale}");
    await _loadFile(_composeFileName());
  }

  Future _loadFallback() async {
    try {
      await _loadFile(_fallbackFile);
    } catch (e) {
      MessagePrinter.debug('Error loading translation fallback $e');
      _decodedMap = Map();
    }
  }

  Future<void> _loadFile(final String fileName) async {
    try {
      await _decodeFile(fileName, 'json', json.decode);
      MessagePrinter.info("JSON file loaded for $fileName");
    } on Error catch (_) {
      MessagePrinter.debug(
          "Unable to load JSON file for $fileName, I'm trying with YAML");
      await _decodeFile(fileName, 'yaml', loadYaml);
    }
  }

  Future<void> _decodeFile(final String fileName, final String extension,
      final Function decodeFunction) async {
    _decodedMap = await rootBundle
        .loadString('$_basePath/$fileName.$extension')
        .then((fileContent) => decodeFunction(fileContent));
  }

  Future<Locale> _findCurrentLocale() async {
    final String systemLocale = await findSystemLocale();
    MessagePrinter.info("The system locale is $systemLocale");
    final List<String> systemLocaleSplitted = systemLocale.split("_");
    final int countryCodeIndex = systemLocaleSplitted.length == 3 ? 2 : 1;
    return Future(() => Locale(
        systemLocaleSplitted[0], systemLocaleSplitted[countryCodeIndex]));
  }

  String _composeFileName() {
    return "${_locale.languageCode}${_composeCountryCode()}";
  }

  String _composeCountryCode() {
    String countryCode = "";
    if (_useCountryCode && _locale.countryCode != null) {
      countryCode = "_${_locale.countryCode}";
    }
    return countryCode;
  }
}
