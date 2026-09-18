import 'package:drift/drift.dart';

@DataClassName('Goal')
class GoalsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get targetAmount => integer()();
  IntColumn get currentAmount => integer().withDefault(const Constant(0))();
  TextColumn get currencyCode => text()();
  TextColumn? get linkedAccountId => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn? get targetDate => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn? get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (linked_account_id) REFERENCES accounts (id)',
      ];

  @override
  String? get tableName => 'goals';
}
