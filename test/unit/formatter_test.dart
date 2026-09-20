import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/extensions/formatter_extensions.dart';

void main() {
  group('getWeekDates', () {
    test('starts on Monday by default', () {
      final week = getWeekDates(DateTime(2026, 9, 20), startMonday: true);
      expect(week.length, 7);
      expect(week.first.weekday, DateTime.monday);
      expect(week.first.day, 14); // 2026-09-20 is a Sunday; Monday = 14
      expect(week.last.day, 20);
    });

    test('can start on Sunday', () {
      final week = getWeekDates(DateTime(2026, 9, 20), startMonday: false);
      expect(week.first.weekday, DateTime.sunday);
      expect(week.first.day, 20);
    });
  });

  group('monthDates', () {
    test('returns correct day counts per month', () {
      expect(monthDates(DateTime(2026, 9, 1)).length, 30);
      expect(monthDates(DateTime(2026, 2, 1)).length, 28);
      expect(monthDates(DateTime(2024, 2, 1)).length, 29);
      expect(monthDates(DateTime(2026, 12, 1)).length, 31);
      expect(monthDates(DateTime(2026, 1, 1)).first.day, 1);
    });
  });

  group('formatCurrencyCompact (en locale)', () {
    testWidgets('formats thousands, millions, billions and negatives', (tester) async {
      String? out;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (ctx) {
          out = formatCurrencyCompact(ctx, 12340000); // Rp 123.400
          return const SizedBox();
        }),
      ));
      expect(out, '+123K');
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (ctx) {
          out = formatCurrencyCompact(ctx, 150000000); // Rp 1.5jt
          return const SizedBox();
        }),
      ));
      expect(out, '+1.5M');
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (ctx) {
          out = formatCurrencyCompact(ctx, 950000000000); // Rp 9,5 M
          return const SizedBox();
        }),
      ));
      expect(out, '+9.5B');
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (ctx) {
          out = formatCurrencyCompact(ctx, -50000); // Rp -500
          return const SizedBox();
        }),
      ));
      expect(out, '−500');
    });
  });
}