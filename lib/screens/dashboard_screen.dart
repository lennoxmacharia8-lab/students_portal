import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget buildCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String route,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color.withValues(alpha: 0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Dashboard"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            buildCard(
              context: context,
              title: "Courses",
              icon: Icons.book,
              route: "/courses",
              color: Colors.blue,
            ),
            buildCard(
              context: context,
              title: "Assignments",
              icon: Icons.assignment,
              route: "/assignments",
              color: Colors.green,
            ),
            buildCard(
              context: context,
              title: "Results",
              icon: Icons.bar_chart,
              route: "/results",
              color: Colors.orange,
            ),
            buildCard(
              context: context,
              title: "Events",
              icon: Icons.event,
              route: "/events",
              color: Colors.purple,
            ),

            // 👤 Students (CRUD system)
            buildCard(
              context: context,
              title: "Students",
              icon: Icons.people,
              route: "/students",
              color: Colors.teal,
            ),

            // 🌐 NEW: API Users (REST API)
            buildCard(
              context: context,
              title: "API Users",
              icon: Icons.cloud,
              route: "/users",
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }
}
