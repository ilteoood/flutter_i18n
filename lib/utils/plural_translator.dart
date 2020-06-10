import 'package:flutter_i18n/utils/simple_translator.dart';

class PluralTranslator extends SimpleTranslator {
  static const String PLURAL_SEPARATOR = "-";
  static final RegExp _parameterRegexp = RegExp("{(.+)}");

  final int pluralValue;

  PluralTranslator(
    Map decodedMap,
    String key,
    this.pluralValue, {
    MissingKeyTranslationHandler missingKeyTranslationHandler,
  }) : super(
          decodedMap,
          key,
          missingKeyTranslationHandler: missingKeyTranslationHandler,
        );

  String plural() {
    final Map<dynamic, dynamic> decodedSubMap = calculateSubmap(key);
    key = _findCorrectKey(decodedSubMap);
    final String parameterName = _findParameterName(decodedSubMap);
    translationParams =
        Map.fromIterables([parameterName], [pluralValue.toString()]);
    return translate();
  }

  String _findCorrectKey(final Map<dynamic, dynamic> decodedSubMap) {
    final List<String> splittedKey = key.split(SimpleTranslator.KEY_SEPARATOR);
    final String translationKey = splittedKey.removeLast();
    final String pluralSuffix =
        _findPluralSuffix(decodedSubMap, translationKey);
    final String lastKeyPart = "$translationKey$PLURAL_SEPARATOR$pluralSuffix";
    splittedKey.add(lastKeyPart);
    return splittedKey.join(SimpleTranslator.KEY_SEPARATOR);
  }

  String _findPluralSuffix(
      final Map<dynamic, dynamic> decodedSubMap, final String translationKey) {
    final int pluralSuffix = decodedSubMap.keys
        .where((mapKey) => mapKey.startsWith(translationKey))
        .where((mapKey) => mapKey.split(PLURAL_SEPARATOR).length == 2)
        .map((mapKey) => int.tryParse(mapKey.split(PLURAL_SEPARATOR).last))
        .where((mapKeyPluralValue) => mapKeyPluralValue != null)
        .lastWhere((mapKeyPluralValue) => mapKeyPluralValue <= pluralValue,
            orElse: () => null);
    return pluralSuffix?.toString() ?? '';
  }

  String _findParameterName(final Map<dynamic, dynamic> decodedSubMap) {
    String parameterName = "";
    final String translation =
        decodedSubMap[key.split(SimpleTranslator.KEY_SEPARATOR).last];
    if (translation != null && _parameterRegexp.hasMatch(translation)) {
      final Match match = _parameterRegexp.firstMatch(translation);
      parameterName = match.groupCount > 0 ? match.group(1) : "";
    }
    return parameterName;
  }
}
