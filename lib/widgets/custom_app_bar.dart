// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showThemeToggle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.showThemeToggle = true,
  });

  void _showColorModeSheet(BuildContext context) {
    final controller = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ColorBlindMode.values.map((mode) {
              final pal = ThemeProvider.palettes[mode]!;
              return ListTile(
                leading: CircleAvatar(backgroundColor: pal.terracotta),
                title: Text(ThemeProvider.modeLabel(mode)),
                subtitle: Text(
                  _getModeDescription(mode),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: controller.mode == mode 
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  controller.setMode(mode);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getModeDescription(ColorBlindMode mode) {
    switch (mode) {
      case ColorBlindMode.normal:
        return 'Standard colors';
      case ColorBlindMode.protanopia:
        return 'Red deficiency';
      case ColorBlindMode.deuteranopia:
        return 'Green deficiency';
      case ColorBlindMode.tritanopia:
        return 'Blue-yellow blindness';
      case ColorBlindMode.achromatopsia:
        return 'Monochrome';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;
    
    List<Widget> appBarActions = [];
    
    // Add theme toggle if enabled
    if (showThemeToggle) {
      appBarActions.add(
        IconButton(
          icon: const Icon(Icons.visibility),
          tooltip: 'Change color theme',
          onPressed: () => _showColorModeSheet(context),
        ),
      );
    }
    
    // Add custom actions
    if (actions != null) {
      appBarActions.addAll(actions!);
    }
    
    return AppBar(
      title: Text(
        title,
        style: TextStyle(color: colors.ivory),
      ),
      backgroundColor: colors.terracotta,
      foregroundColor: colors.ivory,
      elevation: 2,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: appBarActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}