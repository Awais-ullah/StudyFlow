import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/notes_cubit.dart';
import '../cubit/notes_state.dart';
import '../repository/notes_repository.dart';
import '../../../models/note.dart';
import 'add_edit_note_screen.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<NotesCubit>().userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) => context.read<NotesCubit>().search(value),
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          if (state is NotesLoading) return const Center(child: CircularProgressIndicator());
          if (state is NotesError) return Center(child: Text(state.message));

          final loaded = state as NotesLoaded;
          final notes = loaded.visibleNotes;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SegmentedButton<NotesFilter>(
                  segments: const [
                    ButtonSegment(value: NotesFilter.all, label: Text('All')),
                    ButtonSegment(value: NotesFilter.pinned, label: Text('Pinned')),
                    ButtonSegment(value: NotesFilter.archived, label: Text('Archived')),
                  ],
                  selected: {loaded.filter},
                  onSelectionChanged: (s) => context.read<NotesCubit>().setFilter(s.first),
                ),
              ),
              Expanded(
                child: notes.isEmpty
                    ? const Center(child: Text('No notes here yet.'))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      child: ListTile(
                        title: Text(note.title),
                        subtitle: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                        onTap: () => _pushAddEdit(context, userId, note: note),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            final cubit = context.read<NotesCubit>();
                            switch (value) {
                              case 'pin':
                                cubit.togglePin(note.id, !note.isPinned);
                                break;
                              case 'archive':
                                cubit.toggleArchive(note.id, !note.isArchived);
                                break;
                              case 'delete':
                                cubit.deleteNote(note.id);
                                break;
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'pin', child: Text(note.isPinned ? 'Unpin' : 'Pin')),
                            PopupMenuItem(
                              value: 'archive',
                              child: Text(note.isArchived ? 'Unarchive' : 'Archive'),
                            ),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pushAddEdit(context, userId),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _pushAddEdit(BuildContext context, String userId, {Note? note}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => NotesCubit(context.read<NotesRepository>(), userId),
          child: AddEditNoteScreen(note: note),
        ),
      ),
    );
  }
}