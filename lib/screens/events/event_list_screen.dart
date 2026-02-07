import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final group = authService.currentUser?.group;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Événements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => authService.logout(),
          ),
        ],
      ),
      body: FutureBuilder<List<EventModel>>(
        future: Provider.of<EventService>(context, listen: false)
            .getEvents(group: group),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun événement à venir.'));
          }

          final events = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: event.kind == EventType.weeklyLongRun
                        ? Colors.purple
                        : AppColors.primary,
                    child: Icon(
                        event.kind == EventType.weeklyLongRun
                            ? Icons.star
                            : Icons.directions_run,
                        color: Colors.white),
                  ),
                  title: Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          DateFormat('dd MMM yyyy - HH:mm').format(event.date)),
                      Text(event.location),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // TODO: Show details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
