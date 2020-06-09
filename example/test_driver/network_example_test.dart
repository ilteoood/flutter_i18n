import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('File translation loader example', () {

    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      await driver.tap(find.byValueKey('networkExample'));
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('content translated', () async {
      await driver.waitFor(find.text("Translated content"));
      await driver.waitFor(find.text("Basic network example"));
    });
  });
}
