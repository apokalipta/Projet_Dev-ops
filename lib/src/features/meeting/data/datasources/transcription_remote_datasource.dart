import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/api/transcription_dio_client.dart';
import '../../../../core/api/api_config.dart';

part 'transcription_remote_datasource.g.dart';

/// Remote datasource pour le service de transcription
@riverpod
TranscriptionRemoteDataSource transcriptionRemoteDataSource(
  TranscriptionRemoteDataSourceRef ref,
) {
  return TranscriptionRemoteDataSource(ref.watch(transcriptionDioProvider));
}

class TranscriptionRemoteDataSource {
  final Dio _dio;

  TranscriptionRemoteDataSource(this._dio);

  // ========================================
  // TRANSCRIPTION
  // ========================================

  /// Créer une transcription pour une réunion
  /// POST /start_transcription/{id_reunion}
  Future<Response> startTranscription(String meetingId, {
    int? idFat,
    String? recordFileName,
  }) async {
    final endpoint = ApiConfig.replaceParams(
      ApiConfig.startTranscriptionEndpoint,
      {'id': meetingId},
    );

    return await _dio.post(
      endpoint,
      data: {
        if (idFat != null) 'idFat': idFat,
        if (recordFileName != null) 'recordFileName': recordFileName,
      },
    );
  }

  /// Envoyer un segment audio pour transcription
  /// POST /transcription/{id_reunion}/send_segment
  Future<Response> sendAudioSegment(String meetingId, String filePath) async {
    final endpoint = ApiConfig.replaceParams(
      ApiConfig.sendSegmentEndpoint,
      {'id': meetingId},
    );

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    return await _dio.post(
      endpoint,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }

  /// Sauvegarder des segments en base de données (utilisé par l'IA)
  /// POST /transcription/{id_reunion}/segment_to_bdd
  Future<Response> saveSegmentsToBdd(
    String meetingId,
    dynamic segments, // Peut être un Map ou une List<Map>
  ) async {
    final endpoint = ApiConfig.replaceParams(
      ApiConfig.saveSegmentToBddEndpoint,
      {'id': meetingId},
    );

    return await _dio.post(endpoint, data: segments);
  }

  /// Sauvegarder le fichier audio complet
  /// POST /transcription/{id_reunion}/save_record_file
  Future<Response> saveRecordFile(String meetingId, String filePath) async {
    final endpoint = ApiConfig.replaceParams(
      ApiConfig.saveRecordFileEndpoint,
      {'id': meetingId},
    );

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    return await _dio.post(
      endpoint,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }

  /// Obtenir le nom du fichier audio
  /// GET /transcription/{id_reunion}/obtain_record_file
  Future<Response> getRecordFileName(String meetingId) async {
    final endpoint = ApiConfig.replaceParams(
      ApiConfig.obtainRecordFileEndpoint,
      {'id': meetingId},
    );

    return await _dio.get(endpoint);
  }

  // ========================================
  // SEGMENTS
  // ========================================

  /// Récupérer tous les segments d'une réunion
  /// GET /transcription/{id_reunion}/segment/all
  Future<Response> getAllSegments(String meetingId) async {
    final endpoint = ApiConfig.replaceParams(
      ApiConfig.allSegmentsEndpoint,
      {'id': meetingId},
    );

    return await _dio.get(endpoint);
  }

  /// Récupérer un segment spécifique
  /// GET /transcription/{id_reunion}/segment/{id_segment}
  Future<Response> getSegmentById(String meetingId, String segmentId) async {
    final endpoint = ApiConfig.replaceParams(
      ApiConfig.segmentByIdEndpoint,
      {'id': meetingId, 'segmentId': segmentId},
    );

    return await _dio.get(endpoint);
  }

  /// Modifier le texte d'un segment
  /// PUT /transcription/{id_reunion}/segment/{id_segment}
  Future<Response> updateSegmentText(
    String meetingId,
    String segmentId,
    String newText,
  ) async {
    final endpoint = ApiConfig.replaceParams(
      ApiConfig.segmentByIdEndpoint,
      {'id': meetingId, 'segmentId': segmentId},
    );

    return await _dio.put(
      endpoint,
      data: {'texte': newText},
    );
  }

  /// Récupérer le timestamp de début d'un segment
  /// GET /transcription/{id_reunion}/segment/{id_segment}/time_depart
  Future<Response> getSegmentStartTime(
    String meetingId,
    String segmentId,
  ) async {
    final endpoint = ApiConfig.replaceParams(
      ApiConfig.segmentTimeDepartEndpoint,
      {'id': meetingId, 'segmentId': segmentId},
    );

    return await _dio.get(endpoint);
  }

  /// Récupérer le timestamp de fin d'un segment
  /// GET /transcription/{id_reunion}/segment/{id_segment}/time_fin
  Future<Response> getSegmentEndTime(
    String meetingId,
    String segmentId,
  ) async {
    final endpoint = ApiConfig.replaceParams(
      ApiConfig.segmentTimeFinEndpoint,
      {'id': meetingId, 'segmentId': segmentId},
    );

    return await _dio.get(endpoint);
  }

  // ========================================
  // LOCUTEURS
  // ========================================

  /// Récupérer le locuteur d'un segment
  /// GET /transcription/{id_reunion}/segment/{id_segment}/locuteur/all
  Future<Response> getSegmentSpeaker(
    String meetingId,
    String segmentId,
  ) async {
    final endpoint = ApiConfig.replaceParams(
      ApiConfig.segmentLocuteurEndpoint,
      {'id': meetingId, 'segmentId': segmentId},
    );

    return await _dio.get(endpoint);
  }

  /// Modifier le locuteur d'un segment
  /// PUT /transcription/{id_reunion}/segment/{id_segment}/locuteur/{id_participant}
  Future<Response> updateSegmentSpeaker(
    String meetingId,
    String segmentId,
    String participantId,
  ) async {
    final endpoint = ApiConfig.replaceParams(
      ApiConfig.updateSegmentLocuteurEndpoint,
      {
        'id': meetingId,
        'segmentId': segmentId,
        'participantId': participantId,
      },
    );

    return await _dio.put(endpoint);
  }
}
