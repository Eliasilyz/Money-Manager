import 'package:drift/drift.dart';

@DataClassName('Category')
class CategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn? get icon => text().nullable()();
  TextColumn get type => text().withDefault(const Constant('expense'))();
  TextColumn? get parentId => text().nullable()();
  TextColumn? get systemKey => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (parent_id) REFERENCES categories (id)',
      ];

  @override
  String? get tableName => 'categories';
}
