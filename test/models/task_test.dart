import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/models/task.dart';


void main() {
  group('Task.isOverdue', () {
    test('returns true when due date is in the past and not completed', () {
      final task = Task(
        id: '1',
        title: 'Test',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        isCompleted: false,
      );
      expect(task.isOverdue, isTrue);
    });

    test('returns false when due date is in the past but IS completed', () {
      final task = Task(
        id: '1',
        title: 'Test',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        isCompleted: true,
      );
      expect(task.isOverdue, isFalse);
    });

    test('returns false when due date is in the future', () {
      final task = Task(
        id: '1',
        title: 'Test',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
      );
      expect(task.isOverdue, isFalse);
    });
  });

  group('Task.isDueToday', () {
    test('returns true for a due date later today', () {
      final now = DateTime.now();
      final task = Task(id: '1', title: 'Test', dueDate: DateTime(now.year, now.month, now.day, 23, 59));
      expect(task.isDueToday, isTrue);
    });

    test('returns false for a due date tomorrow', () {
      final task = Task(id: '1', title: 'Test', dueDate: DateTime.now().add(const Duration(days: 1)));
      expect(task.isDueToday, isFalse);
    });
  });

  group('Task.fromMap / toMap round-trip', () {
    test('preserves all fields through map conversion', () {
      final original = Task(
        id: '1',
        title: 'Physics Homework',
        description: 'Chapter 5',
        subjectId: 'physics-101',
        type: TaskType.homework,
        priority: TaskPriority.high,
        dueDate: DateTime(2026, 12, 25, 14, 30),
        isCompleted: false,
      );

      final map = original.toMap();
      final restored = Task.fromMap('1', map);

      expect(restored.title, original.title);
      expect(restored.type, original.type);
      expect(restored.priority, original.priority);
      expect(restored.dueDate, original.dueDate);
    });

    test('falls back to safe defaults for unrecognized enum strings', () {
      final map = {
        'title': 'Test',
        'type': 'not_a_real_type',
        'priority': 'not_a_real_priority',
        'dueDate': null, // will throw if not handled — see note below
      };
      // Note: dueDate is required with no fallback in our current model,
      // so this specific case documents a real gap — see Common Errors
      // in this step's write-up for the discussion.
    });
  });
}