// Service API pour Transcript IA
import { API_CONFIG, buildApiUrl, getDefaultHeaders, getAuthHeaders, ENDPOINTS } from '../config/api.js'
import { ERROR_MESSAGES } from '../config/constants.js'
import { cacheService } from './cacheService.js'

class ApiError extends Error {
  constructor(status, message, details = null) {
    super(message || `Erreur API (HTTP ${status})`)
    this.name = 'ApiError'
    this.status = status
    this.details = details
  }
}

class ApiService {
  constructor() {
    this.baseURL = API_CONFIG.BASE_URL
    this.timeout = API_CONFIG.TIMEOUTS.DEFAULT
  }

  // Méthode générique pour les requêtes HTTP avec cache de secours
  async request(endpoint, options = {}) {
    const url = endpoint.startsWith('http') ? endpoint : `${this.baseURL}${endpoint}`
    const cacheKey = `${options.method || 'GET'}:${url}`

    // Pour les requêtes GET, vérifier d'abord le cache
    if (!options.method || options.method.toUpperCase() === 'GET') {
      try {
        const cachedData = await cacheService.get(cacheKey);
        if (cachedData) {
          console.log('Données récupérées depuis le cache pour:', cacheKey);
          return cachedData;
        }
      } catch (error) {
        console.warn('Erreur lors de la lecture du cache:', error);
      }
    }

    const defaultOptions = {
      headers: getDefaultHeaders(),
      timeout: this.timeout,
      ...options
    }

    try {
      const response = await fetch(url, defaultOptions)
      const contentType = response.headers.get('content-type') || ''
      const isJson = contentType.includes('application/json')
      const body = isJson ? await response.json() : await response.text()

      if (!response.ok) {
        // Log détaillé des erreurs
        console.error('❌ Erreur API:', {
          status: response.status,
          statusText: response.statusText,
          url: url,
          body: body
        })
        
        // En cas d'erreur, essayer de retourner les données en cache si disponibles
        if (!options.method || options.method.toUpperCase() === 'GET') {
          try {
            const cachedData = await cacheService.get(cacheKey);
            if (cachedData) {
              console.warn('API non disponible, utilisation des données en cache pour:', cacheKey);
              return cachedData;
            }
          } catch (cacheError) {
            console.warn('Erreur lors de la lecture du cache de secours:', cacheError);
          }
        }
        throw new ApiError(response.status, body?.message || response.statusText, body)
      }

      // Mettre en cache les réponses GET réussies
      if ((!options.method || options.method.toUpperCase() === 'GET') && isJson) {
        try {
          // Mettre en cache pendant 1 heure par défaut
          await cacheService.set(cacheKey, body, 3600000);
        } catch (cacheError) {
          console.warn('Erreur lors de la mise en cache:', cacheError);
        }
      }

      return body
    } catch (error) {
      console.error('Erreur API:', error);
      
      // Pour les erreurs réseau ou de timeout, essayer de retourner les données en cache
      if ((!options.method || options.method.toUpperCase() === 'GET') && 
          (error.name === 'TypeError' || error.name === 'AbortError')) {
        try {
          const cachedData = await cacheService.get(cacheKey);
          if (cachedData) {
            console.warn('API non disponible, utilisation des données en cache pour:', cacheKey);
            return cachedData;
          }
        } catch (cacheError) {
          console.warn('Erreur lors de la lecture du cache de secours:', cacheError);
        }
      }
      
      throw this.handleError(error);
    }
  }

  // Gestion des erreurs
  handleError(error) {
    if (error instanceof ApiError) {
      return error
    }

    if (error.name === 'TypeError' && error.message.includes('fetch')) {
      return new Error(ERROR_MESSAGES.NETWORK_ERROR)
    }
    return error
  }

  // Méthodes pour l'authentification
  async login(credentials) {
    return this.request(ENDPOINTS.LOGIN, {
      method: 'POST',
      body: JSON.stringify(credentials)
    })
  }

