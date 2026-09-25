import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/database/database.dart';
import 'package:money_manager/features/settings/application/backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('BackupService', () {
    late AppDatabase db;
    const service = BackupService();

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.memory();
    });

    tearDown(() => db.close());

    Future<void> seedData() async {
      await db.into(db.accountsTable).insert(
            const AccountsTableCompanion(
              id: Value('acc-1'),
              name: Value('Tabungan'),
              accountType: Value('bank'),
              currencyCode: Value('IDR'),
              initialBalance: Value(500000),
              systemKey: Value(null),
            ),
          );
      await db.into(db.categoriesTable).insert(
            const CategoriesTableCompanion(
              id: Value('cat-1'),
              name: Value('Makan'),
              type: Value('expense'),
              icon: Value('restaurant'),
              systemKey: Value(null),
            ),
          );
      await db.into(db.notesTable).insert(
            NotesTableCompanion(
              id: const Value('note-1'),
              title: const Value('Catatan'),
              body: const Value('Isi'),
              createdAt: Value(DateTime(2025, 1, 1)),
              updatedAt: Value(DateTime(2025, 1, 2)),
            ),
          );
    }

    test('export then restore roundtrips all seeded data', () async {
      await seedData();
      final raw = await service.generateBackup(db);
      final parsed = await service.parseBackup(raw);
      expect(parsed['accounts'], hasLength(1));
      expect(parsed['categories'], hasLength(1));
      expect(parsed['notes'], hasLength(1));

      final cleanDb = AppDatabase.memory();
      addTearDown(cleanDb.close);
      final count = await service.restoreBackup(cleanDb, parsed);
      expect(count, 3);

      expect((await cleanDb.getAllAccounts()).first.name, 'Tabungan');
      expect((await cleanDb.getAllCategories()).first.name, 'Makan');
      expect((await cleanDb.notesDao.getAllNotes()).single.title, 'Catatan');
    });

    test('schema version is embedded', () async {
      await seedData();
      final raw = await service.generateBackup(db);
      final root = jsonDecode(raw) as Map<String, dynamic>;
      expect(root['format'], backupFormatIdentifier);
      expect(root['schemaVersion'], isA<int>());
      expect(root['data'], isA<Map<String, dynamic>>());
    });

    test('corrupted file is rejected', () async {
      await expectLater(service.parseBackup('{bukan json'), throwsA(isA<BackupException>()));
      await expectLater(service.parseBackup('{"format":"money_manager_backup"}'), throwsA(isA<BackupException>()));
    });

    test('unknown format is rejected', () async {
      const raw = '{"format":"something_else","schemaVersion":1,"data":{}}';
      await expectLater(service.parseBackup(raw), throwsA(isA<BackupException>()));
    });

    test('old schema is accepted', () async {
      await seedData();
      final raw = await service.generateBackup(db);
      final root = jsonDecode(raw) as Map<String, dynamic>;
      root['schemaVersion'] = 1;
      final parsed = await service.parseBackup(jsonEncode(root));
      expect(parsed['accounts'], hasLength(1));
    });

    test('unknown (newer) schema is rejected', () async {
      await seedData();
      final raw = await service.generateBackup(db);
      final root = jsonDecode(raw) as Map<String, dynamic>;
      root['schemaVersion'] = 99;
      await expectLater(service.parseBackup(jsonEncode(root)), throwsA(isA<BackupException>()));
    });

    test('malformed collection row values are rejected', () async {
      final raw = jsonEncode({
        'format': backupFormatIdentifier,
        'schemaVersion': 1,
        'data': {'accounts': 'bukan list'},
      });
      await expectLater(service.parseBackup(raw), throwsA(isA<BackupException>()));
    });

    test('unknown collection names are detected', () {
      final data = {
        'accounts': <Map<String, dynamic>>[],
        'totally_unknown': <Map<String, dynamic>>[],
      };
      expect(service.hasUnknownCollections(data), isTrue);
      expect(service.hasUnknownCollections({'accounts': []}), isFalse);
    });

    test('malformed rows inside restore leave existing data intact', () async {
      await seedData();
      final malformed = {
        'accounts': <Map<String, dynamic>>[
          {'id': 'x', 'name': 'Y'},
        ],
      };
      // "x"/"Y" are wrong types for this schema; ensure it throws and does
      // not silently wipe current data.
      expect(service.restoreBackup(db, malformed), throwsA(anything));
      expect(await db.getAllAccounts(), isNotEmpty);
    });

    test('encrypted backup requires password', () async {
      await seedData();
      final raw = await service.generateBackup(db, password: 'rahasia');
      await expectLater(service.parseBackup(raw), throwsA(isA<BackupException>()));
      await expectLater(service.parseBackup(raw, password: 'salah'), throwsA(isA<BackupException>()));

      final parsed = await service.parseBackup(raw, password: 'rahasia');
      expect(parsed['accounts'], hasLength(1));
    });
  });
}