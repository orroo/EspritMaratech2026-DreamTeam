import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../events/event_details_screen.dart';
import '../../services/event_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Mark as read when opening the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthService>(context, listen: false)
            .updateLastReadTimestamp();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final notificationService = Provider.of<NotificationService>(context);
    final userId = authService.currentUser?.id;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Veuillez vous connecter')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tout marquer comme lu',
            onPressed: () => authService.updateLastReadTimestamp(),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationService.getAnnouncements(
            authService.currentUser?.group ?? 'All',
            authService.currentUser?.lastReadTimestamp ?? DateTime.now()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.isRead
                      ? Colors.grey[200]
                      : AppColors.primary.withValues(alpha: 0.2),
                  child: Icon(
                    notification.eventId != null
                        ? Icons.event
                        : Icons.notifications,
                    color:
                        notification.isRead ? Colors.grey : AppColors.primary,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.message),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM HH:mm').format(notification.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: !notification.isRead
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
                onTap: () {
                  // Navigate to event if applicable
                  if (notification.eventId != null) {
                    _navigateToEvent(context, notification.eventId!);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToEvent(BuildContext context, String eventId) {
    Provider.of<EventService>(context, listen: false)
        .getEvents()
        .then((events) {
      if (!mounted) return;
      final event = events.firstWhere((e) => e.id == eventId,
          orElse: () => throw 'Non trouvé');
      final navContext = context;
      if (navContext.mounted) {
        Navigator.push(
          navContext,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: event),
          ),
        );
      }
    }).catchError((e) {
      final snackContext = context;
      if (snackContext.mounted) {
        ScaffoldMessenger.of(snackContext).showSnackBar(
          const SnackBar(content: Text('Impossible de charger l\'événement')),
        );
      }
    });
  }
}
