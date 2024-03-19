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
    final dynamic subStructure = calculateSubStructure(key);
    var result = null;
    final String lastKeyPart = key.split(this.keySeparator!).last;
    if (subStructure is List) {
      if (int.parse(lastKeyPart) >= subStructure.length) {
        missingKeyTranslationHandler!(key);
        return null;
      }
      result = subStructure[int.parse(lastKeyPart)];
    } else if (subStructure is Map) {
      result = subStructure[lastKeyPart];
    }
    result = result is String ? result : null;
    if (result == null && key.length > 0) {
      missingKeyTranslationHandler!(key);
    }

    return result;
  }

  dynamic calculateSubStructure(final String translationKey) {
    final List<String> translationKeySplitted =
        translationKey.split(this.keySeparator!);
    translationKeySplitted.removeLast();
    dynamic decodedSubStructure = decodedMap;
    translationKeySplitted.forEach((listKey) {
      decodedSubStructure =
          decodedSubStructure is Map || decodedSubStructure is List
              ? decodedSubStructure
              : Map();
      dynamic subStructure;
      if (decodedSubStructure is List) {
        if (int.parse(listKey) < decodedSubStructure.length) {
          subStructure =
              (decodedSubStructure ?? List.empty())[int.parse(listKey)];
        } else {
          subStructure = Map();
        }
      } else if (decodedSubStructure is Map) {
        subStructure = (decodedSubStructure ?? Map())[listKey];
      }
      decodedSubStructure =
          subStructure is Map || subStructure is List ? subStructure : Map();
    });
    return decodedSubStructure ?? {};
  }
}
