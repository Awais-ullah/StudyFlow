import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionStatus { scheduled, completed, missed }

class StudySession {
  final String id;
  final String? subjectId;
  final DateTime startTime;
  final DateTime endTime;
  final String goal;
  final SessionStatus status;

  const StudySession({
    required this.id,
    this.subjectId,
    required this.startTime,
    required this.endTime,
    this.goal = '',
    this.status = SessionStatus.scheduled,
  });

  Duration get duration => endTime.difference(startTime);

  factory StudySession.fromMap(String id, Map<String, dynamic> map) {
    return StudySession(
      id: id,
      subjectId: map['subjectId'] as String?,
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      goal: map['goal'] as String? ?? '',
      status: SessionStatus.values.firstWhere(
            (s) => s.name == map['status'],
        orElse: () => SessionStatus.scheduled,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'goal': goal,
      'status': status.name,
    };
  }
}