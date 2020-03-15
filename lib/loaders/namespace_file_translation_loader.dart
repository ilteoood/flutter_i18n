import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_i18n/utils/message_printer.dart';

class NamespaceFileTranslationLoader extends FileTranslationLoader {
  final String fallbackDir;
  final String basePath;
  final bool useCountryCode;
  final Locale forcedLocale;
  final List<String> namespaces;
  AssetBundle assetBundle;

  Map<dynamic, dynamic> _decodedMap = {};

  NamespaceFileTranslationLoader(
      {@required this.namespaces,
      this.fallbackDir = "en",
      this.basePath = "assets/flutter_i18n",
      this.useCountryCode = false,
      this.forcedLocale}) {
    assert(namespaces != null);
    assert(namespaces.length > 0);

    assetBundle = rootBundle;
  }

  Future<Map> load() async {
    this.locale = locale ?? await findCurrentLocale();
    MessagePrinter.info("The current locale is ${this.locale}");

    List<Future<void>> waitList =
        namespaces.map((namespace) => _loadTranslation(namespace)).toList();

    await Future.wait(waitList);

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
