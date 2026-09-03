import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/subjects_cubit.dart';
import '../cubit/subjects_state.dart';
import '../repository/subjects_repository.dart';
import '../../../models/subject.dart';
import 'add_edit_subject_screen.dart';

class SubjectsListScreen extends StatelessWidget {
  const SubjectsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<SubjectsCubit>().userId;

    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: BlocBuilder<SubjectsCubit, SubjectsState>(
        builder: (context, state) {
          if (state is SubjectsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SubjectsError) {
            return Center(child: Text(state.message));
          }
          final subjects = (state as SubjectsLoaded).subjects;

          if (subjects.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No subjects yet.\nTap + to add your first subject.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: subject.color.withOpacity(0.15),
                    child: Icon(subject.icon, color: subject.color),
                  ),
                  title: Text(subject.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subject.teacherName.isNotEmpty) Text(subject.teacherName),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: subject.progress,
                        color: subject.color,
                        backgroundColor: subject.color.withOpacity(0.15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(subject.progress * 100).toStringAsFixed(0)}% • '
                            '${subject.completedChapters}/${subject.totalChapters} chapters',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _pushAddEdit(context, userId, subject: subject);
                      } else if (value == 'delete') {
                        context.read<SubjectsCubit>().deleteSubject(subject.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pushAddEdit(context, userId),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Pushes the Add/Edit screen with a FRESH SubjectsCubit created from
  /// the repository — this is the fix: a pushed route is a SIBLING
  /// route, not a descendant of SubjectsListScreen's BlocProvider, so it
  /// cannot see that instance. Creating a new cubit here (which only
  /// needs to WRITE, not read the existing list) sidesteps that entirely.
  void _pushAddEdit(BuildContext context, String userId, {Subject? subject}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => SubjectsCubit(context.read<SubjectsRepository>(), userId),
          child: AddEditSubjectScreen(subject: subject),
        ),
      ),
    );
  }
}