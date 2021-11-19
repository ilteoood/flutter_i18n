import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'decoders/base_decode_strategy.dart';
import 'file_translation_loader.dart';

/// Try to loads translations from the remote resource. If offline or failed, then loads translation files from local path.
class NetworkOrFileTranslationLoader extends FileTranslationLoader {
  late final Uri _baseUri;
  late final bool _printLog;

  NetworkOrFileTranslationLoader(
      {required String basePath,
      required Uri baseUri,
      List<BaseDecodeStrategy>? decodeStrategies,
      String fallbackFile = 'en',
      Locale? forcedLocale,
      bool printLog = false,
      bool useCountryCode = false,
      bool useScriptCode = false})
      : super(
            basePath: basePath,
            decodeStrategies: decodeStrategies,
            fallbackFile: fallbackFile,
            forcedLocale: forcedLocale,
            useCountryCode: useCountryCode,
            useScriptCode: useScriptCode) {
    _baseUri = baseUri;
    _printLog = printLog;
  }

  @override
  Future<String> loadString(
      final String fileName, final String extension) async {
    try {
      final HttpClient httpClient = HttpClient();
      final HttpClientRequest request =
          await httpClient.getUrl(_baseUri.resolve('$fileName.$extension'));
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw Exception();
      }
      final Uint8List bytes =
          await consolidateHttpClientResponseBytes(response);
      final ByteData? data = bytes.buffer.asByteData();
      if (data == null) {
        throw Exception();
      }
      if (_printLog) {
        print('Using remote translation.');
      }
      // 50 KB of data should take 2-3 ms to parse on a Moto G4, and about 400 μs
      // on a Pixel 4.
      if (data.lengthInBytes < 50 * 1024) {
        return _utf8decode(data);
      }
      // For strings larger than 50 KB, run the computation in an isolate to
      // avoid causing main thread jank.
      return compute(_utf8decode, data,
          debugLabel: 'UTF8 decode for "$fileName.$extension"');
    } catch (exception) {
      if (_printLog) {
        print(exception.toString());
      }
    }
    if (_printLog) {
      print('Using local translation.');
    }
    return super.loadString(fileName, extension);
  }

  static String _utf8decode(ByteData data) {
    return utf8.decode(data.buffer.asUint8List());
  }
}
