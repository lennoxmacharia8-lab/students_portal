class Result {
  final int? id;
  final String course;
  final String code;
  final String grade;

  const Result({
    this.id,
    required this.course,
    required this.code,
    required this.grade,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'course': course, 'code': code, 'grade': grade};
  }

  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      id: map['id'],
      course: map['course'],
      code: map['code'],
      grade: map['grade'],
    );
  }
}
