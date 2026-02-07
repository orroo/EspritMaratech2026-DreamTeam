import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService with ChangeNotifier {
  Future<List<EventModel>> getEvents({String? group}) async {
    // Return mock data for now - DISABLED

    // Real Firestore Implementation
    try {
      // Use 'event' collection
      Query query =
          FirebaseFirestore.instance.collection('event').orderBy('date');

      if (group != null && group != 'All') {
        query = query.where('group', whereIn: [group, 'All']);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              EventModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching events: $e");
      }
      return [];
    }
  }

  Future<void> createEvent(EventModel event) async {
    try {
      await FirebaseFirestore.instance.collection('event').add(event.toMap());
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error creating event: $e");
      }
    }
  }
}
