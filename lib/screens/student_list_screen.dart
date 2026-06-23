import 'package:flutter/material.dart';
import '../../databases/database_service.dart';
import 'edit_student_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    final data = await DatabaseService.instance.getStudents();
    setState(() {
      students = data;
      filteredStudents = data;
    });
  }

  void searchStudent(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredStudents = students;
      });
      return;
    }

    final result = await DatabaseService.instance.searchStudents(query);

    setState(() {
      filteredStudents = result;
    });
  }

  Future<void> deleteStudent(String id) async {
    await DatabaseService.instance.deleteStudent(id);
    loadStudents();
  }

  Future<void> openEditScreen(Map<String, dynamic> student) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentScreen(student: student),
      ),
    );

    if (result == true) {
      loadStudents();
    }
  }

  Future<void> openRegistrationScreen() async {
    final result = await Navigator.pushNamed(context, '/register');
    if (result == true) {
      loadStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Students Registry"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Register Student',
            onPressed: openRegistrationScreen,
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: searchStudent,
              decoration: const InputDecoration(
                hintText: "Search by name, email, or reg no...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // 📋 LIST
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(child: Text("No students found"))
                : ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];

                      final String id = student['id']?.toString() ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            "${student['name'] ?? 'Unknown'} (${student['reg_no'] ?? 'No Reg'})",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("Email: ${student['email'] ?? 'N/A'}"),
                              Text("Phone: ${student['phone'] ?? 'N/A'}"),
                              Text("Course: ${student['course'] ?? 'N/A'}"),
                              Text("Year: ${student['year'] ?? 'N/A'}"),
                            ],
                          ),

                          isThreeLine: true,

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  openEditScreen(student);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  if (id.isNotEmpty) {
                                    deleteStudent(id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
