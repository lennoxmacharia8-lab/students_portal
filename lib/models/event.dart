class Event {
  final int? id;
  final String title;
  final String date;
  final String location;

  const Event({
    this.id,
    required this.title,
    required this.date,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'date': date, 'location': location};
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      date: map['date'],
      location: map['location'],
    );
  }
}
