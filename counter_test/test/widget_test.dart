// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:counter_test/main.dart';

void main() {
  testWidgets('check Counter decrement button', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await(tester.tap(find.bySemanticsLabel('Decrement')));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Confirm CINS467 Hello World text', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    final title = find.text('CINS467 Hello World');
    expect(title, findsAtLeastNWidgets(1));
  });

  testWidgets('Confirm CINS467', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    final title = find.textContaining('CINS467');
    expect(title, findsAtLeastNWidgets(1));
  });
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
