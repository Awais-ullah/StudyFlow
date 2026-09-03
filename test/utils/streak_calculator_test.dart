import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/core/utils/streak_calculator.dart';
import 'package:study_flow/models/study_session.dart';


StudySession _sessionOn(DateTime day) {
  return StudySession(
    id: '',
    startTime: DateTime(day.year, day.month, day.day, 10),
    endTime: DateTime(day.year, day.month, day.day, 11),
  );
}

void main() {
  group('StreakCalculator', () {
    test('returns 0/0 for no sessions', () {
      final result = StreakCalculator.calculate([]);
      expect(result.currentStreak, 0);
      expect(result.longestStreak, 0);
    });

    test('counts a single session today as a 1-day streak', () {
      final result = StreakCalculator.calculate([_sessionOn(DateTime.now())]);
      expect(result.currentStreak, 1);
    });

    test('counts consecutive days correctly', () {
      final today = DateTime.now();
      final sessions = List.generate(5, (i) => _sessionOn(today.subtract(Duration(days: i))));
      final result = StreakCalculator.calculate(sessions);
      expect(result.currentStreak, 5);
    });

    test('does NOT reset streak if today has no session yet, but yesterday does', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = StreakCalculator.calculate([_sessionOn(yesterday)]);
      expect(result.currentStreak, 1); // still counts yesterday's day
    });

    test('resets to 0 if there is a gap before today', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final result = StreakCalculator.calculate([_sessionOn(threeDaysAgo)]);
      expect(result.currentStreak, 0);
    });

    test('longest streak persists even after the current streak breaks', () {
      final today = DateTime.now();
      final sessions = [
        _sessionOn(today.subtract(const Duration(days: 10))),
        _sessionOn(today.subtract(const Duration(days: 9))),
        _sessionOn(today.subtract(const Duration(days: 8))),
        // gap here
        _sessionOn(today), // current streak = 1, but longest should be 3
      ];
      final result = StreakCalculator.calculate(sessions);
      expect(result.currentStreak, 1);
      expect(result.longestStreak, 3);
    });

    test('multiple sessions on the same day count as one streak day, not extra', () {
      final today = DateTime.now();
      final sessions = [_sessionOn(today), _sessionOn(today), _sessionOn(today)];
      final result = StreakCalculator.calculate(sessions);
      expect(result.currentStreak, 1);
    });
  });
}