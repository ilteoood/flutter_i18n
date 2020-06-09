import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'file_translation_loader.dart';

class NetworkFileTranslationLoader extends FileTranslationLoader {
  AssetBundle networkAssetBundle;
  final Uri baseUri;

  NetworkFileTranslationLoader({
    @required this.baseUri,
    forcedLocale,
    fallbackFile = "en",
    useCountryCode = false,
    decodeStrategies,
  }) : super(
          fallbackFile: fallbackFile,
          useCountryCode: useCountryCode,
          forcedLocale: forcedLocale,
          decodeStrategies: decodeStrategies,
        ) {
    networkAssetBundle = NetworkAssetBundle(baseUri);
  }

  @override
  Future<String> loadString(final String fileName, final String extension) {
    return networkAssetBundle.loadString('$fileName.$extension');
  }
}
