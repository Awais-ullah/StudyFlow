import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/notes_repository.dart';
import '../../../models/note.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final NotesRepository _repository;
  final String userId;
  StreamSubscription? _subscription;

  NotesCubit(this._repository, this.userId) : super(NotesLoading()) {
    _subscription = _repository.watchNotes(userId).listen(
          (notes) {
        final current = state;
        emit(NotesLoaded(
          allNotes: notes,
          filter: current is NotesLoaded ? current.filter : NotesFilter.all,
          searchQuery: current is NotesLoaded ? current.searchQuery : '',
        ));
      },
      onError: (e) => emit(NotesError('Failed to load notes: $e')),
    );
  }

  void setFilter(NotesFilter filter) {
    if (state is NotesLoaded) emit((state as NotesLoaded).copyWith(filter: filter));
  }

  void search(String query) {
    if (state is NotesLoaded) emit((state as NotesLoaded).copyWith(searchQuery: query));
  }

  Future<void> addNote(Note note) async {
    try {
      await _repository.addNote(userId, note);
    } catch (e) {
      emit(NotesError('Failed to add note: $e'));
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _repository.updateNote(userId, note);
    } catch (e) {
      emit(NotesError('Failed to update note: $e'));
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _repository.deleteNote(userId, noteId);
    } catch (e) {
      emit(NotesError('Failed to delete note: $e'));
    }
  }

  Future<void> togglePin(String noteId, bool isPinned) async {
    try {
      await _repository.togglePin(userId, noteId, isPinned);
    } catch (e) {
      emit(NotesError('Failed to update note: $e'));
    }
  }

  Future<void> toggleArchive(String noteId, bool isArchived) async {
    try {
      await _repository.toggleArchive(userId, noteId, isArchived);
    } catch (e) {
      emit(NotesError('Failed to update note: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}