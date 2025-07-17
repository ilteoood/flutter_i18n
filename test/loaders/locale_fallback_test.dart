import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_i18n/loaders/decoders/base_decode_strategy.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_asset_bundle_fallback.dart';

class TestableFileTranslationLoader extends FileTranslationLoader {
  TestableFileTranslationLoader({
    String? fallbackFile,
    String basePath = "assets/flutter_i18n",
    String separator = "_",
    bool useCountryCode = true,
    bool useScriptCode = true,
    Locale? forcedLocale,
    List<BaseDecodeStrategy>? decodeStrategies,
  }) : super(
    fallbackFile: fallbackFile,
    basePath: basePath,
    separator: separator,
    useCountryCode: useCountryCode,
    useScriptCode: useScriptCode,
    forcedLocale: forcedLocale,
    decodeStrategies: decodeStrategies,
  );

  @override
  List<String> generateLocaleCandidates() => super.generateLocaleCandidates();
}

void main() {
  group('LocaleFallback', () {
    test('should generate correct fallback candidates for de_DE', () {
      final loader = TestableFileTranslationLoader(
        useCountryCode: true,
        useScriptCode: true,
      );
      loader.locale = const Locale('de', 'DE');
      
      final candidates = loader.generateLocaleCandidates();
      
      expect(candidates, equals(['de_DE', 'de']));
    });

    test('should generate correct fallback candidates for en_AU', () {
      final loader = TestableFileTranslationLoader(
        useCountryCode: true,
        useScriptCode: true,
      );
      loader.locale = const Locale('en', 'AU');
      
      final candidates = loader.generateLocaleCandidates();
      
      expect(candidates, equals(['en_AU', 'en']));
    });

    test('should generate correct fallback candidates for zh_Hans_CN', () {
      final loader = TestableFileTranslationLoader(
        useCountryCode: true,
        useScriptCode: true,
      );
      loader.locale = const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      );
      
      final candidates = loader.generateLocaleCandidates();
      
      expect(candidates, equals(['zh_Hans_CN', 'zh_CN', 'zh_Hans', 'zh']));
    });

    test('should load with fallback hierarchy', () async {
      final loader = TestableFileTranslationLoader(
        useCountryCode: true,
        useScriptCode: false,
        fallbackFile: 'en',
      );
      loader.assetBundle = TestAssetBundleFallback();
      loader.locale = const Locale('de', 'DE');
      
      final result = await loader.load();
      
      expect(result['label'], equals('Deutsch'));
      expect(result['hello'], equals('Hello'));
    });
  });
}