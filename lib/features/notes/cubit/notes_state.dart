import 'package:equatable/equatable.dart';
import '../../../models/note.dart';

enum NotesFilter { all, pinned, archived }

abstract class NotesState extends Equatable {
  const NotesState();
  @override
  List<Object?> get props => [];
}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> allNotes;
  final NotesFilter filter;
  final String searchQuery;

  const NotesLoaded({
    required this.allNotes,
    this.filter = NotesFilter.all,
    this.searchQuery = '',
  });

  /// Computed, filtered view — the UI never filters manually, it just
  /// reads this getter. Keeps filtering logic in exactly one place.
  List<Note> get visibleNotes {
    var notes = allNotes.where((n) {
      switch (filter) {
        case NotesFilter.all:
          return !n.isArchived;
        case NotesFilter.pinned:
          return n.isPinned && !n.isArchived;
        case NotesFilter.archived:
          return n.isArchived;
      }
    });

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      notes = notes.where((n) =>
      n.title.toLowerCase().contains(query) || n.content.toLowerCase().contains(query));
    }

    final list = notes.toList();
    // Pinned notes float to top within the "all" view.
    list.sort((a, b) => a.isPinned == b.isPinned ? 0 : (a.isPinned ? -1 : 1));
    return list;
  }

  NotesLoaded copyWith({List<Note>? allNotes, NotesFilter? filter, String? searchQuery}) {
    return NotesLoaded(
      allNotes: allNotes ?? this.allNotes,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allNotes, filter, searchQuery];
}

class NotesError extends NotesState {
  final String message;
  const NotesError(this.message);
  @override
  List<Object?> get props => [message];
}