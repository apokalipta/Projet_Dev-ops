/// Configuration globale de l'application
/// 
/// Ce fichier centralise les paramètres de configuration de l'application.

class AppConfig {
  // ============================================================================
  // MODE DE DÉVELOPPEMENT
  // ============================================================================
  
  /// Active le mode debug
  static const bool debugMode = true;

  /// Affiche les logs détaillés
  static const bool verboseLogs = true;

  // ============================================================================
  // API CONFIGURATION
  // ============================================================================
  
  /// URL de base de l'API Meeting-service
  static const String apiBaseUrl = 'http://localhost:8081/api';

  /// Timeout pour les requêtes API (en secondes)
  static const int apiTimeout = 30;

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
    ║ Debug Mode:       ${debugMode ? 'ACTIVÉ ✅' : 'DÉSACTIVÉ ❌'}    ║
    ║ API Base URL:     $apiBaseUrl
    ║ Transcription:    ${enableTranscription ? 'ACTIVÉ ✅' : 'DÉSACTIVÉ ❌'}    ║
    ║ AI Analysis:      ${enableAiAnalysis ? 'ACTIVÉ ✅' : 'DÉSACTIVÉ ❌'}    ║
    ║ Offline Mode:     ${enableOfflineMode ? 'ACTIVÉ ✅' : 'DÉSACTIVÉ ❌'}    ║
    ╚════════════════════════════════════════╝
    ''';
  }

  /// Vérifie si l'application est en mode développement
  static bool get isDevelopment => debugMode;

  /// Vérifie si l'application est en mode production
  static bool get isProduction => !debugMode;
}
