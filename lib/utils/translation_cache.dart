class TranslationCache {
  final Map<String, Map<dynamic, dynamic>> cache = {};

   bool hasLocale(String localeCode) {
    return cache.containsKey(localeCode);
  }

   Map<dynamic, dynamic>? getLocale(String localeCode) {
    return cache[localeCode];
  }

  void setLocale(String localeCode, Map<dynamic, dynamic>? localeMap) {
    cache[localeCode] = localeMap ?? Map();
  }
}
