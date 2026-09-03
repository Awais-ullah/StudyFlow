import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Widget test suite sanity check', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('StudyFlow Test Suite Active'),
        ),
      ),
    );

    expect(find.text('StudyFlow Test Suite Active'), findsOneWidget);
  });
}