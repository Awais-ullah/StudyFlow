import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/subjects_repository.dart';
import '../../../models/subject.dart';
import 'subjects_state.dart';

class SubjectsCubit extends Cubit<SubjectsState> {
  final SubjectsRepository _repository;
  final String userId;
  StreamSubscription? _subscription;

  SubjectsCubit(this._repository, this.userId) : super(SubjectsLoading()) {
    _watch();
  }

  void _watch() {
    _subscription = _repository.watchSubjects(userId).listen(
          (subjects) {
        final current = state;
        emit(
          SubjectsLoaded(
            allSubjects: subjects,
            sort: current is SubjectsLoaded ? current.sort : SubjectSort.nameAsc,
            searchQuery: current is SubjectsLoaded ? current.searchQuery : '',
          ),
        );
      },
      onError: (e) => emit(SubjectsError('Failed to load subjects: $e')),
    );
  }

  void setSort(SubjectSort sort) {
    if (state is SubjectsLoaded) {
      emit((state as SubjectsLoaded).copyWith(sort: sort));
    }
  }

  void search(String query) {
    if (state is SubjectsLoaded) {
      emit((state as SubjectsLoaded).copyWith(searchQuery: query));
    }
  }

  Future<void> addSubject(Subject subject) async {
    try {
      await _repository.addSubject(userId, subject);
    } catch (e) {
      emit(SubjectsError('Failed to add subject: $e'));
    }
  }

  Future<void> updateSubject(Subject subject) async {
    try {
      await _repository.updateSubject(userId, subject);
    } catch (e) {
      emit(SubjectsError('Failed to update subject: $e'));
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      await _repository.deleteSubject(userId, subjectId);
    } catch (e) {
      emit(SubjectsError('Failed to delete subject: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}