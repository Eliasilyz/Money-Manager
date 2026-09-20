import 'package:drift/drift.dart';

@DataClassName('Account')
class AccountsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get currencyCode => text().withDefault(const Constant('IDR'))();
  TextColumn get accountType => text()();
  IntColumn get initialBalance => integer().withDefault(const Constant(0))();
  TextColumn? get icon => text().nullable()();
  TextColumn? get color => text().nullable()();
  TextColumn? get note => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn? get systemKey => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'accounts';
}
