import 'package:money_manager/domain/entities/note.dart';

abstract class INoteRepository {
  Future<List<Note>> getAllNotes();
  Stream<List<Note>> watchAllNotes();
  Future<void> insertNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
}