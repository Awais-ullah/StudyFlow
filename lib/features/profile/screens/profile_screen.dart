import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart' as provider;
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/profile_avatar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          final profile = (state as ProfileLoaded).profile;
          final profileCubit = context.read<ProfileCubit>();

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: ProfileAvatar(
                  imagePath: profile.photoUrl,
                  fallbackInitial: profile.displayName.isNotEmpty ? profile.displayName[0] : '',
                  radius: 40,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  profile.displayName.isNotEmpty ? profile.displayName : 'Student',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Center(child: Text(profile.email)),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text('University'),
                  subtitle: Text(profile.university.isNotEmpty ? profile.university : 'Not set'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Daily Study Goal'),
                  subtitle: Text('${profile.studyGoalHours} hours'),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: provider.Consumer<ThemeController>(
                  builder: (context, themeController, _) => Column(
                    children: [
                      const ListTile(title: Text('Appearance')),
                      RadioListTile<ThemeMode>(
                        title: const Text('Light'),
                        value: ThemeMode.light,
                        groupValue: themeController.themeMode,
                        onChanged: (mode) => themeController.setThemeMode(mode!),
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('Dark'),
                        value: ThemeMode.dark,
                        groupValue: themeController.themeMode,
                        onChanged: (mode) => themeController.setThemeMode(mode!),
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('System Default'),
                        value: ThemeMode.system,
                        groupValue: themeController.themeMode,
                        onChanged: (mode) => themeController.setThemeMode(mode!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider<ProfileCubit>.value(
                      value: profileCubit,
                      child: EditProfileScreen(profile: profile),
                    ),
                  ),
                ),
                child: const Text('Edit Profile'),
              ),
            ],
          );
        },
      ),
    );
  }
}