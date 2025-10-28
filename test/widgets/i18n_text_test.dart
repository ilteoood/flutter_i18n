
import 'package:flutter/material.dart';
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

  testWidgets('TestWidget should reload language', (WidgetTester tester) async {
    await tester.pumpWidget(TestWidget());
    await tester.pump();

    await tester.tap(find.byType(ElevatedButton));
  });

  testWidgets('a key that point to an object must return the key itself',
      (WidgetTester tester) async {
    await tester.pumpWidget(TestWidget());
    await tester.pump();

    expect(find.text('Key1Value'), findsOneWidget);
    expect(find.text('Key2Value'), findsNothing);
    expect(find.text('object'), findsOneWidget);
    expect(find.text('en'), findsOneWidget);
  });
}
