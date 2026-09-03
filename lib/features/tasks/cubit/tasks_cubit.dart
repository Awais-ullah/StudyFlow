import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/tasks_repository.dart';
import '../../../models/task.dart';
import 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final TasksRepository _repository;
  final String userId;
  StreamSubscription? _subscription;

  TasksCubit(this._repository, this.userId) : super(TasksLoading()) {
    _subscription = _repository.watchTasks(userId).listen(
          (tasks) {
        final current = state;
        emit(
          TasksLoaded(
            tasks,
            searchQuery: current is TasksLoaded ? current.searchQuery : '',
          ),
        );
      },
      onError: (e) => emit(TasksError('Failed to load tasks: $e')),
    );
  }

  void search(String query) {
    if (state is TasksLoaded) {
      emit((state as TasksLoaded).copyWith(searchQuery: query));
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _repository.addTask(userId, task);
    } catch (e) {
      emit(TasksError('Failed to add task: $e'));
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _repository.updateTask(userId, task);
    } catch (e) {
      emit(TasksError('Failed to update task: $e'));
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(userId, taskId);
    } catch (e) {
      emit(TasksError('Failed to delete task: $e'));
    }
  }

  Future<void> toggleComplete(String taskId, bool isCompleted) async {
    try {
      await _repository.toggleComplete(userId, taskId, isCompleted);
    } catch (e) {
      emit(TasksError('Failed to update task: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}