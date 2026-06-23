class Assignment {
  final int? id;
  final String title;
  final String course;
  final String status;

  const Assignment({
    this.id,
    required this.title,
    required this.course,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'course': course, 'status': status};
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      title: map['title'],
      course: map['course'],
      status: map['status'],
    );
  }
}
