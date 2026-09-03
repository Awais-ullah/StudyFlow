import 'package:equatable/equatable.dart';

enum PomodoroPhase { study, shortBreak, longBreak }
enum PomodoroStatus { idle, running, paused }

class PomodoroSettings extends Equatable {
  final int studyMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;

  const PomodoroSettings({
    this.studyMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
  });

  @override
  List<Object?> get props => [studyMinutes, shortBreakMinutes, longBreakMinutes, sessionsBeforeLongBreak];
}

class PomodoroState extends Equatable {
  final PomodoroSettings settings;
  final PomodoroPhase phase;
  final PomodoroStatus status;
  final int secondsRemaining;
  final int completedStudySessions;
  final String? selectedSubjectId;

  const PomodoroState({
    this.settings = const PomodoroSettings(),
    this.phase = PomodoroPhase.study,
    this.status = PomodoroStatus.idle,
    required this.secondsRemaining,
    this.completedStudySessions = 0,
    this.selectedSubjectId,
  });

  factory PomodoroState.initial([PomodoroSettings settings = const PomodoroSettings(), String? selectedSubjectId]) {
    return PomodoroState(
      settings: settings,
      secondsRemaining: settings.studyMinutes * 60,
      selectedSubjectId: selectedSubjectId,
    );
  }

  PomodoroState copyWith({
    PomodoroSettings? settings,
    PomodoroPhase? phase,
    PomodoroStatus? status,
    int? secondsRemaining,
    int? completedStudySessions,
    String? selectedSubjectId,
  }) {
    return PomodoroState(
      settings: settings ?? this.settings,
      phase: phase ?? this.phase,
      status: status ?? this.status,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      completedStudySessions: completedStudySessions ?? this.completedStudySessions,
      selectedSubjectId: selectedSubjectId ?? this.selectedSubjectId,
    );
  }

  @override
  List<Object?> get props => [settings, phase, status, secondsRemaining, completedStudySessions, selectedSubjectId];
}