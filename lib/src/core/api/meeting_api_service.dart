import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dio_client.dart';

part 'meeting_api_service.g.dart';

/// Service API pour la gestion des réunions
/// Basé sur la spécification API_SPECIFICATION.md - Sous-projet N°1
@riverpod
MeetingApiService meetingApiService(MeetingApiServiceRef ref) {
  return MeetingApiService(ref.watch(dioProvider));
}

class MeetingApiService {
  final Dio _dio;

  MeetingApiService(this._dio);

  // POST /api/meeting
  // Créer une nouvelle réunion
  // Réponse: 201 + Meeting
  Future<Response> createMeeting(Map<String, dynamic> meetingData) async {
    return await _dio.post('/meeting', data: meetingData);
  }

  // GET /api/meeting/all
  // Lister toutes les réunions
  // Réponse: 200 + List
  Future<Response> getAllMeetings() async {
    return await _dio.get('/meeting/all');
  }

  // GET /api/meeting/:Id_meeting
  // Obtenir les détails d'une réunion spécifique
  // Réponse: 200 + Meeting
  Future<Response> getMeetingById(String meetingId) async {
    return await _dio.get('/meeting/$meetingId');
  }

  // GET /api/meeting/:Id_meeting/participant/all
  // Lister les participants d'une réunion
  // Réponse: 200 + Meeting
  Future<Response> getMeetingParticipants(String meetingId) async {
    return await _dio.get('/meeting/$meetingId/participant/all');
  }

  // DELETE /api/meeting/:Id_meeting/participant/:Id_participant
  // Retirer un participant d'une réunion
  // Réponse: 204 + No Content
  Future<Response> removeParticipant(
    String meetingId,
    String participantId,
  ) async {
    return await _dio.delete('/meeting/$meetingId/participant/$participantId');
  }

  // POST /api/meeting/:Id_meeting/participant/
  // Ajouter un participant à une réunion
  // Réponse: 201 + Participants
  Future<Response> addParticipant(
    String meetingId,
    Map<String, dynamic> participantData,
  ) async {
    return await _dio.post(
      '/meeting/$meetingId/participant/',
      data: participantData,
    );
  }

  // GET /api/meeting/search/byTitle
  // Recherche par titre
  // Réponse: 200 + Meeting
  Future<Response> searchMeetingByTitle(String title) async {
    return await _dio.get(
      '/meeting/search/byTitle',
      queryParameters: {'title': title},
    );
  }
}
