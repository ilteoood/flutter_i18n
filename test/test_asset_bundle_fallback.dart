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
