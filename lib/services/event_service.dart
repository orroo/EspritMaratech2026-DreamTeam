import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService with ChangeNotifier {
  Future<List<EventModel>> getEvents({String? group}) async {
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

  Stream<List<EventModel>> getEventsStream({String? group}) {
    Query query =
        FirebaseFirestore.instance.collection('event').orderBy('date');

    if (group != null && group != 'All') {
      query = query.where('group', whereIn: [group, 'All']);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              EventModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Stream<EventModel?> getEventStream(String eventId) {
    return FirebaseFirestore.instance
        .collection('event')
        .doc(eventId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return EventModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    });
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

  Future<void> updateEvent(String eventId, EventModel event) async {
    try {
      await FirebaseFirestore.instance
          .collection('event')
          .doc(eventId)
          .update(event.toMap());
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error updating event: $e");
      }
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('event')
          .doc(eventId)
          .delete();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting event: $e");
      }
    }
  }
}
