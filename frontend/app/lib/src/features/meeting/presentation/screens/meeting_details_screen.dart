import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/meeting.dart';
import '../providers/meeting_provider.dart';
// Mock data imports removed - using real backend

/// Écran de détails d'une réunion
class MeetingDetailsScreen extends ConsumerStatefulWidget {
  final String meetingId;

  const MeetingDetailsScreen({
    super.key,
    required this.meetingId,
  });

  @override
  ConsumerState<MeetingDetailsScreen> createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends ConsumerState<MeetingDetailsScreen> {
  bool _isEditMode = false;
  final Map<int, TextEditingController> _participantControllers = {};
  final Map<int, String> _editedNames = {};

  @override
  void dispose() {
    // Nettoyer les contrôleurs
    for (var controller in _participantControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditMode) {
        // Sauvegarder les modifications
        _saveChanges();
      }
      _isEditMode = !_isEditMode;
    });
  }

  void _saveChanges() {
    // Sauvegarder les noms modifiés
    for (var entry in _participantControllers.entries) {
      final newName = entry.value.text.trim();
      if (newName.isNotEmpty) {
        _editedNames[entry.key] = newName;
      }
    }
    
    // TODO: Appeler l'API pour sauvegarder les modifications
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Modifications enregistrées'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      // Réinitialiser les contrôleurs
      for (var controller in _participantControllers.values) {
        controller.clear();
      }
      _participantControllers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final meetingsAsync = ref.watch(asyncMeetingProvider);

    return meetingsAsync.when(
      data: (meetings) {
        final meeting = meetings.firstWhere(
          (m) => m.id == widget.meetingId,
          orElse: () => throw Exception('Réunion non trouvée'),
        );

        // TODO: Implement real audio/transcript check from backend
        final hasAudio = meeting.id == 'demo-999'; // Demo meeting has audio
        final hasTranscript = meeting.id == 'demo-999'; // Demo meeting has transcript
        final isCompleted = meeting.status == MeetingStatus.completed || 
                           meeting.status == MeetingStatus.transcribed;

        return _buildContent(context, meeting, hasAudio, hasTranscript, isCompleted);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Chargement...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(child: Text('Réunion non trouvée')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Meeting meeting,
    bool hasAudio,
    bool hasTranscript,
    bool isCompleted,
  ) {

    return Scaffold(
      appBar: AppBar(
        title: Text(meeting.title),
        actions: [
          // Bouton pour éditer les participants
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelEdit,
              tooltip: 'Annuler',
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: 'Modifier les participants',
            ),
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _toggleEditMode,
              tooltip: 'Enregistrer',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge de statut
            _buildStatusBadge(meeting.status),
            const SizedBox(height: 16),

            // Description
            if (meeting.description != null && meeting.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting.description!,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Informations de la réunion
            _buildInfoCard(meeting),
            const SizedBox(height: 24),

            // Statistiques (si réunion terminée)
            // TODO: Implémenter les statistiques depuis les vraies données
            // if (isCompleted) ..[
            //   _buildStatsCard(synthesis),
            //   const SizedBox(height: 24),
            // ],

            // Boutons d'action (si réunion terminée)
            if (isCompleted) ...[
              if (hasTranscript) ...[
                _buildTranscriptButton(context, meeting.id),
                const SizedBox(height: 12),
              ],
              if (hasAudio) ...[
                _buildPlaybackButton(context, meeting.id),
                const SizedBox(height: 24),
              ],
            ],

            // Participants
            const Text(
              'Participants',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (meeting.participants.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('Aucun participant'),
                  ),
                ),
              )
            else
              ...meeting.participants.asMap().entries.map((entry) {
                final index = entry.key;
                final participant = entry.value;
                return _buildParticipantCard(index, participant.name);
              }).toList(),
          ],
        ),
      ),
    );
  }

  /// Badge de statut
  Widget _buildStatusBadge(MeetingStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case MeetingStatus.scheduled:
        color = Colors.blue;
        label = 'Planifiée';
        icon = Icons.schedule;
        break;
      case MeetingStatus.inProgress:
        color = Colors.orange;
        label = 'En cours';
        icon = Icons.play_circle;
        break;
      case MeetingStatus.completed:
      case MeetingStatus.transcribed: // Traiter comme terminée
        color = Colors.green;
        label = 'Terminée';
        icon = Icons.check_circle;
        break;
      case MeetingStatus.failed:
        color = Colors.red;
        label = 'Échec';
        icon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Card avec les informations de la réunion
  Widget _buildInfoCard(Meeting meeting) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.calendar_today,
              'Date',
              _formatDate(meeting.date),
            ),
            if (meeting.duration != null) ...[
              const Divider(),
              _buildInfoRow(
                Icons.access_time,
                'Durée',
                '${meeting.duration} minutes',
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Ligne d'information
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  /// Bouton pour voir la transcription
  Widget _buildTranscriptButton(BuildContext context, String meetingId) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Navigation vers l'écran de transcription
          context.push('/meeting-transcript/$meetingId');
        },
        icon: const Icon(Icons.text_snippet, size: 24),
        label: const Text(
          'Voir la transcription',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.purple, width: 2),
          foregroundColor: Colors.purple,
        ),
      ),
    );
  }

  /// Bouton pour réécouter la réunion
  Widget _buildPlaybackButton(BuildContext context, String meetingId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigation vers l'écran de lecture
          context.push('/meeting-playback/$meetingId');
        },
        icon: const Icon(Icons.play_circle_filled, size: 28),
        label: const Text(
          'Réécouter la réunion',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  /// Card d'un participant
  Widget _buildParticipantCard(int index, String participantName) {
    // Utiliser le nom édité s'il existe, sinon le nom original
    final displayName = _editedNames[index] ?? participantName;
    
    // Créer un contrôleur si on est en mode édition et qu'il n'existe pas
    if (_isEditMode && !_participantControllers.containsKey(index)) {
      _participantControllers[index] = TextEditingController(text: displayName);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _isEditMode ? Colors.orange : Colors.blue,
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
          ),
        ),
        title: _isEditMode
            ? TextField(
                controller: _participantControllers[index],
                decoration: InputDecoration(
                  hintText: 'Nom du participant',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        trailing: _isEditMode
            ? const Icon(Icons.edit, color: Colors.orange)
            : null,
      ),
    );
  }

  /// Formater la date
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
