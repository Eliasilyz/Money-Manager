import 'package:drift/drift.dart';

@TableIndex(name: 'idx_debt_payments_debt_id', columns: {#debtId})
@DataClassName('DebtPayment')
class DebtPaymentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get debtId => text()();
  TextColumn get accountId => text()();
  IntColumn get amount => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn? get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (debt_id) REFERENCES debts (id)',
        'FOREIGN KEY (account_id) REFERENCES accounts (id)',
      ];

  @override
  String? get tableName => 'debt_payments';
}
