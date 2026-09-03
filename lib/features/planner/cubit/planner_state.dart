import 'package:equatable/equatable.dart';
import '../../../models/study_session.dart';

abstract class PlannerState extends Equatable {
  const PlannerState();
  @override
  List<Object?> get props => [];
}

class PlannerLoading extends PlannerState {}

class PlannerLoaded extends PlannerState {
  final List<StudySession> allSessions;
  final DateTime selectedDay;

  const PlannerLoaded({required this.allSessions, required this.selectedDay});

  /// Sessions for whichever day is currently selected on the calendar.
  List<StudySession> get sessionsForSelectedDay => allSessions.where((s) {
    return s.startTime.year == selectedDay.year &&
        s.startTime.month == selectedDay.month &&
        s.startTime.day == selectedDay.day;
  }).toList();

  /// Used by table_calendar to show a dot marker under days with sessions.
  List<StudySession> sessionsForDay(DateTime day) => allSessions.where((s) {
    return s.startTime.year == day.year &&
        s.startTime.month == day.month &&
        s.startTime.day == day.day;
  }).toList();

  PlannerLoaded copyWith({List<StudySession>? allSessions, DateTime? selectedDay}) {
    return PlannerLoaded(
      allSessions: allSessions ?? this.allSessions,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }

  @override
  List<Object?> get props => [allSessions, selectedDay];
}

class PlannerError extends PlannerState {
  final String message;
  const PlannerError(this.message);
  @override
  List<Object?> get props => [message];
}