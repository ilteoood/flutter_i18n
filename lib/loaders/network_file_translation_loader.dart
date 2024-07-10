import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/decoders/base_decode_strategy.dart';
import 'package:http/http.dart' as http;

import 'file_translation_loader.dart';

/// Loads translations from the remote resource
class NetworkFileTranslationLoader extends FileTranslationLoader {
  final Uri baseUri;

  NetworkFileTranslationLoader(
      {required Uri this.baseUri,
      Locale? forcedLocale,
      String fallbackFile = "en",
      String separator = "_",
      bool useCountryCode = false,
      bool useScriptCode = false,
      List<BaseDecodeStrategy>? decodeStrategies})
      : super(
            fallbackFile: fallbackFile,
            separator: separator,
            useCountryCode: useCountryCode,
            forcedLocale: forcedLocale,
            decodeStrategies: decodeStrategies);

  /// Load the file using an http client
  @override
  Future<String> loadString(
      final String fileName, final String extension) async {
    final resolvedUri = resolveUri(fileName, extension);
    final result = await http.get(resolvedUri);
    return result.body;
  }

  Uri resolveUri(final String fileName, final String extension) {
    final fileToFind = '$fileName.$extension';
    return this.baseUri.replace(path: '${this.baseUri.path}/$fileToFind');
  }
}
