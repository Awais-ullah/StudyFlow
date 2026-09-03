import 'package:equatable/equatable.dart';
import '../../../models/task.dart';

enum TaskCategory { today, upcoming, completed, overdue }

abstract class TasksState extends Equatable {
  const TasksState();
  @override
  List<Object?> get props => [];
}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<Task> allTasks;
  final String searchQuery;

  const TasksLoaded(this.allTasks, {this.searchQuery = ''});

  List<Task> _matchingSearch(List<Task> tasks) {
    if (searchQuery.isEmpty) return tasks;
    final q = searchQuery.toLowerCase();
    return tasks.where((t) => t.title.toLowerCase().contains(q)).toList();
  }

  /// Categorization logic lives here, once, as computed getters — every
  /// screen (this list, the Dashboard later) reads from the same source
  /// of truth instead of re-implementing date math independently.
  List<Task> get overdueTasks =>
      _matchingSearch(allTasks.where((t) => t.isOverdue).toList());

  List<Task> get todayTasks => _matchingSearch(
    allTasks
        .where((t) => t.isDueToday && !t.isCompleted && !t.isOverdue)
        .toList(),
  );

  List<Task> get upcomingTasks => _matchingSearch(
    allTasks
        .where((t) => !t.isCompleted && !t.isOverdue && !t.isDueToday)
        .toList(),
  );

  List<Task> get completedTasks =>
      _matchingSearch(allTasks.where((t) => t.isCompleted).toList());

  TasksLoaded copyWith({List<Task>? allTasks, String? searchQuery}) {
    return TasksLoaded(
      allTasks ?? this.allTasks,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allTasks, searchQuery];
}

class TasksError extends TasksState {
  final String message;
  const TasksError(this.message);
  @override
  List<Object?> get props => [message];
}