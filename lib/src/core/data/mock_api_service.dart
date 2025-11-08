import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'mock_data.dart';

part 'mock_api_service.g.dart';

/// Service API mocké pour le développement
/// 
/// Ce service simule les appels API avec des données mockées et des délais réseau.
/// Utilisez ce service pendant le développement pour tester l'UI sans backend.

@riverpod
MockApiService mockApiService(MockApiServiceRef ref) {
  return MockApiService();
}

class MockApiService {
  // Délai pour simuler la latence réseau (en millisecondes)
  final int networkDelay;

  MockApiService({this.networkDelay = 500});

  /// Simule un délai réseau
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: networkDelay));
  }

  /// Simule une réponse Dio
  Response<T> _createResponse<T>(T data, {int statusCode = 200}) {
    return Response<T>(
      data: data,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: ''),
    );
  }

  // ============================================================================
  // MEETING ENDPOINTS
  // ============================================================================

  /// POST /api/meeting - Créer une nouvelle réunion
  Future<Response> createMeeting(Map<String, dynamic> meetingData) async {
    await _simulateNetworkDelay();

    final newMeeting = {
      'id': 'meeting-${DateTime.now().millisecondsSinceEpoch}',
      ...meetingData,
      'status': 'scheduled',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    MockData.meetings.add(newMeeting);
    return _createResponse(newMeeting, statusCode: 201);
  }

  /// GET /api/meeting/all - Lister toutes les réunions
  Future<Response> getAllMeetings() async {
    await _simulateNetworkDelay();
    return _createResponse(MockData.meetings);
  }

  /// GET /api/meeting/:id - Obtenir une réunion spécifique
  Future<Response> getMeetingById(String meetingId) async {
    await _simulateNetworkDelay();

    final meeting = MockData.getMeetingById(meetingId);
    if (meeting == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/meeting/$meetingId'),
        response: Response(
          requestOptions: RequestOptions(path: '/meeting/$meetingId'),
          statusCode: 404,
          data: {'error': 'Meeting not found'},
        ),
      );
    }

    return _createResponse(meeting);
  }

  /// GET /api/meeting/:id/participant/all - Lister les participants
  Future<Response> getMeetingParticipants(String meetingId) async {
    await _simulateNetworkDelay();

    final participants = MockData.getMeetingParticipantsList(meetingId);
    return _createResponse(participants);
  }

  /// POST /api/meeting/:id/participant/ - Ajouter un participant
  Future<Response> addParticipant(
    String meetingId,
    Map<String, dynamic> participantData,
  ) async {
    await _simulateNetworkDelay();

    final participantId = participantData['participantId'] as String;
    final existingParticipants = MockData.meetingParticipants[meetingId] ?? [];

    // Vérifier si le participant n'est pas déjà ajouté
    if (existingParticipants.any((p) => p['participantId'] == participantId)) {
      throw DioException(
        requestOptions: RequestOptions(path: '/meeting/$meetingId/participant'),
        response: Response(
          requestOptions: RequestOptions(path: '/meeting/$meetingId/participant'),
          statusCode: 400,
          data: {'error': 'Participant already added'},
        ),
      );
    }

    final newParticipant = {
      'participantId': participantId,
      'speakTime': 0,
      'interventions': 0,
    };

    existingParticipants.add(newParticipant);
    MockData.meetingParticipants[meetingId] = existingParticipants;

    return _createResponse(newParticipant, statusCode: 201);
  }

  /// DELETE /api/meeting/:id/participant/:participantId - Retirer un participant
  Future<Response> removeParticipant(
    String meetingId,
    String participantId,
  ) async {
    await _simulateNetworkDelay();

    final participants = MockData.meetingParticipants[meetingId] ?? [];
    participants.removeWhere((p) => p['participantId'] == participantId);
    MockData.meetingParticipants[meetingId] = participants;

    return _createResponse(null, statusCode: 204);
  }

  /// GET /api/meeting/search/byTitle - Rechercher par titre
  Future<Response> searchMeetingByTitle(String title) async {
    await _simulateNetworkDelay();

    final results = MockData.searchMeetings(title);
    return _createResponse(results);
  }

  // ============================================================================
  // TRANSCRIPTION ENDPOINTS
  // ============================================================================

  /// POST /api/transcribe - Transcrire un audio
  Future<Response> transcribeAudio(FormData audioData) async {
    // Simuler un délai plus long pour la transcription
    await Future.delayed(Duration(seconds: 2));

    final transcription = {
      'id': 'transcription-${DateTime.now().millisecondsSinceEpoch}',
      'meetingId': audioData.fields
          .firstWhere((f) => f.key == 'meetingId', orElse: () => MapEntry('', ''))
          .value,
      'status': 'completed',
      'segments': [],
      'createdAt': DateTime.now().toIso8601String(),
    };

    return _createResponse(transcription, statusCode: 201);
  }

  /// GET /api/transcription/:id/segment/all - Lister les segments
  Future<Response> getAllSegments(String meetingId) async {
    await _simulateNetworkDelay();

    final segments = MockData.getSegments(meetingId);
    return _createResponse(segments);
  }

  /// GET /api/transcription/:id/segment/:segmentId - Obtenir un segment
  Future<Response> getSegmentById(String meetingId, String segmentId) async {
    await _simulateNetworkDelay();

    final segments = MockData.getSegments(meetingId);
    final segment = segments.firstWhere(
      (s) => s['id'] == segmentId,
      orElse: () => throw DioException(
        requestOptions: RequestOptions(path: '/transcription/$meetingId/segment/$segmentId'),
        response: Response(
          requestOptions: RequestOptions(path: '/transcription/$meetingId/segment/$segmentId'),
          statusCode: 404,
          data: {'error': 'Segment not found'},
        ),
      ),
    );

    return _createResponse(segment);
  }

  /// PUT /api/transcription/:id/segment/:segmentId - Modifier un segment
  Future<Response> updateSegmentText(
    String meetingId,
    String segmentId,
    Map<String, dynamic> textData,
  ) async {
    await _simulateNetworkDelay();

    final segments = MockData.transcriptionSegments[meetingId] ?? [];
    final segmentIndex = segments.indexWhere((s) => s['id'] == segmentId);

    if (segmentIndex == -1) {
      throw DioException(
        requestOptions: RequestOptions(path: '/transcription/$meetingId/segment/$segmentId'),
        response: Response(
          requestOptions: RequestOptions(path: '/transcription/$meetingId/segment/$segmentId'),
          statusCode: 404,
          data: {'error': 'Segment not found'},
        ),
      );
    }

    segments[segmentIndex]['text'] = textData['text'];
    segments[segmentIndex]['updatedAt'] = DateTime.now().toIso8601String();

    return _createResponse(segments[segmentIndex], statusCode: 202);
  }

  /// GET /api/transcription/:id/segment/:segmentId/locuteur/all - Lister les locuteurs
  Future<Response> getSegmentSpeakers(String meetingId, String segmentId) async {
    await _simulateNetworkDelay();

    final segment = (MockData.getSegments(meetingId))
        .firstWhere((s) => s['id'] == segmentId, orElse: () => {});

    if (segment.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/transcription/$meetingId/segment/$segmentId/locuteur/all'),
        response: Response(
          requestOptions: RequestOptions(path: '/transcription/$meetingId/segment/$segmentId/locuteur/all'),
          statusCode: 404,
          data: {'error': 'Segment not found'},
        ),
      );
    }

    final speakerId = segment['speakerId'];
    final speaker = MockData.getParticipantById(speakerId);

    return _createResponse([speaker]);
  }

  /// PUT /api/transcription/:id/segment/:segmentId/locuteur/:participantId - Modifier le locuteur
  Future<Response> updateSegmentSpeaker(
    String meetingId,
    String segmentId,
    String participantId,
  ) async {
    await _simulateNetworkDelay();

    final segments = MockData.transcriptionSegments[meetingId] ?? [];
    final segmentIndex = segments.indexWhere((s) => s['id'] == segmentId);

    if (segmentIndex == -1) {
      throw DioException(
        requestOptions: RequestOptions(path: '/transcription/$meetingId/segment/$segmentId/locuteur/$participantId'),
        response: Response(
          requestOptions: RequestOptions(path: '/transcription/$meetingId/segment/$segmentId/locuteur/$participantId'),
          statusCode: 404,
          data: {'error': 'Segment not found'},
        ),
      );
    }

    segments[segmentIndex]['speakerId'] = participantId;
    segments[segmentIndex]['updatedAt'] = DateTime.now().toIso8601String();

    return _createResponse(segments[segmentIndex], statusCode: 202);
  }

  /// GET /api/transcription/:id/record_file - Récupérer l'audio
  Future<Response> getRecordFile(String meetingId) async {
    await _simulateNetworkDelay();

    // Simuler des données audio (bytes vides pour le mock)
    final audioBytes = List<int>.filled(1024, 0);
    return _createResponse(audioBytes);
  }

  /// GET /api/transcription/:id/segment/:segmentId/time_depart - Heure de début
  Future<Response> getSegmentStartTime(String meetingId, String segmentId) async {
    await _simulateNetworkDelay();

    final segments = MockData.getSegments(meetingId);
    final segment = segments.firstWhere(
      (s) => s['id'] == segmentId,
      orElse: () => throw DioException(
        requestOptions: RequestOptions(path: '/transcription/$meetingId/segment/$segmentId/time_depart'),
        response: Response(
          requestOptions: RequestOptions(path: '/transcription/$meetingId/segment/$segmentId/time_depart'),
          statusCode: 404,
          data: {'error': 'Segment not found'},
        ),
      ),
    );

    return _createResponse({'startTime': segment['startTime']});
  }

  /// GET /api/transcription/:id/segment/:segmentId/time_fin - Heure de fin
  Future<Response> getSegmentEndTime(String meetingId, String segmentId) async {
    await _simulateNetworkDelay();

    final segments = MockData.getSegments(meetingId);
    final segment = segments.firstWhere(
      (s) => s['id'] == segmentId,
      orElse: () => throw DioException(
        requestOptions: RequestOptions(path: '/transcription/$meetingId/segment/$segmentId/time_fin'),
        response: Response(
          requestOptions: RequestOptions(path: '/transcription/$meetingId/segment/$segmentId/time_fin'),
          statusCode: 404,
          data: {'error': 'Segment not found'},
        ),
      ),
    );

    return _createResponse({'endTime': segment['endTime']});
  }

  // ============================================================================
  // HELPERS & STATS
  // ============================================================================

  /// Obtenir la synthèse d'une réunion
  Future<Response> getMeetingSynthesis(String meetingId) async {
    await _simulateNetworkDelay();

    final synthesis = MockData.getMeetingSynthesis(meetingId);
    if (synthesis.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '/meeting/$meetingId/synthesis'),
        response: Response(
          requestOptions: RequestOptions(path: '/meeting/$meetingId/synthesis'),
          statusCode: 404,
          data: {'error': 'Meeting not found'},
        ),
      );
    }

    return _createResponse(synthesis);
  }

  /// Obtenir les statistiques globales
  Future<Response> getGlobalStats() async {
    await _simulateNetworkDelay();

    final stats = MockData.getGlobalStats();
    return _createResponse(stats);
  }
}
