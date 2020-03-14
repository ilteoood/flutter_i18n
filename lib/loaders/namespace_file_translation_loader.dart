import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';
import 'package:flutter_i18n/utils/message_printer.dart';
import 'package:yaml/yaml.dart';

class NamespaceFileTranslationLoader extends TranslationLoader {
  final String fallbackDir;
  final String basePath;
  final bool useCountryCode;
  final Locale forcedLocale;
  final List<String> namespaces;
  AssetBundle assetBundle;

  Locale _locale;

  get locale => _locale ?? forcedLocale;

  set locale(Locale locale) => _locale = locale;

  Map<dynamic, dynamic> _decodedMap = {};

  NamespaceFileTranslationLoader(
      {@required this.namespaces,
      this.fallbackDir = "en",
      this.basePath = "assets/flutter_i18n",
      this.useCountryCode = false,
      this.forcedLocale}) {
    assetBundle = rootBundle;
  }

  Future<Map> load() async {
    await _loadTranslation();
    return _decodedMap;
  }

  Future<String> loadString(final String fileName, final String extension) {
    return assetBundle.loadString('$basePath/$fileName.$extension');
  }

  _loadTranslation() async {
    this.locale = locale ?? await findCurrentLocale();
    MessagePrinter.info("The current locale is ${this.locale}");

    for (var namespace in namespaces) {
      try {
        _decodedMap[namespace] =
            await _loadFile("${_composeDirName()}/$namespace");
      } catch (e) {
        MessagePrinter.debug('Error loading translation $e');
        try {
          _decodedMap[namespace] = await _loadFile("$fallbackDir/$namespace");
        } catch (e) {
          MessagePrinter.debug('Error loading translation fallback $e');
          _decodedMap[namespace] = Map();
        }
      }
    }
  }

  Future<Map> _loadFile(final String fileName) async {
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

  String _composeDirName() {
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
