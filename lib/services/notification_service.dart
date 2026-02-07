import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';

class NotificationService with ChangeNotifier {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(settings: initializationSettings);

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && !kIsWeb) {
        _showLocalNotification(
          notification.title ?? '',
          notification.body ?? '',
          channel,
        );
      }
    });

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    }
  }

  Future<void> _showLocalNotification(
    String title,
    String body,
    AndroidNotificationChannel channel,
  ) async {
    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // Send a shared announcement to a group (1 write only)
  Future<void> sendAnnouncement({
    required String group,
    required String title,
    required String message,
    String? eventId,
  }) async {
    try {
      final announcementRef = _firestore.collection('announcement').doc();
      final timestamp = DateTime.now();

      final announcement = {
        'id': announcementRef.id,
        'group': group,
        'title': title,
        'message': message,
        'timestamp': Timestamp.fromDate(timestamp),
        'eventId': eventId,
      };

      await announcementRef.set(announcement);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error sending announcement: $e");
      }
    }
  }

  // Get shared announcements for a user based on group and timestamp
  Stream<List<NotificationModel>> getAnnouncements(
      String group, DateTime? lastRead) {
    Query query = _firestore.collection('announcement');

    // Filter by group
    if (group != 'All') {
      query = query.where('group', whereIn: [group, 'All']);
    }

    return query
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = (data['timestamp'] as Timestamp).toDate();

        // Mark as read locally based on user's lastReadTimestamp
        bool isRead = lastRead != null && timestamp.isBefore(lastRead);

        return NotificationModel(
          id: doc.id,
          userId: '', // Shared, per-user ID not applicable
          title: data['title'] ?? '',
          message: data['message'] ?? '',
          timestamp: timestamp,
          isRead: isRead,
          eventId: data['eventId'],
        );
      }).toList();
      return list;
    });
  }

  // Fetch recent announcements (Future, not Stream)
  Future<List<NotificationModel>> fetchRecentAnnouncements(
      String group, DateTime? lastRead) async {
    Query query = _firestore.collection('announcement');

    if (group != 'All') {
      query = query.where('group', whereIn: [group, 'All']);
    }

    final snapshot =
        await query.orderBy('timestamp', descending: true).limit(5).get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      bool isRead = lastRead != null && timestamp.isBefore(lastRead);

      return NotificationModel(
        id: doc.id,
        userId: '',
        title: data['title'] ?? '',
        message: data['message'] ?? '',
        timestamp: timestamp,
        isRead: isRead,
        eventId: data['eventId'],
      );
    }).toList();
  }

  // Get unread count via shared announcements
  Stream<int> getUnreadCount(String group, DateTime? lastRead) {
    Query query = _firestore.collection('announcement');

    if (group != 'All') {
      query = query.where('group', whereIn: [group, 'All']);
    }

    return query.snapshots().map((snapshot) {
      if (lastRead == null) return snapshot.docs.length;

      return snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        return timestamp.isAfter(lastRead);
      }).length;
    });
  }

  // Get latest for pop-up and system notification triggers
  Stream<NotificationModel?> getLatestAnnouncement(
      String group, DateTime? lastRead) {
    Query query = _firestore.collection('announcement');

    if (group != 'All') {
      query = query.where('group', whereIn: [group, 'All']);
    }

    return query
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp).toDate();

      // Only trigger if it's newer than lastRead
      if (lastRead != null &&
          (timestamp.isBefore(lastRead) ||
              timestamp.isAtSameMomentAs(lastRead))) {
        return null;
      }

      final notification = NotificationModel(
        id: snapshot.docs.first.id,
        userId: '',
        title: data['title'] ?? '',
        message: data['message'] ?? '',
        timestamp: timestamp,
        isRead: false,
        eventId: data['eventId'],
      );

      // Trigger local notification if not already handled by FCM (e.g. from Firestore stream logic)
      // Note: We use the overlay listener for in-app popups, but the actual system tray
      // is best handled via FCM foreground messages in initialize() or here manually.
      // To strictly follow "notification bar", we used onMessage in initialize().

      return notification;
    });
  }
}
