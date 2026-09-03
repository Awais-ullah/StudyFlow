import 'package:equatable/equatable.dart';
import '../../../models/subject.dart';

enum SubjectSort { nameAsc, progressDesc, progressAsc }

abstract class SubjectsState extends Equatable {
  const SubjectsState();

  @override
  List<Object?> get props => [];
}

class SubjectsLoading extends SubjectsState {}

class SubjectsLoaded extends SubjectsState {
  final List<Subject> allSubjects;
  final SubjectSort sort;
  final String searchQuery;

  const SubjectsLoaded({
    required this.allSubjects,
    this.sort = SubjectSort.nameAsc,
    this.searchQuery = '',
  });

  /// Alias getter for backward compatibility and screen access
  List<Subject> get subjects => visibleSubjects;

  List<Subject> get visibleSubjects {
    var subjects = allSubjects.toList();

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      subjects = subjects
          .where((s) =>
      s.name.toLowerCase().contains(q) ||
          s.teacherName.toLowerCase().contains(q))
          .toList();
    }

    switch (sort) {
      case SubjectSort.nameAsc:
        subjects.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SubjectSort.progressDesc:
        subjects.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case SubjectSort.progressAsc:
        subjects.sort((a, b) => a.progress.compareTo(b.progress));
        break;
    }
    return subjects;
  }

  SubjectsLoaded copyWith({
    List<Subject>? allSubjects,
    SubjectSort? sort,
    String? searchQuery,
  }) {
    return SubjectsLoaded(
      allSubjects: allSubjects ?? this.allSubjects,
      sort: sort ?? this.sort,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allSubjects, sort, searchQuery];
}

class SubjectsError extends SubjectsState {
  final String message;

  const SubjectsError(this.message);

  @override
  List<Object?> get props => [message];
}