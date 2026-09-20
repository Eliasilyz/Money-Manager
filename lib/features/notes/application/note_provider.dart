import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/note.dart';
import 'package:money_manager/domain/repositories/note_repository.dart';

final noteRepositoryProvider = Provider<INoteRepository>((ref) {
  throw UnimplementedError('NoteRepository not initialized');
});

class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final INoteRepository _repo;

  NotesNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repo.getAllNotes();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> save(Note note) async {
    final existing = state.valueOrNull ?? [];
    final found = existing.any((n) => n.id == note.id);
    if (found) {
      await _repo.updateNote(note);
    } else {
      await _repo.insertNote(note);
    }
    await loadAll();
  }

  Future<void> delete(String id) async {
    await _repo.deleteNote(id);
    await loadAll();
  }
}

final notesNotifierProvider =
    StateNotifierProvider<NotesNotifier, AsyncValue<List<Note>>>((ref) {
  return NotesNotifier(ref.read(noteRepositoryProvider));
});