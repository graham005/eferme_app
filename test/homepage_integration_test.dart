import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eferme_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('HomePage integration test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Today's Weather"), findsOneWidget);
    expect(find.text("Today's Farm Tips"), findsOneWidget);
    expect(find.text("5-Day Forecast"), findsOneWidget);
  });
}