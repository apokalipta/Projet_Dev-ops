/// Configuration globale de l'application
/// 
/// Ce fichier centralise les paramètres de configuration de l'application.
/// Modifiez `useMockData` pour basculer entre les données mockées et l'API réelle.

class AppConfig {
  // ============================================================================
  // MODE DE DÉVELOPPEMENT
  // ============================================================================
  
  /// Active les données mockées pour le développement
  /// 
  /// - `true` : Utilise MockApiService avec des données fictives
  /// - `false` : Utilise les vraies APIs (MeetingApiService, TranscriptionApiService)
  static const bool useMockData = true;

  /// Active le mode debug
  static const bool debugMode = true;

  /// Affiche les logs détaillés
  static const bool verboseLogs = true;

  // ============================================================================
  // API CONFIGURATION
  // ============================================================================
  
  /// URL de base de l'API (utilisée quand useMockData = false)
  static const String apiBaseUrl = 'http://localhost:8080/api';

  /// Timeout pour les requêtes API (en secondes)
  static const int apiTimeout = 30;

  /// Délai de simulation réseau pour les mocks (en millisecondes)
  static const int mockNetworkDelay = 500;

  // ============================================================================
  // FEATURES FLAGS
  // ============================================================================
  
  /// Active la fonctionnalité de transcription
  static const bool enableTranscription = true;

  /// Active la fonctionnalité d'analyse IA
  static const bool enableAiAnalysis = true;

  /// Active le mode hors ligne
  static const bool enableOfflineMode = true;

  /// Active les notifications
  static const bool enableNotifications = true;

  // ============================================================================
  // UI CONFIGURATION
  // ============================================================================
  
  /// Nombre d'éléments par page pour la pagination
  static const int itemsPerPage = 20;

  /// Durée des animations (en millisecondes)
  static const int animationDuration = 300;

  /// Active le mode sombre par défaut
  static const bool defaultDarkMode = false;

  // ============================================================================
  // STORAGE
  // ============================================================================
  
  /// Nom de la base de données locale
  static const String databaseName = 'meeting_app.db';

  /// Version de la base de données
  static const int databaseVersion = 1;

  /// Durée de cache des données (en heures)
  static const int cacheExpirationHours = 24;

  // ============================================================================
  // HELPERS
  // ============================================================================
  
  /// Retourne un message de configuration pour le debug
  static String getConfigInfo() {
    return '''
    ╔════════════════════════════════════════╗
    ║     Configuration de l'application     ║
    ╠════════════════════════════════════════╣
    ║ Mode Mock:        ${useMockData ? 'ACTIVÉ ✅' : 'DÉSACTIVÉ ❌'}    ║
    ║ Debug Mode:       ${debugMode ? 'ACTIVÉ ✅' : 'DÉSACTIVÉ ❌'}    ║
    ║ API Base URL:     $apiBaseUrl
    ║ Transcription:    ${enableTranscription ? 'ACTIVÉ ✅' : 'DÉSACTIVÉ ❌'}    ║
    ║ AI Analysis:      ${enableAiAnalysis ? 'ACTIVÉ ✅' : 'DÉSACTIVÉ ❌'}    ║
    ║ Offline Mode:     ${enableOfflineMode ? 'ACTIVÉ ✅' : 'DÉSACTIVÉ ❌'}    ║
    ╚════════════════════════════════════════╝
    ''';
  }

  /// Vérifie si l'application est en mode développement
  static bool get isDevelopment => useMockData || debugMode;

  /// Vérifie si l'application est en mode production
  static bool get isProduction => !useMockData && !debugMode;
}
