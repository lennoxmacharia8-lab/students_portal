import 'package:flutter/material.dart';
import '../../databases/database_service.dart';

class EditStudentScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const EditStudentScreen({super.key, required this.student});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.student['name']);
    emailController = TextEditingController(text: widget.student['email']);
    passwordController = TextEditingController(
      text: widget.student['password'],
    );
  }

  Future<void> updateStudent() async {
    if (!_formKey.currentState!.validate()) return;

    await DatabaseService.instance.updateStudent(widget.student['id'], {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
    });

    if (!mounted) return; // ✅ FIX FOR YOUR ERROR

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Student")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter name" : null,
              ),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter email" : null,
              ),

              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter password" : null,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: updateStudent,
                child: const Text("Update Student"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
