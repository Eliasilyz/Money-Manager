import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';

void main() {
  group('convertAmount', () {
    const rates = <String, double>{
      'IDR:USD': 0.000064,
      'EUR:IDR': 17000.0,
    };

    test('direct pair converts', () {
      expect(convertAmount(15625, 'IDR', 'USD', rates), closeTo(1.0, 1e-9));
    });

    test('inverse pair converts', () {
      expect(convertAmount(34000, 'IDR', 'EUR', rates), closeTo(2.0, 1e-9));
    });

    test('unknown pair falls back to 1:1', () {
      expect(convertAmount(1000, 'USD', 'GBP', rates), 1000);
    });

    test('same currency is identity', () {
      expect(convertAmount(777, 'IDR', 'IDR', rates), 777);
    });
  });
}
