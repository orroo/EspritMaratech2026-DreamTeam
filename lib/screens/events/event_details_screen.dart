import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../services/event_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late DateTime _selectedDate;
  late EventType _selectedType;
  late String _targetGroup;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers(widget.event);
  }

  void _initializeControllers(EventModel event) {
    _titleController = TextEditingController(text: event.title);
    _descController = TextEditingController(text: event.description);
    _locationController = TextEditingController(text: event.location);
    _selectedDate = event.date;
    _selectedType = event.kind;
    _targetGroup = event.group;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool _canManageEvent(UserModel? user) {
    if (user == null) return false;
    // Only group admins can manage events (edit/delete)
    return user.role == UserRole.groupAdmin;
  }

  Future<void> _updateEvent(String eventId, List<String> participants) async {
    if (_formKey.currentState!.validate()) {
      final updatedEvent = EventModel(
        id: eventId,
        title: _titleController.text,
        description: _descController.text,
        date: _selectedDate,
        location: _locationController.text,
        group: _targetGroup,
        kind: _selectedType,
        participants: participants,
      );

      await Provider.of<EventService>(context, listen: false)
          .updateEvent(eventId, updatedEvent);

      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Événement mis à jour avec succès')),
        );
      }
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer cet événement ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final nav = Navigator.of(context);
      await Provider.of<EventService>(context, listen: false)
          .deleteEvent(widget.event.id);

      if (nav.canPop()) {
        nav.pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Événement supprimé avec succès')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final canManage = _canManageEvent(authService.currentUser);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isEditing ? 'Modifier l\'événement' : 'Détails de l\'événement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (canManage && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                  // Re-initialize controllers with the current event data when entering edit mode
                  _initializeControllers(widget.event);
                });
              },
            ),
          if (canManage && !_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteEvent,
            ),
        ],
      ),
      body: StreamBuilder<EventModel?>(
        stream: Provider.of<EventService>(context, listen: false)
            .getEventStream(widget.event.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final event = snapshot.data;

          if (event == null) {
            return const Center(child: Text('Événement introuvable.'));
          }

          return _isEditing ? _buildEditForm(event) : _buildDetailsView(event);
        },
      ),
    );
  }

  Widget _buildDetailsView(EventModel event) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            icon: Icons.title,
            title: 'Titre',
            content: event.title,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.description,
            title: 'Description',
            content: event.description.isEmpty
                ? 'Aucune description'
                : event.description,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.calendar_today,
            title: 'Date et Heure',
            content: DateFormat('dd MMMM yyyy à HH:mm').format(event.date),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.location_on,
            title: 'Lieu',
            content: event.location,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.group,
            title: 'Groupe',
            content: event.group == 'All'
                ? 'Tous les groupes'
                : 'Groupe ${event.group}',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.category,
            title: 'Type',
            content: _getEventTypeLabel(event.kind),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.people,
            title: 'Participants',
            content: '${event.participants.length} participant(s)',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(EventModel event) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Titre'),
            validator: (v) => v!.isEmpty ? 'Requis' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Lieu'),
            validator: (v) => v!.isEmpty ? 'Requis' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _targetGroup,
            decoration: const InputDecoration(labelText: 'Groupe Cible'),
            items: ['All', 'A', 'B']
                .map((g) => DropdownMenuItem(
                      value: g,
                      child:
                          Text(g == 'All' ? 'Tous les groupes' : 'Groupe $g'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _targetGroup = v!),
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
                if (!mounted) return;
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
            value: _selectedType,
            decoration: const InputDecoration(labelText: 'Type d\'événement'),
            items: EventType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(_getEventTypeLabel(t)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedType = v!),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateEvent(event.id, event.participants),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.daily:
        return 'Quotidien';
      case EventType.weeklyLongRun:
        return 'Course Longue Hebdomadaire';
      case EventType.special:
        return 'Spécial';
    }
  }
}
