import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'multiplication_mastery.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE quiz_scores(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        quiz_type TEXT NOT NULL,
        date_taken TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertQuizScore(Map<String, dynamic> score) async {
    final db = await database;
    return await db.insert('quiz_scores', score);
  }

  Future<List<Map<String, dynamic>>> getQuizScores() async {
    final db = await database;
    return await db.query('quiz_scores', orderBy: 'date_taken DESC');
  }
}
