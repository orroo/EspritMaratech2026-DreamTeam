import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE53935); // Run club red
  static const Color secondary = Color(0xFF1E88E5);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
}

class AppTextStyles {
  // Add custom styles if needed, mostly using GoogleFonts via Theme
}
// lib/models/event_model.dart
enum EventType { daily, weeklyLongRun, competition, training }

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String group;
  final EventType kind;
  final List<String> participants;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.group,
    required this.kind,
    required this.participants,
  });
}

// lib/models/user_model.dart
enum UserRole { superAdmin, coach, groupAdmin, member, visitor }

class UserModel {
  final String id;
  final String name;
  final UserRole role;
  final String? group;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.group,
  });
}