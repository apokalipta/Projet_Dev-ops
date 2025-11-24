/// Configuration des endpoints API
/// 
/// Ce fichier centralise la configuration de l'API backend.
/// Les deux microservices backend (Meeting et Transcription) sont opérationnels.
class ApiConfig {
  // URLs de base des microservices
  static const String meetingServiceUrl = 'http://10.0.2.2:8081/api'; // Android emulator - PORT 8081 !
  static const String transcriptionServiceUrl = 'http://10.0.2.2:8082/api'; // Android emulator
  
  // Pour device physique, utiliser l'IP de votre machine
  // static const String meetingServiceUrl = 'http://192.168.x.x:8081/api';
  // static const String transcriptionServiceUrl = 'http://192.168.x.x:8082/api';
  
  // URL par défaut (Meeting service)
  static const String baseUrl = meetingServiceUrl;
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 60); // Pour upload de fichiers audio
  
  // ========================================
  // MEETING SERVICE ENDPOINTS (Port 8080)
  // ========================================
  
  // Réunions
  static const String meetingEndpoint = '/meeting';
  static const String meetingAllEndpoint = '/meeting/all';
  static const String meetingByIdEndpoint = '/meeting/:id';
  static const String meetingSearchByTitleEndpoint = '/meeting/search/byTitle';
  static const String meetingStartEndpoint = '/meeting/:id/start';
  static const String meetingEndEndpoint = '/meeting/:id/end';
  
  // Participants
  static const String meetingParticipantsEndpoint = '/meeting/:id/participant/all';
  static const String addParticipantEndpoint = '/meeting/:id/participant';
  static const String removeParticipantEndpoint = '/meeting/:id/participant/:participantId';
  static const String allParticipantsEndpoint = '/participant/all';
  static const String participantEndpoint = '/participant';
  
  // ========================================
  // TRANSCRIPTION SERVICE ENDPOINTS (Port 8082)
  // ========================================
  
  // Transcription
  static const String startTranscriptionEndpoint = '/start_transcription/:id';
  static const String sendSegmentEndpoint = '/transcription/:id/send_segment';
  static const String saveSegmentToBddEndpoint = '/transcription/:id/segment_to_bdd';
  static const String saveRecordFileEndpoint = '/transcription/:id/save_record_file';
  static const String obtainRecordFileEndpoint = '/transcription/:id/obtain_record_file';
  
  // Segments
  static const String allSegmentsEndpoint = '/transcription/:id/segment/all';
  static const String segmentByIdEndpoint = '/transcription/:id/segment/:segmentId';
  static const String segmentTimeDepartEndpoint = '/transcription/:id/segment/:segmentId/time_depart';
  static const String segmentTimeFinEndpoint = '/transcription/:id/segment/:segmentId/time_fin';
  
  // Locuteurs
  static const String segmentLocuteurEndpoint = '/transcription/:id/segment/:segmentId/locuteur/all';
  static const String updateSegmentLocuteurEndpoint = '/transcription/:id/segment/:segmentId/locuteur/:participantId';
  
  /// Obtient l'URL du Meeting Service
  static String getMeetingServiceUrl() {
    return meetingServiceUrl;
  }
  
  /// Obtient l'URL du Transcription Service
  static String getTranscriptionServiceUrl() {
    return transcriptionServiceUrl;
  }
  
  /// Remplace les paramètres dans une URL
  /// Exemple: replaceParams('/meeting/:id', {'id': '123'}) -> '/meeting/123'
  static String replaceParams(String endpoint, Map<String, dynamic> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value.toString());
    });
    return result;
  }
}
