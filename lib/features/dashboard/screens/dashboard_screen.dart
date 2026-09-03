import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../../core/services/auth_service.dart';
import '../../statistics/cubit/statistics_cubit.dart';
import '../../statistics/cubit/statistics_state.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import '../../notes/cubit/notes_cubit.dart';
import '../../notes/repository/notes_repository.dart';
import '../../notes/screens/notes_list_screen.dart';
import '../../tasks/cubit/tasks_cubit.dart';
import '../../tasks/repository/tasks_repository.dart';
import '../../tasks/screens/tasks_list_screen.dart';
import '../../pomodoro/cubit/pomodoro_cubit.dart';
import '../../planner/repository/study_sessions_repository.dart';
import '../../pomodoro/screens/pomodoro_screen.dart';
import '../../subjects/cubit/subjects_cubit.dart';
import '../../subjects/repository/subjects_repository.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final uid = user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Greeting — uses the display name from the user's Firestore
          // profile (set at registration to the part before "@", editable
          // afterward in Edit Profile) instead of a generic time-of-day
          // message.
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final name = state is ProfileLoaded && state.profile.displayName.isNotEmpty
                  ? state.profile.displayName
                  : 'there';
              return Text('Hello, $name 👋', style: Theme.of(context).textTheme.titleLarge);
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Ready to continue learning?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          BlocBuilder<StatisticsCubit, StatisticsState>(
            builder: (context, state) {
              if (state.isLoading) return const SizedBox.shrink();
              return Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${state.streak.currentStreak} Day Streak',
                              style: Theme.of(context).textTheme.titleMedium),
                          Text('Longest: ${state.streak.longestStreak} days'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('Note'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) => NotesCubit(context.read<NotesRepository>(), uid),
                        child: const NotesListScreen(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Task'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) => TasksCubit(context.read<TasksRepository>(), uid),
                        child: const TasksListScreen(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.timer),
              label: const Text('Start Study Session'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) =>
                            PomodoroCubit(context.read<StudySessionsRepository>(), uid),
                      ),
                      BlocProvider(
                        create: (context) =>
                            SubjectsCubit(context.read<SubjectsRepository>(), uid),
                      ),
                    ],
                    child: const PomodoroScreen(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}