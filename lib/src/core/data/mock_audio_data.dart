/// Données audio mockées pour les tests
/// 
/// Ce fichier contient des URLs d'audio de test pour simuler la lecture
/// de réunions enregistrées.

class MockAudioData {
  // URLs d'audio de test (fichiers MP3 publics pour les tests)
  // En production, ces URLs seront remplacées par les vrais fichiers audio
  static const Map<String, String> audioUrls = {
    'meeting-001': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    'meeting-002': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    'meeting-003': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    'meeting-005': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
  };

  /// Obtenir l'URL audio d'une réunion
  static String? getAudioUrl(String meetingId) {
    return audioUrls[meetingId];
  }

  /// Vérifier si une réunion a un audio disponible
  static bool hasAudio(String meetingId) {
    return audioUrls.containsKey(meetingId);
  }

  /// Obtenir la durée totale de l'audio (en secondes)
  /// En production, cela sera récupéré depuis les métadonnées du fichier
  static int getAudioDuration(String meetingId) {
    // Pour le mock, on utilise la durée de la réunion
    // En production, on utilisera la vraie durée du fichier audio
    switch (meetingId) {
      case 'meeting-001':
        return 3600; // 1h
      case 'meeting-002':
        return 5400; // 1h30
      case 'meeting-003':
        return 2700; // 45min
      case 'meeting-005':
        return 4500; // 1h15
      default:
        return 0;
    }
  }
}
