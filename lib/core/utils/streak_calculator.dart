import '../../models/study_session.dart';

class StreakResult {
  final int currentStreak;
  final int longestStreak;
  const StreakResult({required this.currentStreak, required this.longestStreak});
}

class StreakCalculator {
  StreakCalculator._();

  static StreakResult calculate(List<StudySession> sessions) {
    if (sessions.isEmpty) return const StreakResult(currentStreak: 0, longestStreak: 0);

    final studyDays = sessions.map((s) {
      final d = s.startTime;
      return DateTime(d.year, d.month, d.day);
    }).toSet();

    final today = _dateOnly(DateTime.now());
    int currentStreak = 0;
    DateTime cursor = today;

    if (!studyDays.contains(today)) {
      cursor = today.subtract(const Duration(days: 1));
    }

    while (studyDays.contains(cursor)) {
      currentStreak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final sortedDays = studyDays.toList()..sort();
    int longestStreak = 0;
    int runLength = 0;
    DateTime? previousDay;

    for (final day in sortedDays) {
      if (previousDay != null && day.difference(previousDay).inDays == 1) {
        runLength++;
      } else {
        runLength = 1;
      }
      if (runLength > longestStreak) longestStreak = runLength;
      previousDay = day;
    }

    return StreakResult(currentStreak: currentStreak, longestStreak: longestStreak);
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}