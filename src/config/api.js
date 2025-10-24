// Configuration des routes API et variables globales
export const API_CONFIG = {
  // URL de base de l'API
  BASE_URL: process.env.VUE_APP_API_URL || 'http://localhost:8000/api',
  
  // Routes principales
  ROUTES: {
    // Routes de transcription
    TRANSCRIPTION: {
      START: '/transcription/start',
      STOP: '/transcription/stop',
      STATUS: '/transcription/status',
      GET_ALL: '/all_met', // Votre route spécifique
      GET_BY_ID: '/transcription/:id',
      DELETE: '/transcription/:id'
    },
    
    // Routes d'authentification
    AUTH: {
      LOGIN: '/auth/login',
      LOGOUT: '/auth/logout',
      REGISTER: '/auth/register',
      REFRESH: '/auth/refresh',
      PROFILE: '/auth/profile'
    },
    
    // Routes des réunions
    MEETINGS: {
      GET_ALL: '/meetings',
      CREATE: '/meetings',
      GET_BY_ID: '/meetings/:id',
      UPDATE: '/meetings/:id',
      DELETE: '/meetings/:id',
      GET_PARTICIPANTS: '/meetings/:id/participants'
    },
    
    // Routes des utilisateurs
    USERS: {
      GET_ALL: '/users',
      GET_BY_ID: '/users/:id',
      UPDATE: '/users/:id',
      DELETE: '/users/:id'
    },
    
    // Routes des fichiers
    FILES: {
      UPLOAD: '/files/upload',
      DOWNLOAD: '/files/:id/download',
      DELETE: '/files/:id',
      GET_ALL: '/files'
    }
  },
  
  // Configuration des timeouts
  TIMEOUTS: {
    DEFAULT: 30000, // 30 secondes
    UPLOAD: 300000, // 5 minutes pour les uploads
    TRANSCRIPTION: 600000 // 10 minutes pour la transcription
  },
  
  // Configuration des formats de fichiers supportés
  SUPPORTED_FORMATS: {
    AUDIO: ['.mp3', '.wav', '.m4a', '.aac', '.ogg'],
    VIDEO: ['.mp4', '.avi', '.mov', '.mkv'],
    DOCUMENTS: ['.pdf', '.doc', '.docx', '.txt']
  },
  
  // Configuration des langues supportées
  SUPPORTED_LANGUAGES: [
    { code: 'fr', name: 'Français' },
    { code: 'en', name: 'English' },
    { code: 'es', name: 'Español' },
    { code: 'de', name: 'Deutsch' },
    { code: 'it', name: 'Italiano' }
  ],
  
  // Configuration des tailles de fichiers
  FILE_LIMITS: {
    MAX_SIZE: 100 * 1024 * 1024, // 100MB
    MAX_DURATION: 3600 // 1 heure en secondes
  }
}

// Fonctions utilitaires pour construire les URLs
export const buildApiUrl = (route, params = {}) => {
  let url = `${API_CONFIG.BASE_URL}${route}`
  
  // Remplace les paramètres dans l'URL
  Object.keys(params).forEach(key => {
    url = url.replace(`:${key}`, params[key])
  })
  
  return url
}

// Configuration des headers par défaut
export const getDefaultHeaders = () => {
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
}

// Configuration des headers avec authentification
export const getAuthHeaders = (token) => {
  return {
    ...getDefaultHeaders(),
    'Authorization': `Bearer ${token}`
  }
}

// Configuration des endpoints spécifiques
export const ENDPOINTS = {
  // Votre route spécifique
  ALL_MEETINGS: buildApiUrl(API_CONFIG.ROUTES.TRANSCRIPTION.GET_ALL),
  
  // Autres endpoints utiles
  START_TRANSCRIPTION: buildApiUrl(API_CONFIG.ROUTES.TRANSCRIPTION.START),
  STOP_TRANSCRIPTION: buildApiUrl(API_CONFIG.ROUTES.TRANSCRIPTION.STOP),
  GET_TRANSCRIPTION_STATUS: buildApiUrl(API_CONFIG.ROUTES.TRANSCRIPTION.STATUS),
  
  // Authentification
  LOGIN: buildApiUrl(API_CONFIG.ROUTES.AUTH.LOGIN),
  REGISTER: buildApiUrl(API_CONFIG.ROUTES.AUTH.REGISTER),
  
  // Réunions
  GET_MEETINGS: buildApiUrl(API_CONFIG.ROUTES.MEETINGS.GET_ALL),
  CREATE_MEETING: buildApiUrl(API_CONFIG.ROUTES.MEETINGS.CREATE),
  
  // Fichiers
  UPLOAD_FILE: buildApiUrl(API_CONFIG.ROUTES.FILES.UPLOAD)
}

// Configuration de l'environnement
export const ENV_CONFIG = {
  IS_DEVELOPMENT: process.env.NODE_ENV === 'development',
  IS_PRODUCTION: process.env.NODE_ENV === 'production',
  API_URL: process.env.VUE_APP_API_URL || 'http://localhost:8000/api',
  WS_URL: process.env.VUE_APP_WS_URL || 'ws://localhost:8000/ws'
}
