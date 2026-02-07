import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import 'home_screen.dart';
import 'guest_news_screen.dart';
import 'profile_screen.dart';
import 'events_screen.dart';

class AppShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isGuest;

  const AppShell({
    super.key,
    required this.onToggleTheme,
    this.isGuest = false,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    if (widget.isGuest) {
      _pages = [
        HomeScreen(onToggleTheme: widget.onToggleTheme),
        GuestNewsScreen(onToggleTheme: widget.onToggleTheme), // Events tab becomes News
      ];
    } else {
      _pages = [
        HomeScreen(onToggleTheme: widget.onToggleTheme),
const EventsScreen(),
        const _PlaceholderPage(title: "Stats"),
        ProfileScreen(
          onToggleTheme: widget.onToggleTheme,
          onLogout: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: _RCTBottomNav(
            currentIndex: _index,
            onChanged: (i) => setState(() => _index = i),
            isDark: isDark,
            isGuest: widget.isGuest,
          ),
        ),
      ),
    );
  }
}

class _RCTBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final bool isDark;
  final bool isGuest;

  const _RCTBottomNav({
    required this.currentIndex,
    required this.onChanged,
    required this.isDark,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    final pill = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.08);
    final iconOn = isDark ? Colors.white : Colors.black;
    final iconOff =
        isDark ? Colors.white.withOpacity(0.55) : Colors.black.withOpacity(0.45);

    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: pill,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),

          _NavItem(
            selected: currentIndex == 0,
            label: "Home",
            icon: Icons.home_rounded,
            onTap: () => onChanged(0),
            iconOn: iconOn,
            iconOff: iconOff,
          ),

          // ✅ Guest: only 2 tabs (Home + News)
          if (isGuest) ...[
            _NavIcon(
              selected: currentIndex == 1,
              icon: Icons.article_outlined, // News
              onTap: () => onChanged(1),
              iconOn: iconOn,
              iconOff: iconOff,
            ),
          ] else ...[
            // ✅ Logged-in: 4 tabs
            _NavIcon(
              selected: currentIndex == 1,
              icon: Icons.event_note_rounded,
              onTap: () => onChanged(1),
              iconOn: iconOn,
              iconOff: iconOff,
            ),
            _NavIcon(
              selected: currentIndex == 2,
              icon: Icons.bar_chart_rounded,
              onTap: () => onChanged(2),
              iconOn: iconOn,
              iconOff: iconOff,
            ),
            _NavIcon(
              selected: currentIndex == 3,
              icon: Icons.person_rounded,
              onTap: () => onChanged(3),
              iconOn: iconOn,
              iconOff: iconOff,
            ),
          ],

          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconOn;
  final Color iconOff;

  const _NavItem({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.iconOn,
    required this.iconOff,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: selected ? 3 : 2,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.terracotta.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? iconOn : iconOff, size: 22),
              if (selected) ...[
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: iconOn,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconOn;
  final Color iconOff;

  const _NavIcon({
    required this.selected,
    required this.icon,
    required this.onTap,
    required this.iconOn,
    required this.iconOff,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: selected ? iconOn : iconOff, size: 24),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
