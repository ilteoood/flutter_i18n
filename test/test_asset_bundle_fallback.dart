import 'package:flutter/services.dart';

class TestAssetBundleFallbackFrToEn extends PlatformAssetBundle {
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key.endsWith("fr.json")) {
      return '{"title": "flutter_18n_fr", "block": {"label2": "Bonjour"}}';
    } else {
      return '{"title": "flutter_18n", "sub_title": "Hello World", "block": {"label1": "This is my app", "label2": "Welcome"}}';
    }
  }
}

class TestAssetBundleFallback extends PlatformAssetBundle {
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'assets/flutter_i18n/en.json') {
      return '{"hello": "Hello", "world": "World"}';
    }
    if (key == 'assets/flutter_i18n/de.json') {
      return '{"label": "Deutsch"}';
    }
    throw Exception('Asset not found: $key');
  }
}
