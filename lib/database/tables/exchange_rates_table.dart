import 'package:drift/drift.dart';

@DataClassName('ExchangeRate')
class ExchangeRatesTable extends Table {
  TextColumn get baseCurrency => text().withLength(min: 3, max: 3)();
  TextColumn get targetCurrency => text().withLength(min: 3, max: 3)();
  RealColumn get rate => real()();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column>? get primaryKey => {baseCurrency, targetCurrency, date};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (base_currency) REFERENCES currencies (code)',
        'FOREIGN KEY (target_currency) REFERENCES currencies (code)',
      ];

  @override
  String? get tableName => 'exchange_rates';
}
