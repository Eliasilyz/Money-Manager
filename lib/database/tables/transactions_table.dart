import 'package:drift/drift.dart';

@TableIndex(name: 'idx_transactions_account_id', columns: {#accountId})
@TableIndex(name: 'idx_transactions_category_id', columns: {#categoryId})
@TableIndex(name: 'idx_transactions_date', columns: {#date})
@TableIndex(name: 'idx_transactions_type', columns: {#type})
@DataClassName('Transaction')
class TransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get accountId => text()();
  TextColumn? get categoryId => text().nullable()();
  IntColumn get amount => integer()();
  TextColumn get currencyCode => text()();
  TextColumn? get description => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn? get note => text().nullable()();
  TextColumn? get transferId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (account_id) REFERENCES accounts (id)',
        'FOREIGN KEY (category_id) REFERENCES categories (id)',
        'FOREIGN KEY (currency_code) REFERENCES currencies (code)',
        'FOREIGN KEY (transfer_id) REFERENCES transfers (id)',
      ];

  @override
  String? get tableName => 'transactions';
}
