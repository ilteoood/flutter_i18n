typedef MissingKeyTranslationHandler = void Function(String key);

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
    final Map<dynamic, dynamic> subMap = calculateSubmap(key);
    final String lastKeyPart = key.split(keySeparator!).last;
    final result = subMap[lastKeyPart] is String ? subMap[lastKeyPart] : null;

    if (result == null && key.isNotEmpty) {
      missingKeyTranslationHandler!(key);
    }

    return result;
  }

  Map<dynamic, dynamic> calculateSubmap(final String translationKey) {
    final List<String> translationKeySplitted =
        translationKey.split(keySeparator!);
    translationKeySplitted.removeLast();
    Map<dynamic, dynamic>? decodedSubMap = decodedMap;
    for (var listKey in translationKeySplitted) {
      final subMap = (decodedSubMap ?? {})[listKey];
      decodedSubMap = subMap is Map ? subMap : {};
    }
    return decodedSubMap ?? {};
  }
}
