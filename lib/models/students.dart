class Student {
  final String id; // STU001 etc
  final String regNo;
  final String name;
  final String email;
  final String phone;
  final String course;
  final int year;

  const Student({
    required this.id,
    required this.regNo,
    required this.name,
    required this.email,
    required this.phone,
    required this.course,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reg_no': regNo,
      'name': name,
      'email': email,
      'phone': phone,
      'course': course,
      'year': year,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      regNo: map['reg_no'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      course: map['course'],
      year: map['year'],
    );
  }
}
