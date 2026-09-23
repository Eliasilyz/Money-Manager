import 'package:drift/drift.dart';

@TableIndex(name: 'idx_recurring_next_occurrence', columns: {#nextOccurrence})
@DataClassName('RecurringTransaction')
class RecurringTransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get accountId => text()();
  TextColumn? get categoryId => text().nullable()();
  IntColumn get amount => integer()();
  TextColumn get currencyCode => text()();
  TextColumn? get description => text().nullable()();
  TextColumn get frequency => text()();
  IntColumn get interval => integer().withDefault(const Constant(1))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn? get endDate => dateTime().nullable()();
  DateTimeColumn get nextOccurrence => dateTime()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'recurring_transactions';
}