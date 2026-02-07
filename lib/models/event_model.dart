import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType { daily, weeklyLongRun, special }

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String group; // Changed from groupName
  final EventType kind; // Changed from type
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

  factory EventModel.fromMap(String id, Map<String, dynamic> data) {
    return EventModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      // Handle both Timestamp and direct Date if needed, usually Firestore returns Timestamp
      date: (data['date'] is Timestamp)
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      location: data['location'] ?? '',
      group: data['group'] ?? 'All',
      kind: _stringToKind(data['kind']),
      participants: List<String>.from(data['participants'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'group': group,
      'kind': _kindToString(kind),
      'participants': participants,
    };
  }

  static EventType _stringToKind(String? str) {
    switch (str) {
      case 'WEEKLY':
        return EventType.weeklyLongRun;
      case 'SPECIAL':
        return EventType.special;
      default:
        return EventType.daily;
    }
  }

  static String _kindToString(EventType kind) {
    switch (kind) {
      case EventType.weeklyLongRun:
        return 'WEEKLY';
      case EventType.special:
        return 'SPECIAL';
      case EventType.daily:
        return 'DAILY';
    }
  }
}
