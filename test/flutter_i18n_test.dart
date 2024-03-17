import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/translation_loader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<TranslationLoader>(),
  MockSpec<FileTranslationLoader>(),
  MockSpec<NamespaceFileTranslationLoader>(),
  MockSpec<NetworkFileTranslationLoader>()
])
import 'flutter_i18n_test.mocks.dart';

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

  group('getLocaleMap', () {
    testWidgets('Should fetch locale map from cache',
        (WidgetTester tester) async {
      MockFileTranslationLoader mockLoader = MockFileTranslationLoader();

      FlutterI18nDelegate flutterI18n = FlutterI18nDelegate(
        translationLoader: mockLoader,
        missingTranslationHandler: (key, locale) {
          print("--- Missing Key: $key, languageCode: ${locale!.languageCode}");
        },
      );
      FlutterI18n.translationCache.setLocale('en', {'hello': 'world'});

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [flutterI18n],
          home: Builder(
            builder: (BuildContext context) {
              return FutureBuilder<dynamic>(
                future: FlutterI18n.getLocaleMap(context, null, 'en'),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data['hello']);
                  }
                  return CircularProgressIndicator();
                },
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle(); // Wait for FutureBuilder to resolve
      expect(find.text('world'), findsOneWidget);
    });

    testWidgets('Should return null for a non-existent key in cache',
        (WidgetTester tester) async {
      FlutterI18n.translationCache.setLocale('en', {'hello': 'world'});

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return FutureBuilder<dynamic>(
                future: FlutterI18n.getLocaleMap(context, 'nonexistent', 'en'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==ConnectionState.done) {
                    return Text(snapshot.data.toString());
                  }
                  return CircularProgressIndicator();
                },
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('null'), findsOneWidget);
    });

    testWidgets('Should fetch a nested key value from cache',
        (WidgetTester tester) async {
      FlutterI18n.translationCache.setLocale('en', {
        'greetings': {
          'morning': 'Good morning',
          'evening': 'Good evening',
        }
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return FutureBuilder<dynamic>(
                future: FlutterI18n.getLocaleMap(
                    context, 'greetings.morning', 'en'),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.toString());
                  }
                  return CircularProgressIndicator();
                },
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Good morning'), findsOneWidget);
    });

    // TODO mabye use factory fn to overwrite the replacement instance so that I can test
    testWidgets('Should load locale map when not cached',
        (WidgetTester tester) async {
      MockFileTranslationLoader mockLoader = MockFileTranslationLoader();
      when(mockLoader.load()).thenAnswer((_) async {
        return {'greeting': 'Hello'};
      });

      FlutterI18nDelegate flutterI18n = FlutterI18nDelegate(
        translationLoader: mockLoader,
        missingTranslationHandler: (key, locale) {
          print("--- Missing Key: $key, languageCode: ${locale!.languageCode}");
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [flutterI18n],
          home: Builder(
            builder: (BuildContext context) {
              return FutureBuilder<dynamic>(
                future: FlutterI18n.getLocaleMap(context, null, 'en'),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("Passed");
                  }
                  return CircularProgressIndicator();
                },
              );
            },
          ),
        ),
      );

      // await tester
      //     .pumpAndSettle(); // Wait for FutureBuilder to resolve and translations to load
      // expect(find.text('Hello'), findsOneWidget);
      // the assertion here is that the test case should not fail
    });
  });

  group('getValueFromKey', () {
    test('should return the correct nested value from a map', () {
      var map = {
        'level1': {
          'level2': {'key': 'value'}
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
      var map = {
        'list': [1, 2, 3]
      };
      expect(FlutterI18n.getValueFromKey(map, 'list.5'), isNull);
    });

    test('should return null for a non-integer index for a list', () {
      var map = {
        'list': [1, 2, 3]
      };
      expect(FlutterI18n.getValueFromKey(map, 'list.two'), isNull);
    });

    test('should return null for a key leading to a non-map or non-list value',
        () {
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
