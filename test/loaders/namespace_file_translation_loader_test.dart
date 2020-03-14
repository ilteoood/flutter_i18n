import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_asset_bundle.dart';
import '../test_loader.dart';

void main() {
  test('should have initial values', () {
    final List<String> namespaces = ["common"];
    var instance = TestNamespaceLoader(namespaces: namespaces);
    expect(instance.fallbackDir, "en");
    expect(instance.forcedLocale, isNull);
    expect(instance.basePath, isNotNull);
    expect(instance.useCountryCode, isFalse);
  });

  test('should have assert if namespaces is empty list', () {
    final List<String> namespaces = [];
    expect(() => TestNamespaceLoader(namespaces: namespaces),
        throwsAssertionError);
  });

  test('should have assert if namespaces is null', () {
    expect(() => TestNamespaceLoader(namespaces: null), throwsAssertionError);
  });

  test('should load correct map', () async {
    var instance = NamespaceFileTranslationLoader(namespaces: ["common"]);
    instance.assetBundle = TestAssetBundle();

    Map result = await instance.load();

    expect(result, isMap);
    expect(result.length, 1);
    expect(result.containsKey("common"), isTrue);
    expect(result["common"], isMap);
    expect(result["common"], isEmpty);
  });

  test('`loadString` should load correct string', () async {
    final instance = TestNamespaceLoader(namespaces: ["common"]);
    final result = await instance.loadString("_fileName", "_extension");
    expect(result, contains("_fileName"));
    expect(result, contains("_extension"));
  });

  test('`load` should load correct map with initial values', () async {
    final instance = TestNamespaceLoader(namespaces: ["common"]);
    final result = await instance.load();
    expect(result["common"]["fileName"], "en/common");
    expect(result["common"]["extension"], "json");
  });

  test('`load` should load correct map with country code', () async {
    final instance =
        TestNamespaceLoader(useCountryCode: true, namespaces: ["common"]);
    final result = await instance.load();
    expect(result["common"]["fileName"], "en_US/common");
    expect(result["common"]["extension"], "json");
  });

  test('`load` should load correct map with another locale', () async {
    final instance =
        TestNamespaceLoader(forcedLocale: Locale("ua"), namespaces: ["common"]);
    final result = await instance.load();
    expect(result["common"]["fileName"], "ua/common");
    expect(result["common"]["extension"], "json");
  });

  test('`load` should load correct map from yaml file', () async {
    final instance =
        TestNamespaceLoader(forcedLocale: Locale("uk"), namespaces: ["common"]);
    final result = await instance.load();
    expect(result["common"]["fileName"], "uk/common");
    expect(result["common"]["extension"], "yaml");
  });

  test(
      '`load` should load correct map with invalid locale and correct fallback locale',
      () async {
    final instance = TestNamespaceLoader(
        forcedLocale: Locale("_en"), namespaces: ["common"]);
    final result = await instance.load();
    expect(result["common"]["fileName"], "en/common");
    expect(result["common"]["extension"], "json");
  });

  test(
      '`load` should load empty map with invalid locale and invalid fallback locale',
      () async {
    final instance = TestNamespaceLoader(
        forcedLocale: Locale("_en"),
        fallbackDir: "_en",
        namespaces: ["common"]);
    final result = await instance.load();

    expect(result, isMap);
    expect(result.length, 1);
    expect(result.containsKey("common"), isTrue);
    expect(result["common"], isMap);
    expect(result["common"], isEmpty);
  });

  test('`load` should load correct map different namespaces', () async {
    final instance = TestNamespaceLoader(namespaces: ["ns1", "ns2"]);
    final result = await instance.load();

    expect(result, isMap);
    expect(result.length, 2);
    expect(result.containsKey("ns1"), isTrue);
    expect(result.containsKey("ns2"), isTrue);

    expect(result["ns1"]["fileName"], "en/ns1");
    expect(result["ns1"]["extension"], "json");

    expect(result["ns2"]["fileName"], "en/ns2");
    expect(result["ns2"]["extension"], "json");
  });
}
