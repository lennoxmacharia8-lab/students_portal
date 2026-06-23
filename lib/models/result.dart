class Result {
  final int? id;
  final String course;
  final String code;
  final String grade;
  final String studentId;
  final String studentName;

  const Result({
    this.id,
    required this.course,
    required this.code,
    required this.grade,
    required this.studentId,
    required this.studentName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course': course,
      'code': code,
      'grade': grade,
      'student_id': studentId,
      'student_name': studentName,
    };
  }

  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      id: map['id'],
      course: map['course'],
      code: map['code'],
      grade: map['grade'],
      studentId: map['student_id'] ?? '',
      studentName: map['student_name'] ?? 'Unknown',
    );
  }
}
