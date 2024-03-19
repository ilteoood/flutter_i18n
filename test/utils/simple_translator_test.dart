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

    test('should calculate substructure from key', () {
      final instance = SimpleTranslator(
        {
          'object': {
            'key1': 'value1',
          },
        },
        'object.key1',
        '.',
      );
      final substructure = instance.calculateSubStructure('object.key1');
      expect(
        substructure,
        {'key1': 'value1'},
      );
    });

    test('should calculate empty substructure from empty key', () {
      final instance = SimpleTranslator(
        null,
        'object.key1',
        '.',
      );
      final substructure = instance.calculateSubStructure('');
      expect(substructure, {});
    });

    test(
        'should return empty substructure when the value of nested key is not a Map or List',
        () {
      final instance = SimpleTranslator(
        {
          'object': {
            'key1': 'value1',
          },
        },
        'object.key1.key2',
        '.',
      );
      final subStructure = instance.calculateSubStructure('object.key1.key2');
      expect(subStructure, {});
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

  // additional tests
  test('should correctly handle a list item translation', () {
    final instance = SimpleTranslator(
      {
        'list': ['item0', 'item1', 'item2'],
      },
      'list.1',
      '.',
    );
    final translation = instance.translate();
    expect(translation, 'item1');
  });

  test('should return empty string for out of range index in a list', () {
    final instance = SimpleTranslator(
      {
        'list': ['item0', 'item1', 'item2'],
      },
      'list.3',
      '.',
      missingKeyTranslationHandler: (key) {},
    );
    final translation = instance.translate();
    expect(translation, 'list.3');
  });

  test('should handle nested maps correctly', () {
    final instance = SimpleTranslator(
      {
        'object': {
          'nested': {'key': 'value'},
        },
      },
      'object.nested.key',
      '.',
    );
    final translation = instance.translate();
    expect(translation, 'value');
  });

  test('should return empty map for invalid nested path in map', () {
    final instance = SimpleTranslator(
      {
        'object': {
          'nested': {'key': 'value'},
        },
      },
      'object.wrongKey.key',
      '.',
    );
    final subStructure = instance.calculateSubStructure('object.wrongKey.key');
    expect(subStructure, {});
  });

  test('should handle nested lists correctly', () {
    final instance = SimpleTranslator(
      {
        'list': [
          ['item00', 'item01'],
          ['item10', 'item11']
        ],
      },
      'list.1.0',
      '.',
    );
    final translation = instance.translate();
    expect(translation, 'item10');
  });

  test('should return empty map for invalid index in nested list', () {
    final instance = SimpleTranslator(
      {
        'list': [
          ['item00', 'item01'],
          ['item10', 'item11']
        ],
      },
      'list.2.1',
      '.',
      missingKeyTranslationHandler: (key) {},
    );
    final translation = instance.calculateSubStructure('list.2.1');
    expect(translation, {});
  });
}
