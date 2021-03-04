import 'dart:async';

import 'package:flutter/services.dart';

import 'file_translation_loader.dart';

/// Loads translations from the remote resource
class NetworkFileTranslationLoader extends FileTranslationLoader {
  late AssetBundle networkAssetBundle;
  final Uri baseUri;

  NetworkFileTranslationLoader(
      {required this.baseUri,
      forcedLocale,
      fallbackFile = "en",
      useCountryCode = false,
      decodeStrategies})
      : super(
            fallbackFile: fallbackFile,
            useCountryCode: useCountryCode,
            forcedLocale: forcedLocale,
            decodeStrategies: decodeStrategies) {
    networkAssetBundle = NetworkAssetBundle(baseUri);
  }

  /// Load the file using the AssetBundle networkAssetBundle
  @override
  Future<String> loadString(final String fileName, final String extension) {
    return networkAssetBundle.loadString('$fileName.$extension');
  }
}
