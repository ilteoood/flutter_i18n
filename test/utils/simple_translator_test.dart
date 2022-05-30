import 'package:flutter_i18n/utils/simple_translator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimpleTranslator', () {
    test('should have initial values', () {
      final instance = SimpleTranslator(
        null,
        'object.key1',
        '.',
      );
      expect(instance.decodedMap, null);
      expect(instance.key, 'object.key1');
      expect(instance.keySeparator, '.');
    });

    test('should translate from decoded map', () {
      final instance = SimpleTranslator(
        {
          'object': {
            'key1': 'value1',
          },
        },
        'object.key1',
        '.',
      );
      final translation = instance.translate();
      expect(translation, 'value1');
    });

    test('should return key when value is missing in decoded map', () {
      final instance = SimpleTranslator(
        null,
        'object.key1',
        '.',
        missingKeyTranslationHandler: (key) {},
      );
      final translation = instance.translate();
      expect(translation, 'object.key1');
    });

    test('should calculate submap from key', () {
      final instance = SimpleTranslator(
        {
          'object': {
            'key1': 'value1',
          },
        },
        'object.key1',
        '.',
      );
      final submap = instance.calculateSubmap('object.key1');
      expect(
        submap,
        {'key1': 'value1'},
      );
    });

    test('should calculate empty submap from empty key', () {
      final instance = SimpleTranslator(
        null,
        'object.key1',
        '.',
      );
      final submap = instance.calculateSubmap('');
      expect(submap, {});
    });

    test('should return empty submap when the value of nested key is not a Map', () {
      final instance = SimpleTranslator(
        {
          'object': {
            'key1': 'value1',
          },
        },
        'object.key1.key2',
        '.',
      );
      final subMap = instance.calculateSubmap('object.key1.key2');
      expect(subMap, {});
    });

    test('should return key when the value of nested key is not a Map', () {
      final instance = SimpleTranslator(
        {
          'object': {
            'key1': 'value1',
          },
        },
        'object.key1.key2',
        '.',
        missingKeyTranslationHandler: (key) {},
      );
      final translation = instance.translate();
      expect(translation, 'object.key1.key2');
    });
  });
}
