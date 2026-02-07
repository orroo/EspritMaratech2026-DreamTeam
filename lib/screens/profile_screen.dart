import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'personal_screen.dart';


class ProfileScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.onToggleTheme,
    required this.onLogout,
  });

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

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Top profile card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                // Avatar + edit
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.terracotta.withOpacity(0.25),
                      child: const Icon(Icons.person, size: 46),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          // UI only for now
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Edit profile (UI only)")),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.terracotta,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.black : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  "Runner",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textMain,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  "guest@rct.tn",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: textSub,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Options list
          Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
_OptionTile(
  icon: Icons.badge_outlined,
  title: "Personal",
  subtitle: "Name, group, and account details",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonalScreen(onToggleTheme: onToggleTheme),
      ),
    );
  },
),
_DividerLine(isDark: isDark),

                _OptionTile(
                  icon: Icons.palette_outlined,
                  title: "Customize",
                  subtitle:
                      "Choose a color-blind friendly palette (4 types supported)",
                  onTap: () => _toast(context, "Customize palettes (next step)"),
                ),
                _DividerLine(isDark: isDark),


                _OptionTile(
                  icon: Icons.verified_user_outlined,
                  title: "Rules & agreements",
                  subtitle: "Club charter, guidelines, and terms",
                  onTap: () => _toast(context, "Rules & agreements (UI only)"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Logout button
          SizedBox(
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: onLogout,
              child: const Text(
                "Logout",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              "RCT • Running Club Tunis",
              style: TextStyle(
                color: textSub,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? Colors.white : Colors.black;
    final textSub = isDark ? Colors.white70 : Colors.black54;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.terracotta.withOpacity(isDark ? 0.18 : 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: textMain),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: textMain,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textSub,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? Colors.white54 : Colors.black45,
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  final bool isDark;
  const _DividerLine({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
    );
  }
}
