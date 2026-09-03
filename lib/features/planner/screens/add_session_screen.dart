import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/planner_cubit.dart';
import '../../../models/study_session.dart';
import '../../../core/services/notification_service.dart';

class AddSessionScreen extends StatefulWidget {
  const AddSessionScreen({super.key});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  final _goalController = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: (TimeOfDay.now().hour + 1) % 24);

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _pickTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (time == null) return;
    setState(() => isStart ? _startTime = time : _endTime = time);
  }

  void _save() {
    final start = DateTime(_date.year, _date.month, _date.day, _startTime.hour, _startTime.minute);
    final end = DateTime(_date.year, _date.month, _date.day, _endTime.hour, _endTime.minute);

    if (!end.isAfter(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }

    final session = StudySession(
      id: '',
      startTime: start,
      endTime: end,
      goal: _goalController.text.trim(),
    );

    context.read<PlannerCubit>().addSession(session);

    NotificationService().scheduleAt(
      id: start.hashCode,
      title: 'Study session starting soon',
      body: session.goal.isNotEmpty ? session.goal : 'Time to start studying!',
      dateTime: start.subtract(const Duration(minutes: 10)),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Study Session')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start Time'),
                subtitle: Text(_startTime.format(context)),
                onTap: () => _pickTime(true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End Time'),
                subtitle: Text(_endTime.format(context)),
                onTap: () => _pickTime(false),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _goalController,
                decoration: const InputDecoration(labelText: 'Study Goal (optional)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Schedule Session')),
            ],
          ),
        ),
      ),
    );
  }
}