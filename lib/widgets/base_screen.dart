// lib/widgets/base_screen.dart
import 'package:flutter/material.dart';
import 'custom_app_bar.dart'; // Add this import

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showThemeToggle;

  const BaseScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = true,
    this.showThemeToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        actions: actions,
        showBackButton: showBackButton,
        showThemeToggle: showThemeToggle,
      ),
      body: body,
    );
  }
}