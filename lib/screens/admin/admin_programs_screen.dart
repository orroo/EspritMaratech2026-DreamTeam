import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdminProgramsScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const AdminProgramsScreen({super.key, required this.onToggleTheme});

  @override
  State<AdminProgramsScreen> createState() => _AdminProgramsScreenState();
}

class _AdminProgramsScreenState extends State<AdminProgramsScreen> {
  final List<Map<String, dynamic>> programs = [
    {
      "title": "Beginner Week Plan",
      "group": "Beginner",
      "shared": true,
    },
    {
      "title": "5K Preparation",
      "group": "Intermediate",
      "shared": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Programs"),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
    floatingActionButton: FloatingActionButton(
  heroTag: "programsFab",
  backgroundColor: AppColors.terracotta,
  onPressed: _createProgram,
  child: const Icon(Icons.add, color: Colors.white),
),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: programs.length,
        itemBuilder: (_, i) {
          final p = programs[i];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                p["title"],
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text("${p["group"]} • ${p["shared"] ? "Shared" : "Draft"}"),
              trailing: IconButton(
                icon: Icon(
                  p["shared"] ? Icons.check_circle : Icons.send,
                  color: p["shared"] ? Colors.green : AppColors.terracotta,
                ),
                onPressed: () => _shareProgram(i),
              ),
            ),
          );
        },
      ),
    );
  }

  void _createProgram() {
    setState(() {
      programs.add({
        "title": "New Program",
        "group": "Beginner",
        "shared": false,
      });
    });
  }

  void _shareProgram(int i) {
    setState(() => programs[i]["shared"] = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Program shared (UI only)")),
    );
  }
}
