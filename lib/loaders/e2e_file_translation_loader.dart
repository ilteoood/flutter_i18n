import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'file_translation_loader.dart';

class _CustomAssetBundle extends PlatformAssetBundle {
  Future<String> loadString(String key, {bool cache = true}) async {
    final ByteData data = await load(key);
    if (data == null) throw FlutterError('Unable to load asset: $key');

    return utf8.decode(data.buffer.asUint8List());
  }
}

class E2EFileTranslationLoader extends FileTranslationLoader {
  final bool useE2E;

  AssetBundle customAssetBundle = _CustomAssetBundle();

  E2EFileTranslationLoader(
      {forcedLocale,
      fallbackFile = "en",
      basePath = "assets/flutter_i18n",
      useCountryCode = false,
      this.useE2E = true,
      decodeStrategies})
      : super(
            fallbackFile: fallbackFile,
            basePath: basePath,
            useCountryCode: useCountryCode,
            forcedLocale: forcedLocale,
            decodeStrategies: decodeStrategies);

  Future<String> loadString(final String fileName, final String extension) {
    return useE2E
        ? customAssetBundle.loadString('$basePath/$fileName.$extension')
        : super.loadString(fileName, extension);
  }
}
