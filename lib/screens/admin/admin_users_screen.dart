import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const AdminUsersScreen({super.key, required this.onToggleTheme});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String q = "";

  // UI-only mock data
  final List<Map<String, String>> users = [
    {"name": "Fares Chakroun", "role": "Admin Principal", "group": "Committee"},
    {"name": "Coach Ahmed", "role": "Admin Coach", "group": "All Groups"},
    {"name": "Amal Mouelhi", "role": "Member", "group": "Beginner"},
    {"name": "Sami Ben Ali", "role": "Member", "group": "Intermediate"},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? Colors.white : Colors.black;
    final card = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.08);

    final filtered = users.where((u) {
      return u["name"]!.toLowerCase().contains(q.toLowerCase()) ||
          u["role"]!.toLowerCase().contains(q.toLowerCase()) ||
          u["group"]!.toLowerCase().contains(q.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin • Users"),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
     floatingActionButton: FloatingActionButton(
  heroTag: "usersFab",
  backgroundColor: AppColors.terracotta,
  onPressed: () => _openCreateUser(context),
  child: const Icon(Icons.add, color: Colors.white),
),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // search
          TextField(
            onChanged: (v) => setState(() => q = v),
            decoration: InputDecoration(
              hintText: "Search users, roles, groups...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                for (int i = 0; i < filtered.length; i++) ...[
                  _UserRow(
                    name: filtered[i]["name"]!,
                    role: filtered[i]["role"]!,
                    group: filtered[i]["group"]!,
                    onEdit: () => _openEditUser(context, filtered[i]),
                    onDelete: () => _confirmDelete(context, filtered[i]),
                  ),
                  if (i != filtered.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.06),
                    ),
                ],
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "No users found.",
                      style: TextStyle(
                        color: textMain.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openCreateUser(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Create user (UI only)")),
    );
  }

  void _openEditUser(BuildContext context, Map<String, String> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Edit ${user["name"]} (UI only)")),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, String> user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete user?"),
        content: Text("Remove ${user["name"]} from the system (UI only)."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.terracotta),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => users.remove(user));
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final String name;
  final String role;
  final String group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserRow({
    required this.name,
    required this.role,
    required this.group,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? Colors.white70 : Colors.black54;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: AppColors.terracotta.withOpacity(isDark ? 0.18 : 0.12),
        child: Icon(Icons.person, color: textMain),
      ),
      title: Text(
        name,
        style: TextStyle(fontWeight: FontWeight.w900, color: textMain),
      ),
      subtitle: Text(
        "$role • $group",
        style: TextStyle(fontWeight: FontWeight.w600, color: textSub),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit, color: AppColors.terracotta),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, color: textMain.withOpacity(0.75)),
          ),
        ],
      ),
    );
  }
}
