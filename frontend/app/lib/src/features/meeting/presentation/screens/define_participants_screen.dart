import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Écran pour définir les noms des participants avant de démarrer l'enregistrement
class DefineParticipantsScreen extends ConsumerStatefulWidget {
  final String meetingId;
  final String meetingTitle;
  final int participantCount;

  const DefineParticipantsScreen({
    super.key,
    required this.meetingId,
    required this.meetingTitle,
    required this.participantCount,
  });

  @override
  ConsumerState<DefineParticipantsScreen> createState() => _DefineParticipantsScreenState();
}

class _DefineParticipantsScreenState extends ConsumerState<DefineParticipantsScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<TextEditingController> _nameControllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    // Créer un contrôleur pour chaque participant
    _nameControllers = List.generate(
      widget.participantCount,
      (index) => TextEditingController(text: 'Participant ${index + 1}'),
    );
    _focusNodes = List.generate(
      widget.participantCount,
      (index) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startRecording() {
    if (_formKey.currentState!.validate()) {
      // Récupérer les noms des participants
      final participantNames = _nameControllers.map((c) => c.text.trim()).toList();
      
      // Naviguer vers l'écran d'enregistrement avec les noms des participants
      context.go(
        '/meeting-recording/${widget.meetingId}?title=${Uri.encodeComponent(widget.meetingTitle)}&participants=${Uri.encodeComponent(participantNames.join(','))}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Définir les participants'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations de la réunion
                _buildMeetingInfo(),
                const SizedBox(height: 24),
                
                // Liste des participants
                ...List.generate(widget.participantCount, (index) {
                  return _buildParticipantField(index);
                }),
                
                const SizedBox(height: 32),
                
                // Bouton d'action
                _buildActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.people, color: Colors.blue[700], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.meetingTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.participantCount} participant(s)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantField(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _nameControllers[index],
        focusNode: _focusNodes[index],
        decoration: InputDecoration(
          labelText: 'Participant ${index + 1} *',
          hintText: 'Entrez le nom',
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.primaries[index % Colors.primaries.length].withOpacity(0.2),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.primaries[index % Colors.primaries.length],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        textCapitalization: TextCapitalization.words,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Veuillez entrer un nom';
          }
          return null;
        },
        onFieldSubmitted: (value) {
          if (index < widget.participantCount - 1) {
            _focusNodes[index + 1].requestFocus();
          }
        },
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _startRecording,
        icon: const Icon(Icons.rocket_launch, size: 18),
        label: const Text('Démarrer l\'enregistrement'),
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
    );
  }
}
