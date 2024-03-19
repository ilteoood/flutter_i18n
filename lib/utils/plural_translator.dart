import 'package:flutter_i18n/utils/simple_translator.dart';

/// Translator for plural values
class PluralTranslator extends SimpleTranslator {
  static const String PLURAL_SEPARATOR = "-";
  static final RegExp _parameterRegexp = RegExp("{(.+)}");

  final int pluralValue;
  final String? keySeparator;

  PluralTranslator(
    Map? decodedMap,
    String key,
    this.keySeparator,
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
    final Map<dynamic, dynamic> decodedSubStructure = calculateSubStructure(key);
    key = _findCorrectKey(decodedSubStructure);
    final String? parameterName = _findParameterName(decodedSubStructure);
    translationParams =
        Map.fromIterables([parameterName], [pluralValue.toString()]);
    return translate();
  }

  String _findCorrectKey(final Map<dynamic, dynamic> decodedSubStructure) {
    final List<String> splittedKey = key.split(this.keySeparator!);
    final String translationKey = splittedKey.removeLast();
    final String pluralSuffix =
        _findPluralSuffix(decodedSubStructure, translationKey);
    final String lastKeyPart = "$translationKey$PLURAL_SEPARATOR$pluralSuffix";
    splittedKey.add(lastKeyPart);
    return splittedKey.join(this.keySeparator!);
  }

  String _findPluralSuffix(
      final Map<dynamic, dynamic> decodedSubStructure, final String translationKey) {
    final int? pluralSuffix = decodedSubStructure.keys
        .where((mapKey) => mapKey.startsWith(translationKey))
        .where((mapKey) => mapKey.split(PLURAL_SEPARATOR).length == 2)
        .map((mapKey) => int.tryParse(mapKey.split(PLURAL_SEPARATOR).last))
        .where((mapKeyPluralValue) => mapKeyPluralValue != null)
        .lastWhere((mapKeyPluralValue) => mapKeyPluralValue! <= pluralValue,
            orElse: () => null);
    return pluralSuffix?.toString() ?? '';
  }

  String? _findParameterName(final Map<dynamic, dynamic> decodedSubStructure) {
    String? parameterName = "";
    final String? translation =
        decodedSubStructure[key.split(this.keySeparator!).last];
    if (translation != null && _parameterRegexp.hasMatch(translation)) {
      final Match match = _parameterRegexp.firstMatch(translation)!;
      parameterName = match.groupCount > 0 ? match.group(1)! : "";
    }
    return parameterName;
  }
}
