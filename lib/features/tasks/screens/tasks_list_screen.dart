import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/tasks_cubit.dart';
import '../cubit/tasks_state.dart';
import '../repository/tasks_repository.dart';
import '../../../models/task.dart';
import 'add_edit_task_screen.dart';

class TasksListScreen extends StatelessWidget {
  const TasksListScreen({super.key});

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<TasksCubit>().userId;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Overdue'),
            Tab(text: 'Completed'),
          ]),
        ),
        body: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            if (state is TasksLoading) return const Center(child: CircularProgressIndicator());
            if (state is TasksError) return Center(child: Text(state.message));

            final loaded = state as TasksLoaded;
            return TabBarView(
              children: [
                _TaskList(tasks: loaded.todayTasks, priorityColor: _priorityColor, userId: userId),
                _TaskList(tasks: loaded.upcomingTasks, priorityColor: _priorityColor, userId: userId),
                _TaskList(tasks: loaded.overdueTasks, priorityColor: _priorityColor, userId: userId),
                _TaskList(tasks: loaded.completedTasks, priorityColor: _priorityColor, userId: userId),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _pushAddEdit(context, userId),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  static void _pushAddEdit(BuildContext context, String userId, {Task? task}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => TasksCubit(context.read<TasksRepository>(), userId),
          child: AddEditTaskScreen(task: task),
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Color Function(TaskPriority) priorityColor;
  final String userId;
  const _TaskList({required this.tasks, required this.priorityColor, required this.userId});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const Center(child: Text('Nothing here.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          child: ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) =>
                  context.read<TasksCubit>().toggleComplete(task.id, value ?? false),
            ),
            title: Row(
              children: [
                Container(width: 4, height: 16, color: priorityColor(task.priority)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: task.isCompleted ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${task.type.name} • Due ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                final cubit = context.read<TasksCubit>();
                if (value == 'edit') {
                  TasksListScreen._pushAddEdit(context, userId, task: task);
                } else if (value == 'delete') {
                  cubit.deleteTask(task.id);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }
}