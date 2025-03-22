import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_planner/models/task.dart';
import 'package:task_planner/providers/task_provider.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  const AddTaskScreen({super.key});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = TimeOfDay.now();
  bool _isRepeatable = false;
  List<bool> _repeatDays = List.generate(7, (_) => false);
  DateTime? _repeatEndDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _dueTime.hour,
          _dueTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null && picked != _dueTime) {
      setState(() {
        _dueTime = picked;
        _dueDate = DateTime(
          _dueDate.year,
          _dueDate.month,
          _dueDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectRepeatEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _repeatEndDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _repeatEndDate) {
      setState(() {
        _repeatEndDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        dueDate: _dueDate,
        isRepeatable: _isRepeatable,
        repeatDays: _repeatDays,
        repeatEndDate: _isRepeatable ? _repeatEndDate : null,
      );

      ref.read(taskProvider.notifier).addTask(task);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(
                DateFormat('MMM d, y').format(_dueDate),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: const Text('Due Time'),
              subtitle: Text(
                _dueTime.format(context),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            SwitchListTile(
              title: const Text('Repeatable Task'),
              value: _isRepeatable,
              onChanged: (value) {
                setState(() {
                  _isRepeatable = value;
                });
              },
            ),
            if (_isRepeatable) ...[
              const Text('Repeat Days:'),
              Wrap(
                spacing: 8,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .asMap()
                    .entries
                    .map((entry) {
                  return FilterChip(
                    label: Text(entry.value),
                    selected: _repeatDays[entry.key],
                    onSelected: (selected) {
                      setState(() {
                        _repeatDays[entry.key] = selected;
                      });
                    },
                  );
                }).toList(),
              ),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(
                  _repeatEndDate != null
                      ? DateFormat('MMM d, y').format(_repeatEndDate!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectRepeatEndDate(context),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
