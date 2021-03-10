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
    await tester.tap(find.byKey(new Key('nameSpaceExample')));
    await tester.pumpAndSettle();
  }

  testWidgets('Namespace translation loader example',
      (WidgetTester tester) async {
    await launchApp(tester);
    final elevatedButton = find.byType(ElevatedButton);
    expect(find.text("Namespace example"), findsOneWidget);
    expect(find.text("Label from another namespace"), findsOneWidget);
    expect(find.text("Change language"), findsOneWidget);

    await tester.tap(elevatedButton);
    await tester.pumpAndSettle();
    expect(find.text("Приклад простору імен"), findsOneWidget);
    expect(find.text("Напис з іншого простору імен"), findsOneWidget);
    expect(find.text("Change language"), findsOneWidget);

    await tester.tap(elevatedButton);
    await tester.pumpAndSettle();
    expect(find.text("Namespace example"), findsOneWidget);
    expect(find.text("Label from another namespace"), findsOneWidget);
    expect(find.text("Change language"), findsOneWidget);
  });
}
