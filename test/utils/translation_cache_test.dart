import 'package:flutter_i18n/utils/translation_cache.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  group('TranslationCache', () {
    late TranslationCache translationCache;

    setUp(() {
      translationCache = TranslationCache();
    });

    test('should be empty initially', () {
      expect(translationCache.cache.isEmpty, isTrue);
    });

    test('should return false for non-existent locale', () {
      var result = translationCache.hasLocale('en');
      expect(result, isFalse);
    });

    test('should return null for getLocale on non-existent locale', () {
      var result = translationCache.getLocale('en');
      expect(result, isNull);
    });

    test('should set and get locale data correctly', () {
      var localeData = {'hello': 'Hello'};
      translationCache.setLocale('en', localeData);

      expect(translationCache.hasLocale('en'), isTrue);
      expect(translationCache.getLocale('en'), equals(localeData));
    });

    test('should override existing locale data', () {
      translationCache.setLocale('en', {'hello': 'Hello'});
      var newLocaleData = {'hello': 'Bonjour'};
      translationCache.setLocale('en', newLocaleData);

      expect(translationCache.getLocale('en'), equals(newLocaleData));
    });

    test('should handle setting null locale data', () {
      translationCache.setLocale('en', null);
      expect(translationCache.getLocale('en'), isNotNull);
      expect(translationCache.getLocale('en')!.isEmpty, isTrue);
    });

    test('should handle multiple locales', () {
      translationCache.setLocale('en', {'hello': 'Hello'});
      translationCache.setLocale('fr', {'hello': 'Bonjour'});

      expect(translationCache.hasLocale('en'), isTrue);
      expect(translationCache.hasLocale('fr'), isTrue);
      expect(translationCache.getLocale('en'), equals({'hello': 'Hello'}));
      expect(translationCache.getLocale('fr'), equals({'hello': 'Bonjour'}));
    });

    test('should return null for getLocale on cleared locale', () {
      translationCache.setLocale('en', {'hello': 'Hello'});
      translationCache.setLocale('en', null);

      expect(translationCache.getLocale('en'), isNotNull);
      expect(translationCache.getLocale('en')!.isEmpty, isTrue);
    });
  });
}
