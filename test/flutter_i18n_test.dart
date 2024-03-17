import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockTranslationLoader extends Mock implements TranslationLoader {}
void main() {
  const MethodChannel channel = MethodChannel('flutter_i18n');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // group('FlutterI18n getLocaleMap', () {
  //   late MockTranslationLoader mockTranslationLoader;
  //   late FlutterI18n flutterI18n;

  //   setUp(() {
  //     mockTranslationLoader = MockTranslationLoader();
  //     flutterI18n = FlutterI18n( mockTranslationLoader,".");
  //   });

  //   test('should retrieve the correct locale map', () async {
  //     when(mockTranslationLoader.load()).thenAnswer((_) async => {'hello': 'world'});
  //     await flutterI18n.load();
  //     var result = await FlutterI18n.getLocaleMap(BuildContext(), 'en');
  //     expect(result, containsPair('hello', 'world'));
  //   });

  //   // Add more tests to cover other scenarios, such as handling of different translation loaders,
  //   // behavior when locale code is null, and when the key is specified or null.
  // });

  group('getValueFromKey', () {
    test('should return the correct nested value from a map', () {
      var map = {
        'level1': {
          'level2': {
            'key': 'value'
          }
        }
      };
      expect(FlutterI18n.getValueFromKey(map, 'level1.level2.key'), 'value');
    });

    test('should return the correct value from a nested list', () {
      var map = {
        'list': [
          ['first', 'second'],
          ['third', 'fourth']
        ]
      };
      expect(FlutterI18n.getValueFromKey(map, 'list.1.0'), 'third');
    });

    test('should return null for non-existent key', () {
      var map = {'hello': 'world'};
      expect(FlutterI18n.getValueFromKey(map, 'nonexistent'), isNull);
    });

    test('should return null for out of bounds index in a list', () {
      var map = {'list': [1, 2, 3]};
      expect(FlutterI18n.getValueFromKey(map, 'list.5'), isNull);
    });

    test('should return null for a non-integer index for a list', () {
      var map = {'list': [1, 2, 3]};
      expect(FlutterI18n.getValueFromKey(map, 'list.two'), isNull);
    });

    test('should return null for a key leading to a non-map or non-list value', () {
      var map = {'hello': 'world'};
      expect(FlutterI18n.getValueFromKey(map, 'hello.world'), isNull);
    });

    test('should handle complex nested structures', () {
      var map = {
        'users': [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25},
          {'name': 'Charlie', 'age': 35}
        ]
      };
      expect(FlutterI18n.getValueFromKey(map, 'users.1.name'), 'Bob');
      expect(FlutterI18n.getValueFromKey(map, 'users.2.age'), 35);
    });

    test('should return null if the key is empty', () {
      var map = {'hello': 'world'};
      expect(FlutterI18n.getValueFromKey(map, ''), null);
    });


  });
}
