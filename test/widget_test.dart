import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/main.dart';

void main() {
  testWidgets('MoneyManager app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MoneyManagerApp()),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
