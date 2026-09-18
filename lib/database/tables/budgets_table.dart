import 'package:drift/drift.dart';

@DataClassName('Budget')
class BudgetsTable extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  IntColumn get amount => integer()();
  TextColumn get currencyCode => text()();
  TextColumn get period => text().withDefault(const Constant('monthly'))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn? get endDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (category_id) REFERENCES categories (id)',
      ];

  @override
  String? get tableName => 'budgets';
}
