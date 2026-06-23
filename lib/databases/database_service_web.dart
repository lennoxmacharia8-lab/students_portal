class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  final List<Map<String, dynamic>> _students = [];
  final List<Map<String, dynamic>> _courses = [];
  final List<Map<String, dynamic>> _assignments = [];
  final List<Map<String, dynamic>> _results = [];
  final List<Map<String, dynamic>> _events = [];

  int _nextId = 1;

  DatabaseService._init();

  Future<void> get database async {
    return;
  }

  int _nextItemId() => _nextId++;

  // =========================
  // 👤 STUDENTS METHODS
  // =========================

  Future<int> registerStudent(Map<String, dynamic> student) async {
    final record = Map<String, dynamic>.from(student);
    record['id'] = _nextItemId();
    _students.add(record);
    return record['id'] as int;
  }

  Future<Map<String, dynamic>?> loginStudent(
    String email,
    String password,
  ) async {
    final match = _students.firstWhere(
      (student) => student['email'] == email && student['password'] == password,
      orElse: () => {},
    );

    if (match.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(match);
  }

  // 📋 GET ALL STUDENTS
  Future<List<Map<String, dynamic>>> getStudents() async {
    return List<Map<String, dynamic>>.from(_students);
  }

  // 🔍 SEARCH STUDENTS
  Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    return _students.where((student) {
      final name = student['name'].toString().toLowerCase();
      final email = student['email'].toString().toLowerCase();
      final q = query.toLowerCase();

      return name.contains(q) || email.contains(q);
    }).toList();
  }

  // 🗑️ DELETE STUDENT
  Future<int> deleteStudent(int id) async {
    _students.removeWhere((student) => student['id'] == id);
    return id;
  }

  // ✏️ UPDATE STUDENT
  Future<int> updateStudent(int id, Map<String, dynamic> student) async {
    final index = _students.indexWhere((s) => s['id'] == id);

    if (index != -1) {
      _students[index] = {..._students[index], ...student, 'id': id};
    }

    return id;
  }

  // =========================
  // 📚 COURSES METHODS
  // =========================

  Future<int> addCourse(Map<String, dynamic> course) async {
    final record = Map<String, dynamic>.from(course);
    record['id'] = _nextItemId();
    _courses.add(record);
    return record['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    return List<Map<String, dynamic>>.from(_courses);
  }

  // =========================
  // 📝 ASSIGNMENTS METHODS
  // =========================

  Future<int> addAssignment(Map<String, dynamic> assignment) async {
    final record = Map<String, dynamic>.from(assignment);
    record['id'] = _nextItemId();
    _assignments.add(record);
    return record['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getAssignments() async {
    return List<Map<String, dynamic>>.from(_assignments);
  }

  // =========================
  // 📊 RESULTS METHODS
  // =========================

  Future<int> addResult(Map<String, dynamic> result) async {
    final record = Map<String, dynamic>.from(result);
    record['id'] = _nextItemId();
    _results.add(record);
    return record['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getResults() async {
    return List<Map<String, dynamic>>.from(_results);
  }

  // =========================
  // 📅 EVENTS METHODS
  // =========================

  Future<int> addEvent(Map<String, dynamic> event) async {
    final record = Map<String, dynamic>.from(event);
    record['id'] = _nextItemId();
    _events.add(record);
    return record['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    return List<Map<String, dynamic>>.from(_events);
  }
}
