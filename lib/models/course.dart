class Course {
  final int? id;
  final String title;
  final String code;

  const Course({this.id, required this.title, required this.code});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'code': code};
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(id: map['id'], title: map['title'], code: map['code']);
  }
}
