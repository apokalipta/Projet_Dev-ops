// Service API pour Transcript IA
import { API_CONFIG, buildApiUrl, getDefaultHeaders, getAuthHeaders, ENDPOINTS } from '../config/api.js'
import { ERROR_MESSAGES } from '../config/constants.js'

class ApiService {
  constructor() {
    this.baseURL = API_CONFIG.BASE_URL
    this.timeout = API_CONFIG.TIMEOUTS.DEFAULT
  }

  // Méthode générique pour les requêtes HTTP
  async request(endpoint, options = {}) {
    const url = endpoint.startsWith('http') ? endpoint : `${this.baseURL}${endpoint}`
    
    const defaultOptions = {
      headers: getDefaultHeaders(),
      timeout: this.timeout,
      ...options
    }

    try {
      const response = await fetch(url, defaultOptions)
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`)
      }
      
      const contentType = response.headers.get('content-type')
      if (contentType && contentType.includes('application/json')) {
        return await response.json()
      }
      
      return await response.text()
    } catch (error) {
      console.error('Erreur API:', error)
      throw this.handleError(error)
    }
  }

  // Gestion des erreurs
  handleError(error) {
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
    return this.request(ENDPOINTS.ALL_MEETINGS, {
      method: 'GET',
      headers: getAuthHeaders(token)
    })
  }

  async getMeetingById(id, token) {
    return this.request(`/meetings/${id}`, {
      method: 'GET',
      headers: getAuthHeaders(token)
    })
  }

  async createMeeting(meetingData, token) {
    return this.request(ENDPOINTS.CREATE_MEETING, {
      method: 'POST',
      headers: getAuthHeaders(token),
      body: JSON.stringify(meetingData)
    })
  }

  async updateMeeting(id, meetingData, token) {
    return this.request(`/meetings/${id}`, {
      method: 'PUT',
      headers: getAuthHeaders(token),
      body: JSON.stringify(meetingData)
    })
  }

  async deleteMeeting(id, token) {
    return this.request(`/meetings/${id}`, {
      method: 'DELETE',
      headers: getAuthHeaders(token)
    })
  }

  // Méthodes pour la transcription
  async startTranscription(meetingId, token) {
    return this.request(ENDPOINTS.START_TRANSCRIPTION, {
      method: 'POST',
      headers: getAuthHeaders(token),
      body: JSON.stringify({ meetingId })
    })
  }

  async stopTranscription(meetingId, token) {
    return this.request(ENDPOINTS.STOP_TRANSCRIPTION, {
      method: 'POST',
      headers: getAuthHeaders(token),
      body: JSON.stringify({ meetingId })
    })
  }

  async getTranscriptionStatus(meetingId, token) {
    return this.request(`${ENDPOINTS.GET_TRANSCRIPTION_STATUS}?meetingId=${meetingId}`, {
      method: 'GET',
      headers: getAuthHeaders(token)
    })
  }

  async getTranscriptionById(id, token) {
    return this.request(`/transcription/${id}`, {
      method: 'GET',
      headers: getAuthHeaders(token)
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
