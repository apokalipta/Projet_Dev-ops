// ignore_for_file: unused_local_variable, dead_code

/// FICHIER D'EXEMPLE - NE PAS UTILISER EN PRODUCTION
/// 
/// Ce fichier montre des exemples d'utilisation des services API.
/// Copiez et adaptez ces exemples dans vos propres fichiers.

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_services.dart';

// ============================================================================
// EXEMPLE 1 : Utilisation directe du service Meeting
// ============================================================================

void exampleDirectUsage(WidgetRef ref) async {
  final meetingService = ref.read(meetingApiServiceProvider);

  try {
    // Créer une réunion
    final createResponse = await meetingService.createMeeting({
      'title': 'Réunion d\'équipe',
      'date': DateTime.now().toIso8601String(),
      'description': 'Discussion sur le projet',
    });
    print('Réunion créée: ${createResponse.data}');

    // Lister toutes les réunions
    final listResponse = await meetingService.getAllMeetings();
    print('Nombre de réunions: ${listResponse.data.length}');

    // Obtenir une réunion spécifique
    final meetingId = 'meeting-123';
    final getResponse = await meetingService.getMeetingById(meetingId);
    print('Réunion: ${getResponse.data}');

    // Ajouter un participant
    await meetingService.addParticipant(meetingId, {
      'name': 'John Doe',
      'email': 'john@example.com',
    });

    // Rechercher par titre
    final searchResponse = await meetingService.searchMeetingByTitle('équipe');
    print('Résultats: ${searchResponse.data}');
  } on DioException catch (e) {
    print('Erreur API: ${e.message}');
    if (e.response != null) {
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
    }
  }
}

// ============================================================================
// EXEMPLE 2 : Utilisation du service Transcription
// ============================================================================

void exampleTranscriptionUsage(WidgetRef ref) async {
  final transcriptionService = ref.read(transcriptionApiServiceProvider);

  try {
    // Transcrire un audio
    final audioPath = '/path/to/audio.mp3';
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        audioPath,
        filename: 'recording.mp3',
      ),
      'meetingId': 'meeting-123',
    });
    final transcribeResponse = await transcriptionService.transcribeAudio(formData);
    print('Transcription: ${transcribeResponse.data}');

    // Obtenir tous les segments
    final meetingId = 'meeting-123';
    final segmentsResponse = await transcriptionService.getAllSegments(meetingId);
    print('Segments: ${segmentsResponse.data}');

    // Modifier un segment
    final segmentId = 'segment-456';
    await transcriptionService.updateSegmentText(
      meetingId,
      segmentId,
      {'text': 'Nouveau texte corrigé'},
    );

    // Modifier le locuteur
    final participantId = 'participant-789';
    await transcriptionService.updateSegmentSpeaker(
      meetingId,
      segmentId,
      participantId,
    );

    // Récupérer le fichier audio
    final audioResponse = await transcriptionService.getRecordFile(meetingId);
    // audioResponse.data contient les bytes du fichier audio
  } on DioException catch (e) {
    print('Erreur API: ${e.message}');
  }
}

// ============================================================================
// EXEMPLE 3 : Widget avec gestion d'état
// ============================================================================

class ExampleMeetingsListWidget extends ConsumerStatefulWidget {
  const ExampleMeetingsListWidget({super.key});

  @override
  ConsumerState<ExampleMeetingsListWidget> createState() =>
      _ExampleMeetingsListWidgetState();
}

