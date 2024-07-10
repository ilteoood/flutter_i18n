import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/decoders/base_decode_strategy.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';

class LocalTranslationLoader extends FileTranslationLoader {
  LocalTranslationLoader(
      {String basePath = "assets/flutter_i18n",
      bool useCountryCode = false,
      bool useScriptCode = false,
      Locale? forcedLocale,
      List<BaseDecodeStrategy>? decodeStrategies})
      : super(
            basePath: basePath,
            useCountryCode: useCountryCode,
            useScriptCode: useScriptCode,
            forcedLocale: forcedLocale,
            decodeStrategies: decodeStrategies);

  /// Load the file using the File class
  @override
  Future<String> loadString(final String fileName, final String extension) {
    return File('$basePath/$fileName.$extension').readAsString();
  }
}
