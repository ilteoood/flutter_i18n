import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n_example/main.dart' as appmain;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  launchApp(WidgetTester tester) async {
    appmain.main();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('networkExample')));
    await tester.pumpAndSettle(const Duration(milliseconds: 5000));
  }

  testWidgets('Network translation loader example',
      (WidgetTester tester) async {
    await launchApp(tester);
    expect(find.text("Translated content"), findsOneWidget);
    expect(find.text("Basic network example"), findsOneWidget);
  });
}
