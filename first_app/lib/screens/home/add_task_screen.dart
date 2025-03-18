import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  RecurrenceType _recurrenceType = RecurrenceType.none;
  List<String> _selectedDays = [];
  List<DateTime> _customDates = [];
  TimeOfDay? _reminderTime;
  bool _isLoading = false;

  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void dispose() {
    _titleController.dispose();
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
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectCustomDates(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (!_customDates.any((date) =>
            date.year == picked.year &&
            date.month == picked.month &&
            date.day == picked.day)) {
          _customDates.add(picked);
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = context.read<AuthService>().currentUserId;
      if (userId == null) throw 'User not authenticated';

      final task = Task(
        id: '', // Will be set by SQLite
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
        dueDate: _dueDate,
        status: TaskStatus.pending,
        recurrenceType: _recurrenceType,
        selectedDays: _selectedDays,
        reminderTime: _reminderTime,
        customDates:
            _recurrenceType == RecurrenceType.custom ? _customDates : null,
        userId: userId,
      );

      await context.read<TaskService>().createTask(task);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(
                  '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RecurrenceType>(
                value: _recurrenceType,
                decoration: const InputDecoration(
                  labelText: 'Recurrence',
                  border: OutlineInputBorder(),
                ),
                items: RecurrenceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _recurrenceType = value!;
                    if (value == RecurrenceType.none) {
                      _selectedDays = [];
                      _customDates = [];
                    }
                  });
                },
              ),
              if (_recurrenceType == RecurrenceType.weekly) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: _weekDays.map((day) {
                    final isSelected = _selectedDays.contains(day);
                    return FilterChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(day);
                          } else {
                            _selectedDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              if (_recurrenceType == RecurrenceType.custom) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _selectCustomDates(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Custom Date'),
                ),
                if (_customDates.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _customDates.map((date) {
                      return Chip(
                        label: Text(
                          '${date.day}/${date.month}/${date.year}',
                        ),
                        onDeleted: () {
                          setState(() {
                            _customDates.remove(date);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Reminder Time'),
                subtitle: Text(
                  _reminderTime != null
                      ? '${_reminderTime!.hour}:${_reminderTime!.minute}'
                      : 'Not set',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
