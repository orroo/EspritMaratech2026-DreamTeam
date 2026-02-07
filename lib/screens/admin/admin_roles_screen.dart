import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdminRolesScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const AdminRolesScreen({super.key, required this.onToggleTheme});

  @override
  State<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends State<AdminRolesScreen> {
  // UI-only: selected role to preview/edit permissions
  String selectedRole = "Admin Principal";

  // UI-only: permissions map per role
  final Map<String, Map<String, bool>> perms = {
    "Admin Principal": {
      "Manage roles & permissions": true,
      "Create users": true,
      "Edit users": true,
      "Delete users": true,
      "Create admins": true,
      "Edit admins": true,
      "Delete admins": true,
      "Assign users to groups": true,
      "Publish programs": false,
      "View club data": true,
    },
    "Admin Coach": {
      "Manage roles & permissions": false,
      "Create users": false,
      "Edit users": false,
      "Delete users": false,
      "Create admins": false,
      "Edit admins": false,
      "Delete admins": false,
      "Assign users to groups": false,
      "Publish programs": true,
      "View club data": true,
    },
    "Group Admin": {
      "Manage roles & permissions": false,
      "Create users": false,
      "Edit users": false,
      "Delete users": false,
      "Create admins": false,
      "Edit admins": false,
      "Delete admins": false,
      "Assign users to groups": true,
      "Publish programs": false,
      "View club data": true,
    },
    "Member": {
      "Manage roles & permissions": false,
      "Create users": false,
      "Edit users": false,
      "Delete users": false,
      "Create admins": false,
      "Edit admins": false,
      "Delete admins": false,
      "Assign users to groups": false,
      "Publish programs": false,
      "View club data": true,
    },
  };

  // UI-only: current admins list
  final List<Map<String, String>> admins = [
    {"name": "Fares Chakroun", "role": "Admin Principal"},
    {"name": "Coach Ahmed", "role": "Admin Coach"},
    {"name": "Group Lead Sami", "role": "Group Admin"},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F0F10) : const Color(0xFFF7F3E3);
    final card = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.08);
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? Colors.white70 : Colors.black54;

    final roles = perms.keys.toList();
    final currentPerms = perms[selectedRole]!;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Admin • Roles"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.terracotta,
        onPressed: () => _openAddAdmin(context),
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text(
          "Add admin",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Admins list
          Text(
            "Admins",
            style: TextStyle(
              color: textMain,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                for (int i = 0; i < admins.length; i++) ...[
                  _AdminRow(
                    name: admins[i]["name"]!,
                    role: admins[i]["role"]!,
                    onChangeRole: () => _openChangeRole(context, i),
                    onRemove: () => _confirmRemoveAdmin(context, i),
                  ),
                  if (i != admins.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.06),
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Role selector
          Text(
            "Permissions matrix",
            style: TextStyle(
              color: textMain,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: textMain.withOpacity(0.9)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Select a role to preview/edit its permissions.",
                    style: TextStyle(
                      color: textSub,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedRole,
                  underline: const SizedBox.shrink(),
                  items: roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => selectedRole = v);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Permissions list (toggle UI-only)
          Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                for (int i = 0; i < currentPerms.keys.length; i++) ...[
                  _PermRow(
                    title: currentPerms.keys.elementAt(i),
                    value: currentPerms.values.elementAt(i),
                    onChanged: (val) {
                      setState(() {
                        currentPerms[currentPerms.keys.elementAt(i)] = val;
                      });
                    },
                  ),
                  if (i != currentPerms.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.06),
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Safety note
          Text(
            "Note: This is UI-only for now. We’ll enforce these permissions later via Firebase rules/claims.",
            style: TextStyle(
              color: textSub,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  void _openAddAdmin(BuildContext context) {
    final nameCtrl = TextEditingController();
    String role = "Admin Coach";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final textMain = isDark ? Colors.white : Colors.black;

        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 10,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add admin",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: "User full name (UI-only)",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "Admin Principal", child: Text("Admin Principal")),
                  DropdownMenuItem(value: "Admin Coach", child: Text("Admin Coach")),
                  DropdownMenuItem(value: "Group Admin", child: Text("Group Admin")),
                ],
                onChanged: (v) => role = v ?? role,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;

                    setState(() {
                      admins.add({"name": name, "role": role});
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    "Add",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openChangeRole(BuildContext context, int adminIndex) {
    String role = admins[adminIndex]["role"]!;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Change role",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                items: const [
                  DropdownMenuItem(value: "Admin Principal", child: Text("Admin Principal")),
                  DropdownMenuItem(value: "Admin Coach", child: Text("Admin Coach")),
                  DropdownMenuItem(value: "Group Admin", child: Text("Group Admin")),
                ],
                onChanged: (v) => role = v ?? role,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                  ),
                  onPressed: () {
                    setState(() {
                      admins[adminIndex]["role"] = role;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmRemoveAdmin(BuildContext context, int adminIndex) {
    final name = admins[adminIndex]["name"]!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove admin?"),
        content: Text("Remove $name admin access (UI-only)."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.terracotta),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => admins.removeAt(adminIndex));
            },
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }
}

class _AdminRow extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback onChangeRole;
  final VoidCallback onRemove;

  const _AdminRow({
    required this.name,
    required this.role,
    required this.onChangeRole,
    required this.onRemove,
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
        child: Icon(Icons.admin_panel_settings_outlined, color: textMain),
      ),
      title: Text(
        name,
        style: TextStyle(fontWeight: FontWeight.w900, color: textMain),
      ),
      subtitle: Text(
        role,
        style: TextStyle(fontWeight: FontWeight.w700, color: textSub),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onChangeRole,
            icon: Icon(Icons.edit, color: AppColors.terracotta),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.delete_outline, color: textMain.withOpacity(0.75)),
          ),
        ],
      ),
    );
  }
}

class _PermRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? Colors.white70 : Colors.black54;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: textMain,
        ),
      ),
      subtitle: Text(
        value ? "Allowed" : "Not allowed",
        style: TextStyle(fontWeight: FontWeight.w700, color: textSub),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: AppColors.terracotta,
        onChanged: onChanged,
      ),
    );
  }
}
