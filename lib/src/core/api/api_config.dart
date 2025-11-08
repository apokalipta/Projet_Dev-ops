/// Configuration des endpoints API
/// 
/// Ce fichier centralise la configuration de l'API backend.
/// Pour l'environnement de production, utilisez des variables d'environnement
/// ou un fichier .env pour stocker l'URL de base.
class ApiConfig {
  // URL de base de l'API
  // TODO: Remplacer par l'URL réelle de votre backend
  static const String baseUrl = 'http://localhost:8080/api';
  
  // URLs alternatives pour différents environnements
  static const String devUrl = 'http://localhost:8080/api';
  static const String stagingUrl = 'https://staging-api.votre-domaine.com/api';
  static const String prodUrl = 'https://api.votre-domaine.com/api';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 3);
  static const Duration sendTimeout = Duration(seconds: 10);
  
  // Endpoints Meeting (Sous-projet N°1)
  static const String meetingEndpoint = '/meeting';
  static const String meetingAllEndpoint = '/meeting/all';
  static const String meetingByIdEndpoint = '/meeting/:id';
  static const String meetingParticipantsEndpoint = '/meeting/:id/participant/all';
  static const String meetingSearchByTitleEndpoint = '/meeting/search/byTitle';
  
  // Endpoints Transcription (Sous-projet N°2)
  static const String transcribeEndpoint = '/transcribe';
  static const String transcriptionSegmentsEndpoint = '/transcription/:id/segment/all';
  static const String transcriptionSegmentEndpoint = '/transcription/:id/segment/:segmentId';
  static const String transcriptionRecordFileEndpoint = '/transcription/:id/record_file';
  
  /// Obtient l'URL de base en fonction de l'environnement
  static String getBaseUrl() {
    // TODO: Implémenter la logique pour déterminer l'environnement
    // Par exemple, en utilisant des variables d'environnement ou des flavors
    const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
    
    switch (environment) {
      case 'prod':
        return prodUrl;
      case 'staging':
        return stagingUrl;
      case 'dev':
      default:
        return devUrl;
    }
  }
}
