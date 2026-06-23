import 'package:flutter/material.dart';
import '../databases/database_service.dart';
import '../models/students.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController regNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  Future<void> registerStudent() async {
    if (_formKey.currentState!.validate()) {
      try {
        final student = Student(
          id: idController.text.trim(),
          name: nameController.text.trim(),
          regNo: regNoController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          course: courseController.text.trim(),
          year: int.parse(yearController.text.trim()),
        );

        await DatabaseService.instance.registerStudent(student.toMap());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Student added: ${student.name}")),
          );

          Navigator.pop(context, true); // return to list screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    regNoController.dispose();
    emailController.dispose();
    phoneController.dispose();
    courseController.dispose();
    yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Student Record"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),

              _buildField(idController, "Student ID (e.g STU001)"),
              _buildField(regNoController, "Registration Number"),
              _buildField(nameController, "Full Name"),
              _buildField(emailController, "Email"),
              _buildField(phoneController, "Phone Number"),
              _buildField(courseController, "Course"),

              TextFormField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Year of Study",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter year of study";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: registerStudent,
                  child: const Text("Save Student"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Required field";
          }
          return null;
        },
      ),
    );
  }
}
