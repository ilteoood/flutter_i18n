import 'dart:io';

import 'package:flutter_i18n/loaders/file_translation_loader.dart';

class LocalTranslationLoader extends FileTranslationLoader {
  LocalTranslationLoader(
      {basePath = "assets/flutter_i18n",
      useCountryCode = false,
      forcedLocale,
      decodeStrategies})
      : super(
            basePath: basePath,
            useCountryCode: useCountryCode,
            forcedLocale: forcedLocale,
            decodeStrategies: decodeStrategies);

  @override
  Future<String> loadString(final String fileName, final String extension) {
    return File('$basePath/$fileName.$extension').readAsString();
  }
}
