import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_asset_bundle.dart';

void main() {
  test('should load correct map with E2E', () async {
    var instance = E2EFileTranslationLoader();
    instance.assetBundle = TestAssetBundle();

    var result = await instance.load();

    expect(result, isMap);
    expect(result, isEmpty);
  });

  test('should load correct map without E2E', () async {
    var instance = E2EFileTranslationLoader(useE2E: false);
    instance.assetBundle = TestAssetBundle();

    var result = await instance.load();

    expect(result, isMap);
    expect(result, isEmpty);
  });
}
