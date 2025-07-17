import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/decoders/base_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/toml_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/xml_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/yaml_decode_strategy.dart';
import 'package:flutter_i18n/loaders/file_content.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';

import '../utils/message_printer.dart';

/// Loads translation files from JSON, YAML or XML format
class FileTranslationLoader extends TranslationLoader implements IFileContent {
  final String? fallbackFile;
  final String basePath;
  final String separator;
  final bool useCountryCode;
  final bool useScriptCode;
  AssetBundle assetBundle = rootBundle;

  Map<dynamic, dynamic> _decodedMap = Map();
  late List<BaseDecodeStrategy> _decodeStrategies;

  set decodeStrategies(List<BaseDecodeStrategy>? decodeStrategies) =>
      _decodeStrategies = decodeStrategies ??
          [
            JsonDecodeStrategy(),
            YamlDecodeStrategy(),
            XmlDecodeStrategy(),
            TomlDecodeStrategy()
          ];

  FileTranslationLoader(
      {String? this.fallbackFile = "en",
      String this.basePath = "assets/flutter_i18n",
      String this.separator = "_",
      bool this.useCountryCode = true,
      bool this.useScriptCode = true,
      Locale? forcedLocale,
      List<BaseDecodeStrategy>? decodeStrategies}) {
    this.forcedLocale = forcedLocale;
    this.decodeStrategies = decodeStrategies;
  }

  /// Return the translation Map
  Future<Map> load() async {
    _decodedMap = Map();
    await this._defineLocale();
    
    final candidateFiles = generateLocaleCandidates();
    Map<dynamic, dynamic> loadedMap = Map();
    
    for (final candidateFile in candidateFiles) {
      final translationMap = await _loadTranslation(candidateFile, false);
      if (translationMap.isNotEmpty) {
        loadedMap = _deepMergeMaps(translationMap, loadedMap);
        MessagePrinter.debug('Loaded translation file: $candidateFile');
      }
    }
    
    if (fallbackFile != null && !candidateFiles.contains(fallbackFile)) {
      final Map fallbackMap = await _loadTranslation(fallbackFile!, true);
      loadedMap = _deepMergeMaps(fallbackMap, loadedMap);
      MessagePrinter.debug('Fallback maps have been merged');
    }
    
    _decodedMap = loadedMap;
    return _decodedMap;
  }

  /// Load the file using the AssetBundle rootBundle
  @override
  Future<String> loadString(final String fileName, final String extension) {
    return assetBundle.loadString('$basePath/$fileName.$extension',
        cache: false);
  }

  Future<Map<dynamic, dynamic>> _loadTranslation(String fileName, bool isFallback) async {
    try {
      return await loadFile(fileName);
    } catch (e) {
      if (isFallback) {
        MessagePrinter.debug('Error loading fallback translation $fileName: $e');
      } else {
        MessagePrinter.debug('Translation file $fileName not found, trying next candidate');
      }
    }
    return Map();
  }

  Future _defineLocale() async {
    this.locale = locale ?? await findDeviceLocale();
    MessagePrinter.info("The current locale is ${this.locale}");
  }

  Map<K, V> _deepMergeMaps<K, V>(
    Map<K, V> map1,
    Map<K, V> map2,
  ) {
    var result = Map<K, V>.of(map1);

    map2.forEach((key, mapValue) {
      var p1 = result[key] as V;
      var p2 = mapValue;

      V mapResult;
      if (result.containsKey(key)) {
        if (p1 is Map && p2 is Map) {
          Map map1 = p1;
          Map map2 = p2;
          mapResult = _deepMergeMaps(map1, map2) as V;
        } else {
          mapResult = p2;
        }
      } else {
        mapResult = mapValue;
      }

      result[key] = mapResult;
    });
    return result;
  }

  /// Load the fileName using one of the strategies provided
  @protected
  Future<Map> loadFile(final String fileName) async {
    final List<Future<Map?>> strategiesFutures = _executeStrategies(fileName);
    final Stream<Map?> strategiesStream = Stream.fromFutures(strategiesFutures);
    return await strategiesStream.firstWhere((map) => map != null,
            orElse: null) ??
        Map();
  }

  List<Future<Map?>> _executeStrategies(final String fileName) {
    return _decodeStrategies
        .map((decodeStrategy) => decodeStrategy.decode(fileName, this))
        .toList();
  }

  /// Generate a list of locale candidate files in fallback order
  @protected
  List<String> generateLocaleCandidates() {
    final candidates = <String>[];
    final locale = this.locale!;
    
    // Most specific: language + script + country (e.g., "zh_Hans_CN")
    if (useScriptCode && useCountryCode && 
        locale.scriptCode != null && locale.countryCode != null) {
      candidates.add("${locale.languageCode}${separator}${locale.scriptCode}${separator}${locale.countryCode}");
    }
    
    // Language + country (e.g., "en_US", "de_DE")
    if (useCountryCode && locale.countryCode != null) {
      candidates.add("${locale.languageCode}${separator}${locale.countryCode}");
    }
    
    // Language + script (e.g., "zh_Hans")
    if (useScriptCode && locale.scriptCode != null) {
      candidates.add("${locale.languageCode}${separator}${locale.scriptCode}");
    }
    
    // Base language (e.g., "en", "de", "zh")
    candidates.add(locale.languageCode);
    
    return candidates;
  }

  /// Compose the file name using the format languageCode_countryCode
  @protected
  String composeFileName() {
    return "${locale!.languageCode}${_composeSuffixCode()}";
  }

  /// Return the country code to attach to the file name, if required
  @protected
  String _composeSuffixCode() {
    String countryCode = "";
    if (useScriptCode && locale!.scriptCode != null) {
      countryCode = "${countryCode}${separator}${locale!.scriptCode}";
    }
    if (useCountryCode && locale!.countryCode != null) {
      countryCode = "${countryCode}${separator}${locale!.countryCode}";
    }
    return countryCode;
  }
}
