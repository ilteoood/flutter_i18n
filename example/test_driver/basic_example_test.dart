import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('File translation loader example', () {
    final incrementCounter = find.byValueKey('incrementCounter');
    final changeLanguage = find.byValueKey('changeLanguage');

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
      await driver.tap(incrementCounter);
      await driver.tap(incrementCounter);
      await driver.waitFor(find.text("Hiciste clic 2 veces!"));
      await driver.waitForAbsent(find.text("Hai premuto 2 volte!"));
      await driver.waitForAbsent(find.text("You clicked 2 times!"));
    });

    test('switch language to english', () async {
      await driver.tap(changeLanguage);
      await driver.waitFor(find.text("You clicked 2 times!"));
      await driver.waitForAbsent(find.text("Hiciste clic 2 veces!"));
      await driver.waitForAbsent(find.text("Hai premuto 2 volte!"));
    });

    test('switch language to italian', () async {
      await driver.tap(changeLanguage);
      await driver.waitFor(find.text("Hai premuto 2 volte!"));
      await driver.waitForAbsent(find.text("You clicked 2 times!"));
      await driver.waitForAbsent(find.text("Hiciste clic 2 veces!"));
    });

    test('clicked 5 times', () async {
      await driver.tap(incrementCounter);
      await driver.tap(incrementCounter);
      await driver.tap(incrementCounter);
      await driver.waitFor(find.text("Hai premuto 5 volte!"));
      await driver.waitForAbsent(find.text("Hiciste clic 2 veces!"));
      await driver.waitForAbsent(find.text("You clicked 2 times!"));
    });

    test('switch back to english', () async {
      await driver.tap(changeLanguage);
      await driver.waitFor(find.text("You clicked 5 times!"));
      await driver.waitForAbsent(find.text("Hiciste clic 5 veces!"));
      await driver.waitForAbsent(find.text("Hai premuto 5 volte!"));
    });

  });
}
