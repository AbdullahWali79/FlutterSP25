import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        status TEXT NOT NULL,
        recurrenceType TEXT NOT NULL,
        progress REAL NOT NULL,
        userId TEXT NOT NULL,
        selectedDays TEXT,
        reminderTime TEXT,
        customDates TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE subtasks(
        id TEXT PRIMARY KEY,
        taskId TEXT NOT NULL,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        FOREIGN KEY (taskId) REFERENCES tasks (id)
      )
    ''');
  }

  // User operations
  Future<String> createUser(String username, String password) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert('users', {
      'id': id,
      'username': username,
      'password': password,
    });

    return id;
  }

  Future<Map<String, dynamic>?> getUser(
      String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> updateUserPassword(String userId, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Task operations
  Future<String> createTask(Task task) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert('tasks', {
      'id': id,
      'title': task.title,
      'description': task.description,
      'createdAt': task.createdAt.toIso8601String(),
      'dueDate': task.dueDate.toIso8601String(),
      'status': task.status.toString(),
      'recurrenceType': task.recurrenceType.toString(),
      'progress': task.progress,
      'userId': task.userId,
      'selectedDays': task.selectedDays.join(','),
      'reminderTime': task.reminderTime != null
          ? '${task.reminderTime!.hour}:${task.reminderTime!.minute}'
          : null,
      'customDates': task.customDates != null
          ? task.customDates!.map((date) => date.toIso8601String()).join(',')
          : null,
    });

    return id;
  }

  Future<List<Task>> getTasks(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      final selectedDays = map['selectedDays']?.split(',') ?? [];
      final customDates = map['customDates']
          ?.split(',')
          .map((date) => DateTime.parse(date))
          .toList();
      final reminderTime = map['reminderTime'] != null
          ? TimeOfDay(
              hour: int.parse(map['reminderTime'].split(':')[0]),
              minute: int.parse(map['reminderTime'].split(':')[1]),
            )
          : null;

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
        progress: map['progress'],
        userId: map['userId'],
        selectedDays: selectedDays,
        reminderTime: reminderTime,
        customDates: customDates,
      );
    });
  }

  Future<List<Task>> getTodayTasks(String userId) async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ? AND dueDate >= ? AND dueDate < ?',
      whereArgs: [
        userId,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      final selectedDays = map['selectedDays']?.split(',') ?? [];
      final customDates = map['customDates']
          ?.split(',')
          .map((date) => DateTime.parse(date))
          .toList();
      final reminderTime = map['reminderTime'] != null
          ? TimeOfDay(
              hour: int.parse(map['reminderTime'].split(':')[0]),
              minute: int.parse(map['reminderTime'].split(':')[1]),
            )
          : null;

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
        progress: map['progress'],
        userId: map['userId'],
        selectedDays: selectedDays,
        reminderTime: reminderTime,
        customDates: customDates,
      );
    });
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      {
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate.toIso8601String(),
        'status': task.status.toString(),
        'recurrenceType': task.recurrenceType.toString(),
        'progress': task.progress,
        'selectedDays': task.selectedDays.join(','),
        'reminderTime': task.reminderTime != null
            ? '${task.reminderTime!.hour}:${task.reminderTime!.minute}'
            : null,
        'customDates': task.customDates != null
            ? task.customDates!.map((date) => date.toIso8601String()).join(',')
            : null,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String taskId) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<String> exportTasksToPDF(String userId) async {
    final tasks = await getTasks(userId);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Task List',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            ...tasks.map((task) => pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 10),
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        task.title,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text('Description: ${task.description}'),
                      pw.Text('Due Date: ${task.dueDate.toString()}'),
                      pw.Text('Status: ${task.status.toString()}'),
                      pw.Text('Recurrence: ${task.recurrenceType.toString()}'),
                      pw.Text('Progress: ${task.progress.toString()}'),
                      pw.Text('Selected Days: ${task.selectedDays.join(', ')}'),
                      pw.Text(
                          'Custom Dates: ${task.customDates?.map((d) => d.toString()).join(', ') ?? ''}'),
                      pw.Text(
                          'Reminder: ${task.reminderTime != null ? '${task.reminderTime!.hour}:${task.reminderTime!.minute}' : ''}'),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'tasks_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = join(directory.path, fileName);

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
