import 'package:drift/drift.dart';

@DataClassName('Currency')
class CurrenciesTable extends Table {
  TextColumn get code => text().withLength(min: 3, max: 3)();
  TextColumn get name => text()();
  TextColumn get symbol => text()();
  IntColumn get decimalDigits => integer().withDefault(const Constant(0))();

  @override
  Set<Column>? get primaryKey => {code};

  @override
  String? get tableName => 'currencies';
}
