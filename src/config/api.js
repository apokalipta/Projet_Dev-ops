// Configuration des routes API et variables globales
const VITE_API_URL = import.meta?.env?.VITE_API_URL || import.meta?.env?.VITE_API_BASE_URL
const VITE_WS_URL = import.meta?.env?.VITE_WS_URL || import.meta?.env?.VITE_API_WS_URL

export const API_CONFIG = {
  // URL de base de l'API (backend Express ou autre)
  BASE_URL: VITE_API_URL || 'http://localhost:5000/api',
  
  // Routes principales
  ROUTES: {
    // Routes de transcription
    TRANSCRIPTION: {
      SEGMENTS_ALL: '/transcription/:id_reunion/segment/all',
      SEGMENT_BY_ID: '/transcription/:id_reunion/segment/:id_segment',
      SEGMENT_UPDATE: '/transcription/:id_reunion/segment/:id_segment',
      SEGMENT_SPEAKERS: '/transcription/:id_reunion/segment/:id_segment/locuteur/all',
      SEGMENT_SPEAKER_UPDATE: '/transcription/:id_reunion/segment/:id_segment/locuteur/:id_participant',
      RECORD_FILE: '/transcription/:id_reunion/record_file',
      SEGMENT_START_TIME: '/transcription/:id_reunion/segment/:id_segment/time_depart',
      SEGMENT_END_TIME: '/transcription/:id_reunion/segment/:id_segment/time_fin'
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
      CREATE: '/meeting',
      GET_ALL: '/meeting/all',
      GET_BY_ID: '/meeting/:id_meeting',
      GET_PARTICIPANTS: '/meeting/:id_meeting/participant/all',
      ADD_PARTICIPANT: '/meeting/:id_meeting/participant',
      REMOVE_PARTICIPANT: '/meeting/:id_meeting/participant/:id_participant',
      SEARCH_BY_TITLE: '/meeting/search/byTitle',
      START_MEETING: '/start_meeting/:id_meeting'
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
  // Réunions
  CREATE_MEETING: buildApiUrl(API_CONFIG.ROUTES.MEETINGS.CREATE),
  LIST_MEETINGS: buildApiUrl(API_CONFIG.ROUTES.MEETINGS.GET_ALL),
  GET_MEETING: (id) => buildApiUrl(API_CONFIG.ROUTES.MEETINGS.GET_BY_ID, { id_meeting: id }),
  LIST_PARTICIPANTS: (id) => buildApiUrl(API_CONFIG.ROUTES.MEETINGS.GET_PARTICIPANTS, { id_meeting: id }),
  ADD_PARTICIPANT: (id) => buildApiUrl(API_CONFIG.ROUTES.MEETINGS.ADD_PARTICIPANT, { id_meeting: id }),
  REMOVE_PARTICIPANT: (meetingId, participantId) => buildApiUrl(API_CONFIG.ROUTES.MEETINGS.REMOVE_PARTICIPANT, { id_meeting: meetingId, id_participant: participantId }),
  SEARCH_MEETING_BY_TITLE: (title) => `${buildApiUrl(API_CONFIG.ROUTES.MEETINGS.SEARCH_BY_TITLE)}?title=${encodeURIComponent(title)}`,
  START_MEETING: (id) => buildApiUrl(API_CONFIG.ROUTES.MEETINGS.START_MEETING, { id_meeting: id }),

  // Transcription
  LIST_SEGMENTS: (meetingId) => buildApiUrl(API_CONFIG.ROUTES.TRANSCRIPTION.SEGMENTS_ALL, { id_reunion: meetingId }),
  SEGMENT_DETAILS: (meetingId, segmentId) => buildApiUrl(API_CONFIG.ROUTES.TRANSCRIPTION.SEGMENT_BY_ID, { id_reunion: meetingId, id_segment: segmentId }),
  UPDATE_SEGMENT: (meetingId, segmentId) => buildApiUrl(API_CONFIG.ROUTES.TRANSCRIPTION.SEGMENT_UPDATE, { id_reunion: meetingId, id_segment: segmentId }),
  LIST_SEGMENT_SPEAKERS: (meetingId, segmentId) => buildApiUrl(API_CONFIG.ROUTES.TRANSCRIPTION.SEGMENT_SPEAKERS, { id_reunion: meetingId, id_segment: segmentId }),
  UPDATE_SEGMENT_SPEAKER: (meetingId, segmentId, participantId) => buildApiUrl(API_CONFIG.ROUTES.TRANSCRIPTION.SEGMENT_SPEAKER_UPDATE, { id_reunion: meetingId, id_segment: segmentId, id_participant: participantId }),
  GET_RECORD_FILE: (meetingId) => buildApiUrl(API_CONFIG.ROUTES.TRANSCRIPTION.RECORD_FILE, { id_reunion: meetingId }),
  GET_SEGMENT_START: (meetingId, segmentId) => buildApiUrl(API_CONFIG.ROUTES.TRANSCRIPTION.SEGMENT_START_TIME, { id_reunion: meetingId, id_segment: segmentId }),
  GET_SEGMENT_END: (meetingId, segmentId) => buildApiUrl(API_CONFIG.ROUTES.TRANSCRIPTION.SEGMENT_END_TIME, { id_reunion: meetingId, id_segment: segmentId }),

  // Authentification
  LOGIN: buildApiUrl(API_CONFIG.ROUTES.AUTH.LOGIN),
  REGISTER: buildApiUrl(API_CONFIG.ROUTES.AUTH.REGISTER),

  // Fichiers
  UPLOAD_FILE: buildApiUrl(API_CONFIG.ROUTES.FILES.UPLOAD)
}

// Configuration de l'environnement
const NODE_ENV = import.meta?.env?.MODE || import.meta?.env?.NODE_ENV

export const ENV_CONFIG = {
  IS_DEVELOPMENT: NODE_ENV === 'development',
  IS_PRODUCTION: NODE_ENV === 'production',
  API_URL: VITE_API_URL || 'http://localhost:5000/api',
  WS_URL: VITE_WS_URL || 'ws://localhost:5000/ws'
}
