import 'package:flutter_test/flutter_test.dart';

import '../test_widget.dart';

void main() {
  testWidgets('TestWidget with I18nText should translate text',
      (WidgetTester tester) async {
    await tester.pumpWidget(TestWidget());
    await tester.pump();

    final valueFinder = find.text('valueSingle');
    final keyFinder = find.text('keySingle');

    expect(valueFinder, findsOneWidget);
    expect(keyFinder, findsNothing);
  });
}
