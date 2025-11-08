// ignore_for_file: unused_local_variable, avoid_print

/// EXEMPLES D'UTILISATION DES DONNÉES MOCKÉES
/// 
/// Ce fichier contient des exemples pratiques d'utilisation du système de mock.
/// Copiez et adaptez ces exemples dans votre code.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_data.dart';
import 'api_service_provider.dart';

// ============================================================================
// EXEMPLE 1 : Liste simple de réunions
// ============================================================================

class SimpleMeetingListExample extends StatelessWidget {
  const SimpleMeetingListExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Accès direct aux données mockées
    final meetings = MockData.meetings;

    return ListView.builder(
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(meeting['title'] as String),
            subtitle: Text(
              '${meeting['date']} - ${(meeting['duration'] as int) ~/ 60} min',
            ),
            trailing: _buildStatusChip(meeting['status'] as String),
            onTap: () {
              // Navigation vers les détails
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    return Chip(
      label: Text(
        status == 'completed' ? 'Terminée' : 'Planifiée',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: status == 'completed' ? Colors.green : Colors.orange,
    );
  }
}

// ============================================================================
// EXEMPLE 2 : Utilisation avec Riverpod et API Service
// ============================================================================

class MeetingListWithProviderExample extends ConsumerWidget {
  const MeetingListWithProviderExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Le provider retourne automatiquement Mock ou Real selon AppConfig
    final meetingService = ref.watch(meetingServiceProvider);

    return FutureBuilder(
      future: meetingService.getAllMeetings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erreur: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Réessayer
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Aucune donnée'));
        }

        final response = snapshot.data!;
        final meetings = response.data as List;

        return RefreshIndicator(
          onRefresh: () async {
            // Rafraîchir les données
          },
          child: ListView.builder(
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final meeting = meetings[index];
              return _buildMeetingCard(meeting);
            },
          ),
        );
      },
    );
  }

  Widget _buildMeetingCard(Map<String, dynamic> meeting) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigation
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting['title'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(meeting['status'] as String),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                meeting['description'] as String? ?? '',
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(meeting['date'] as String),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${(meeting['duration'] as int) ~/ 60} min',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'completed' ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status == 'completed' ? 'Terminée' : 'Planifiée',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// EXEMPLE 3 : Détails d'une réunion avec participants
// ============================================================================

class MeetingDetailsExample extends StatelessWidget {
  final String meetingId;

  const MeetingDetailsExample({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    final meeting = MockData.getMeetingById(meetingId);
    final synthesis = MockData.getMeetingSynthesis(meetingId);

    if (meeting == null) {
      return const Center(child: Text('Réunion non trouvée'));
    }

    final participants = synthesis['participants'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Text(
            meeting['title'] as String,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            meeting['description'] as String? ?? '',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Statistiques
          _buildStatsCard(synthesis),
          const SizedBox(height: 24),

          // Participants
          const Text(
            'Participants',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...participants.map((p) => _buildParticipantCard(p)).toList(),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> synthesis) {
    final totalDuration = synthesis['totalDuration'] as int;
    final totalSpeakTime = synthesis['totalSpeakTime'] as int;
    final silenceTime = synthesis['silenceTime'] as int;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow(
              'Durée totale',
              '${totalDuration ~/ 60} min',
              Icons.access_time,
            ),
            const Divider(),
            _buildStatRow(
              'Temps de parole',
              '${totalSpeakTime ~/ 60} min',
              Icons.record_voice_over,
            ),
            const Divider(),
            _buildStatRow(
              'Temps de silence',
              '${silenceTime ~/ 60} min',
              Icons.volume_off,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildParticipantCard(Map<String, dynamic> participant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(participant['avatar'] as String),
        ),
        title: Text(participant['name'] as String),
        subtitle: Text(participant['role'] as String),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(participant['speakTime'] as int) ~/ 60} min',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${participant['speakPercentage']}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXEMPLE 4 : Transcription avec segments
// ============================================================================

class TranscriptionExample extends StatelessWidget {
  final String meetingId;

  const TranscriptionExample({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    final segments = MockData.getSegments(meetingId);

    if (segments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucune transcription disponible'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: segments.length,
      itemBuilder: (context, index) {
        final segment = segments[index];
        final speaker = MockData.getParticipantById(segment['speakerId'] as String);

        return _buildSegmentCard(segment, speaker);
      },
    );
  }

  Widget _buildSegmentCard(
    Map<String, dynamic> segment,
    Map<String, dynamic>? speaker,
  ) {
    final confidence = segment['confidence'] as double;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec locuteur
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(speaker?['avatar'] ?? ''),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        speaker?['name'] ?? 'Inconnu',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        speaker?['role'] ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(segment['startTime'] as double).toStringAsFixed(1)}s',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Texte transcrit
            Text(
              segment['text'] as String,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 12),

            // Indicateur de confiance
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: confidence,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      confidence > 0.9
                          ? Colors.green
                          : confidence > 0.8
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXEMPLE 5 : Recherche de réunions
// ============================================================================

class SearchMeetingsExample extends StatefulWidget {
  const SearchMeetingsExample({super.key});

  @override
  State<SearchMeetingsExample> createState() => _SearchMeetingsExampleState();
}

class _SearchMeetingsExampleState extends State<SearchMeetingsExample> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _results = MockData.meetings; // Afficher toutes les réunions au départ
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
    });

    // Simuler un délai de recherche
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _results = MockData.searchMeetings(query);
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _performSearch,
            decoration: InputDecoration(
              hintText: 'Rechercher une réunion...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          )
        else
          Expanded(
            child: _results.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Aucun résultat trouvé'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final meeting = _results[index];
                      return ListTile(
                        title: Text(meeting['title'] as String),
                        subtitle: Text(meeting['description'] as String? ?? ''),
                        trailing: Text(
                          '${(meeting['duration'] as int) ~/ 60} min',
                        ),
                        onTap: () {
                          // Navigation vers les détails
                        },
                      );
                    },
                  ),
          ),
      ],
    );
  }
}

// ============================================================================
// EXEMPLE 6 : Créer une nouvelle réunion
// ============================================================================

class CreateMeetingExample extends ConsumerStatefulWidget {
  const CreateMeetingExample({super.key});

  @override
  ConsumerState<CreateMeetingExample> createState() =>
      _CreateMeetingExampleState();
}

class _CreateMeetingExampleState extends ConsumerState<CreateMeetingExample> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final meetingService = ref.read(meetingServiceProvider);
      final newMeeting = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': DateTime.now().toIso8601String(),
        'duration': 3600,
        'language': 'FR',
        'location': 'Salle A',
      };

      final response = await meetingService.createMeeting(newMeeting);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réunion créée avec succès')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un titre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createMeeting,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Créer la réunion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
