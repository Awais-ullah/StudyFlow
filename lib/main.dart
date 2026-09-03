import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart' as provider;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_service.dart';
import 'core/routes/app_router.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/profile/repository/profile_repository.dart';
import 'features/profile/cubit/profile_cubit.dart';
import 'features/subjects/repository/subjects_repository.dart';
import 'features/notes/repository/notes_repository.dart';
import 'features/tasks/repository/tasks_repository.dart';
import 'features/planner/repository/study_sessions_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();
  runApp(const StudyFlowApp());
}

class StudyFlowApp extends StatefulWidget {
  const StudyFlowApp({super.key});

  @override
  State<StudyFlowApp> createState() => _StudyFlowAppState();
}

class _StudyFlowAppState extends State<StudyFlowApp> {
  final ThemeController _themeController = ThemeController();

  @override
  Widget build(BuildContext context) {
    return provider.ChangeNotifierProvider<ThemeController>.value(
      value: _themeController,
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (_) => ProfileRepository()),
          RepositoryProvider(create: (_) => SubjectsRepository()),
          RepositoryProvider(create: (_) => NotesRepository()),
          RepositoryProvider(create: (_) => TasksRepository()),
          RepositoryProvider(create: (_) => StudySessionsRepository()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthCubit(AuthService(), context.read<ProfileRepository>()),
            ),
          ],
          child: provider.Consumer<ThemeController>(
            builder: (context, themeController, _) {
              return MaterialApp(
                title: 'StudyFlow',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeController.themeMode,
                home: const AuthWrapper(),
              );
            },
          ),
        ),
      ),
    );
  }
}