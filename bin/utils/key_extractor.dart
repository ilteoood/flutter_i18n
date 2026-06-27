/// Flattens a nested [map] into a set of dotted key paths.
///
/// Leaf keys whose value is a scalar (String, int, double, num, bool) are
/// included.  Collection types (List, Set, Map) are skipped — Maps are
/// recursed into for their children; Lists and Sets are treated as
/// non-translatable structural data.
class KeyExtractor {
  /// Extract all scalar-leaf keys from [map] as dotted paths.
  static Set<String> extract(Map<dynamic, dynamic> map) {
    final keys = <String>{};
    _walk(map, [], keys);
    return keys;
  }

  static void _walk(
    Map<dynamic, dynamic> map,
    List<String> path,
    Set<String> result,
  ) {
    for (final entry in map.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      path.add(key);
      if (value is Map) {
        _walk(value, path, result);
      } else if (_isScalar(value)) {
        result.add(path.join('.'));
      }
      path.removeLast();
    }
  }

  static bool _isScalar(dynamic value) {
    return value is String || value is num || value is bool;
  }

  /// Returns the key with its trailing plural suffix stripped.
  /// Example: `"clicked.times-2"` → `"clicked.times"`.
  /// Returns null if the key does not have a plural suffix, or if the numeric
  /// suffix exceeds [maxSuffix] (default 99) — large numbers like `-404` are
  /// unlikely to be plural forms.
  static String? normalizePlural(String key, {int maxSuffix = 99}) {
    final idx = key.lastIndexOf('-');
    if (idx < 0) return null;
    final suffix = key.substring(idx + 1);
    final n = int.tryParse(suffix);
    if (n == null || n > maxSuffix) return null;
    return key.substring(0, idx);
  }
}
