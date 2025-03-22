import 'package:uuid/uuid.dart';

enum TaskPriority {
  low,
  medium,
  high,
}

class Task {
  final String id;
  final String name;
  final String? description;
  final DateTime dueDate;
  final bool isRepeatable;
  final List<bool> repeatDays; // [Monday, Tuesday, ..., Sunday]
  final DateTime? repeatEndDate;
  final bool isCompleted;
  final DateTime createdAt;
  final TaskPriority priority;

  Task({
    String? id,
    required this.name,
    this.description,
    required this.dueDate,
    this.isRepeatable = false,
    this.repeatDays = const [false, false, false, false, false, false, false],
    this.repeatEndDate,
    this.isCompleted = false,
    DateTime? createdAt,
    this.priority = TaskPriority.medium,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? name,
    String? description,
    DateTime? dueDate,
    bool? isRepeatable,
    List<bool>? repeatDays,
    DateTime? repeatEndDate,
    bool? isCompleted,
    TaskPriority? priority,
  }) {
    return Task(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isRepeatable: isRepeatable ?? this.isRepeatable,
      repeatDays: repeatDays ?? this.repeatDays,
      repeatEndDate: repeatEndDate ?? this.repeatEndDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isRepeatable': isRepeatable,
      'repeatDays': repeatDays,
      'repeatEndDate': repeatEndDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'priority': priority.index,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isRepeatable: map['isRepeatable'],
      repeatDays: List<bool>.from(map['repeatDays']),
      repeatEndDate: map['repeatEndDate'] != null
          ? DateTime.parse(map['repeatEndDate'])
          : null,
      isCompleted: map['isCompleted'],
      createdAt: DateTime.parse(map['createdAt']),
      priority: TaskPriority.values[map['priority'] ?? 1],
    );
  }
}
