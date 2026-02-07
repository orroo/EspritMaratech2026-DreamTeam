import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../models/group_model.dart';
import '../../services/group_service.dart';
import '../../utils/constants.dart';
import '../../widgets/assistant_fab.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  EventType _selectedType = EventType.daily;
  String _targetGroup = 'All';

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final newEvent = EventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descController.text,
        date: _selectedDate,
        location: _locationController.text,
        group: _targetGroup,
        kind: _selectedType,
        participants: [],
      );

      final nav = Navigator.of(context);
      final eventService = Provider.of<EventService>(context, listen: false);
      final notificationService =
          Provider.of<NotificationService>(context, listen: false);

      await eventService.createEvent(newEvent, notificationService);

      if (nav.canPop()) {
        nav.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    // Pre-fill group if group admin
    if (currentUser?.role == UserRole.groupAdmin && _targetGroup == 'All') {
      if (currentUser?.group != null) {
        _targetGroup = currentUser!.group!;
      }
    }

    // Determine if user can change group (only adminPrincipal or adminCoach)
    final canChangeGroup = currentUser?.role == UserRole.adminPrincipal ||
        currentUser?.role == UserRole.adminCoach;

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un événement')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titre'),
              validator: (v) => v!.isEmpty ? 'Requis' : null,
            ),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Lieu'),
              validator: (v) => v!.isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            if (canChangeGroup)
              StreamBuilder<List<GroupModel>>(
                stream: Provider.of<GroupService>(context).getAllGroups(),
                builder: (context, snapshot) {
                  final groups = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    initialValue: _targetGroup,
                    decoration:
                        const InputDecoration(labelText: 'Groupe Cible'),
                    items: [
                      const DropdownMenuItem(
                          value: 'All', child: Text('Tous les groupes')),
                      ...groups.map((g) => DropdownMenuItem(
                            value: g
                                .name, // Or g.id depending on how events filter
                            child: Text('Groupe ${g.name}'),
                          )),
                    ],
                    onChanged: (v) => setState(() => _targetGroup = v!),
                  );
                },
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Groupe cible: $_targetGroup',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date et Heure'),
              subtitle:
                  Text(DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030));
                if (date != null) {
                  // ignore: use_build_context_synchronously
                  if (!context.mounted) return;
                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDate));
                  if (time != null) {
                    setState(() {
                      _selectedDate = DateTime(date.year, date.month, date.day,
                          time.hour, time.minute);
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EventType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(labelText: 'Type d\'événement'),
              items: EventType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.toString().split('.').last),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
      floatingActionButton: const AssistantFAB(),
    );
  }
}
