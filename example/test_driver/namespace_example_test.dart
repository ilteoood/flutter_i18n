import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Namespace translation loader example', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      await driver.tap(find.byValueKey('nameSpaceExample'));
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('content translated', () async {
      await driver.waitFor(find.text("Namespace example"));
      await driver.waitFor(find.text("Label from another namespace"));
      await driver.waitFor(find.text("Change language"));
    });

    test('change language to ua', () async {
      await driver.tap(find.byType('RaisedButton'));
      await driver.waitFor(find.text("Приклад простору імен"));
      await driver.waitFor(find.text("Напис з іншого простору імен"));
      await driver.waitFor(find.text("Change language"));
    });

    test('change language to en', () async {
      await driver.tap(find.byType('RaisedButton'));
      await driver.waitFor(find.text("Namespace example"));
      await driver.waitFor(find.text("Label from another namespace"));
      await driver.waitFor(find.text("Change language"));
    });
  });
}
