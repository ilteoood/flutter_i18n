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
    final dynamic subMap = calculateSubmap(key);
    final String lastKeyPart = key.split(this.keySeparator!).last;

    // Check if the last part of the key is numeric and handle it as an index in a list
    final result = _isNumeric(lastKeyPart) && subMap is List
        ? subMap[int.parse(lastKeyPart)]
        : subMap is Map ? subMap[lastKeyPart] : null;

    if (result == null && key.length > 0) {
      missingKeyTranslationHandler!(key);
    }

    return result is String ? result : null;
  }

  dynamic calculateSubmap(final String translationKey) {
    final List<String> translationKeySplitted =
        translationKey.split(this.keySeparator!);
    dynamic currentLevel = decodedMap;
    for (final String part in translationKeySplitted) {
      if (_isNumeric(part) && currentLevel is List) {
        currentLevel = currentLevel[int.parse(part)];
      } else if (currentLevel is Map) {
        currentLevel = currentLevel[part];
      } else {
        // If the current level is neither Map nor List, or the key is not valid, return null
        return null;
      }
    }
    return currentLevel;
  }

  // Utility function to check if a string is numeric
  bool _isNumeric(String str) {
    return int.tryParse(str) != null;
  }
}
