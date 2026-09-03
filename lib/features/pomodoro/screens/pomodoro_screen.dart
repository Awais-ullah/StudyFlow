import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../subjects/cubit/subjects_cubit.dart';
import '../../subjects/cubit/subjects_state.dart';
import '../cubit/pomodoro_cubit.dart';
import '../cubit/pomodoro_state.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  String _phaseLabel(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.study:
        return 'Focus Time';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<PomodoroCubit, PomodoroState>(
        builder: (context, state) {
          final totalSeconds = switch (state.phase) {
            PomodoroPhase.study => state.settings.studyMinutes * 60,
            PomodoroPhase.shortBreak => state.settings.shortBreakMinutes * 60,
            PomodoroPhase.longBreak => state.settings.longBreakMinutes * 60,
          };
          final progress = 1 - (state.secondsRemaining / totalSeconds);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_phaseLabel(state.phase), style: Theme.of(context).textTheme.titleLarge),
                BlocBuilder<SubjectsCubit, SubjectsState>(
                  builder: (context, subjectsState) {
                    if (subjectsState is! SubjectsLoaded || subjectsState.subjects.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: DropdownButton<String>(
                        hint: const Text('Link to a subject (optional)'),
                        items: subjectsState.subjects
                            .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                            .toList(),
                        onChanged: (subjectId) => context.read<PomodoroCubit>().setSubject(subjectId),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                      ),
                      Text(_formatTime(state.secondsRemaining),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 40)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => context.read<PomodoroCubit>().reset(),
                      icon: const Icon(Icons.replay),
                    ),
                    const SizedBox(width: 24),
                    IconButton.filled(
                      iconSize: 40,
                      onPressed: () {
                        final cubit = context.read<PomodoroCubit>();
                        state.status == PomodoroStatus.running ? cubit.pause() : cubit.start();
                      },
                      icon: Icon(state.status == PomodoroStatus.running ? Icons.pause : Icons.play_arrow),
                    ),
                    const SizedBox(width: 24),
                    IconButton.filledTonal(
                      onPressed: () => context.read<PomodoroCubit>().skip(),
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Completed sessions today: ${state.completedStudySessions}'),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    final cubit = context.read<PomodoroCubit>();
    final current = cubit.state.settings;
    int study = current.studyMinutes;
    int shortBreak = current.shortBreakMinutes;
    int longBreak = current.longBreakMinutes;

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Timer Settings', style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 16),
              _SettingSlider(
                label: 'Study duration',
                value: study,
                min: 5, max: 60,
                onChanged: (v) => setSheetState(() => study = v),
              ),
              _SettingSlider(
                label: 'Short break',
                value: shortBreak,
                min: 1, max: 30,
                onChanged: (v) => setSheetState(() => shortBreak = v),
              ),
              _SettingSlider(
                label: 'Long break',
                value: longBreak,
                min: 5, max: 45,
                onChanged: (v) => setSheetState(() => longBreak = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  cubit.updateSettings(PomodoroSettings(
                    studyMinutes: study,
                    shortBreakMinutes: shortBreak,
                    longBreakMinutes: longBreak,
                  ));
                  Navigator.pop(sheetContext);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _SettingSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$label: $value min'),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}