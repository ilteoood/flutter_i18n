import 'package:flutter_test/flutter_test.dart';

import '../text_widget_no_context.dart';

void main() {
  testWidgets(
      'TestWidget with I18nPlural should translate text with `1` plural value',
          (WidgetTester tester) async {
        await tester.pumpWidget(TestWidgetNoContext());
        await tester.pump();

        expect(find.text('valuePlural-1'), findsOneWidget);
        expect(find.text('valuePlural'), findsNothing);
        expect(find.text('keyPlural'), findsNothing);
        expect(find.text('keyPlural-1'), findsNothing);
      });

  testWidgets(
      'TestWidget with I18nPlural should translate text with `2` plural value',
          (WidgetTester tester) async {
        await tester.pumpWidget(TestWidgetNoContext());
        await tester.pump();

        expect(find.text('valuePlural-2'), findsOneWidget);
        expect(find.text('valuePlural'), findsNothing);
        expect(find.text('keyPlural'), findsNothing);
        expect(find.text('keyPlural-2'), findsNothing);
      });
}
