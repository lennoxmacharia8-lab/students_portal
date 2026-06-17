import 'package:flutter/material.dart';
import '../databases/database_service.dart';
import '../models/result.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<List<Result>> _resultsFuture;
  final _formKey = GlobalKey<FormState>();
  final _courseController = TextEditingController();
  final _codeController = TextEditingController();
  String _grade = 'A';

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  @override
  void dispose() {
    _courseController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _loadResults() {
    setState(() {
      _resultsFuture = DatabaseService.instance.getResults().then(
        (results) => results.map((r) => Result.fromMap(r)).toList(),
      );
    });
  }

  Color getGradeColor(String grade) {
    switch (grade) {
      case 'A':
      case 'A-':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  Future<void> _showAddResultDialog() async {
    _courseController.clear();
    _codeController.clear();
    _grade = 'A';

    final added = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Result'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(labelText: 'Course code'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter course code';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _grade,
                    decoration: const InputDecoration(labelText: 'Grade'),
                    items: const [
                      DropdownMenuItem(value: 'A', child: Text('A')),
                      DropdownMenuItem(value: 'A-', child: Text('A-')),
                      DropdownMenuItem(value: 'B+', child: Text('B+')),
                      DropdownMenuItem(value: 'B', child: Text('B')),
                      DropdownMenuItem(value: 'C', child: Text('C')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _grade = value;
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
                  await DatabaseService.instance.addResult({
                    'course': _courseController.text.trim(),
                    'code': _codeController.text.trim(),
                    'grade': _grade,
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
      _loadResults();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Result added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results'), centerTitle: true),
      body: FutureBuilder<List<Result>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No results available'));
          }

          final results = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.school, color: Colors.indigo),
                  title: Text(
                    result.course,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Code: ${result.code}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getGradeColor(
                        result.grade,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      result.grade,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: getGradeColor(result.grade),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddResultDialog,
        tooltip: 'Add result',
        child: const Icon(Icons.add),
      ),
    );
  }
}
