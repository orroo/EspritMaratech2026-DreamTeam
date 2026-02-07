import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../models/notification_model.dart';
import '../utils/constants.dart';

class NotificationOverlayListener extends StatefulWidget {
  const NotificationOverlayListener({super.key});

  @override
  State<NotificationOverlayListener> createState() =>
      _NotificationOverlayListenerState();
}

class _NotificationOverlayListenerState
    extends State<NotificationOverlayListener> {
  StreamSubscription? _subscription;
  NotificationModel? _currentNotification;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribe();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _subscribe() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final notificationService =
        Provider.of<NotificationService>(context, listen: false);

    _subscription = authService.authStateStream().listen((user) {
      if (user != null) {
        _subscription?.cancel(); // Cancel old sub if exists
        _subscription = notificationService
            .getLatestAnnouncement(user.group ?? 'All', user.lastReadTimestamp)
            .listen((notification) {
          if (notification != null &&
              notification.id != _currentNotification?.id) {
            setState(() {
              _currentNotification = notification;
            });
            _startTimer();
          }
        });
      } else {
        _subscription?.cancel();
        setState(() {
          _currentNotification = null;
        });
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _currentNotification = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentNotification == null) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          right: 10,
        ),
        child: _PopupBanner(
          title: _currentNotification!.title,
          message: _currentNotification!.message,
          onDismiss: () {
            setState(() {
              _currentNotification = null;
            });
          },
        ),
      ),
    );
  }
}

class _PopupBanner extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onDismiss;

  const _PopupBanner({
    required this.title,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
