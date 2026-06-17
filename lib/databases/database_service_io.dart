import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  // 🔥 Get database (singleton)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_app.db');
    return _database!;
  }

  // 🏗️ Create database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // 🧱 Create tables
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        code TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        course TEXT,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course TEXT,
        code TEXT,
        grade TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        date TEXT,
        location TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS results (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          course TEXT,
          code TEXT,
          grade TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          date TEXT,
          location TEXT
        )
      ''');
    }
  }

  // =========================
  // 👤 STUDENTS METHODS
  // =========================

  // ➕ Register Student
  Future<int> registerStudent(Map<String, dynamic> student) async {
    final db = await database;
    return await db.insert('students', student);
  }

  // 🔐 Login Student
  Future<Map<String, dynamic>?> loginStudent(
    String email,
    String password,
  ) async {
    final db = await database;

    final result = await db.query(
      'students',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // 📋 Get All Students
  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    return await db.query('students');
  }

  // 🔍 Search Students
  Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    final db = await database;

    return await db.query(
      'students',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  // 🗑️ Delete Student
  Future<int> deleteStudent(int id) async {
    final db = await database;

    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // ✏️ Update Student
  Future<int> updateStudent(int id, Map<String, dynamic> student) async {
    final db = await database;

    return await db.update(
      'students',
      student,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // 📚 COURSES METHODS
  // =========================

  Future<int> addCourse(Map<String, dynamic> course) async {
    final db = await database;
    return await db.insert('courses', course);
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    final db = await database;
    return await db.query('courses');
  }

  // =========================
  // 📝 ASSIGNMENTS METHODS
  // =========================

  Future<int> addAssignment(Map<String, dynamic> assignment) async {
    final db = await database;
    return await db.insert('assignments', assignment);
  }

  Future<List<Map<String, dynamic>>> getAssignments() async {
    final db = await database;
    return await db.query('assignments');
  }

  // =========================
  // 📊 RESULTS METHODS
  // =========================

  Future<int> addResult(Map<String, dynamic> result) async {
    final db = await database;
    return await db.insert('results', result);
  }

  Future<List<Map<String, dynamic>>> getResults() async {
    final db = await database;
    return await db.query('results');
  }

  // =========================
  // 📅 EVENTS METHODS
  // =========================

  Future<int> addEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert('events', event);
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await database;
    return await db.query('events');
  }
}
