import 'package:equatable/equatable.dart';
import '../../../models/study_session.dart';
import '../../../models/task.dart';
import '../../../models/subject_session_summary.dart';
import '../../../core/utils/streak_calculator.dart';

class StatisticsState extends Equatable {
  final List<StudySession> sessions;
  final List<Task> tasks;
  final bool isLoading;

  const StatisticsState({
    this.sessions = const [],
    this.tasks = const [],
    this.isLoading = true,
  });

  Duration get totalStudyTime => sessions.fold(Duration.zero, (sum, s) => sum + s.duration);

  Duration get todayStudyTime => sessions
      .where((s) => _isSameDay(s.startTime, DateTime.now()))
      .fold(Duration.zero, (sum, s) => sum + s.duration);

  Duration get weeklyStudyTime {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return sessions
        .where((s) => s.startTime.isAfter(weekAgo))
        .fold(Duration.zero, (sum, s) => sum + s.duration);
  }

  Duration get monthlyStudyTime {
    final now = DateTime.now();
    return sessions
        .where((s) => s.startTime.year == now.year && s.startTime.month == now.month)
        .fold(Duration.zero, (sum, s) => sum + s.duration);
  }

  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;

  int get pomodoroSessionsCount => sessions.where((s) => s.goal == 'Pomodoro session').length;

  List<SubjectSessionSummary> get subjectBreakdown => SubjectSessionSummary.summarize(sessions);

  StreakResult get streak => StreakCalculator.calculate(sessions);

  List<double> get last7DaysHours {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayTotal = sessions
          .where((s) => _isSameDay(s.startTime, day))
          .fold<Duration>(Duration.zero, (sum, s) => sum + s.duration);
      return dayTotal.inMinutes / 60.0;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  StatisticsState copyWith({List<StudySession>? sessions, List<Task>? tasks, bool? isLoading}) {
    return StatisticsState(
      sessions: sessions ?? this.sessions,
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [sessions, tasks, isLoading];
}