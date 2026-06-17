import 'package:flutter/material.dart';
import '../databases/database_service.dart';
import '../models/assignment.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  late Future<List<Assignment>> _assignmentsFuture;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  String _status = 'Pending';

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  void _loadAssignments() {
    setState(() {
      _assignmentsFuture = DatabaseService.instance.getAssignments().then(
        (assignments) => assignments
            .map((assignment) => Assignment.fromMap(assignment))
            .toList(),
      );
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Done':
        return Colors.green;
      case 'Pending':
      default:
        return Colors.orange;
    }
  }

  Future<void> _showAddAssignmentDialog() async {
    _titleController.clear();
    _courseController.clear();
    _status = 'Pending';

    final added = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Assignment'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Assignment title',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter assignment title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _courseController,
                    decoration: const InputDecoration(labelText: 'Course'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter course name';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(value: 'Done', child: Text('Done')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _status = value;
                        });
                      }
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
                  await DatabaseService.instance.addAssignment({
                    'title': _titleController.text.trim(),
                    'course': _courseController.text.trim(),
                    'status': _status,
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
      _loadAssignments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments'), centerTitle: true),
      body: FutureBuilder<List<Assignment>>(
        future: _assignmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No assignments available'));
          }

          final assignments = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final a = assignments[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.assignment,
                    color: getStatusColor(a.status),
                  ),
                  title: Text(
                    a.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Course: ${a.course}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(a.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      a.status,
                      style: TextStyle(
                        color: getStatusColor(a.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opened: ${a.title}')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssignmentDialog,
        tooltip: 'Add assignment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
