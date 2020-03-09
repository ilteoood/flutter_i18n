import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
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
  _CustomAssetBundle customAssetBundle = _CustomAssetBundle();

  E2EFileTranslationLoader(
      {fallbackFile, basePath, useCountryCode, forcedLocale})
      : super(
          fallbackFile: fallbackFile,
          basePath: basePath,
          useCountryCode: useCountryCode,
          forcedLocale: forcedLocale,
        );

  Future<String> loadString(final String fileName, final String extension) {
    return customAssetBundle.loadString('$basePath/$fileName.$extension');
  }
}
