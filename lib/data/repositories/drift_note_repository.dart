import 'package:drift/drift.dart';
import 'package:money_manager/database/database.dart' as drift;
import 'package:money_manager/domain/entities/note.dart' as domain;
import 'package:money_manager/domain/repositories/note_repository.dart';

class DriftNoteRepository implements INoteRepository {
  final drift.AppDatabase _db;

  DriftNoteRepository(this._db);

  @override
  Future<List<domain.Note>> getAllNotes() async {
    final notes = await _db.notesDao.getAllNotes();
    return notes.map(_toDomain).toList();
  }

  @override
  Stream<List<domain.Note>> watchAllNotes() =>
      _db.notesDao.watchAllNotes().map((notes) => notes.map(_toDomain).toList());

  @override
  Future<void> insertNote(domain.Note note) async {
    await _db.notesDao.insertNote(
      drift.NotesTableCompanion(
        id: Value(note.id),
        title: Value(note.title),
        body: Value(note.body),
        createdAt: Value(note.createdAt),
        updatedAt: Value(note.updatedAt),
      ),
    );
  }

  @override
  Future<void> updateNote(domain.Note note) async {
    await _db.notesDao.updateNote(
      drift.NotesTableCompanion(
        id: Value(note.id),
        title: Value(note.title),
        body: Value(note.body),
        createdAt: Value(note.createdAt),
        updatedAt: Value(note.updatedAt),
      ),
    );
  }

  @override
  Future<void> deleteNote(String id) async {
    await _db.notesDao.deleteNote(id);
  }

  domain.Note _toDomain(drift.Note n) => domain.Note(
        id: n.id,
        title: n.title,
        body: n.body,
        createdAt: n.createdAt,
        updatedAt: n.updatedAt,
      );
}