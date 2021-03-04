import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/xml_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/yaml_decode_strategy.dart';

Future<String> _loadString(String fileName, String extension) async {
  if (fileName.contains('_en')) {
    // Throw the error for all cases with this locale.
    throw new Error();
  }

  if (fileName.contains('uk') && extension == 'json') {
    // Throw the error only for json extension with this locale.
    throw new Error();
  }

  return '''
      {
        "keySingle": "valueSingle",
        "keyPlural-1": "valuePlural-1",
        "keyPlural-2": "valuePlural-2",
        "fileName": "$fileName",
        "extension": "$extension",
        "object": {
          "key1": "Key1Value",
          "key2": "Key2Value"
        }
      }
    ''';
}

class TestJsonLoader extends FileTranslationLoader {
  TestJsonLoader({
    forcedLocale,
    fallbackFile = "en",
    basePath = "assets/flutter_i18n",
    useCountryCode = false,
  }) : super(
            fallbackFile: fallbackFile,
            basePath: basePath,
            useCountryCode: useCountryCode,
            forcedLocale: forcedLocale);

  @override
  Future<String> loadString(String fileName, String extension) {
    return _loadString(fileName, extension);
  }
}

class TestYamlLoader extends FileTranslationLoader {
  TestYamlLoader({
    forcedLocale,
    fallbackFile = "en",
    basePath = "assets/flutter_i18n",
    useCountryCode = false,
  }) : super(
            fallbackFile: fallbackFile,
            basePath: basePath,
            useCountryCode: useCountryCode,
            forcedLocale: forcedLocale,
            decodeStrategies: [YamlDecodeStrategy()]);

  @override
  Future<String> loadString(String fileName, String extension) {
    return Future<String>.value('''
      keySingle: valueSingle
      keyPlural-1: valuePlural-1
      keyPlural-2: valuePlural-2
      fileName: "$fileName"
      extension: "$extension"
      object:
        key1: Key1Value
        key2: Key2Value
    ''');
  }
}

class TestXmlLoader extends FileTranslationLoader {
  TestXmlLoader({
    forcedLocale,
    fallbackFile = "en",
    basePath = "assets/flutter_i18n",
    useCountryCode = false,
  }) : super(
            fallbackFile: fallbackFile,
            basePath: basePath,
            useCountryCode: useCountryCode,
            forcedLocale: forcedLocale,
            decodeStrategies: [XmlDecodeStrategy()]);

  @override
  Future<String> loadString(String fileName, String extension) {
    return Future<String>.value('''
    <?xml version="1.0" encoding="UTF-8" ?>
    <root>
      <keySingle>valueSingle</keySingle>
      <keyPlural-1>valuePlural-1</keyPlural-1>
      <keyPlural-2>valuePlural-2</keyPlural-2>
      <fileName>$fileName</fileName>
      <extension>$extension</extension>
      <object>
        <key1>Key1Value</key1>
        <key2>Key2Value</key2>
      </object>
    </root>
    ''');
  }
}

class TestNamespaceLoader extends NamespaceFileTranslationLoader {
  TestNamespaceLoader({
    required namespaces,
    forcedLocale,
    fallbackDir = "en",
    basePath = "assets/flutter_i18n",
    useCountryCode = false,
  }) : super(
          namespaces: namespaces,
          fallbackDir: fallbackDir,
          basePath: basePath,
          useCountryCode: useCountryCode,
          forcedLocale: forcedLocale,
        );

  @override
  Future<String> loadString(String fileName, String extension) {
    return _loadString(fileName, extension);
  }
}
