import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../subjects/cubit/subjects_cubit.dart';
import '../../subjects/repository/subjects_repository.dart';
import '../cubit/planner_cubit.dart';
import '../cubit/planner_state.dart';
import 'add_session_screen.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planner')),
      body: BlocBuilder<PlannerCubit, PlannerState>(
        builder: (context, state) {
          if (state is PlannerLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PlannerError) {
            return Center(child: Text(state.message));
          }

          final loaded = state as PlannerLoaded;

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: loaded.selectedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(day, loaded.selectedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  context.read<PlannerCubit>().selectDay(selectedDay);
                },
                eventLoader: loaded.sessionsForDay,
                calendarStyle: CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  outsideTextStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                  Theme.of(context).textTheme.titleMedium ??
                      const TextStyle(),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  weekendStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: loaded.sessionsForSelectedDay.isEmpty
                    ? const Center(child: Text('No study sessions this day.'))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: loaded.sessionsForSelectedDay.length,
                  itemBuilder: (context, index) {
                    final session = loaded.sessionsForSelectedDay[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          '${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}',
                        ),
                        subtitle: Text(
                          session.goal.isNotEmpty
                              ? session.goal
                              : 'Study session',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => context
                              .read<PlannerCubit>()
                              .deleteSession(session.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final plannerCubit = context.read<PlannerCubit>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: plannerCubit),
                  BlocProvider(
                    create: (context) => SubjectsCubit(
                      context.read<SubjectsRepository>(),
                      plannerCubit.userId,
                    ),
                  ),
                ],
                child: const AddSessionScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}