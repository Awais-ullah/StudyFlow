import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskType { assignment, homework, quiz, exam, project, personal }
enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final String? subjectId;
  final TaskType type;
  final TaskPriority priority;
  final DateTime dueDate;
  final bool isCompleted;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.subjectId,
    this.type = TaskType.personal,
    this.priority = TaskPriority.medium,
    required this.dueDate,
    this.isCompleted = false,
  });

  /// True if overdue: due date has passed AND it's not completed.
  /// Completed tasks are never "overdue" regardless of date — this is a
  /// deliberate business rule, not just a technicality.
  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day;
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      subjectId: map['subjectId'] as String?,
      type: TaskType.values.firstWhere(
            (t) => t.name == map['type'],
        orElse: () => TaskType.personal,
      ),
      priority: TaskPriority.values.firstWhere(
            (p) => p.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'type': type.name,
      'priority': priority.name,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
    };
  }

  Task copyWith({
    String? title,
    String? description,
    String? subjectId,
    TaskType? type,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}