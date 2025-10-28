import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/decoders/base_decode_strategy.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_i18n/utils/message_printer.dart';

/// Loads translations from separate files
class NamespaceFileTranslationLoader extends FileTranslationLoader {
  final String fallbackDir;
  final List<String>? namespaces;
  @override
  AssetBundle assetBundle = rootBundle;

  final Map<dynamic, dynamic> _decodedMap = {};

  NamespaceFileTranslationLoader(
      {required this.namespaces,
      this.fallbackDir = "en",
      String basePath = "assets/flutter_i18n",
      String separator = "_",
      bool useCountryCode = false,
      bool useScriptCode = false,
      Locale? forcedLocale,
      List<BaseDecodeStrategy>? decodeStrategies})
      : super(
            basePath: basePath,
            separator: separator,
            useCountryCode: useCountryCode,
            useScriptCode: useScriptCode,
            forcedLocale: forcedLocale,
            decodeStrategies: decodeStrategies) {
    assert(namespaces != null);
    assert(namespaces!.isNotEmpty);
  }

  /// Return the translation Map for the namespace
  @override
  Future<Map> load() async {
    locale = locale ?? await findDeviceLocale();
    MessagePrinter.info("The current locale is $locale");

    await Future.wait(
        namespaces!.map((namespace) => _loadTranslation(namespace)));

    return _decodedMap;
  }

  Future<void> _loadTranslation(String namespace) async {
    _decodedMap[namespace] = {};

    try {
      _decodedMap[namespace] =
          await loadFile("${composeFileName()}/$namespace");
    } catch (e) {
      MessagePrinter.debug('Error loading translation $e');
      await _loadTranslationFallback(namespace);
    }
  }

  Future<void> _loadTranslationFallback(String namespace) async {
    try {
      _decodedMap[namespace] = await loadFile("$fallbackDir/$namespace");
    } catch (e) {
      MessagePrinter.debug('Error loading translation fallback $e');
    }
  }
}
