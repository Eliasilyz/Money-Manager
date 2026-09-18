import 'package:drift/drift.dart';

@DataClassName('Transfer')
class TransfersTable extends Table {
  TextColumn get id => text()();
  TextColumn get fromAccountId => text()();
  TextColumn get toAccountId => text()();
  IntColumn get sourceAmount => integer()();
  IntColumn get destinationAmount => integer()();
  TextColumn get currencyCode => text()();
  RealColumn? get exchangeRate => real().nullable()();
  TextColumn? get description => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (from_account_id) REFERENCES accounts (id)',
        'FOREIGN KEY (to_account_id) REFERENCES accounts (id)',
      ];

  @override
  String? get tableName => 'transfers';
}
