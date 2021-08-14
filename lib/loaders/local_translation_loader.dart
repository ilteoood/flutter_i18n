import 'dart:io';

import 'package:flutter_i18n/loaders/file_translation_loader.dart';

class LocalTranslationLoader extends FileTranslationLoader {
  LocalTranslationLoader(
      {basePath = "assets/flutter_i18n",
      useCountryCode = false,
      useScriptCode = false,
      forcedLocale,
      decodeStrategies})
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
