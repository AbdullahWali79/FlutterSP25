import 'package:flutter/material.dart';

enum TaskStatus {
  pending,
  inProgress,
  completed,
}

enum RecurrenceType {
  daily,
  weekly,
  monthly,
  custom,
  none,
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime dueDate;
  final TaskStatus status;
  final RecurrenceType recurrenceType;
  final List<String> subtasks;
  final double progress;
  final String userId;
  final List<String> selectedDays;
  final TimeOfDay? reminderTime;
  final List<DateTime>? customDates;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.dueDate,
    this.status = TaskStatus.pending,
    this.recurrenceType = RecurrenceType.none,
    this.subtasks = const [],
    this.progress = 0.0,
    required this.userId,
    this.selectedDays = const [],
    this.reminderTime,
    this.customDates,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status.toString(),
      'recurrenceType': recurrenceType.toString(),
      'subtasks': subtasks,
      'progress': progress,
      'userId': userId,
      'selectedDays': selectedDays,
      'reminderTime': reminderTime != null
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : null,
      'customDates':
          customDates?.map((date) => date.toIso8601String()).toList(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: DateTime.parse(map['dueDate']),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
      recurrenceType: RecurrenceType.values.firstWhere(
        (e) => e.toString() == map['recurrenceType'],
      ),
      subtasks: List<String>.from(map['subtasks']),
      progress: map['progress'],
      userId: map['userId'],
      selectedDays: List<String>.from(map['selectedDays']),
      reminderTime: map['reminderTime'] != null
          ? TimeOfDay(
              hour: int.parse(map['reminderTime'].split(':')[0]),
              minute: int.parse(map['reminderTime'].split(':')[1]),
            )
          : null,
      customDates: map['customDates'] != null
          ? (map['customDates'] as List)
              .map((date) => DateTime.parse(date))
              .toList()
          : null,
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
    List<String>? subtasks,
    double? progress,
    String? userId,
    List<String>? selectedDays,
    TimeOfDay? reminderTime,
    List<DateTime>? customDates,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      subtasks: subtasks ?? this.subtasks,
      progress: progress ?? this.progress,
      userId: userId ?? this.userId,
      selectedDays: selectedDays ?? this.selectedDays,
      reminderTime: reminderTime ?? this.reminderTime,
      customDates: customDates ?? this.customDates,
    );
  }
}
