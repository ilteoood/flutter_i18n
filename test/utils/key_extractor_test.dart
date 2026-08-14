import 'package:flutter_test/flutter_test.dart';

import '../../bin/utils/key_extractor.dart';

void main() {
  group('KeyExtractor', () {
    test('extracts keys from flat map', () {
      final map = {'title': 'Hello', 'subtitle': 'World'};
      final keys = KeyExtractor.extract(map);
      expect(keys, {'title', 'subtitle'});
    });

    test('extracts nested dotted keys', () {
      final map = {
        'home': {
          'title': 'Home',
          'nested': {'deep': 'Deep Value'},
        },
        'profile': {'name': 'Profile'},
      };
      final keys = KeyExtractor.extract(map);
      expect(keys, {
        'home.title',
        'home.nested.deep',
        'profile.name',
      });
    });

    test('extracts scalar leaf values (String, int, double, bool)', () {
      final map = {
        'title': 'Hello',
        'list': ['a', 'b'],
        'count': 42,
        'price': 9.99,
        'enabled': true,
        'nested': {'valid': 'OK', 'flag': false},
      };
      final keys = KeyExtractor.extract(map);
      expect(keys, {
        'title',
        'count',
        'price',
        'enabled',
        'nested.valid',
        'nested.flag',
      });
    });

    test('returns empty set for empty map', () {
      expect(KeyExtractor.extract({}), isEmpty);
    });

    test('skips List and Set but extracts scalar values from nested Maps', () {
      final map = {
        'a': [1, 2],
        'b': {'c': 3},
        'd': {1, 2, 3},
      };
      final keys = KeyExtractor.extract(map);
      expect(keys, {'b.c'});
    });
  });

  group('normalizePlural', () {
    test('strips plural suffix', () {
      expect(KeyExtractor.normalizePlural('clicked.times-0'), 'clicked.times');
      expect(KeyExtractor.normalizePlural('home.list-12'), 'home.list');
    });

    test('returns null for non-plural keys', () {
      expect(KeyExtractor.normalizePlural('home.title'), isNull);
      expect(KeyExtractor.normalizePlural('a-b-c'), isNull);
    });

    test('returns null for hyphen without numeric suffix', () {
      expect(KeyExtractor.normalizePlural('clicked.times-'), isNull);
      expect(KeyExtractor.normalizePlural('clicked.times-abc'), isNull);
    });

    test('returns null for large numeric suffix (non-plural)', () {
      expect(KeyExtractor.normalizePlural('error-404'), isNull);
      expect(KeyExtractor.normalizePlural('section-100'), isNull);
    });

    test('allows custom maxSuffix', () {
      expect(
          KeyExtractor.normalizePlural('error-404', maxSuffix: 999), 'error');
    });
  });

  test('skips null values', () {
    final map = {
      'title': 'Hello',
      'nullable': null,
      'nested': {'valid': 'OK', 'alsoNull': null},
    };
    final keys = KeyExtractor.extract(map);
    expect(keys, {'title', 'nested.valid'});
  });
}
