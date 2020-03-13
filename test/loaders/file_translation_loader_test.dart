import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_loader.dart';

void main() {
  test('should have initial values', () {
    var instance = TestLoader();
    expect(instance.fallbackFile, "en");
    expect(instance.forcedLocale, isNull);
    expect(instance.basePath, isNotNull);
    expect(instance.useCountryCode, isFalse);
  });

  test('`loadString` should load correct string', () async {
    final instance = TestLoader();
    final result = await instance.loadString("_fileName", "_extension");
    expect(result, contains("_fileName"));
    expect(result, contains("_extension"));
  });

  test('`load` should load correct map with initial values', () async {
    final instance = TestLoader();
    final result = await instance.load();
    expect(result["fileName"], "en");
    expect(result["extension"], "json");
  });

  test('`load` should load correct map with country code', () async {
    final instance = TestLoader(useCountryCode: true);
    final result = await instance.load();
    expect(result["fileName"], "en_US");
    expect(result["extension"], "json");
  });

  test('`load` should load correct map with another locale', () async {
    final instance = TestLoader(forcedLocale: Locale("ua"));
    final result = await instance.load();
    expect(result["fileName"], "ua");
    expect(result["extension"], "json");
  });

  test('`load` should load correct map from yaml file', () async {
    final instance = TestLoader(forcedLocale: Locale("uk"));
    final result = await instance.load();
    expect(result["fileName"], "uk");
    expect(result["extension"], "yaml");
  });

  test(
      '`load` should load correct map with invalid locale and correct fallback locale',
      () async {
    final instance = TestLoader(forcedLocale: Locale("_en"));
    final result = await instance.load();
    expect(result["fileName"], "en");
    expect(result["extension"], "json");
  });

  test(
      '`load` should load empty map with invalid locale and invalid fallback locale',
      () async {
    final instance =
        TestLoader(forcedLocale: Locale("_en"), fallbackFile: "_en");
    final result = await instance.load();
    expect(result, isMap);
    expect(result, isEmpty);
  });
}
