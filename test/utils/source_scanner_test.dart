import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../bin/utils/source_scanner.dart';

void main() {
  late Directory tmpDir;
  late String libDir;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('source_scanner_test_');
    libDir = p.join(tmpDir.path, 'lib');
    Directory(libDir).createSync();
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  void writeDartFile(String name, String content) {
    File(p.join(libDir, name)).writeAsStringSync(content);
  }

  group('SourceScanner', () {
    test('finds FlutterI18n.translate with double quotes', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        void f(BuildContext context) {
          FlutterI18n.translate(context, "home.title");
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('home.title'));
      expect(result.dynamicRefs, isEmpty);
    });

    test('finds FlutterI18n.translate with single quotes', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        void f(BuildContext context) {
          FlutterI18n.translate(context, 'settings.general');
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('settings.general'));
    });

    test('finds FlutterI18n.plural', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        void f(BuildContext context) {
          FlutterI18n.plural(context, "clicked.times", n);
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('clicked.times'));
    });

    test('finds I18nText widget', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        Widget b() => I18nText("home.title");
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('home.title'));
    });

    test('finds I18nPlural widget', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        Widget b() => I18nPlural("clicked.times", 3);
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('clicked.times'));
    });

    test('finds fallbackKey', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        void f(BuildContext context) {
          FlutterI18n.translate(context, "home.new",
              fallbackKey: "common.ok");
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('home.new'));
      expect(result.literalKeys, contains('common.ok'));
    });

    test('handles import alias prefix', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart' as i18n;
        void f(BuildContext context) {
          i18n.FlutterI18n.translate(context, "home.title");
          i18n.I18nText("profile.name");
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('home.title'));
      expect(result.literalKeys, contains('profile.name'));
    });

    test('handles arbitrary import prefix', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart' as my_i18n;
        void f(BuildContext context) {
          my_i18n.FlutterI18n.plural(context, "items.count", 5);
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('items.count'));
    });

    test('skips commented-out calls', () {
      writeDartFile('a.dart', '''
        void f(BuildContext context) {
          // FlutterI18n.translate(context, "commented.key");
          FlutterI18n.translate(context, "active.key");
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('active.key'));
      expect(result.literalKeys, isNot(contains('commented.key')));
    });

    test('detects dynamic keys (variable reference)', () {
      writeDartFile('a.dart', '''
        void f(BuildContext context, String key) {
          FlutterI18n.translate(context, key);
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, isEmpty);
      expect(result.dynamicRefs, isNotEmpty);
      expect(result.dynamicRefs.first.lineContent,
          contains('FlutterI18n.translate(context, key)'));
    });

    test('detects dynamic keys (string interpolation)', () {
      writeDartFile('a.dart', '''
        void f(BuildContext context) {
          FlutterI18n.translate(context, "home.\\\${section}");
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, isEmpty);
      expect(result.dynamicRefs, isNotEmpty);
    });

    test('collects multiple keys from one file', () {
      writeDartFile('a.dart', '''
        void f(BuildContext c) {
          FlutterI18n.translate(c, "a.b");
          FlutterI18n.plural(c, "c.d", 1);
        }
        Widget g() => I18nText("e.f");
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, containsAll(['a.b', 'c.d', 'e.f']));
    });

    test('does not match unrelated names', () {
      writeDartFile('a.dart', '''
        void f() {
          SomeOther.translate("not.a.key");
          MyFlutterI18n.translate(ctx, "also.not");
          I18nSomething("wrong.widget");
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, isEmpty);
    });

    test('handles extra whitespace in calls', () {
      writeDartFile('a.dart', '''
        void f(BuildContext c) {
          FlutterI18n . translate ( c , "key.with.spaces" ) ;
          I18nText   (   "padded.key"   );
          FlutterI18n . plural (c, "plural.spaces", 1);
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys,
          containsAll(['key.with.spaces', 'padded.key', 'plural.spaces']));
    });

    test('includes file path and line in dynamic refs', () {
      writeDartFile('a.dart', '''
        void f(BuildContext c) {
          FlutterI18n.translate(c, dynamicVar);
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.dynamicRefs, hasLength(1));
      expect(result.dynamicRefs.first.filePath, endsWith('.dart'));
      expect(result.dynamicRefs.first.line, equals(2));
    });

    test('scans multiple files', () {
      writeDartFile('a.dart', '''
        void f(BuildContext c) { FlutterI18n.translate(c, "file.a.key"); }
      ''');
      writeDartFile('b.dart', '''
        Widget g() => I18nText("file.b.key");
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, containsAll(['file.a.key', 'file.b.key']));
    });

    test('handles // inside string literal (URL)', () {
      writeDartFile('a.dart', '''
        void f(BuildContext c) {
          FlutterI18n.translate(c, "http://example.com/title");
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('http://example.com/title'));
    });

    test('does not match key after // comment on same line', () {
      writeDartFile('a.dart', '''
        void f(BuildContext c) {
          FlutterI18n.translate(c, "live.key"); // FlutterI18n.translate(c, "dead.key")
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('live.key'));
      expect(result.literalKeys, isNot(contains('dead.key')));
    });

    test('scans dart files outside lib/ directory', () {
      final testDir = p.join(tmpDir.path, 'test');
      Directory(testDir).createSync();
      writeDartFile('a.dart', '''
        void f(BuildContext c) { FlutterI18n.translate(c, "lib.key"); }
      ''');
      File(p.join(testDir, 'b.dart')).writeAsStringSync('''
        void f(BuildContext c) { FlutterI18n.translate(c, "test.key"); }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, containsAll(['lib.key', 'test.key']));
    });

    test('extracts literal key from multi-line FlutterI18n.translate', () {
      writeDartFile('a.dart', '''
        void f(BuildContext c) {
          FlutterI18n.translate(
            c,
            "multi.line.key"
          );
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('multi.line.key'));
      expect(result.dynamicRefs, isEmpty);
    });

    test('captures multiple literal keys on same line', () {
      writeDartFile('a.dart', '''
        void f(BuildContext c) {
          I18nText("first.key"); I18nText("second.key");
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, containsAll(['first.key', 'second.key']));
    });

    test('finds fallbackKey with single quotes', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        void f(BuildContext context) {
          FlutterI18n.translate(context, "home.new",
              fallbackKey: 'common.ok');
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('home.new'));
      expect(result.literalKeys, contains('common.ok'));
    });

    test('extracts multiline I18nText key', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        Widget b() => I18nText(
          "multiline.widget.key"
        );
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('multiline.widget.key'));
    });

    test('extracts multiline I18nPlural key', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        Widget b() => I18nPlural(
          "multiline.plural.key",
          3,
        );
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('multiline.plural.key'));
    });

    test('skips commented-out fallbackKey', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        void f(BuildContext context) {
          FlutterI18n.translate(context, "live.key");
          // FlutterI18n.translate(context, "dead.key", fallbackKey: "dead.fb");
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('live.key'));
      expect(result.literalKeys, isNot(contains('dead.key')));
      expect(result.literalKeys, isNot(contains('dead.fb')));
    });

    test('detects dynamic key in I18nText', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        Widget b(String key) => I18nText(key);
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, isEmpty);
      expect(result.dynamicRefs, isNotEmpty);
      expect(result.dynamicRefs.first.lineContent,
          contains('I18nText(key)'));
    });

    test('detects dynamic key in I18nPlural', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        Widget b(String key, int n) => I18nPlural(key, n);
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, isEmpty);
      expect(result.dynamicRefs, isNotEmpty);
      expect(result.dynamicRefs.first.lineContent,
          contains('I18nPlural(key, n)'));
    });

    test('scans only specified scanPaths', () {
      final testDir = p.join(tmpDir.path, 'test');
      Directory(testDir).createSync();
      File(p.join(libDir, 'a.dart')).writeAsStringSync('''
        void f(BuildContext c) { FlutterI18n.translate(c, "lib.key"); }
      ''');
      File(p.join(testDir, 'b.dart')).writeAsStringSync('''
        void f(BuildContext c) { FlutterI18n.translate(c, "test.key"); }
      ''');
      final result = SourceScanner.scan(
        tmpDir.path,
        scanPaths: ['lib'],
      );
      expect(result.literalKeys, contains('lib.key'));
      expect(result.literalKeys, isNot(contains('test.key')));
    });

    test('extracts NamespaceConfig from source', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        final loader = NamespaceFileTranslationLoader(
          basePath: "assets/i18n",
          namespaces: ["common", "home"],
        );
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.namespaceConfigs, hasLength(1));
      expect(result.namespaceConfigs.first.basePath, 'assets/i18n');
      expect(result.namespaceConfigs.first.namespaces,
          containsAll(['common', 'home']));
    });

    test('extracts multiple NamespaceConfigs', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        final a = NamespaceFileTranslationLoader(
          basePath: "i18n/common",
          namespaces: ["common"],
        );
        final b = NamespaceFileTranslationLoader(
          namespaces: ["home"],
        );
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.namespaceConfigs, hasLength(2));
      expect(result.namespaceConfigs[0].basePath, 'i18n/common');
      expect(result.namespaceConfigs[0].namespaces, ['common']);
      expect(result.namespaceConfigs[1].basePath, isNull);
      expect(result.namespaceConfigs[1].namespaces, ['home']);
    });

    test('extracts literal keys from ternary branches, still flags dynamic',
        () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        void f(BuildContext c, bool cond) {
          FlutterI18n.translate(c, cond ? "key.true" : "key.false");
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, containsAll(['key.true', 'key.false']));
      expect(result.dynamicRefs, isNotEmpty);
      expect(result.dynamicRefs.first.lineContent,
          contains('FlutterI18n.translate'));
    });

    test('extracts literal key from ternary with one hardcoded branch', () {
      writeDartFile('a.dart', '''
        import 'package:flutter_i18n/flutter_i18n.dart';
        void f(BuildContext c, String fallback) {
          FlutterI18n.translate(c, cond ? "key.if" : fallback);
        }
      ''');
      final result = SourceScanner.scan(tmpDir.path);
      expect(result.literalKeys, contains('key.if'));
      expect(result.literalKeys, isNot(contains('fallback')));
      expect(result.dynamicRefs, isNotEmpty);
    });
  });
}
