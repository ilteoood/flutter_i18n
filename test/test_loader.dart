import 'package:flutter_i18n/flutter_i18n.dart';

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
  Future<String> loadString(String fileName, String extension) async {
    if (fileName == '_en') {
      // Throw the error for all cases with this locale.
      throw new Error();
    }

    if (fileName == 'uk' && extension == 'json') {
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
}
