import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_app/src/core/api/dio_client.dart';
import 'package:meeting_app/src/features/meeting/data/models/meeting_model.dart';

part 'meeting_remote_datasource.g.dart';

/// Classe responsable des appels API bruts pour les réunions
/// Basée sur la documentation du Meeting-service backend
class MeetingRemoteDataSource {
  final Dio dioClient;

  MeetingRemoteDataSource(this.dioClient);

  // ==================== MEETINGS ====================
  
  /// GET /api/meeting/all - Lister toutes les réunions
  Future<List<MeetingModel>> fetchMeetings() async {
    try {
      final response = await dioClient.get('/meeting/all');
      final List<dynamic> data = response.data as List;
      return data.map((json) => MeetingModel.fromJson(json)).toList();
    } on DioException {
      rethrow;
    }
  }

  /// GET /api/meeting/{id} - Détail d'une réunion
  Future<MeetingModel> getMeetingById(int id) async {
    try {
      final response = await dioClient.get('/meeting/$id');
      return MeetingModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// POST /api/meeting - Créer une réunion
  /// Body: {title, description, scheduledAt, durationMinutes, status, participants[]}
  Future<MeetingModel> createMeeting(Map<String, dynamic> meetingData) async {
    try {
      final response = await dioClient.post('/meeting', data: meetingData);
      return MeetingModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// GET /api/meeting/search/byTitle - Rechercher par titre
  /// Query param: title
  Future<List<MeetingModel>> searchMeetingsByTitle(String title) async {
    try {
      final response = await dioClient.get(
        '/meeting/search/byTitle',
        queryParameters: {'title': title},
      );
      final List<dynamic> data = response.data as List;
      return data.map((json) => MeetingModel.fromJson(json)).toList();
    } on DioException {
      rethrow;
    }
  }

  /// PUT /api/meeting/{id}/start - Démarrer la réunion
  /// Transition: scheduled -> in_progress
  Future<MeetingModel> startMeeting(int id) async {
    try {
      final response = await dioClient.put('/meeting/$id/start');
      return MeetingModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// PUT /api/meeting/{id}/end - Clore la réunion
  /// Transition: in_progress -> completed
  Future<MeetingModel> endMeeting(int id) async {
    try {
      final response = await dioClient.put('/meeting/$id/end');
      return MeetingModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  // ==================== PARTICIPANTS ====================

  /// GET /api/meeting/{id}/participant/all - Lister les participants d'une réunion
  Future<List<Map<String, dynamic>>> getMeetingParticipants(int id) async {
    try {
      final response = await dioClient.get('/meeting/$id/participant/all');
      return List<Map<String, dynamic>>.from(response.data as List);
    } on DioException {
      rethrow;
    }
  }

  /// GET /api/participant/all - Lister tous les participants enregistrés
  Future<List<Map<String, dynamic>>> getAllParticipants() async {
    try {
      final response = await dioClient.get('/participant/all');
      return List<Map<String, dynamic>>.from(response.data as List);
    } on DioException {
      rethrow;
    }
  }

  /// POST /api/meeting/{id}/participant - Ajouter un participant
  /// Body: {firstname, lastname, email} ou {id} pour un participant existant
  /// Refuse si la réunion est completed (HTTP 409)
  Future<Map<String, dynamic>> addParticipant(
    int meetingId,
    Map<String, dynamic> participantData,
  ) async {
    try {
      final response = await dioClient.post(
        '/meeting/$meetingId/participant',
        data: participantData,
      );
      return response.data as Map<String, dynamic>;
    } on DioException {
      rethrow;
    }
  }

  /// DELETE /api/meeting/{id}/participant/{participantId} - Retirer un participant
  /// Refuse si la réunion est completed (HTTP 409)
  Future<void> removeParticipant(int meetingId, int participantId) async {
    try {
      await dioClient.delete('/meeting/$meetingId/participant/$participantId');
    } on DioException {
      rethrow;
    }
  }
}

// Provider Riverpod pour injecter la source de données
@riverpod
MeetingRemoteDataSource meetingRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return MeetingRemoteDataSource(dio);
}
