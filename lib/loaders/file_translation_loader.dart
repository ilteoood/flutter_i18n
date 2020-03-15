import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';
import 'package:yaml/yaml.dart';

import '../utils/message_printer.dart';

class FileTranslationLoader extends TranslationLoader {
  final String fallbackFile;
  final String basePath;
  final bool useCountryCode;
  final Locale forcedLocale;
  AssetBundle assetBundle;

  Locale _locale;

  @override
  Locale get locale => _locale ?? forcedLocale;

  @override
  set locale(Locale locale) => _locale = locale;

  Map<dynamic, dynamic> _decodedMap;

  FileTranslationLoader(
      {this.fallbackFile = "en",
      this.basePath = "assets/flutter_i18n",
      this.useCountryCode = false,
      this.forcedLocale}) {
    assetBundle = rootBundle;
  }

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
    return assetBundle.loadString('$basePath/$fileName.$extension');
  }

  Future _loadCurrentTranslation() async {
    this.locale = locale ?? await findCurrentLocale();
    MessagePrinter.info("The current locale is ${this.locale}");
    _decodedMap = await loadFile(composeFileName());
  }

  Future _loadFallback() async {
    try {
      _decodedMap = await loadFile(fallbackFile);
    } catch (e) {
      MessagePrinter.debug('Error loading translation fallback $e');
      _decodedMap = Map();
    }
  }

  Future<Map> loadFile(final String fileName) async {
    try {
      var data = await _decodeFile(fileName, 'json', json.decode);
      MessagePrinter.info("JSON file loaded for $fileName");
      return data;
    } on Error catch (_) {
      MessagePrinter.debug(
          "Unable to load JSON file for $fileName, I'm trying with YAML");
      var data = await _decodeFile(fileName, 'yaml', loadYaml);
      MessagePrinter.info("YAML file loaded for $fileName");
      return data;
    }
  }

  Future<Map> _decodeFile(final String fileName, final String extension,
      final Function decodeFunction) async {
    return loadString(fileName, extension)
        .then((fileContent) => decodeFunction(fileContent));
  }

  @protected
  String composeFileName() {
    return "${locale.languageCode}${composeCountryCode()}";
  }

  @protected
  String composeCountryCode() {
    String countryCode = "";
    if (useCountryCode && locale.countryCode != null) {
      countryCode = "_${locale.countryCode}";
    }
    return countryCode;
  }
}
