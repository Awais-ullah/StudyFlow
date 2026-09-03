import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/study_sessions_repository.dart';
import '../../../models/study_session.dart';
import 'planner_state.dart';

class PlannerCubit extends Cubit<PlannerState> {
  final StudySessionsRepository _repository;
  final String userId;
  StreamSubscription? _subscription;

  PlannerCubit(this._repository, this.userId)
      : super(PlannerLoading()) {
    _subscription = _repository.watchSessions(userId).listen(
          (sessions) {
        final current = state;
        emit(PlannerLoaded(
          allSessions: sessions,
          selectedDay: current is PlannerLoaded ? current.selectedDay : DateTime.now(),
        ));
      },
      onError: (e) => emit(PlannerError('Failed to load sessions: $e')),
    );
  }

  void selectDay(DateTime day) {
    if (state is PlannerLoaded) emit((state as PlannerLoaded).copyWith(selectedDay: day));
  }

  Future<void> addSession(StudySession session) async {
    try {
      await _repository.addSession(userId, session);
    } catch (e) {
      emit(PlannerError('Failed to add session: $e'));
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _repository.deleteSession(userId, sessionId);
    } catch (e) {
      emit(PlannerError('Failed to delete session: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}