class _ExampleMeetingsListWidgetState
    extends ConsumerState<ExampleMeetingsListWidget> {
  List<dynamic> meetings = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final meetingService = ref.read(meetingApiServiceProvider);
      final response = await meetingService.getAllMeetings();
      setState(() {
        meetings = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _createMeeting() async {
    try {
      final meetingService = ref.read(meetingApiServiceProvider);
      await meetingService.createMeeting({
        'title': 'Nouvelle réunion',
        'date': DateTime.now().toIso8601String(),
      });
      // Recharger la liste
      await _loadMeetings();
    } catch (e) {
      // Afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erreur: $error'),
            ElevatedButton(
              onPressed: _loadMeetings,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        return ListTile(
          title: Text(meeting['title'] ?? 'Sans titre'),
          subtitle: Text(meeting['description'] ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Supprimer la réunion
            },
          ),
        );
      },
    );
  }
}

// ============================================================================
// EXEMPLE 4 : Provider avec AsyncValue (Recommandé)
// ============================================================================

// Créer un provider pour les réunions
// @riverpod
// Future<List<Map<String, dynamic>>> meetings(MeetingsRef ref) async {
//   final meetingService = ref.watch(meetingApiServiceProvider);
//   final response = await meetingService.getAllMeetings();
//   return List<Map<String, dynamic>>.from(response.data);
// }

// Utiliser dans un widget
class ExampleMeetingsWithProviderWidget extends ConsumerWidget {
  const ExampleMeetingsWithProviderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Décommentez cette ligne quand vous aurez créé le provider
    // final meetingsAsync = ref.watch(meetingsProvider);

    // return meetingsAsync.when(
    //   data: (meetings) => ListView.builder(
    //     itemCount: meetings.length,
    //     itemBuilder: (context, index) {
    //       final meeting = meetings[index];
    //       return ListTile(
    //         title: Text(meeting['title'] ?? 'Sans titre'),
    //         subtitle: Text(meeting['description'] ?? ''),
    //       );
    //     },
    //   ),
    //   loading: () => const Center(child: CircularProgressIndicator()),
    //   error: (error, stack) => Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Text('Erreur: $error'),
    //         ElevatedButton(
    //           onPressed: () => ref.invalidate(meetingsProvider),
    //           child: const Text('Réessayer'),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    return const Placeholder();
  }
}

// ============================================================================
// EXEMPLE 5 : Gestion des erreurs personnalisée
// ============================================================================

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

Future<List<dynamic>> getMeetingsWithErrorHandling(WidgetRef ref) async {
  final meetingService = ref.read(meetingApiServiceProvider);

  try {
    final response = await meetingService.getAllMeetings();
    return response.data;
  } on DioException catch (e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          throw ApiException('Requête invalide', 400);
        case 401:
          throw ApiException('Non autorisé', 401);
        case 404:
          throw ApiException('Ressource non trouvée', 404);
        case 500:
          throw ApiException('Erreur serveur', 500);
        default:
          throw ApiException(
            'Erreur HTTP: ${e.response!.statusCode}',
            e.response!.statusCode,
          );
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      throw ApiException('Délai de connexion dépassé');
    } else if (e.type == DioExceptionType.receiveTimeout) {
      throw ApiException('Délai de réception dépassé');
    } else {
      throw ApiException('Erreur réseau: ${e.message}');
    }
  } catch (e) {
    throw ApiException('Erreur inconnue: $e');
  }
}

// ============================================================================
// EXEMPLE 6 : Upload de fichier audio avec progression
// ============================================================================

Future<void> uploadAudioWithProgress(
  WidgetRef ref,
  String audioPath,
  void Function(double progress) onProgress,
) async {
  final transcriptionService = ref.read(transcriptionApiServiceProvider);

  try {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        audioPath,
        filename: audioPath.split('/').last,
      ),
      'meetingId': 'meeting-123',
    });

    // Note: Pour suivre la progression, vous devrez modifier le service
    // pour accepter un callback onSendProgress
    final response = await transcriptionService.transcribeAudio(formData);
    print('Upload terminé: ${response.data}');
  } catch (e) {
    print('Erreur upload: $e');
  }
}

// ============================================================================
// EXEMPLE 7 : Recherche avec debounce
// ============================================================================

class ExampleSearchWidget extends ConsumerStatefulWidget {
  const ExampleSearchWidget({super.key});

  @override
  ConsumerState<ExampleSearchWidget> createState() =>
      _ExampleSearchWidgetState();
}

class _ExampleSearchWidgetState extends ConsumerState<ExampleSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Implémenter un debounce ici si nécessaire
    if (_searchController.text.isEmpty) {
      setState(() => searchResults = []);
      return;
    }
    _performSearch(_searchController.text);
  }

  Future<void> _performSearch(String query) async {
    setState(() => isSearching = true);

    try {
      final meetingService = ref.read(meetingApiServiceProvider);
      final response = await meetingService.searchMeetingByTitle(query);
      setState(() {
        searchResults = response.data;
        isSearching = false;
      });
    } catch (e) {
      setState(() => isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Rechercher une réunion...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        if (isSearching) const CircularProgressIndicator(),
        Expanded(
          child: ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final result = searchResults[index];
              return ListTile(
                title: Text(result['title'] ?? ''),
              );
            },
          ),
        ),
      ],
    );
  }
}
