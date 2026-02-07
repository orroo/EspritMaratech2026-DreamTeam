import 'package:cloud_firestore/cloud_firestore.dart';

class ProgramModel {
  final String id;
  final String title;
  final String description;
  final String coachId;
  final String? coachName;
  final DateTime timestamp;
  final String? pdfUrl;

  ProgramModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coachId,
    this.coachName,
    required this.timestamp,
    this.pdfUrl,
  });

  factory ProgramModel.fromMap(String id, Map<String, dynamic> data) {
    return ProgramModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      coachId: data['coachId'] ?? '',
      coachName: data['coachName'],
      timestamp: (data['timestamp'] is Timestamp)
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      pdfUrl: data['pdfUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'coachId': coachId,
      'coachName': coachName,
      'timestamp': Timestamp.fromDate(timestamp),
      'pdfUrl': pdfUrl,
    };
  }
}
