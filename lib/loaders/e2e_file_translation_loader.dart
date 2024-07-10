import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_i18n/loaders/decoders/base_decode_strategy.dart';
import 'package:flutter/widgets.dart';

import 'file_translation_loader.dart';

class _CustomAssetBundle extends PlatformAssetBundle {
  Future<String> loadString(String key, {bool cache = true}) async {
    final ByteData data = await load(key);
    return utf8.decode(data.buffer.asUint8List());
  }
}

/// Special loader for solving isolates problem with flutter drive
class E2EFileTranslationLoader extends FileTranslationLoader {
  final bool useE2E;

  AssetBundle customAssetBundle = _CustomAssetBundle();

  E2EFileTranslationLoader(
      {Locale? forcedLocale,
      String? fallbackFile = "en",
      String basePath = "assets/flutter_i18n",
      bool useCountryCode = false,
      bool this.useE2E = true,
      List<BaseDecodeStrategy>? decodeStrategies})
      : super(
            fallbackFile: fallbackFile,
            basePath: basePath,
            useCountryCode: useCountryCode,
            forcedLocale: forcedLocale,
            decodeStrategies: decodeStrategies);

  /// Method used to load string from the _CustomAssetBundle
  Future<String> loadString(final String fileName, final String extension) {
    return useE2E
        ? customAssetBundle.loadString('$basePath/$fileName.$extension')
        : super.loadString(fileName, extension);
  }
}
