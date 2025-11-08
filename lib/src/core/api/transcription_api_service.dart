import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dio_client.dart';

part 'transcription_api_service.g.dart';

/// Service API pour la gestion des transcriptions
/// Basé sur la spécification API_SPECIFICATION.md - Sous-projet N°2
@riverpod
TranscriptionApiService transcriptionApiService(
  TranscriptionApiServiceRef ref,
) {
  return TranscriptionApiService(ref.watch(dioProvider));
}

class TranscriptionApiService {
  final Dio _dio;

  TranscriptionApiService(this._dio);

  // POST /api/transcribe
  // Envoyer l'audio à l'IA pour la transcription
  // Réponse: 201 + Transcribe
  Future<Response> transcribeAudio(FormData audioData) async {
    return await _dio.post('/transcribe', data: audioData);
  }

  // GET /api/transcription/:Id_reunion/segment/all
  // Lister les segments de la transcription pour reconstruire la synthèse
  // Réponse: 200 + All segments
  Future<Response> getAllSegments(String reunionId) async {
    return await _dio.get('/transcription/$reunionId/segment/all');
  }

  // GET /api/transcription/:Id_reunion/segment/:Id_segment
  // Obtenir un segment spécifique
  // Réponse: 200 + Segment
  Future<Response> getSegmentById(String reunionId, String segmentId) async {
    return await _dio.get('/transcription/$reunionId/segment/$segmentId');
  }

  // PUT /api/transcription/:Id_reunion/segment/:Id_segment
  // Modifier le texte d'un segment spécifique
  // Réponse: 202 + Modif texte
  Future<Response> updateSegmentText(
    String reunionId,
    String segmentId,
    Map<String, dynamic> textData,
  ) async {
    return await _dio.put(
      '/transcription/$reunionId/segment/$segmentId',
      data: textData,
    );
  }

  // GET /api/transcription/:Id_reunion/segment/:Id_segment/locuteur/all
  // Lister les locuteurs d'un segment
  // Réponse: 200 + Locuteurs
  Future<Response> getSegmentSpeakers(
    String reunionId,
    String segmentId,
  ) async {
    return await _dio.get(
      '/transcription/$reunionId/segment/$segmentId/locuteur/all',
    );
  }

  // PUT /api/transcription/:Id_reunion/segment/:Id_segment/locuteur/:Id_participant
  // Modifier le locuteur d'un segment défini par défaut par l'IA
  // Réponse: 202 + Modif locuteur
  Future<Response> updateSegmentSpeaker(
    String reunionId,
    String segmentId,
    String participantId,
  ) async {
    return await _dio.put(
      '/transcription/$reunionId/segment/$segmentId/locuteur/$participantId',
    );
  }

  // GET /api/transcription/:Id_reunion/record_file
  // Récupérer pour écouter l'audio de la réunion
  // Réponse: 200 + Record file
  Future<Response> getRecordFile(String reunionId) async {
    return await _dio.get(
      '/transcription/$reunionId/record_file',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  // GET /api/transcription/:Id_reunion/segment/:Id_segment/time_depart
  // Obtenir date démarrage d'enregistrement du segment pour trouver l'audio correspondant
  // Réponse: 200 + Temps départ segment
  Future<Response> getSegmentStartTime(
    String reunionId,
    String segmentId,
  ) async {
    return await _dio.get(
      '/transcription/$reunionId/segment/$segmentId/time_depart',
    );
  }

  // GET /api/transcription/:Id_reunion/segment/:Id_segment/time_fin
  // Obtenir date de fin d'enregistrement du segment pour trouver l'audio correspondant
  // Réponse: 200 + Temps fin segment
  Future<Response> getSegmentEndTime(
    String reunionId,
    String segmentId,
  ) async {
    return await _dio.get(
      '/transcription/$reunionId/segment/$segmentId/time_fin',
    );
  }
}
