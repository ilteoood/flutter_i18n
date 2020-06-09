import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/decoders/base_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/xml_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/yaml_decode_strategy.dart';
import 'package:flutter_i18n/loaders/file_content.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';
import "package:merge_map/merge_map.dart";

import '../utils/message_printer.dart';

class FileTranslationLoader extends TranslationLoader implements IFileContent {
  final String fallbackFile;
  final String basePath;
  final bool useCountryCode;
  AssetBundle assetBundle;
  List<BaseDecodeStrategy> decodeStrategies;

  Map<dynamic, dynamic> _decodedMap = Map();

  FileTranslationLoader({
    this.fallbackFile = "en",
    this.basePath = "assets/flutter_i18n",
    this.useCountryCode = false,
    forcedLocale,
    decodeStrategies,
  }) {
    this.forcedLocale = forcedLocale;
    assetBundle = rootBundle;
    this.decodeStrategies = decodeStrategies ??
        [JsonDecodeStrategy(), YamlDecodeStrategy(), XmlDecodeStrategy()];
  }

  Future<Map> load() async {
    _decodedMap = Map();
    await _loadCurrentTranslation();
    await _loadFallback();
    return _decodedMap;
  }

  @override
  Future<String> loadString(final String fileName, final String extension) {
    return assetBundle.loadString('$basePath/$fileName.$extension');
  }

  Future _loadCurrentTranslation() async {
    try {
      this.locale = locale ?? await findDeviceLocale();
      MessagePrinter.info("The current locale is ${this.locale}");
      _decodedMap.addAll(await loadFile(composeFileName()));
    } catch (e) {
      MessagePrinter.debug('Error loading translation $e');
    }
  }

  Future _loadFallback() async {
    try {
      final Map fallbackMap = await loadFile(fallbackFile);
      _decodedMap = mergeMap([fallbackMap, _decodedMap]);
    } catch (e) {
      MessagePrinter.debug('Error loading translation fallback $e');
    }
  }

  @protected
  Future<Map> loadFile(final String fileName) async {
    final List<Future<Map>> strategiesFutures = _executeStrategies(fileName);
    final Stream<Map> strategiesStream = Stream.fromFutures(strategiesFutures);
    return strategiesStream.firstWhere((map) => map != null);
  }

  List<Future<Map>> _executeStrategies(final String fileName) {
    return decodeStrategies
        .map((decodeStrategy) => decodeStrategy.decode(fileName, this))
        .toList();
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
