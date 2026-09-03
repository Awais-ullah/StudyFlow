import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../planner/repository/study_sessions_repository.dart';
import '../../tasks/repository/tasks_repository.dart';
import 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final StudySessionsRepository _sessionsRepository;
  final TasksRepository _tasksRepository;
  final String userId;

  StreamSubscription? _sessionsSub;
  StreamSubscription? _tasksSub;

  StatisticsCubit(this._sessionsRepository, this._tasksRepository, this.userId)
      : super(const StatisticsState()) {
    _sessionsSub = _sessionsRepository.watchSessions(userId).listen((sessions) {
      emit(state.copyWith(sessions: sessions, isLoading: false));
    });
    _tasksSub = _tasksRepository.watchTasks(userId).listen((tasks) {
      emit(state.copyWith(tasks: tasks, isLoading: false));
    });
  }

  @override
  Future<void> close() {
    _sessionsSub?.cancel();
    _tasksSub?.cancel();
    return super.close();
  }
}