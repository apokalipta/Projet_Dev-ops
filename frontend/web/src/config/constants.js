// Constantes globales de l'application Transcript IA

// Constantes de l'application
export const APP_CONSTANTS = {
  NAME: 'Transcript IA',
  VERSION: '1.0.0',
  DESCRIPTION: 'Application de transcription de réunion en temps réel',
  
  // Configuration des thèmes
  THEMES: {
    LIGHT: 'light',
    DARK: 'dark'
  },
  
  // Configuration des langues par défaut
  DEFAULT_LANGUAGE: 'fr',
  
  // Configuration des notifications
  NOTIFICATION_TYPES: {
    SUCCESS: 'success',
    ERROR: 'error',
    WARNING: 'warning',
    INFO: 'info'
  }
}

// Constantes pour les états de transcription
export const TRANSCRIPTION_STATUS = {
  IDLE: 'idle',
  RECORDING: 'recording',
  PROCESSING: 'processing',
  COMPLETED: 'completed',
  ERROR: 'error',
  PAUSED: 'paused'
}

// Constantes pour les types de réunions
export const MEETING_TYPES = {
  INTERNAL: 'internal',
  EXTERNAL: 'external',
  CLIENT: 'client',
  TEAM: 'team',
  CONFERENCE: 'conference'
}

// Constantes pour les rôles d'utilisateurs
export const USER_ROLES = {
  ADMIN: 'admin',
  MODERATOR: 'moderator',
  USER: 'user',
  GUEST: 'guest'
}

// Constantes pour les permissions
export const PERMISSIONS = {
  CREATE_MEETING: 'create_meeting',
  EDIT_MEETING: 'edit_meeting',
  DELETE_MEETING: 'delete_meeting',
  START_TRANSCRIPTION: 'start_transcription',
  STOP_TRANSCRIPTION: 'stop_transcription',
  DOWNLOAD_TRANSCRIPT: 'download_transcript',
  MANAGE_USERS: 'manage_users'
}

// Constantes pour les formats de sortie
export const OUTPUT_FORMATS = {
  TXT: 'txt',
  PDF: 'pdf',
  DOCX: 'docx',
  SRT: 'srt',
  VTT: 'vtt'
}

// Constantes pour les tailles de fichiers
export const FILE_SIZES = {
  BYTES: 'bytes',
  KB: 'kb',
  MB: 'mb',
  GB: 'gb'
}

// Constantes pour les durées
export const DURATION_FORMATS = {
  SECONDS: 'seconds',
  MINUTES: 'minutes',
  HOURS: 'hours'
}

// Constantes pour les couleurs de l'interface
export const UI_COLORS = {
  PRIMARY: '#6366f1',
  SECONDARY: '#f8fafc',
  SUCCESS: '#10b981',
  WARNING: '#f59e0b',
  ERROR: '#ef4444',
  INFO: '#3b82f6'
}

// Constantes pour les messages d'erreur
export const ERROR_MESSAGES = {
  NETWORK_ERROR: 'Erreur de connexion réseau',
  UNAUTHORIZED: 'Accès non autorisé',
  FORBIDDEN: 'Accès interdit',
  NOT_FOUND: 'Ressource non trouvée',
  SERVER_ERROR: 'Erreur du serveur',
  VALIDATION_ERROR: 'Erreur de validation',
  FILE_TOO_LARGE: 'Fichier trop volumineux',
  UNSUPPORTED_FORMAT: 'Format de fichier non supporté'
}

// Constantes pour les messages de succès
export const SUCCESS_MESSAGES = {
  TRANSCRIPTION_STARTED: 'Transcription démarrée avec succès',
  TRANSCRIPTION_STOPPED: 'Transcription arrêtée avec succès',
  FILE_UPLOADED: 'Fichier téléchargé avec succès',
  MEETING_CREATED: 'Réunion créée avec succès',
  SETTINGS_SAVED: 'Paramètres sauvegardés avec succès'
}

// Constantes pour les limites
export const LIMITS = {
  MAX_FILE_SIZE: 100 * 1024 * 1024, // 100MB
  MAX_MEETING_DURATION: 3600, // 1 heure
  MAX_PARTICIPANTS: 50,
  MAX_TRANSCRIPTION_LENGTH: 10000 // 10000 caractères
}

// Constantes pour les intervalles de temps
export const INTERVALS = {
  REFRESH_STATUS: 1000, // 1 seconde
  AUTO_SAVE: 30000, // 30 secondes
  SESSION_TIMEOUT: 3600000 // 1 heure
}
