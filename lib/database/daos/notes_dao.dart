import 'package:drift/drift.dart';
import 'package:money_manager/database/tables/notes_table.dart';
import 'package:money_manager/database/database.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [NotesTable])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  final AppDatabase db;

  NotesDao(this.db) : super(db);

  Future<int> insertNote(NotesTableCompanion note) => into(notesTable).insert(note);
  Future<bool> updateNote(NotesTableCompanion note) => update(notesTable).replace(note);
  Future<int> deleteNote(String id) => (delete(notesTable)..where((n) => n.id.equals(id))).go();
  Future<List<Note>> getAllNotes() => select(notesTable).get();
  Stream<List<Note>> watchAllNotes() => select(notesTable).watch();
  Future<Note?> getNoteById(String id) => (select(notesTable)..where((n) => n.id.equals(id))).getSingleOrNull();
}
