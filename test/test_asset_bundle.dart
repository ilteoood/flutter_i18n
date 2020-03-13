import 'package:flutter/services.dart';

class TestAssetBundle extends PlatformAssetBundle {
  Future<String> loadString(String key, {bool cache = true}) async {
    return "{}";
  }
}
