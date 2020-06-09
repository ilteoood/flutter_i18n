import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_i18n/utils/message_printer.dart';

class NamespaceFileTranslationLoader extends FileTranslationLoader {
  final String fallbackDir;
  final String basePath;
  final bool useCountryCode;
  final List<String> namespaces;
  AssetBundle assetBundle;

  Map<dynamic, dynamic> _decodedMap = {};

  NamespaceFileTranslationLoader({
    @required this.namespaces,
    this.fallbackDir = "en",
    this.basePath = "assets/flutter_i18n",
    this.useCountryCode = false,
    forcedLocale,
    decodeStrategies,
  }) : super(decodeStrategies: decodeStrategies) {
    assert(namespaces != null);
    assert(namespaces.length > 0);
    this.forcedLocale = forcedLocale;
    assetBundle = rootBundle;
  }

  Future<Map> load() async {
    this.locale = locale ?? await findDeviceLocale();
    MessagePrinter.info("The current locale is ${this.locale}");

    await Future.wait(
        namespaces.map((namespace) => _loadTranslation(namespace)));

    return _decodedMap;
  }

  Future<void> _loadTranslation(String namespace) async {
    _decodedMap[namespace] = Map();

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
