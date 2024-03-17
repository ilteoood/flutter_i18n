typedef void MissingKeyTranslationHandler(String key);

/// Translator for simple values
class SimpleTranslator {
  final Map<dynamic, dynamic>? decodedMap;
  final String? fallbackKey;
  final String? keySeparator;
  final MissingKeyTranslationHandler? missingKeyTranslationHandler;

  String key;
  Map<String?, String>? translationParams;

  SimpleTranslator(
    this.decodedMap,
    this.key,
    this.keySeparator, {
    this.fallbackKey,
    this.translationParams,
    this.missingKeyTranslationHandler,
  });

  /// Return the translation of the key provided, otherwise return the fallbackKey (if provided), otherwise return the same key
  String translate() {
    String translation = _translateWithKeyFallback();
    if (translationParams != null) {
      translation = _replaceParams(translation);
    }
    return translation;
  }

  String _replaceParams(String translation) {
    for (final String? paramKey in translationParams!.keys) {
      translation = translation.replaceAll(
          RegExp('{$paramKey}'), translationParams![paramKey]!);
    }
    return translation;
  }

  String _translateWithKeyFallback() {
    return [
          _decodeFromMap(key),
          _decodeFromMap(fallbackKey ?? ""),
          fallbackKey,
          key
        ].firstWhere((translation) => translation != null) ??
        key;
  }

  String? _decodeFromMap(final String key) {
    final dynamic subMapOrList = calculateSubmap(key);
    final String lastKeyPart = key.split(this.keySeparator!).last;

    // Check if the result is a map and contains the last key part as a string
    if (subMapOrList is Map && subMapOrList[lastKeyPart] is String) {
      return subMapOrList[lastKeyPart];
    }

    // If a list or non-string value is encountered, handle it appropriately (e.g., log an error)
    if (key.isNotEmpty && (subMapOrList is List || !(subMapOrList is String))) {
      missingKeyTranslationHandler?.call(key);
    }

    return null;
  }

  dynamic calculateSubmap(final String translationKey) {
    final List<String> translationKeySplitted =
        translationKey.split(this.keySeparator!);
    translationKeySplitted.removeLast();
    dynamic decodedSubMap = decodedMap;
    for (var listKey in translationKeySplitted) {
      if (decodedSubMap != null && decodedSubMap is Map) {
        decodedSubMap = decodedSubMap[listKey];
      } else {
        // Break out of the loop if we encounter a non-map structure
        break;
      }
    }
    return decodedSubMap;
  }
}
