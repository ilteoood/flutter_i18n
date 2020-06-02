import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('File translation loader example', () {
    final flatButton = find.byValueKey('incrementCounter');

    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      await driver.tap(find.byValueKey('basicExample'));
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('clicked 0 times', () async {
      await driver.waitFor(find.text("Hiciste clic 0 veces!"));
      await driver.waitForAbsent(find.text("Hai premuto 0 volte!"));
      await driver.waitForAbsent(find.text("You clicked 0 times!"));
    });

    test('clicked 2 times', () async {
      await driver.tap(flatButton);
      await driver.tap(flatButton);
      await driver.waitFor(find.text("Hiciste clic 2 veces!"));
      await driver.waitForAbsent(find.text("Hai premuto 2 volte!"));
      await driver.waitForAbsent(find.text("You clicked 2 times!"));
    });
  });
}
