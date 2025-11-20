// Service API pour Transcript IA
import { API_CONFIG, getDefaultHeaders, getAuthHeaders, ENDPOINTS } from '../config/api.js'
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

  // Méthodes alignées avec le Meeting-service backend
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
    const duration = meetingData.duration || meetingData.durationMinutes

    let meetingDate = meetingData.date || meetingData.scheduledAt || meetingData.meetingDate
    if (meetingDate instanceof Date) {
      meetingDate = meetingDate.toISOString()
    }

    const participantsList = Array.isArray(meetingData.participants)
      ? meetingData.participants
      : []

    const payload = {
      title: meetingData.name || meetingData.title,
      description: meetingData.description || '',
      meetingDate,
      durationMinutes: duration ? Number(duration) : undefined,
      previsualDuration: duration ? String(duration) : undefined,
      status: meetingData.status || 'scheduled',
      participants: participantsList,
      ...(meetingData.language && { language: meetingData.language })
    }

    console.log('📤 Envoi de la requête POST à:', ENDPOINTS.CREATE_MEETING)
    console.log('📦 Payload:', payload)

    return this.request(ENDPOINTS.CREATE_MEETING, {
      method: 'POST',
      headers,
      body: JSON.stringify(payload)
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

  async deleteMeeting(id, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.DELETE_MEETING(id), {
      method: 'DELETE',
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

  async saveParticipant(participantData, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    return this.request(ENDPOINTS.SAVE_PARTICIPANT, {
      method: 'POST',
      headers,
      body: JSON.stringify(participantData)
    })
  }

  // ============= Transcription Methods =============

  /**
   * Démarre une transcription pour une réunion
   * @param {number} meetingId - ID de la réunion
   * @param {object} data - {idFat: number, recordFileName: string} (optionnel)
   */
  async startTranscription(meetingId, data = {}, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    console.log('🎙️ Démarrage transcription pour réunion:', meetingId)
    return this.request(ENDPOINTS.START_TRANSCRIPTION(meetingId), {
      method: 'POST',
      headers,
      body: JSON.stringify(data)
    })
  }

  /**
   * Envoie un segment audio pour transcription
   * @param {number} meetingId - ID de la réunion
   * @param {File} audioFile - Fichier audio (mp3, wav, etc.)
   */
  async sendAudioSegment(meetingId, audioFile) {
    const formData = new FormData()
    formData.append('file', audioFile)
    
    // Pour FormData, ne pas inclure Content-Type, le navigateur le définit automatiquement avec le boundary
    // ENDPOINTS.SEND_SEGMENT retourne déjà l'URL complète (via buildTranscriptionUrl)
    const url = ENDPOINTS.SEND_SEGMENT(meetingId)
    
    console.log('📤 Envoi segment audio:', {
      meetingId: meetingId,
      fileName: audioFile.name,
      fileSize: audioFile.size,
      fileType: audioFile.type,
      url: url,
      method: 'POST',
      contentType: 'multipart/form-data (automatique)'
    })
    
    try {
      const response = await fetch(url, {
        method: 'POST',
        body: formData
        // Pas de headers Content-Type, le navigateur le définit automatiquement pour FormData
        // Cela correspond à: curl -X POST ... -F "file=@..."
      })
      
      // Lire le texte de la réponse d'abord
      const responseText = await response.text()
      
      // Vérifier si c'est du JSON valide
      let body
      const contentType = response.headers.get('content-type') || ''
      const isJson = contentType.includes('application/json')
      
      if (isJson && responseText.trim()) {
        try {
          body = JSON.parse(responseText)
        } catch (parseError) {
          // Si le parsing JSON échoue, utiliser le texte (le serveur peut retourner du texte simple)
          console.log('ℹ️ Réponse texte du serveur:', responseText.substring(0, 100))
          body = responseText
        }
      } else {
        body = responseText
      }
      
      if (!response.ok) {
        console.error('❌ Erreur API:', {
          status: response.status,
          statusText: response.statusText,
          url: url,
          body: body
        })
        throw new ApiError(response.status, body?.message || response.statusText || body, body)
      }
      
      // Si la réponse est un message texte de succès, retourner un objet
      if (typeof body === 'string' && response.ok) {
        console.log('✅ Réponse serveur:', body)
        return { message: body, success: true }
      }
      
      return body
    } catch (error) {
      // Si c'est déjà une ApiError, la relancer
      if (error instanceof ApiError) {
        throw error
      }
      console.error('Erreur API:', error)
      throw this.handleError(error)
    }
  }

  /**
   * Sauvegarde des segments transcrits en BDD
   * @param {number} meetingId - ID de la réunion
   * @param {object|array} segments - Segment unique ou tableau de segments
   */
  async saveTranscriptionSegments(meetingId, segments, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    console.log('💾 Sauvegarde segments:', Array.isArray(segments) ? segments.length : 1, 'segment(s)')
    return this.request(ENDPOINTS.SAVE_SEGMENTS(meetingId), {
      method: 'POST',
      headers,
      body: JSON.stringify(segments)
    })
  }

  /**
   * Récupère tous les segments d'une réunion
   * @param {number} meetingId - ID de la réunion
   */
  async getAllSegments(meetingId) {
    console.log('📥 Récupération segments pour réunion:', meetingId)
    return this.request(ENDPOINTS.GET_ALL_SEGMENTS(meetingId), {
      method: 'GET',
      headers: getDefaultHeaders()
    })
  }

  /**
   * Récupère un segment spécifique
   * @param {number} meetingId - ID de la réunion
   * @param {number} segmentId - ID du segment
   */
  async getSegment(meetingId, segmentId) {
    return this.request(ENDPOINTS.GET_SEGMENT(meetingId, segmentId), {
      method: 'GET',
      headers: getDefaultHeaders()
    })
  }

  /**
   * Met à jour le texte d'un segment
   * @param {number} meetingId - ID de la réunion
   * @param {number} segmentId - ID du segment
   * @param {string} texte - Nouveau texte
   */
  async updateSegmentText(meetingId, segmentId, texte, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    console.log('✏️ Mise à jour segment:', segmentId)
    return this.request(ENDPOINTS.UPDATE_SEGMENT(meetingId, segmentId), {
      method: 'PUT',
      headers,
      body: JSON.stringify({ texte })
    })
  }

  /**
   * Met à jour le locuteur d'un segment
   * @param {number} meetingId - ID de la réunion
   * @param {number} segmentId - ID du segment
   * @param {number} participantId - ID du participant/locuteur
   */
  async updateSegmentSpeaker(meetingId, segmentId, participantId, token) {
    const headers = token ? getAuthHeaders(token) : getDefaultHeaders()
    console.log('👤 Attribution locuteur:', participantId, 'au segment:', segmentId)
    return this.request(ENDPOINTS.UPDATE_SEGMENT_SPEAKER(meetingId, segmentId, participantId), {
      method: 'PUT',
      headers
    })
  }

  /**
   * Sauvegarde le fichier audio complet
   * @param {number} meetingId - ID de la réunion
   * @param {File} audioFile - Fichier audio complet
   */
  async saveRecordFile(meetingId, audioFile) {
    const formData = new FormData()
    formData.append('file', audioFile)
    
    console.log('💾 Sauvegarde fichier audio complet:', audioFile.name, 'Taille:', audioFile.size)
    
    // Pour FormData, ne pas inclure Content-Type, le navigateur le définit automatiquement avec le boundary
    // ENDPOINTS.SAVE_RECORD_FILE retourne déjà l'URL complète (via buildTranscriptionUrl)
    const url = ENDPOINTS.SAVE_RECORD_FILE(meetingId)
    
    try {
      const response = await fetch(url, {
        method: 'POST',
        body: formData
        // Pas de headers Content-Type, le navigateur le définit automatiquement pour FormData
      })
      
      // Gérer le parsing de la réponse de manière robuste
      let body
      const contentType = response.headers.get('content-type') || ''
      const isJson = contentType.includes('application/json')
      
      if (isJson) {
        try {
          const text = await response.text()
          // Si la réponse est vide, retourner null
          if (!text || text.trim() === '') {
            body = null
          } else {
            // Essayer de parser en JSON, sinon utiliser le texte brut
            try {
              body = JSON.parse(text)
            } catch (parseError) {
              // Le backend a dit JSON mais a renvoyé du texte brut
              console.warn('⚠️ Content-Type indique JSON mais le contenu est du texte brut:', text)
              body = { message: text, success: true }
            }
          }
        } catch (error) {
          console.warn('⚠️ Erreur lors de la lecture de la réponse:', error)
          body = null
        }
      } else {
        // Content-Type n'est pas JSON, lire comme texte
        body = await response.text()
      }
      
      if (!response.ok) {
        console.error('❌ Erreur API:', {
          status: response.status,
          statusText: response.statusText,
          url: url,
          body: body
        })
        throw new ApiError(response.status, body?.message || response.statusText, body)
      }
      
      return body
    } catch (error) {
      // Si c'est déjà une ApiError, la relancer telle quelle
      if (error instanceof ApiError) {
        throw error
      }
      console.error('Erreur API:', error)
      throw this.handleError(error)
    }
  }

  /**
   * Récupère le nom du fichier audio
   * @param {number} meetingId - ID de la réunion
   */
  async getRecordFileName(meetingId) {
    return this.request(ENDPOINTS.GET_RECORD_FILE(meetingId), {
      method: 'GET',
      headers: getDefaultHeaders()
    })
  }
}

// Instance singleton du service API
export const apiService = new ApiService()

// Export des constantes pour utilisation directe
export { ENDPOINTS, API_CONFIG }
