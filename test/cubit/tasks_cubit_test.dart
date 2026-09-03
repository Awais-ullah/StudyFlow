import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study_flow/features/tasks/cubit/tasks_cubit.dart';
import 'package:study_flow/features/tasks/cubit/tasks_state.dart';
import 'package:study_flow/features/tasks/repository/tasks_repository.dart';
import 'package:study_flow/models/task.dart';


class MockTasksRepository extends Mock implements TasksRepository {}

void main() {
  late MockTasksRepository mockRepository;
  const testUserId = 'test-uid';

  setUp(() {
    mockRepository = MockTasksRepository();
  });

  group('TasksCubit', () {
    final sampleTasks = [
      Task(id: '1', title: 'Overdue Task', dueDate: DateTime.now().subtract(const Duration(days: 2))),
      Task(id: '2', title: 'Today Task', dueDate: DateTime.now().add(const Duration(hours: 2))),
      Task(id: '3', title: 'Done Task', dueDate: DateTime.now(), isCompleted: true),
    ];

    blocTest<TasksCubit, TasksState>(
      'emits TasksLoaded with correctly categorized tasks when stream emits',
      setUp: () {
        when(() => mockRepository.watchTasks(testUserId))
            .thenAnswer((_) => Stream.value(sampleTasks));
      },
      build: () => TasksCubit(mockRepository, testUserId),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) {
        final state = cubit.state as TasksLoaded;
        expect(state.overdueTasks.length, 1);
        expect(state.overdueTasks.first.title, 'Overdue Task');
        expect(state.completedTasks.length, 1);
      },
    );

    blocTest<TasksCubit, TasksState>(
      'search filters tasks by title within categories',
      setUp: () {
        when(() => mockRepository.watchTasks(testUserId))
            .thenAnswer((_) => Stream.value(sampleTasks));
      },
      build: () => TasksCubit(mockRepository, testUserId),
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 10));
        cubit.search('overdue');
      },
      verify: (cubit) {
        final state = cubit.state as TasksLoaded;
        expect(state.overdueTasks.length, 1);
        expect(state.todayTasks.length, 0); // "Today Task" doesn't match "overdue"
      },
    );

    blocTest<TasksCubit, TasksState>(
      'emits TasksError when the repository stream throws',
      setUp: () {
        when(() => mockRepository.watchTasks(testUserId))
            .thenAnswer((_) => Stream.error(Exception('Firestore down')));
      },
      build: () => TasksCubit(mockRepository, testUserId),
      wait: const Duration(milliseconds: 10),
      verify: (cubit) => expect(cubit.state, isA<TasksError>()),
    );
  });
}