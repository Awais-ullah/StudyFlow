import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String? subjectId;
  final bool isPinned;
  final bool isArchived;
  final DateTime? updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.subjectId,
    this.isPinned = false,
    this.isArchived = false,
    this.updatedAt,
  });

  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      subjectId: map['subjectId'] as String?,
      isPinned: map['isPinned'] as bool? ?? false,
      isArchived: map['isArchived'] as bool? ?? false,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'subjectId': subjectId,
      'isPinned': isPinned,
      'isArchived': isArchived,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Note copyWith({
    String? title,
    String? content,
    String? subjectId,
    bool? isPinned,
    bool? isArchived,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      subjectId: subjectId ?? this.subjectId,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      updatedAt: updatedAt,
    );
  }
}