import 'package:drift/drift.dart';

@TableIndex(name: 'idx_debts_due_date', columns: {#dueDate})
@DataClassName('Debt')
class DebtsTable extends Table {
  TextColumn get id => text()();
  TextColumn get personName => text()();
  TextColumn get type => text()();
  IntColumn get originalAmount => integer()();
  IntColumn get remainingAmount => integer()();
  TextColumn get currencyCode => text()();
  TextColumn? get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime()();
  IntColumn? get totalInstallments => integer().nullable()();
  IntColumn? get paidInstallments => integer().nullable()();
  IntColumn? get billingDay => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('unpaid'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'debts';
}
