import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/subjects_cubit.dart';
import '../../../models/subject.dart';

class AddEditSubjectScreen extends StatefulWidget {
  final Subject? subject;
  const AddEditSubjectScreen({super.key, this.subject});

  @override
  State<AddEditSubjectScreen> createState() => _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends State<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _teacherController;
  late final TextEditingController _totalChaptersController;
  late final TextEditingController _completedChaptersController;
  late Color _selectedColor;

  static const _colorOptions = [
    Colors.indigo, Colors.purple, Colors.teal, Colors.orange, Colors.pink, Colors.green,
  ];

  bool get _isEditing => widget.subject != null;

  @override
  void initState() {
    super.initState();
    final s = widget.subject;
    _nameController = TextEditingController(text: s?.name ?? '');
    _teacherController = TextEditingController(text: s?.teacherName ?? '');
    _totalChaptersController = TextEditingController(text: (s?.totalChapters ?? 0).toString());
    _completedChaptersController = TextEditingController(text: (s?.completedChapters ?? 0).toString());
    _selectedColor = s?.color ?? _colorOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _totalChaptersController.dispose();
    _completedChaptersController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final subject = Subject(
      id: widget.subject?.id ?? '',
      name: _nameController.text.trim(),
      teacherName: _teacherController.text.trim(),
      color: _selectedColor,
      icon: widget.subject?.icon ?? Icons.book,
      totalChapters: int.tryParse(_totalChaptersController.text) ?? 0,
      completedChapters: int.tryParse(_completedChaptersController.text) ?? 0,
    );

    if (_isEditing) {
      context.read<SubjectsCubit>().updateSubject(subject);
    } else {
      context.read<SubjectsCubit>().addSubject(subject);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Subject' : 'Add Subject')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Subject Name'),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _teacherController,
              decoration: const InputDecoration(labelText: 'Teacher Name (optional)'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _completedChaptersController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Completed Chapters'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _totalChaptersController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total Chapters'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Color'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: _colorOptions.map((color) {
                final selected = color.value == _selectedColor.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: selected ? 22 : 18,
                    child: selected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Save Changes' : 'Add Subject'),
            ),
          ],
        ),
      ),
    );
  }
}