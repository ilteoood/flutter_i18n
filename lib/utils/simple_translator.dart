typedef void MissingKeyTranslationHandler(String key);

/// Translator for simple values
class SimpleTranslator {
  final Map<dynamic, dynamic>? decodedMap;
  final String? fallbackKey;
  final String? keySeparator;
  final MissingKeyTranslationHandler? missingKeyTranslationHandler;
  final bool mustReturnString;

  String key;
  Map<String?, String>? translationParams;

  SimpleTranslator(
    this.decodedMap,
    this.key,
    this.keySeparator, {
    this.fallbackKey,
    this.translationParams,
    this.missingKeyTranslationHandler,
    this.mustReturnString = false,
  });

  /// Return the translation of the key provided, otherwise return the fallbackKey (if provided), otherwise return the same key
  dynamic translate() {
    dynamic translation = _translateWithKeyFallback();
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

  dynamic _translateWithKeyFallback() {
    return [
          _decodeFromMap(key),
          _decodeFromMap(fallbackKey ?? ""),
          fallbackKey,
          key
        ].firstWhere((translation) => translation != null) ??
        key;
  }

  dynamic? _decodeFromMap(final String key) {
    final dynamic subMap = calculateSubmap(key);
    if (subMap is List) {
      final String lastKeyPart = key.split(this.keySeparator!).last;
      if (int.parse(lastKeyPart) >= subMap.length) {
        missingKeyTranslationHandler!(key);
        return null;
      }
      var result = subMap[int.parse(lastKeyPart)];
      if (mustReturnString && result is! String) {
        result = null;
      }

      if (result == null && key.length > 0) {
        missingKeyTranslationHandler!(key);
      }

      return result;
    } else if (subMap is Map) {
      final String lastKeyPart = key.split(this.keySeparator!).last;
      var result = subMap[lastKeyPart];
      if (mustReturnString && result is! String) {
        result = null;
      }

      if (result == null && key.length > 0) {
        missingKeyTranslationHandler!(key);
      }

      return result;
    }
  }

  dynamic calculateSubmap(final String translationKey) {
    final List<String> translationKeySplitted =
        translationKey.split(this.keySeparator!);
    translationKeySplitted.removeLast();
    dynamic decodedSubMap = decodedMap;
    translationKeySplitted.forEach((listKey) {
      decodedSubMap =
          decodedSubMap is Map || decodedSubMap is List ? decodedSubMap : Map();
      dynamic subMap;
      if (decodedSubMap is List) {
        if (int.parse(listKey) < decodedSubMap.length) {
          subMap = (decodedSubMap ?? List.empty())[int.parse(listKey)];
        } else {
          subMap = Map();
        }
      } else if (decodedSubMap is Map) {
        subMap = (decodedSubMap ?? Map())[listKey];
      }
      decodedSubMap = subMap is Map || subMap is List ? subMap : Map();
    });
    return decodedSubMap ?? {};
  }
}
