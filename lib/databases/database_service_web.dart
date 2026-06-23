class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  bool _initialized = false;

  DatabaseService._init();

  Future<void> get database async {
    if (!_initialized) {
      _initialized = true;
    }
  }

  final List<Map<String, dynamic>> _students = [];
  final List<Map<String, dynamic>> _courses = [];
  final List<Map<String, dynamic>> _assignments = [];
  final List<Map<String, dynamic>> _results = [];
  final List<Map<String, dynamic>> _events = [];
  final List<Map<String, dynamic>> _attendance = [];

  Future<int> registerStudent(Map<String, dynamic> student) async {
    final data = Map<String, dynamic>.from(student);
    data['id'] ??= DateTime.now().millisecondsSinceEpoch.toString();
    _students.removeWhere((row) => row['id'] == data['id']);
    _students.add(data);

    final course = data['course']?.toString().trim();
    if (course != null && course.isNotEmpty) {
      await addCourseIfMissing(course, course);
    }

    return 1;
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    return List<Map<String, dynamic>>.from(_students);
  }

  Future<int> addCourseIfMissing(String title, String code) async {
    final exists = _courses.any((course) {
      return course['title'] == title || course['code'] == code;
    });

    if (exists) return 0;

    _courses.add({'id': _courses.length + 1, 'title': title, 'code': code});
    return 1;
  }

  Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    final lowerQuery = query.toLowerCase();
    return _students
        .where((student) {
          final name = (student['name'] ?? '').toString().toLowerCase();
          final email = (student['email'] ?? '').toString().toLowerCase();
          final regNo = (student['reg_no'] ?? '').toString().toLowerCase();
          return name.contains(lowerQuery) ||
              email.contains(lowerQuery) ||
              regNo.contains(lowerQuery);
        })
        .map((student) => Map<String, dynamic>.from(student))
        .toList();
  }

  Future<int> deleteStudent(String id) async {
    final previousLength = _students.length;
    _students.removeWhere((student) => student['id'] == id);
    return _students.length < previousLength ? 1 : 0;
  }

  Future<int> updateStudent(String id, Map<String, dynamic> student) async {
    final index = _students.indexWhere((row) => row['id'] == id);
    if (index < 0) return 0;
    final updated = Map<String, dynamic>.from(student);
    updated['id'] = id;
    _students[index] = updated;
    return 1;
  }

  Future<int> addCourse(Map<String, dynamic> course) async {
    final nextId = _courses.length + 1;
    final data = Map<String, dynamic>.from(course);
    data['id'] = data['id'] ?? nextId;
    _courses.add(data);
    return 1;
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    return List<Map<String, dynamic>>.from(_courses);
  }

  Future<int> addAssignment(Map<String, dynamic> assignment) async {
    final nextId = _assignments.length + 1;
    final data = Map<String, dynamic>.from(assignment);
    data['id'] = data['id'] ?? nextId;
    data['student_id'] ??= '';
    data['student_name'] ??= 'Unknown';
    _assignments.add(data);
    return 1;
  }

  Future<List<Map<String, dynamic>>> getAssignments() async {
    return List<Map<String, dynamic>>.from(_assignments);
  }

  Future<int> addResult(Map<String, dynamic> result) async {
    final nextId = _results.length + 1;
    final data = Map<String, dynamic>.from(result);
    data['id'] = data['id'] ?? nextId;
    data['student_id'] ??= '';
    data['student_name'] ??= 'Unknown';
    _results.add(data);
    return 1;
  }

  Future<List<Map<String, dynamic>>> getResults() async {
    return List<Map<String, dynamic>>.from(_results);
  }

  Future<int> addEvent(Map<String, dynamic> event) async {
    final nextId = _events.length + 1;
    final data = Map<String, dynamic>.from(event);
    data['id'] = data['id'] ?? nextId;
    _events.add(data);
    return 1;
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    return List<Map<String, dynamic>>.from(_events);
  }

  // =========================
  // ATTENDANCE
  // =========================

  Future<int> markAttendance(Map<String, dynamic> attendance) async {
    final nextId = _attendance.length + 1;
    final data = Map<String, dynamic>.from(attendance);
    data['id'] = data['id'] ?? nextId;
    _attendance.add(data);
    return 1;
  }

  Future<List<Map<String, dynamic>>> getAttendance() async {
    return List<Map<String, dynamic>>.from(_attendance);
  }

  Future<List<Map<String, dynamic>>> getAttendanceByDate(String date) async {
    return _attendance
        .where((a) => a['date'] == date)
        .map((a) => Map<String, dynamic>.from(a))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAttendanceByStudent(
    String studentId,
  ) async {
    return _attendance
        .where((a) => a['student_id'] == studentId)
        .map((a) => Map<String, dynamic>.from(a))
        .toList();
  }

  Future<int> updateAttendance(int id, Map<String, dynamic> attendance) async {
    final index = _attendance.indexWhere((a) => a['id'] == id);
    if (index < 0) return 0;
    final updated = Map<String, dynamic>.from(attendance);
    updated['id'] = id;
    _attendance[index] = updated;
    return 1;
  }

  Future<int> deleteAttendance(int id) async {
    final previousLength = _attendance.length;
    _attendance.removeWhere((a) => a['id'] == id);
    return _attendance.length < previousLength ? 1 : 0;
  }
}
