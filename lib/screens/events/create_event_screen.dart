import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../utils/constants.dart';

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
      await Provider.of<EventService>(context, listen: false)
          .createEvent(newEvent);
      if (nav.canPop()) {
        nav.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              value: _selectedType,
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
    );
  }
}
