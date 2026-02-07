import 'package:flutter/material.dart';

class AdminGroupScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const AdminGroupScreen({super.key, required this.onToggleTheme});

  @override
  State<AdminGroupScreen> createState() => _AdminGroupScreenState();
}

class _AdminGroupScreenState extends State<AdminGroupScreen> {
  final List<Map<String, String>> users = [
    {"name": "Amine", "group": "Beginner"},
    {"name": "Sonia", "group": "Intermediate"},
    {"name": "Karim", "group": "Advanced"},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Management"),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: users.length,
        itemBuilder: (_, i) {
          final u = users[i];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                u["name"]!,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text("Group: ${u["group"]}"),
              trailing: PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == "remove") {
                    setState(() => users.removeAt(i));
                  } else {
                    setState(() => users[i]["group"] = val);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: "Beginner", child: Text("Beginner")),
                  const PopupMenuItem(value: "Intermediate", child: Text("Intermediate")),
                  const PopupMenuItem(value: "Advanced", child: Text("Advanced")),
                  const PopupMenuItem(
                      value: "remove", child: Text("Remove from group")),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
