import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n_example/main.dart' as appmain;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  launchApp(WidgetTester tester) async {
    appmain.main();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('basicExample')));
    await tester.pumpAndSettle();
  }

  testWidgets('File translation loader example 0 times',
      (WidgetTester tester) async {
    await launchApp(tester);
    final incrementCounter = find.byKey(const Key('incrementCounter'));
    final changeLanguage = find.byKey(const Key('changeLanguage'));
    expect(find.text("Hiciste clic 0 veces!"), findsOneWidget);
    expect(find.text("Hola Flutter lover!"), findsOneWidget);
    expect(find.text("Hai premuto 0 volte!"), findsNothing);
    expect(find.text("You clicked 0 times!"), findsNothing);
    await tester.tap(incrementCounter);
    await tester.tap(incrementCounter);
    await tester.pumpAndSettle();
    expect(find.text("Hiciste clic 2 veces!"), findsOneWidget);
    expect(find.text("Hola Flutter lover!"), findsOneWidget);
    expect(find.text("Hai premuto 2 volte!"), findsNothing);
    expect(find.text("You clicked 2 times!"), findsNothing);
    await tester.tap(changeLanguage);
    await tester.pumpAndSettle();
    expect(find.text("Hello Flutter lover!"), findsOneWidget);
    expect(find.text('You clicked on button!'), findsOneWidget);
    expect(find.text("You clicked 2 times!"), findsOneWidget);
    expect(find.text("Hiciste clic 2 veces!"), findsNothing);
    expect(find.text("Hai premuto 2 volte!"), findsNothing);
    await tester.tap(changeLanguage);
    await tester.pumpAndSettle(const Duration(milliseconds: 5000));
    expect(find.text("Ciao Flutter lover!"), findsOneWidget);
    expect(find.text('Hai premuto un bottone!'), findsOneWidget);
    expect(find.text("Hai premuto 2 volte!"), findsOneWidget);
    expect(find.text("You clicked 2 times!"), findsNothing);
    expect(find.text("Hiciste clic 2 veces!"), findsNothing);
    await tester.tap(incrementCounter);
    await tester.tap(incrementCounter);
    await tester.tap(incrementCounter);
    await tester.pumpAndSettle();
    expect(find.text("Ciao Flutter lover!"), findsOneWidget);
    expect(find.text("Hai premuto 5 volte!"), findsOneWidget);
    expect(find.text("Hiciste clic 5 veces!"), findsNothing);
    expect(find.text("You clicked 5 times!"), findsNothing);
    await tester.tap(changeLanguage);
    await tester.pumpAndSettle(const Duration(milliseconds: 5000));
    expect(find.text("Hello Flutter lover!"), findsOneWidget);
    expect(find.text('You clicked on button!'), findsOneWidget);
    expect(find.text("You clicked 5 times!"), findsOneWidget);
    expect(find.text("Hiciste clic 5 veces!"), findsNothing);
    expect(find.text("Hai premuto 5 volte!"), findsNothing);
  });
}
