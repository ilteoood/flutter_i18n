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
    return '''
      {
        "keySingle": "valueSingle",
        "keyPlural-1": "valuePlural-1",
        "keyPlural-2": "valuePlural-2"
      }
    ''';
  }
}
