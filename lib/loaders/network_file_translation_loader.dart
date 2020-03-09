import 'dart:async';

import 'package:flutter/services.dart';

import 'file_translation_loader.dart';

class NetworkFileTranslationLoader extends FileTranslationLoader {
  NetworkAssetBundle networkAssetBundle;
  final Uri baseUri;

  NetworkFileTranslationLoader(
      {fallbackFile, this.baseUri, useCountryCode, forcedLocale})
      : super(
          fallbackFile: fallbackFile,
          useCountryCode: useCountryCode,
          forcedLocale: forcedLocale,
        ) {
    networkAssetBundle = NetworkAssetBundle(baseUri);
  }

  Future<String> loadString(final String fileName, final String extension) {
    return networkAssetBundle.loadString('$basePath/$fileName.$extension');
  }
}
