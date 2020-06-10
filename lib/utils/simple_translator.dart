typedef void MissingKeyTranslationHandler(String key);

class SimpleTranslator {
  static const String KEY_SEPARATOR = ".";

  final Map<dynamic, dynamic> decodedMap;
  final String fallbackKey;
  final MissingKeyTranslationHandler missingKeyTranslationHandler;

  String key;
  Map<String, String> translationParams;

  SimpleTranslator(
    this.decodedMap,
    this.key, {
    this.fallbackKey,
    this.translationParams,
    this.missingKeyTranslationHandler,
  });

  String translate() {
    String translation = _translateWithKeyFallback();
    if (translationParams != null) {
      translation = _replaceParams(translation);
    }
    return translation;
  }

  String _replaceParams(String translation) {
    for (final String paramKey in translationParams.keys) {
      translation = translation.replaceAll(
          RegExp('{$paramKey}'), translationParams[paramKey]);
    }
    return translation;
  }

  String _translateWithKeyFallback() {
    return [
      _decodeFromMap(key),
      _decodeFromMap(fallbackKey ?? ""),
      fallbackKey,
      key
    ].firstWhere((translation) => translation != null);
  }

  String _decodeFromMap(final String key) {
    final Map<dynamic, dynamic> subMap = calculateSubmap(key);
    final String lastKeyPart = key.split(KEY_SEPARATOR).last;
    final result = subMap[lastKeyPart] is String ? subMap[lastKeyPart] : null;

    if (result == null && key.length > 0) {
      missingKeyTranslationHandler(key);
    }

    return result;
  }

  Map<dynamic, dynamic> calculateSubmap(final String translationKey) {
    final List<String> translationKeySplitted =
        translationKey.split(KEY_SEPARATOR);
    translationKeySplitted.removeLast();
    Map<dynamic, dynamic> decodedSubMap = decodedMap;
    translationKeySplitted.forEach((listKey) => decodedSubMap =
        decodedSubMap != null && decodedSubMap[listKey] != null
            ? decodedSubMap[listKey]
            : Map());
    return decodedSubMap;
  }
}
