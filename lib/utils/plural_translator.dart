import 'package:flutter_i18n/utils/simple_translator.dart';

/// Translator for plural values
class PluralTranslator extends SimpleTranslator {
  static const String pluralSeparator = "-";
  static final RegExp _parameterRegexp = RegExp("{(.+)}");

  final int pluralValue;

  PluralTranslator(
    Map? decodedMap,
    String key,
    String? keySeparator,
    this.pluralValue, {
    MissingKeyTranslationHandler? missingKeyTranslationHandler,
  }) : super(
          decodedMap,
          key,
          keySeparator,
          missingKeyTranslationHandler: missingKeyTranslationHandler,
        );

  /// Return the translation of plural key provided
  String plural() {
    final Map<dynamic, dynamic> decodedSubMap = calculateSubmap(key);
    key = _findCorrectKey(decodedSubMap);
    final String? parameterName = _findParameterName(decodedSubMap);
    translationParams =
        Map.fromIterables([parameterName], [pluralValue.toString()]);
    return translate();
  }

  String _findCorrectKey(final Map<dynamic, dynamic> decodedSubMap) {
    final List<String> splittedKey = key.split(keySeparator!);
    final String translationKey = splittedKey.removeLast();
    final String pluralSuffix =
        _findPluralSuffix(decodedSubMap, translationKey);
    final String lastKeyPart = "$translationKey$pluralSeparator$pluralSuffix";
    splittedKey.add(lastKeyPart);
    return splittedKey.join(keySeparator!);
  }

  String _findPluralSuffix(
      final Map<dynamic, dynamic> decodedSubMap, final String translationKey) {
    final int? pluralSuffix = decodedSubMap.keys
        .where((mapKey) => mapKey.startsWith(translationKey))
        .where((mapKey) => mapKey.split(pluralSeparator).length == 2)
        .map((mapKey) => int.tryParse(mapKey.split(pluralSeparator).last))
        .where((mapKeyPluralValue) => mapKeyPluralValue != null)
        .lastWhere((mapKeyPluralValue) => mapKeyPluralValue! <= pluralValue,
            orElse: () => null);
    return pluralSuffix?.toString() ?? '';
  }

  String? _findParameterName(final Map<dynamic, dynamic> decodedSubMap) {
    String? parameterName = "";
    final String? translation =
        decodedSubMap[key.split(keySeparator!).last];
    if (translation != null && _parameterRegexp.hasMatch(translation)) {
      final Match match = _parameterRegexp.firstMatch(translation)!;
      parameterName = match.groupCount > 0 ? match.group(1)! : "";
    }
    return parameterName;
  }
}
