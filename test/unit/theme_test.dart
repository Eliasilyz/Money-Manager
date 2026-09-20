import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/theme/app_colors.dart';

double _luminance(Color c) {
  double sc(double x) => x <= 0.03928 ? x / 12.92 : math.pow((x + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * sc(c.r) + 0.7152 * sc(c.g) + 0.0722 * sc(c.b);
}

double contrast(Color a, Color b) {
  final l1 = _luminance(a), l2 = _luminance(b);
  final hi = math.max(l1, l2);
  final lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('AppColorsT tokens', () {
    test('light and dark tokens are distinct', () {
      expect(AppColorsT.light.background, isNot(AppColorsT.dark.background));
      expect(AppColorsT.light.textPrimary, isNot(AppColorsT.dark.textPrimary));
      expect(AppColorsT.light.primary, isNot(AppColorsT.dark.primary));
    });

    test('light theme contrasts meet WCAG', () {
      const t = AppColorsT.light;
      final c1 = contrast(t.textPrimary, t.background);
      final c2 = contrast(t.textSecondary, t.background);
      final c3 = contrast(t.textPrimary, t.surface);
      final c4 = contrast(Colors.white, t.heroCard);
      // ignore: avoid_print
      print(
          'light: textPrimary/bg=${c1.toStringAsFixed(2)} textSecondary/bg=${c2.toStringAsFixed(2)} textPrimary/surface=${c3.toStringAsFixed(2)} white/hero=${c4.toStringAsFixed(2)}');
      expect(c1, greaterThanOrEqualTo(4.5));
      expect(c2, greaterThanOrEqualTo(3.0));
      expect(c3, greaterThanOrEqualTo(4.5));
      expect(c4, greaterThanOrEqualTo(4.5));
    });

    test('dark theme contrasts meet WCAG', () {
      const t = AppColorsT.dark;
      final c1 = contrast(t.textPrimary, t.background);
      final c2 = contrast(t.textSecondary, t.background);
      final c3 = contrast(t.textPrimary, t.surface);
      final c4 = contrast(Colors.white, t.heroCard);
      // ignore: avoid_print
      print(
          'dark: textPrimary/bg=${c1.toStringAsFixed(2)} textSecondary/bg=${c2.toStringAsFixed(2)} textPrimary/surface=${c3.toStringAsFixed(2)} white/hero=${c4.toStringAsFixed(2)}');
      expect(c1, greaterThanOrEqualTo(4.5));
      expect(c2, greaterThanOrEqualTo(3.0));
      expect(c3, greaterThanOrEqualTo(4.5));
      expect(c4, greaterThanOrEqualTo(4.5));
    });
  });
}