import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  // =========================
  // DATABASE INIT
  // =========================

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // =========================
  // TABLES
  // =========================

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        reg_no TEXT UNIQUE,
        name TEXT,
        email TEXT UNIQUE,
        phone TEXT,
        course TEXT,
        year INTEGER
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
        status TEXT,
        student_id TEXT,
        student_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course TEXT,
        code TEXT,
        grade TEXT,
        student_id TEXT,
        student_name TEXT
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

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT,
        student_name TEXT,
        date TEXT,
        status TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS students');

      await db.execute('''
        CREATE TABLE students (
          id TEXT PRIMARY KEY,
          reg_no TEXT UNIQUE,
          name TEXT,
          email TEXT UNIQUE,
          phone TEXT,
          course TEXT,
          year INTEGER
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('ALTER TABLE assignments ADD COLUMN student_id TEXT');
      await db.execute('ALTER TABLE assignments ADD COLUMN student_name TEXT');
      await db.execute('ALTER TABLE results ADD COLUMN student_id TEXT');
      await db.execute('ALTER TABLE results ADD COLUMN student_name TEXT');
    }

    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE attendance (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          student_id TEXT,
          student_name TEXT,
          date TEXT,
          status TEXT
        )
      ''');
    }
  }

  // =========================
  // STUDENTS
  // =========================

  Future<int> registerStudent(Map<String, dynamic> student) async {
    final db = await database;

    final data = Map<String, dynamic>.from(student);

    // 🔥 FIX: ensure ID exists
    data['id'] ??= DateTime.now().millisecondsSinceEpoch.toString();

    final result = await db.insert(
      'students',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final course = data['course']?.toString().trim();
    if (course != null && course.isNotEmpty) {
      await addCourseIfMissing(course, course);
    }

    return result;
  }

  Future<int> addCourseIfMissing(String title, String code) async {
    final db = await database;
    final existing = await db.query(
      'courses',
      where: 'title = ? OR code = ?',
      whereArgs: [title, code],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return 0;
    }

    return await db.insert('courses', {'title': title, 'code': code});
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    return await db.query('students');
  }

  Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    final db = await database;

    return await db.query(
      'students',
      where: 'name LIKE ? OR email LIKE ? OR reg_no LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
  }

  Future<int> deleteStudent(String id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateStudent(String id, Map<String, dynamic> student) async {
    final db = await database;
    return await db.update(
      'students',
      student,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // COURSES
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
  // ASSIGNMENTS
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
  // RESULTS
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
  // EVENTS
  // =========================

  Future<int> addEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert('events', event);
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await database;
    return await db.query('events');
  }

  // =========================
  // ATTENDANCE
  // =========================

  Future<int> markAttendance(Map<String, dynamic> attendance) async {
    final db = await database;
    return await db.insert('attendance', attendance);
  }

  Future<List<Map<String, dynamic>>> getAttendance() async {
    final db = await database;
    return await db.query('attendance');
  }

  Future<List<Map<String, dynamic>>> getAttendanceByDate(String date) async {
    final db = await database;
    return await db.query('attendance', where: 'date = ?', whereArgs: [date]);
  }

  Future<List<Map<String, dynamic>>> getAttendanceByStudent(
    String studentId,
  ) async {
    final db = await database;
    return await db.query(
      'attendance',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
  }

  Future<int> updateAttendance(int id, Map<String, dynamic> attendance) async {
    final db = await database;
    return await db.update(
      'attendance',
      attendance,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await database;
    return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }
}
