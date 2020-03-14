import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

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
        "extension": "$extension"
      }
    ''';
}

class TestLoader extends FileTranslationLoader {
  TestLoader({
    forcedLocale,
    fallbackFile = "en",
    basePath = "assets/flutter_i18n",
    useCountryCode = false,
  }) : super(
          fallbackFile: fallbackFile,
          basePath: basePath,
          useCountryCode: useCountryCode,
          forcedLocale: forcedLocale,
        );

  @override
  Future<String> loadString(String fileName, String extension) {
    return _loadString(fileName, extension);
  }
}

class TestNamespaceLoader extends NamespaceFileTranslationLoader {
  TestNamespaceLoader({
    @required namespaces,
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
