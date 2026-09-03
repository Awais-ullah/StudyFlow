import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/subjects/screens/subjects_list_screen.dart';
import '../../features/subjects/cubit/subjects_cubit.dart';
import '../../features/subjects/repository/subjects_repository.dart';
import '../../features/planner/screens/planner_screen.dart';
import '../../features/planner/cubit/planner_cubit.dart';
import '../../features/planner/repository/study_sessions_repository.dart';
import '../../features/tasks/repository/tasks_repository.dart';
import '../../features/statistics/cubit/statistics_cubit.dart';
import '../../features/statistics/screens/statistics_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/cubit/profile_cubit.dart';
import '../../features/profile/repository/profile_repository.dart';

/// Bottom-nav shell. StatisticsCubit AND ProfileCubit are both created
/// ONCE here and hoisted above all 5 tabs — Statistics needs this for
/// Dashboard's streak card, and Profile needs this so Dashboard can also
/// read the user's display name for the "Hello, {name}" greeting,
/// without each screen spinning up its own separate Firestore listener.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = AuthService().currentUser!.uid;
    NotificationService().requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => StatisticsCubit(
            context.read<StudySessionsRepository>(),
            context.read<TasksRepository>(),
            _uid,
          ),
        ),
        BlocProvider(
          create: (context) => ProfileCubit(context.read<ProfileRepository>())..loadProfile(_uid),
        ),
      ],
      child: Builder(
        builder: (context) {
          final screens = [
            const DashboardScreen(),
            BlocProvider(
              create: (context) => SubjectsCubit(context.read<SubjectsRepository>(), _uid),
              child: const SubjectsListScreen(),
            ),
            BlocProvider(
              create: (context) => PlannerCubit(context.read<StudySessionsRepository>(), _uid),
              child: const PlannerScreen(),
            ),
            const StatisticsScreen(),
            const ProfileScreen(), // reads the hoisted ProfileCubit above
          ];

          return Scaffold(
            body: IndexedStack(index: _currentIndex, children: screens),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Subjects'),
                NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Planner'),
                NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Statistics'),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          );
        },
      ),
    );
  }
}