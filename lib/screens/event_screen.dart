import 'package:flutter/material.dart';
import '../databases/database_service.dart';
import '../models/event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<Event>> _eventsFuture;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();

  final List<Event> _defaultEvents = const [
    Event(
      title: 'Mobile App Development CAT',
      date: '15 June 2026',
      location: 'Lab 3',
    ),
    Event(
      title: 'Database Systems Assignment Deadline',
      date: '20 June 2026',
      location: 'Online Submission',
    ),
    Event(
      title: 'Career Guidance Seminar',
      date: '25 June 2026',
      location: 'Main Hall',
    ),
    Event(
      title: 'End Semester Exams',
      date: '10 July 2026',
      location: 'Examination Block',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _loadEvents() {
    setState(() {
      _eventsFuture = DatabaseService.instance.getEvents().then(
        (events) => events.map((event) => Event.fromMap(event)).toList(),
      );
    });
  }

  Future<void> _showAddEventDialog() async {
    _titleController.clear();
    _dateController.clear();
    _locationController.clear();

    final added = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Event'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Event title'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter event title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Date'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter event date';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter event location';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final navigator = Navigator.of(context);
                  await DatabaseService.instance.addEvent({
                    'title': _titleController.text.trim(),
                    'date': _dateController.text.trim(),
                    'location': _locationController.text.trim(),
                  });
                  if (!mounted) return;
                  navigator.pop(true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (added == true && mounted) {
      _loadEvents();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Event added successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events'), centerTitle: true),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final events = snapshot.data == null || snapshot.data!.isEmpty
              ? _defaultEvents
              : snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.event)),
                  title: Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Date: ${event.date}\nLocation: ${event.location}',
                  ),
                  isThreeLine: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: ${event.title}')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        tooltip: 'Add event',
        child: const Icon(Icons.add),
      ),
    );
  }
}
