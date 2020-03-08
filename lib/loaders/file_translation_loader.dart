import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';
import 'package:intl/intl_standalone.dart';
import 'package:yaml/yaml.dart';

import '../utils/message_printer.dart';

class FileTranslationLoader extends TranslationLoader {
  final String fallbackFile;
  final String basePath;
  final bool useCountryCode;
  final Locale forcedLocale;

  Locale _locale;

  get locale => _locale ?? forcedLocale;

  set locale(Locale locale) => _locale = locale;

  Map<dynamic, dynamic> _decodedMap;

  FileTranslationLoader(
      {this.fallbackFile = "en",
      this.basePath = "assets/flutter_i18n",
      this.useCountryCode = false,
      this.forcedLocale});

  Future<Map> load() async {
    try {
      await _loadCurrentTranslation();
    } catch (e) {
      MessagePrinter.debug('Error loading translation $e');
      await _loadFallback();
    }
    return _decodedMap;
  }

  Future<String> loadString(final String fileName, final String extension) {
    return rootBundle.loadString('$basePath/$fileName.$extension');
  }

  Future _loadCurrentTranslation() async {
    this.locale = locale ?? await _findCurrentLocale();
    MessagePrinter.info("The current locale is ${this.locale}");
    await _loadFile(_composeFileName());
  }

  Future _loadFallback() async {
    try {
      await _loadFile(fallbackFile);
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
      MessagePrinter.info("YAML file loaded for $fileName");
    }
  }

  Future<void> _decodeFile(final String fileName, final String extension,
      final Function decodeFunction) async {
    _decodedMap = await loadString(fileName, extension)
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
