// Configuration des routes API et variables globales
const VITE_API_URL = import.meta?.env?.VITE_API_URL || import.meta?.env?.VITE_API_BASE_URL
const VITE_WS_URL = import.meta?.env?.VITE_WS_URL || import.meta?.env?.VITE_API_WS_URL

export const API_CONFIG = {
  // URL de base de l'API (backend Quarkus Meeting-service)
  BASE_URL: VITE_API_URL || 'http://localhost:8081/api',
  
  // URL du service de transcription
  TRANSCRIPTION_BASE_URL: 'http://localhost:8082/api',
  
  // Routes principales exposées par le backend
  ROUTES: {
    MEETINGS: {
      CREATE: '/meeting',
      GET_ALL: '/meeting/all',
      GET_BY_ID: '/meeting/:meetingId',
      DELETE_MEETING: '/meeting/:meetingId',
      GET_PARTICIPANTS: '/meeting/:meetingId/participant/all',
      ADD_PARTICIPANT: '/meeting/:meetingId/participant',
      REMOVE_PARTICIPANT: '/meeting/:meetingId/participant/:participantId',
      SEARCH_BY_TITLE: '/meeting/search/byTitle',
      START_MEETING: '/meeting/:meetingId/start',
      END_MEETING: '/meeting/:meetingId/end'
    },
    
    PARTICIPANTS: {
      CREATE_OR_UPDATE: '/participant',
      GET_ALL: '/participant/all'
    },
    
    TRANSCRIPTION: {
      START_TRANSCRIPTION: '/start_transcription/:meetingId',
      SEND_SEGMENT: '/transcription/:meetingId/send_segment',
      SAVE_SEGMENTS: '/transcription/:meetingId/segment_to_bdd',
      GET_ALL_SEGMENTS: '/transcription/:meetingId/segment/all',
      GET_SEGMENT: '/transcription/:meetingId/segment/:segmentId',
      UPDATE_SEGMENT: '/transcription/:meetingId/segment/:segmentId',
      GET_SEGMENT_SPEAKER: '/transcription/:meetingId/segment/:segmentId/locuteur/all',
      UPDATE_SEGMENT_SPEAKER: '/transcription/:meetingId/segment/:segmentId/locuteur/:participantId',
      GET_RECORD_FILE: '/transcription/:meetingId/obtain_record_file',
      SAVE_RECORD_FILE: '/transcription/:meetingId/save_record_file'
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

// Helper pour construire les URLs de transcription
const buildTranscriptionUrl = (route, params = {}) => {
  let url = API_CONFIG.TRANSCRIPTION_BASE_URL + route
  Object.keys(params).forEach(key => {
    url = url.replace(`:${key}`, params[key])
  })
  return url
}

// Configuration des endpoints spécifiques réellement disponibles
export const ENDPOINTS = {
  CREATE_MEETING: buildApiUrl(API_CONFIG.ROUTES.MEETINGS.CREATE),
  LIST_MEETINGS: buildApiUrl(API_CONFIG.ROUTES.MEETINGS.GET_ALL),
  GET_MEETING: (id) => buildApiUrl(API_CONFIG.ROUTES.MEETINGS.GET_BY_ID, { meetingId: id }),
  DELETE_MEETING: (id) => buildApiUrl(API_CONFIG.ROUTES.MEETINGS.DELETE_MEETING, { meetingId: id }),
  LIST_PARTICIPANTS: (id) => buildApiUrl(API_CONFIG.ROUTES.MEETINGS.GET_PARTICIPANTS, { meetingId: id }),
  ADD_PARTICIPANT: (id) => buildApiUrl(API_CONFIG.ROUTES.MEETINGS.ADD_PARTICIPANT, { meetingId: id }),
  REMOVE_PARTICIPANT: (meetingId, participantId) => buildApiUrl(API_CONFIG.ROUTES.MEETINGS.REMOVE_PARTICIPANT, { meetingId, participantId }),
  SEARCH_MEETING_BY_TITLE: (title) => `${buildApiUrl(API_CONFIG.ROUTES.MEETINGS.SEARCH_BY_TITLE)}?title=${encodeURIComponent(title)}`,
  START_MEETING: (id) => buildApiUrl(API_CONFIG.ROUTES.MEETINGS.START_MEETING, { meetingId: id }),
  END_MEETING: (id) => buildApiUrl(API_CONFIG.ROUTES.MEETINGS.END_MEETING, { meetingId: id }),
  GET_ALL_PARTICIPANTS: buildApiUrl(API_CONFIG.ROUTES.PARTICIPANTS.GET_ALL),
  SAVE_PARTICIPANT: buildApiUrl(API_CONFIG.ROUTES.PARTICIPANTS.CREATE_OR_UPDATE),
  
  // Endpoints de transcription (service séparé sur port 8082)
  START_TRANSCRIPTION: (id) => buildTranscriptionUrl(API_CONFIG.ROUTES.TRANSCRIPTION.START_TRANSCRIPTION, { meetingId: id }),
  SEND_SEGMENT: (id) => buildTranscriptionUrl(API_CONFIG.ROUTES.TRANSCRIPTION.SEND_SEGMENT, { meetingId: id }),
  SAVE_SEGMENTS: (id) => buildTranscriptionUrl(API_CONFIG.ROUTES.TRANSCRIPTION.SAVE_SEGMENTS, { meetingId: id }),
  GET_ALL_SEGMENTS: (id) => buildTranscriptionUrl(API_CONFIG.ROUTES.TRANSCRIPTION.GET_ALL_SEGMENTS, { meetingId: id }),
  GET_SEGMENT: (meetingId, segmentId) => buildTranscriptionUrl(API_CONFIG.ROUTES.TRANSCRIPTION.GET_SEGMENT, { meetingId, segmentId }),
  UPDATE_SEGMENT: (meetingId, segmentId) => buildTranscriptionUrl(API_CONFIG.ROUTES.TRANSCRIPTION.UPDATE_SEGMENT, { meetingId, segmentId }),
  GET_SEGMENT_SPEAKER: (meetingId, segmentId) => buildTranscriptionUrl(API_CONFIG.ROUTES.TRANSCRIPTION.GET_SEGMENT_SPEAKER, { meetingId, segmentId }),
  UPDATE_SEGMENT_SPEAKER: (meetingId, segmentId, participantId) => buildTranscriptionUrl(API_CONFIG.ROUTES.TRANSCRIPTION.UPDATE_SEGMENT_SPEAKER, { meetingId, segmentId, participantId }),
  GET_RECORD_FILE: (id) => buildTranscriptionUrl(API_CONFIG.ROUTES.TRANSCRIPTION.GET_RECORD_FILE, { meetingId: id }),
  SAVE_RECORD_FILE: (id) => buildTranscriptionUrl(API_CONFIG.ROUTES.TRANSCRIPTION.SAVE_RECORD_FILE, { meetingId: id })
}

// Configuration de l'environnement
const NODE_ENV = import.meta?.env?.MODE || import.meta?.env?.NODE_ENV

export const ENV_CONFIG = {
  IS_DEVELOPMENT: NODE_ENV === 'development',
  IS_PRODUCTION: NODE_ENV === 'production',
  API_URL: VITE_API_URL || 'http://localhost:8081/api',
  WS_URL: VITE_WS_URL || 'ws://localhost:8081/ws'
}
