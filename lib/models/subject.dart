import 'package:flutter/material.dart';

class Subject {
  final String id;
  final String name;
  final String teacherName;
  final Color color;
  final IconData icon;
  final int totalChapters;
  final int completedChapters;

  const Subject({
    required this.id,
    required this.name,
    this.teacherName = '',
    this.color = Colors.blue,
    this.icon = Icons.book,
    this.totalChapters = 0,
    this.completedChapters = 0,
  });

  double get progress => totalChapters == 0 ? 0 : completedChapters / totalChapters;

  factory Subject.fromMap(String id, Map<String, dynamic> map) {
    return Subject(
      id: id,
      name: map['name'] as String? ?? '',
      teacherName: map['teacherName'] as String? ?? '',
      color: Color(map['colorValue'] as int? ?? Colors.blue.value),
      icon: IconData(map['iconCode'] as int? ?? Icons.book.codePoint, fontFamily: 'MaterialIcons'),
      totalChapters: map['totalChapters'] as int? ?? 0,
      completedChapters: map['completedChapters'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'teacherName': teacherName,
      'colorValue': color.value,
      'iconCode': icon.codePoint,
      'totalChapters': totalChapters,
      'completedChapters': completedChapters,
    };
  }

  Subject copyWith({
    String? name,
    String? teacherName,
    Color? color,
    IconData? icon,
    int? totalChapters,
    int? completedChapters,
  }) {
    return Subject(
      id: id,
      name: name ?? this.name,
      teacherName: teacherName ?? this.teacherName,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      totalChapters: totalChapters ?? this.totalChapters,
      completedChapters: completedChapters ?? this.completedChapters,
    );
  }
}