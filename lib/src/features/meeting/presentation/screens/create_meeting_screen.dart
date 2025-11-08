import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:meeting_app/src/features/meeting/domain/entities/meeting.dart';
import 'package:meeting_app/src/features/meeting/presentation/providers/meeting_provider.dart';

class CreateMeetingScreen extends ConsumerStatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  ConsumerState<CreateMeetingScreen> createState() =>
      _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends ConsumerState<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;
  int? _selectedParticipantCount;
  String? _selectedDuration;
  bool _startTranscription = true;
  bool _sendReminders = false;

  final List<int> _participantOptions = List.generate(20, (index) => index + 1);
  final List<String> _durationOptions = [
    '15 minutes',
    '30 minutes',
    '45 minutes',
    '1 heure',
    '1 heure 30 minutes',
    '2 heures',
    '3 heures',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
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
      _dateController.text =
          DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate!);
    });
  }

  int _parseDuration(String? durationString) {
    if (durationString == null) return 0;

    int totalMinutes = 0;
    final parts = durationString.toLowerCase().split(' ');

    for (int i = 0; i < parts.length; i++) {
      if (parts[i] == 'heure' || parts[i] == 'heures') {
        for (int j = i - 1; j >= 0; j--) {
          if (int.tryParse(parts[j]) != null) {
            totalMinutes += int.parse(parts[j]) * 60;
            break; 
          }
        }
        if (i > 0 && parts[i-1] == '1'){
             totalMinutes += 60;
        } else if (i == 0 || int.tryParse(parts[i-1]) == null) {
           totalMinutes += 60;
        }

      } else if (parts[i] == 'minutes') {
        if (i > 0 && int.tryParse(parts[i - 1]) != null) {
          totalMinutes += int.parse(parts[i - 1]);
        }
      }
    }
    return totalMinutes == 0 && durationString.contains('heure') ? 60 : totalMinutes;
  }

  String _getActiveDuration() {
    return _selectedDuration ?? '';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final durationInMinutes = _parseDuration(_getActiveDuration());

      final newMeeting = Meeting(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        date: _selectedDate!,
        duration: durationInMinutes,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        status: MeetingStatus.scheduled,
        participants: List.generate(
          _selectedParticipantCount!,
          (index) => Participant(
            id: '${DateTime.now().millisecondsSinceEpoch}_$index',
            name: 'Participant ${index + 1}',
          ),
        ),
        startTranscription: _startTranscription,
        sendReminders: _sendReminders,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom et Date
                    if (isSmallScreen) ..._buildMobileLayout() else ..._buildDesktopLayout(),
                    const SizedBox(height: 16),
                    // Description
                    _buildDescriptionField(),
                    const SizedBox(height: 24),
                    // Options avancées
                    _buildAdvancedOptions(),
                    const SizedBox(height: 32),
                    // Boutons d'action
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildMobileLayout() {
    return [
      _buildTextField(
        controller: _titleController,
        labelText: 'Nom de la réunion *',
        hintText: 'Ex: Réunion équipe marketing',
        icon: Icons.description_outlined,
      ),
      const SizedBox(height: 16),
      _buildDateField(),
      const SizedBox(height: 16),
      _buildDropdown(
        value: _selectedParticipantCount,
        items: _participantOptions.map((count) {
          return DropdownMenuItem<int>(
            value: count,
            child: Text('$count'),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedParticipantCount = value;
          });
        },
        labelText: 'Nombre de participants *',
        hintText: 'Sélectionnez le nombre',
        icon: Icons.people_outline,
      ),
      const SizedBox(height: 16),
      _buildDropdown(
        value: _selectedDuration,
        items: _durationOptions.map((duration) {
          return DropdownMenuItem<String>(
            value: duration,
            child: Text(duration),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDuration = value;
          });
        },
        labelText: 'Durée prévue *',
        hintText: 'Sélectionnez la durée',
        icon: Icons.access_time,
      ),
    ];
  }

  List<Widget> _buildDesktopLayout() {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildTextField(
              controller: _titleController,
              labelText: 'Nom de la réunion *',
              hintText: 'Ex: Réunion équipe marketing',
              icon: Icons.description_outlined,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDateField(),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildDropdown(
              value: _selectedParticipantCount,
              items: _participantOptions.map((count) {
                return DropdownMenuItem<int>(
                  value: count,
                  child: Text('$count'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedParticipantCount = value;
                });
              },
              labelText: 'Nombre de participants *',
              hintText: 'Sélectionnez le nombre',
              icon: Icons.people_outline,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdown(
              value: _selectedDuration,
              items: _durationOptions.map((duration) {
                return DropdownMenuItem<String>(
                  value: duration,
                  child: Text(duration),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDuration = value;
                });
              },
              labelText: 'Durée prévue *',
              hintText: 'Sélectionnez la durée',
              icon: Icons.access_time,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (!isOptional && (value == null || value.trim().isEmpty)) {
          return 'Ce champ est obligatoire.';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            labelText: 'Description de la réunion (optionnel)',
            hintText:
                'Décrivez l\'objectif et les points à aborder lors de cette réunion...',
            prefixIcon: const Icon(Icons.description_outlined, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            counterText: '',
            alignLabelWithHint: true,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_descriptionController.text.length}/500 caractères',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Date de la réunion *',
        hintText: 'jj/mm/aaaa --:--',
        prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
        suffixIcon: const Icon(Icons.calendar_month, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onTap: _presentDatePicker,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une date.';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String labelText,
    required String hintText,
    IconData? icon,
    bool hideLabel = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: hideLabel ? null : labelText,
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      validator: (value) {
        if (!hideLabel && value == null) {
          return 'Veuillez faire une sélection.';
        }
        return null;
      },
    );
  }

  Widget _buildAdvancedOptions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.settings, size: 20, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Options avancées',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isSmallScreen)
                Column(
                  children: [
                    CheckboxListTile(
                      title: const Text(
                        'Démarrer automatiquement la transcription',
                        style: TextStyle(fontSize: 13),
                      ),
                      value: _startTranscription,
                      onChanged: (bool? value) {
                        setState(() {
                          _startTranscription = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    CheckboxListTile(
                      title: const Text(
                        'Envoyer des rappels aux participants',
                        style: TextStyle(fontSize: 13),
                      ),
                      value: _sendReminders,
                      onChanged: (bool? value) {
                        setState(() {
                          _sendReminders = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text(
                          'Démarrer automatiquement la transcription',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: _startTranscription,
                        onChanged: (bool? value) {
                          setState(() {
                            _startTranscription = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text(
                          'Envoyer des rappels aux participants',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: _sendReminders,
                        onChanged: (bool? value) {
                          setState(() {
                            _sendReminders = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Retour'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            side: BorderSide(color: Colors.grey.shade300),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _submitForm,
          icon: const Icon(Icons.rocket_launch, size: 18),
          label: const Text('Créer la Réunion'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}
