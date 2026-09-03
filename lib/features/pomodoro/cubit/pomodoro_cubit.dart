import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../planner/repository/study_sessions_repository.dart';
import '../../../models/study_session.dart';
import '../../../core/services/notification_service.dart';
import 'pomodoro_state.dart';

class PomodoroCubit extends Cubit<PomodoroState> {
  final StudySessionsRepository _sessionsRepository;
  final String userId;
  Timer? _timer;
  DateTime? _phaseStartTime;

  PomodoroCubit(this._sessionsRepository, this.userId) : super(PomodoroState.initial());

  void setSubject(String? subjectId) {
    emit(state.copyWith(selectedSubjectId: subjectId));
  }

  void start() {
    _phaseStartTime ??= DateTime.now();
    emit(state.copyWith(status: PomodoroStatus.running));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _timer?.cancel();
    emit(state.copyWith(status: PomodoroStatus.paused));
  }

  void reset() {
    _timer?.cancel();
    _phaseStartTime = null;
    emit(PomodoroState.initial(state.settings).copyWith(
      completedStudySessions: state.completedStudySessions,
    ));
  }

  void updateSettings(PomodoroSettings settings) {
    _timer?.cancel();
    _phaseStartTime = null;
    emit(PomodoroState.initial(settings));
  }

  void _tick() {
    if (state.secondsRemaining <= 1) {
      _completeCurrentPhase();
    } else {
      emit(state.copyWith(secondsRemaining: state.secondsRemaining - 1));
    }
  }

  void _completeCurrentPhase() {
    _timer?.cancel();

    if (state.phase == PomodoroPhase.study) {
      _saveCompletedStudySession();
      NotificationService().showInstant(
        id: 9001,
        title: 'Study session complete! 🎉',
        body: 'Time for a break.',
      );

      final newCount = state.completedStudySessions + 1;
      final needsLongBreak = newCount % state.settings.sessionsBeforeLongBreak == 0;
      final nextPhase = needsLongBreak ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;
      final nextSeconds = needsLongBreak
          ? state.settings.longBreakMinutes * 60
          : state.settings.shortBreakMinutes * 60;

      _phaseStartTime = null;
      emit(state.copyWith(
        phase: nextPhase,
        status: PomodoroStatus.idle,
        secondsRemaining: nextSeconds,
        completedStudySessions: newCount,
      ));
    } else {
      NotificationService().showInstant(
        id: 9002,
        title: 'Break\'s over!',
        body: 'Ready to get back to studying?',
      );

      _phaseStartTime = null;
      emit(state.copyWith(
        phase: PomodoroPhase.study,
        status: PomodoroStatus.idle,
        secondsRemaining: state.settings.studyMinutes * 60,
      ));
    }
  }

  Future<void> _saveCompletedStudySession() async {
    final start = _phaseStartTime ?? DateTime.now();
    final session = StudySession(
      id: '',
      startTime: start,
      endTime: DateTime.now(),
      goal: 'Pomodoro session',
      status: SessionStatus.completed,
      subjectId: state.selectedSubjectId,
    );
    try {
      await _sessionsRepository.addSession(userId, session);
    } catch (_) {}
  }

  void skip() => _completeCurrentPhase();

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}