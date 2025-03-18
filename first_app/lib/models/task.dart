import 'package:flutter/material.dart';

enum TaskStatus { pending, completed }

enum RecurrenceType { none, daily, weekly, monthly, custom }

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TaskStatus status;
  final RecurrenceType recurrenceType;
  final List<String> selectedDays;
  final TimeOfDay? reminderTime;
  final List<DateTime>? customDates;
  final int progress;
  final List<String>? subtasks;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.dueDate,
    this.status = TaskStatus.pending,
    this.recurrenceType = RecurrenceType.none,
    this.selectedDays = const [],
    this.reminderTime,
    this.customDates,
    this.progress = 0,
    this.subtasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status.toString(),
      'recurrenceType': recurrenceType.toString(),
      'selectedDays': selectedDays.join(','),
      'reminderTime': reminderTime != null
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : null,
      'customDates':
          customDates?.map((date) => date.toIso8601String()).join(','),
      'progress': progress,
      'subtasks': subtasks?.join(','),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      recurrenceType: RecurrenceType.values.firstWhere(
        (e) => e.toString() == map['recurrenceType'],
        orElse: () => RecurrenceType.none,
      ),
      selectedDays: map['selectedDays']?.split(',') ?? [],
      reminderTime: map['reminderTime'] != null
          ? TimeOfDay(
              hour: int.parse(map['reminderTime'].split(':')[0]),
              minute: int.parse(map['reminderTime'].split(':')[1]),
            )
          : null,
      customDates: map['customDates']
          ?.split(',')
          .map((date) => DateTime.parse(date))
          .toList(),
      progress: map['progress'] ?? 0,
      subtasks: map['subtasks']?.split(','),
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    TaskStatus? status,
    RecurrenceType? recurrenceType,
    List<String>? selectedDays,
    TimeOfDay? reminderTime,
    List<DateTime>? customDates,
    int? progress,
    List<String>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      selectedDays: selectedDays ?? this.selectedDays,
      reminderTime: reminderTime ?? this.reminderTime,
      customDates: customDates ?? this.customDates,
      progress: progress ?? this.progress,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}
