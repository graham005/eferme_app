import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eferme_app/pages/homepage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('HomePage displays weather and suggestions', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    expect(find.text("Today's Weather"), findsOneWidget);
    expect(find.text("Today's Farm Tips"), findsOneWidget);
    expect(find.text("5-Day Forecast"), findsOneWidget);
  });
}