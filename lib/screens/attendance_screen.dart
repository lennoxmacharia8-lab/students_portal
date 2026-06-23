import 'package:flutter/material.dart';
import '../databases/database_service.dart';
import '../models/students.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Future<List<Student>> _studentsFuture;
  final Map<String, String> _attendanceMap = {}; // studentId -> status
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    setState(() {
      _studentsFuture = DatabaseService.instance.getStudents().then(
        (list) => list.map((m) => Student.fromMap(m)).toList(),
      );
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _attendanceMap.clear();
      });
    }
  }

  Future<void> _saveAttendance() async {
    if (_attendanceMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark attendance for at least one student'),
        ),
      );
      return;
    }

    final students = await DatabaseService.instance.getStudents();
    final studentMap = {for (var s in students) s['id']: s['name']};

    for (final studentId in _attendanceMap.keys) {
      final studentName = studentMap[studentId] ?? 'Unknown';
      await DatabaseService.instance.markAttendance({
        'student_id': studentId,
        'student_name': studentName,
        'date': _selectedDate.toIso8601String().split('T')[0],
        'status': _attendanceMap[studentId],
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved successfully')),
      );
      _attendanceMap.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Select Date',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date display
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.edit),
                      label: const Text('Change'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Students list
          Expanded(
            child: FutureBuilder<List<Student>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No registered students'));
                }

                final students = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final status = _attendanceMap[student.id] ?? 'Absent';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${student.name} (${student.regNo})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatusButton(
                                  student.id,
                                  'Present',
                                  Colors.green,
                                  status,
                                ),
                                _buildStatusButton(
                                  student.id,
                                  'Absent',
                                  Colors.red,
                                  status,
                                ),
                                _buildStatusButton(
                                  student.id,
                                  'Late',
                                  Colors.orange,
                                  status,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveAttendance,
                child: const Text('Save Attendance'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    String studentId,
    String statusLabel,
    Color color,
    String currentStatus,
  ) {
    final isSelected = currentStatus == statusLabel;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? color : Colors.grey[300],
            foregroundColor: isSelected ? Colors.white : Colors.black,
          ),
          onPressed: () {
            setState(() {
              _attendanceMap[studentId] = statusLabel;
            });
          },
          child: Text(statusLabel),
        ),
      ),
    );
  }
}
