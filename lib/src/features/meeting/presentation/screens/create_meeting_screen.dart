import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meeting_app/src/features/meeting/domain/entities/meeting.dart';
import 'package:meeting_app/src/features/meeting/presentation/providers/meeting_provider.dart';

class CreateMeetingScreen extends ConsumerStatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  ConsumerState<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends ConsumerState<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _participantsController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _participantsController.dispose();
    super.dispose();
  }

  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate == null) return;

    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? now),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une date et une heure.')),
        );
        return;
      }
      
      final participantCount = int.parse(_participantsController.text);
      final participants = List.generate(
        participantCount,
        (index) => Participant(
          id: '${DateTime.now().millisecondsSinceEpoch}_$index',
          name: 'Participant ${index + 1}',
        ),
      );

      final newMeeting = Meeting(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text, // CORRIGÉ
        date: _selectedDate!,
        status: MeetingStatus.scheduled, // AJOUTÉ
        participants: participants, // AJOUTÉ
      );

      ref.read(asyncMeetingProvider.notifier).createMeeting(newMeeting);

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une réunion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre de la réunion'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un titre.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _participantsController,
                decoration: const InputDecoration(labelText: 'Nombre de personnes'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Veuillez entrer un nombre valide.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'Aucune date sélectionnée'
                          : 'Date : ${MaterialLocalizations.of(context).formatFullDate(_selectedDate!)} à ${TimeOfDay.fromDateTime(_selectedDate!).format(context)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text('Choisir'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Créer la réunion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