  async register(userData) {
    return this.request(ENDPOINTS.REGISTER, {
      method: 'POST',
      body: JSON.stringify(userData)
    })
  }

  async logout(token) {
    return this.request('/auth/logout', {
      method: 'POST',
      headers: getAuthHeaders(token)
    })
  }

  // Méthodes pour les réunions
  async getAllMeetings(token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.LIST_MEETINGS, {
      method: 'GET',
      headers
    })
  }

  async getMeetingById(id, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.GET_MEETING(id), {
      method: 'GET',
      headers
    })
  }

  async createMeeting(meetingData, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    
    // Transformer les données pour correspondre au format attendu par le backend
    // Le backend attend: title, description, meetingDate/scheduledAt, previsualDuration/durationMinutes, status, participants[]
    const duration = meetingData.duration || meetingData.durationMinutes
    
    // Formater la date correctement (ISO string ou format attendu par le backend)
    let meetingDate = meetingData.date || meetingData.scheduledAt || meetingData.meetingDate
    if (meetingDate && meetingDate instanceof Date) {
      meetingDate = meetingDate.toISOString()
    } else if (meetingDate && typeof meetingDate === 'string') {
      // Si c'est déjà une string, on la garde telle quelle
      // Le backend accepte différents formats de date
    }
    
    // Le champ participants dans meetingData est le nombre de participants, pas la liste
    // Le backend attend une liste vide [] ou une liste d'objets ParticipantRequest
    const participantsList = Array.isArray(meetingData.participants) 
      ? meetingData.participants 
      : []
    
    const payload = {
      title: meetingData.name || meetingData.title,
      description: meetingData.description || '',
      // Le backend accepte meetingDate ou scheduledAt grâce à @JsonAlias
      meetingDate: meetingDate,
      // Le backend accepte previsualDuration (String) ou durationMinutes (Integer)
      durationMinutes: duration ? Number(duration) : undefined,
      previsualDuration: duration ? String(duration) : undefined,
      status: meetingData.status || 'scheduled',
      participants: participantsList,
      // Ajouter la langue si fournie
      ...(meetingData.language && { language: meetingData.language })
    }
    
    // Log pour debug
    console.log('📤 Envoi de la requête POST à:', ENDPOINTS.CREATE_MEETING)
    console.log('📦 Payload:', payload)
    
    return this.request(ENDPOINTS.CREATE_MEETING, {
      method: 'POST',
      headers,
      body: JSON.stringify(payload)
    })
  }

  async updateMeeting(id, meetingData, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.GET_MEETING(id), {
      method: 'PUT',
      headers,
      body: JSON.stringify(meetingData)
    })
  }

  async deleteMeeting(id, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.GET_MEETING(id), {
      method: 'DELETE',
      headers
    })
  }

  async startMeeting(id, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.START_MEETING(id), {
      method: 'PUT',
      headers
    })
  }

  async endMeeting(id, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.END_MEETING(id), {
      method: 'PUT',
      headers
    })
  }

  async searchMeetingsByTitle(title, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.SEARCH_MEETING_BY_TITLE(title), {
      method: 'GET',
      headers
    })
  }

  async getParticipantsByMeeting(meetingId, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.LIST_PARTICIPANTS(meetingId), {
      method: 'GET',
      headers
    })
  }

  async addParticipant(meetingId, participantData, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.ADD_PARTICIPANT(meetingId), {
      method: 'POST',
      headers,
      body: JSON.stringify(participantData)
    })
  }

  async removeParticipant(meetingId, participantId, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.REMOVE_PARTICIPANT(meetingId, participantId), {
      method: 'DELETE',
      headers
    })
  }

  async getAllParticipants(token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.GET_ALL_PARTICIPANTS, {
      method: 'GET',
      headers
    })
  }

  // Méthodes pour la transcription
  async createTranscription(meetingId, transcriptionData, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.CREATE_TRANSCRIPTION(meetingId), {
      method: 'POST',
      headers,
      body: JSON.stringify(transcriptionData || {})
    })
  }

  async sendSegment(meetingId, file, token) {
    const formData = new FormData()
    formData.append('file', file)

    const headers = token ? { 'Authorization': `Bearer ${token}` } : {}
    // Ne pas définir Content-Type pour FormData, le navigateur le fera automatiquement

    return this.request(ENDPOINTS.SEND_SEGMENT(meetingId), {
      method: 'POST',
      headers,
      body: formData
    })
  }

  async saveSegmentToBdd(meetingId, segmentData, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.SEGMENT_TO_BDD(meetingId), {
      method: 'POST',
      headers,
      body: JSON.stringify(segmentData)
    })
  }

  async getSegments(meetingId, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.LIST_SEGMENTS(meetingId), {
      method: 'GET',
      headers
    })
  }

  async getSegment(meetingId, segmentId, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.SEGMENT_DETAILS(meetingId, segmentId), {
      method: 'GET',
      headers
    })
  }

  async updateSegment(meetingId, segmentId, segmentData, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.UPDATE_SEGMENT(meetingId, segmentId), {
      method: 'PUT',
      headers,
      body: JSON.stringify(segmentData)
    })
  }

  async getSegmentSpeakers(meetingId, segmentId, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.LIST_SEGMENT_SPEAKERS(meetingId, segmentId), {
      method: 'GET',
      headers
    })
  }

  async updateSegmentSpeaker(meetingId, segmentId, participantId, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.UPDATE_SEGMENT_SPEAKER(meetingId, segmentId, participantId), {
      method: 'PUT',
      headers
    })
  }

  async getRecordFile(meetingId, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.GET_RECORD_FILE(meetingId), {
      method: 'GET',
      headers
    })
  }

  async saveRecordFile(meetingId, file, token) {
    const formData = new FormData()
    formData.append('file', file)

    const headers = token ? { 'Authorization': `Bearer ${token}` } : {}
    // Ne pas définir Content-Type pour FormData

    return this.request(ENDPOINTS.SAVE_RECORD_FILE(meetingId), {
      method: 'POST',
      headers,
      body: formData
    })
  }

  async getSegmentStartTime(meetingId, segmentId, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.GET_SEGMENT_START(meetingId, segmentId), {
      method: 'GET',
      headers
    })
  }

  async getSegmentEndTime(meetingId, segmentId, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.GET_SEGMENT_END(meetingId, segmentId), {
      method: 'GET',
      headers
    })
  }

  // Méthodes pour les fichiers
  async uploadFile(file, token, onProgress = null) {
    const formData = new FormData()
    formData.append('file', file)

    const options = {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`
        // Ne pas définir Content-Type pour FormData
      },
      body: formData
    }

    if (onProgress) {
      options.onUploadProgress = onProgress
    }

    return this.request(ENDPOINTS.UPLOAD_FILE, options)
  }

  async downloadFile(fileId, token) {
    return this.request(`/files/${fileId}/download`, {
      method: 'GET',
      headers: getAuthHeaders(token)
    })
  }

  async deleteFile(fileId, token) {
    return this.request(`/files/${fileId}`, {
      method: 'DELETE',
      headers: getAuthHeaders(token)
    })
  }

  // Méthodes pour les utilisateurs
  async getUsers(token) {
    return this.request('/users', {
      method: 'GET',
      headers: getAuthHeaders(token)
    })
  }

  async getUserById(id, token) {
    return this.request(`/users/${id}`, {
      method: 'GET',
      headers: getAuthHeaders(token)
    })
  }

  async updateUser(id, userData, token) {
    return this.request(`/users/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(token),
      body: JSON.stringify(userData)
    })
  }

  // Méthode pour les WebSockets (connexion en temps réel)
  connectWebSocket(token) {
    const wsUrl = `${API_CONFIG.WS_URL}?token=${token}`
    return new WebSocket(wsUrl)
  }
}

// Instance singleton du service API
export const apiService = new ApiService()

// Export des constantes pour utilisation directe
export { ENDPOINTS, API_CONFIG }
