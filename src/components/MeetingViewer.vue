<template>
  <div class="meeting-viewer">
    <div class="viewer-container">
      <!-- En-tête avec les informations de la réunion -->
      <div class="meeting-header" :class="{ 'meeting-header-completed': meeting.status === 'completed' }">
        <h1 class="meeting-title">
          <svg class="meeting-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
            <line x1="16" y1="2" x2="16" y2="6"/>
            <line x1="8" y1="2" x2="8" y2="6"/>
            <line x1="3" y1="10" x2="21" y2="10"/>
          </svg>
          {{ meeting.title }}
          <svg v-if="meeting.status === 'completed'" class="completed-check-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
            <path d="M20 6L9 17l-5-5"/>
          </svg>
        </h1>
        <div class="meeting-meta">
          <span class="meeting-status status-badge" :class="`status-${meeting.status}`">
            <svg v-if="meeting.status === 'completed'" class="status-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M20 6L9 17l-5-5"/>
            </svg>
            {{ getStatusLabel(meeting.status) }}
          </span>
          <span class="meeting-date">{{ formatDate(meeting.scheduledAt) }}</span>
          <span class="meeting-duration">{{ formatDuration(meeting.durationMinutes) }}</span>
        </div>
        <div v-if="meeting.description" class="meeting-description">
          {{ meeting.description }}
        </div>
      </div>

      <!-- Actions de gestion -->
      <div class="meeting-actions-bar">
        <button 
          v-if="meeting.status === 'scheduled'"
          @click="startMeeting" 
          class="btn btn-primary"
          :disabled="isStarting"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polygon points="5,3 19,12 5,21 5,3"/>
          </svg>
          {{ isStarting ? 'Démarrage...' : 'Démarrer la réunion' }}
        </button>
        <button 
          v-if="meeting.status === 'in_progress'"
          @click="endMeeting" 
          class="btn btn-danger"
          :disabled="isEnding"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="6" y="6" width="12" height="12" rx="2"/>
          </svg>
          {{ isEnding ? 'Clôture...' : 'Clore la réunion' }}
        </button>
        <button 
          v-if="meeting.status !== 'completed'"
          @click="manageParticipants" 
          class="btn btn-secondary"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
            <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
          </svg>
          Gérer les participants
        </button>
        <button 
          @click="triggerFileUpload" 
          class="btn btn-secondary"
          :disabled="isUploadingAudio || isLoading"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
            <polyline points="17 8 12 3 7 8"/>
            <line x1="12" y1="3" x2="12" y2="15"/>
          </svg>
          {{ isUploadingAudio ? 'Envoi en cours...' : 'Envoyer un fichier audio' }}
        </button>
        <input 
          ref="fileInput" 
          type="file" 
          accept="audio/*,.mp3,.wav,.m4a,.aac,.ogg" 
          @change="handleFileSelect" 
          style="display: none"
        />
        <div v-if="meeting.status === 'completed'" class="completed-message">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M20 6L9 17l-5-5"/>
          </svg>
          <span>Cette réunion est terminée. Aucune action n'est disponible.</span>
        </div>
      </div>

      <!-- Contrôles de lecture (affichés seulement si audio disponible) -->
      <div v-if="hasAudio" class="player-controls">
        <button class="btn btn-icon" @click="togglePlay" :disabled="!hasAudio">
          <svg v-if="!isPlaying" viewBox="0 0 24 24" fill="currentColor">
            <path d="M8 5v14l11-7z"/>
          </svg>
          <svg v-else viewBox="0 0 24 24" fill="currentColor">
            <path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>
          </svg>
        </button>
        
        <div class="progress-container">
          <div class="progress-bar" :style="{ width: progress + '%' }"></div>
          <span class="time-current">{{ formatTime(currentTime) }}</span>
          <span class="time-total">{{ formatTime(duration) }}</span>
        </div>
      </div>
      
      <!-- Message si pas d'audio -->
      <div v-else class="no-audio-message">
        <p>Aucun fichier audio disponible pour cette réunion</p>
      </div>

      <!-- Transcription avec recherche et filtres -->
      <div class="transcript-container">
        <h3>Transcription</h3>
        
        <!-- Barre de recherche et filtres -->
        <div class="transcript-filters">
          <!-- Recherche par mot-clé -->
          <div class="filter-group">
            <label class="filter-label">
              <svg class="filter-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="8"/>
                <path d="m21 21-4.35-4.35"/>
              </svg>
              Rechercher un mot-clé :
            </label>
            <div class="search-input-container">
              <input
                type="text"
                v-model="keywordSearch"
                @input="filterSegments"
                class="filter-input"
                placeholder="Tapez un mot ou une phrase..."
              />
              <button 
                v-if="keywordSearch" 
                @click="clearKeywordSearch" 
                class="clear-filter-btn"
              >
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <line x1="18" y1="6" x2="6" y2="18"/>
                  <line x1="6" y1="6" x2="18" y2="18"/>
                </svg>
              </button>
            </div>
          </div>
          
          <!-- Filtre par locuteur -->
          <div class="filter-group" v-if="meeting.participants && meeting.participants.length > 0">
            <label class="filter-label">
              <svg class="filter-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
              </svg>
              Filtrer par personne :
            </label>
            <select v-model="selectedSpeaker" @change="filterSegments" class="filter-select">
              <option value="">Tous les locuteurs</option>
              <option 
                v-for="participant in meeting.participants" 
                :key="participant.id" 
                :value="participant.id"
              >
                {{ participant.fullName }}
              </option>
            </select>
          </div>
        </div>
        
        <!-- Compteur de résultats -->
        <div v-if="keywordSearch || selectedSpeaker" class="results-count">
          {{ filteredSegments.length }} segment{{ filteredSegments.length > 1 ? 's' : '' }} trouvé{{ filteredSegments.length > 1 ? 's' : '' }}
        </div>

        <!-- Liste des segments de transcription -->
        <div v-if="filteredSegments.length > 0" class="transcript-segments">
          <div 
            v-for="(segment, index) in filteredSegments" 
            :key="segment.id || index"
            class="transcript-segment"
            :class="{ 
              'active': isSegmentActive(segment),
              'speaker-1': getSegmentSpeakerId(segment) === 1,
              'speaker-2': getSegmentSpeakerId(segment) === 2,
              'speaker-3': getSegmentSpeakerId(segment) === 3
            }"
            @click="seekTo(segment.timeDepart || segment.startTime)"
          >
            <div class="segment-header">
              <div class="segment-speaker" @click.stop="showSpeakerSelector(segment)">
                <span v-if="getSegmentSpeakerId(segment)" class="speaker-name">
                  {{ getSpeakerName(getSegmentSpeakerId(segment)) }}
                </span>
                <span v-else class="speaker-name unassigned">
                  <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="8" x2="12" y2="12"/>
                    <line x1="12" y1="16" x2="12.01" y2="16"/>
                  </svg>
                  Non attribué
                </span>
                <svg class="edit-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                  <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                </svg>
              </div>
              <div class="segment-time">
                {{ formatTime(segment.timeDepart || segment.startTime) }}
              </div>
            </div>
            <div class="segment-text" v-html="highlightKeyword(segment.texte || segment.text)"></div>
            
            <!-- Menu de sélection de locuteur -->
            <div v-if="selectedSegmentForEdit?.id === segment.id" class="speaker-selector">
              <div class="selector-header">
                <span>Attribuer à :</span>
                <button @click.stop="closeSpeakerSelector" class="close-btn">×</button>
              </div>
              <div class="participant-list">
                <button
                  v-for="participant in meeting.participants"
                  :key="participant.id"
                  @click.stop="assignSpeaker(segment, participant.id)"
                  class="participant-btn"
                  :class="{ active: getSegmentSpeakerId(segment) === participant.id }"
                >
                  {{ participant.fullName }}
                </button>
                <button
                  @click.stop="removeSpeakerAssignment(segment)"
                  class="participant-btn remove-btn"
                  v-if="getSegmentSpeakerId(segment)"
                >
                  Retirer l'attribution
                </button>
              </div>
            </div>
          </div>
        </div>
        <div v-else class="no-segments-message">
          <p v-if="keywordSearch || selectedSpeaker">
            Aucun segment ne correspond à vos critères de recherche.
          </p>
          <p v-else>
            Aucun segment de transcription disponible pour cette réunion.
          </p>
        </div>
      </div>

      <!-- Boutons d'action -->
      <div class="action-buttons">
        <button @click="$emit('back')" class="btn btn-secondary">
          Retour
        </button>
        <button 
          @click="triggerFileUpload" 
          class="btn btn-primary"
          :disabled="isUploadingAudio || isLoading"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 1em; height: 1em; margin-right: 0.5em; vertical-align: middle;">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
            <polyline points="17 8 12 3 7 8"/>
            <line x1="12" y1="3" x2="12" y2="15"/>
          </svg>
          {{ isUploadingAudio ? 'Envoi en cours...' : 'Envoyer un fichier audio' }}
        </button>
        <button 
          v-if="meeting.segments && meeting.segments.length > 0"
          @click="exportTranscript" 
          class="btn btn-primary"
        >
          Exporter la transcription
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { apiService } from '../services/api.js'

export default {
  name: 'MeetingViewer',
  
  props: {
    meetingId: {
      type: [String, Number],
      required: true
    }
  },

  data() {
    return {
      meeting: {
        id: null,
        title: '',
        description: '',
        scheduledAt: null,
        durationMinutes: 0,
        status: 'scheduled',
        participants: [],
        segments: []
      },
      selectedSpeaker: '',
      keywordSearch: '',
      currentTime: 0,
      duration: 0,
      isPlaying: false,
      audioPlayer: null,
      isLoading: true,
      error: null,
      isStarting: false,
      isEnding: false,
      selectedSegmentForEdit: null,
      isAssigningSpeaker: false,
      isUploadingAudio: false
    }
  },

  computed: {
    hasAudio() {
      // Vérifier si un fichier audio est disponible
      return Boolean(this.meeting.audioFile || this.meeting.recordFileUrl || this.meeting.recordFileName)
    },

    progress() {
      return this.duration > 0 ? (this.currentTime / this.duration) * 100 : 0
    },

    filteredSegments() {
      let filtered = [...(this.meeting.segments || [])]
      
      // Filtrer par personne (locuteur)
      if (this.selectedSpeaker) {
        filtered = filtered.filter(s => {
          const speakerId = s.locuteur?.id || s.locuteurId || s.speakerId
          return speakerId == this.selectedSpeaker
        })
      }
      
      // Filtrer par mot-clé
      if (this.keywordSearch.trim()) {
        const keyword = this.keywordSearch.trim().toLowerCase()
        filtered = filtered.filter(s => {
          const text = (s.texte || s.text || '').toLowerCase()
          return text.includes(keyword)
        })
      }
      
      return filtered
    }
  },

  async created() {
    await this.fetchMeetingData()
  },

  beforeDestroy() {
    if (this.audioPlayer) {
      this.audioPlayer.pause()
      this.audioPlayer.removeEventListener('timeupdate', this.updateProgress)
      this.audioPlayer.removeEventListener('loadedmetadata', this.setDuration)
      this.audioPlayer.removeEventListener('ended', this.onAudioEnd)
    }
  },

  methods: {
    async fetchMeetingData() {
      this.isLoading = true
      this.error = null
      
      try {
        // Vider le cache pour cette réunion spécifique pour avoir les données à jour
        try {
          const { cacheService } = await import('../services/cacheService.js')
          const { ENDPOINTS } = await import('../config/api.js')
          const meetingUrl = ENDPOINTS.GET_MEETING(this.meetingId)
          const cacheKey = `GET:${meetingUrl}`
          await cacheService.delete(cacheKey)
          console.log('🗑️ Cache vidé pour la réunion:', this.meetingId, 'Clé:', cacheKey)
        } catch (cacheError) {
          console.warn('⚠️ Erreur lors du vidage du cache:', cacheError)
        }
        
        // Charger les données de la réunion depuis l'API
        const meetingResponse = await apiService.getMeetingById(this.meetingId)
        console.log('📥 Réponse API réunion:', meetingResponse)
        console.log('📊 Statut de la réunion:', meetingResponse?.status)
        
        // Charger les segments de transcription depuis le service de transcription
        let segments = []
        try {
          const segmentsResponse = await apiService.getAllSegments(this.meetingId)
          segments = Array.isArray(segmentsResponse) ? segmentsResponse : []
          console.log('📥 Segments chargés:', segments.length)
        } catch (err) {
          console.warn('⚠️ Impossible de charger les segments de transcription:', err)
          segments = meetingResponse?.segments || []
        }
        
        // Préserver explicitement le statut de la réunion
        const meetingStatus = meetingResponse?.status || 'scheduled'
        console.log('✅ Statut préservé:', meetingStatus)
        
        this.meeting = {
          ...meetingResponse,
          status: meetingStatus, // S'assurer que le statut est explicitement défini
          segments: segments
        }
        
        console.log('📋 Meeting final:', this.meeting)
        console.log('📊 Statut final du meeting:', this.meeting.status)
        console.log('🔍 Condition bouton upload:', {
          meetingExists: !!this.meeting,
          status: this.meeting.status,
          isNotCompleted: this.meeting.status !== 'completed',
          isLoading: this.isLoading,
          shouldShowButton: this.meeting && this.meeting.status !== 'completed' && !this.isLoading
        })
        
        // Charger les participants
        try {
          const participantsResponse = await apiService.getParticipantsByMeeting(this.meetingId)
          this.meeting.participants = Array.isArray(participantsResponse) ? participantsResponse : []
        } catch (err) {
          console.warn('Impossible de charger les participants:', err)
          this.meeting.participants = []
        }
        
        this.isLoading = false
        this.initializeAudioPlayer()
      } catch (error) {
        console.error('Erreur lors du chargement de la réunion:', error)
        this.error = error?.message || 'Impossible de charger les détails de la réunion. Veuillez réessayer plus tard.'
        this.isLoading = false
      }
    },
    
    async startMeeting() {
      if (this.isStarting) return
      
      this.isStarting = true
      try {
        const response = await apiService.startMeeting(this.meetingId)
        this.meeting = response
        alert('✅ Réunion démarrée avec succès !')
      } catch (error) {
        console.error('Erreur lors du démarrage:', error)
        alert(error?.message || '❌ Erreur lors du démarrage de la réunion')
      } finally {
        this.isStarting = false
      }
    },
    
    async endMeeting() {
      if (this.isEnding) return
      if (!confirm('Êtes-vous sûr de vouloir clore cette réunion ?')) {
        return
      }
      
      this.isEnding = true
      try {
        const response = await apiService.endMeeting(this.meetingId)
        this.meeting = response
        alert('✅ Réunion clôturée avec succès !')
      } catch (error) {
        console.error('Erreur lors de la clôture:', error)
        alert(error?.message || '❌ Erreur lors de la clôture de la réunion')
      } finally {
        this.isEnding = false
      }
    },
    
    manageParticipants() {
      this.$emit('manage-participants', this.meetingId)
    },
    
    filterSegments() {
      // La computed property filteredSegments se met à jour automatiquement
      // Cette méthode est appelée pour forcer la réactivité si nécessaire
    },
    
    clearKeywordSearch() {
      this.keywordSearch = ''
    },
    
    highlightKeyword(text) {
      if (!this.keywordSearch.trim() || !text) {
        return text || ''
      }
      
      const keyword = this.keywordSearch.trim()
      const regex = new RegExp(`(${keyword})`, 'gi')
      return (text || '').replace(regex, '<mark>$1</mark>')
    },

    async initializeAudioPlayer() {
      if (!this.hasAudio) return
      
      try {
        // Essayer de récupérer le fichier audio depuis l'API
        const audioUrl = this.meeting.audioFile ||
                         this.meeting.recordFileUrl ||
                         this.meeting.recordFileName
        
        if (audioUrl) {
          this.audioPlayer = new Audio(audioUrl)
          this.audioPlayer.addEventListener('timeupdate', this.updateProgress)
          this.audioPlayer.addEventListener('loadedmetadata', this.setDuration)
          this.audioPlayer.addEventListener('ended', this.onAudioEnd)
        }
      } catch (error) {
        console.warn('Impossible de charger le fichier audio:', error)
      }
    },

    togglePlay() {
      if (!this.audioPlayer) return
      
      if (this.isPlaying) {
        this.audioPlayer.pause()
      } else {
        this.audioPlayer.play()
      }
      this.isPlaying = !this.isPlaying
    },

    updateProgress() {
      this.currentTime = this.audioPlayer.currentTime
    },

    setDuration() {
      this.duration = this.audioPlayer.duration
    },

    onAudioEnd() {
      this.isPlaying = false
      this.currentTime = 0
    },

    seekTo(time) {
      if (!this.audioPlayer) return
      this.audioPlayer.currentTime = time
      if (!this.isPlaying) {
        this.audioPlayer.play()
        this.isPlaying = true
      }
    },

    isSegmentActive(segment) {
      const startTime = segment.timeDepart || segment.startTime || 0
      const endTime = segment.timeEnd || segment.endTime || 0
      return this.currentTime >= startTime && this.currentTime <= endTime
    },
    
    getSegmentSpeakerId(segment) {
      // Le backend peut retourner locuteur.id ou locuteurId
      return segment.locuteur?.id || segment.locuteurId || segment.speakerId || 0
    },

    getSpeakerName(speakerId) {
      if (!speakerId) return 'Non attribué'
      const speaker = this.meeting.participants.find(p => p.id === speakerId)
      return speaker ? speaker.fullName : `Locuteur ${speakerId}`
    },
    
    showSpeakerSelector(segment) {
      if (this.selectedSegmentForEdit?.id === segment.id) {
        this.selectedSegmentForEdit = null
      } else {
        this.selectedSegmentForEdit = segment
      }
    },
    
    closeSpeakerSelector() {
      this.selectedSegmentForEdit = null
    },
    
    async assignSpeaker(segment, participantId) {
      if (this.isAssigningSpeaker) return
      
      this.isAssigningSpeaker = true
      try {
        await apiService.updateSegmentSpeaker(this.meetingId, segment.id, participantId)
        
        // Mettre à jour le segment localement
        const segmentIndex = this.meeting.segments.findIndex(s => s.id === segment.id)
        if (segmentIndex !== -1) {
          this.meeting.segments[segmentIndex].locuteurId = participantId
          this.meeting.segments[segmentIndex].locuteur = { id: participantId }
        }
        
        this.selectedSegmentForEdit = null
        console.log('✅ Locuteur attribué avec succès')
      } catch (error) {
        console.error('❌ Erreur lors de l\'attribution du locuteur:', error)
        alert('Erreur lors de l\'attribution : ' + (error?.message || 'Erreur inconnue'))
      } finally {
        this.isAssigningSpeaker = false
      }
    },
    
    async removeSpeakerAssignment(segment) {
      if (this.isAssigningSpeaker) return
      
      this.isAssigningSpeaker = true
      try {
        // Pour retirer l'attribution, on peut soit envoyer null, soit utiliser un endpoint spécifique
        // Pour l'instant, on met simplement à jour localement
        const segmentIndex = this.meeting.segments.findIndex(s => s.id === segment.id)
        if (segmentIndex !== -1) {
          this.meeting.segments[segmentIndex].locuteurId = null
          this.meeting.segments[segmentIndex].locuteur = null
        }
        
        this.selectedSegmentForEdit = null
        console.log('✅ Attribution retirée')
      } catch (error) {
        console.error('❌ Erreur lors de la suppression de l\'attribution:', error)
        alert('Erreur lors de la suppression : ' + (error?.message || 'Erreur inconnue'))
      } finally {
        this.isAssigningSpeaker = false
      }
    },

    formatDate(dateString) {
      if (!dateString) return 'Date non définie'
      const date = new Date(dateString)
      const options = { 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric', 
        hour: '2-digit', 
        minute: '2-digit' 
      }
      return date.toLocaleDateString('fr-FR', options)
    },
    
    getStatusLabel(status) {
      const labels = {
        'scheduled': 'Planifiée',
        'in_progress': 'En cours',
        'completed': 'Terminée',
        'cancelled': 'Annulée',
        'postponed': 'Reportée'
      }
      return labels[status] || status
    },

    formatTime(seconds) {
      if (isNaN(seconds)) return '00:00'
      const mins = Math.floor(seconds / 60)
      const secs = Math.floor(seconds % 60)
      return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
    },

    formatDuration(minutes) {
      const hours = Math.floor(minutes / 60)
      const mins = minutes % 60
      if (hours > 0) {
        return `${hours}h${mins > 0 ? ` ${mins}min` : ''}`
      }
      return `${mins} min`
    },

    triggerFileUpload() {
      // Debug: vérifier le statut
      console.log('🔍 triggerFileUpload appelé', {
        meetingId: this.meetingId,
        meetingStatus: this.meeting?.status,
        isLoading: this.isLoading,
        hasFileInput: !!this.$refs.fileInput
      })
      
      // Déclencher le sélecteur de fichier
      if (this.$refs.fileInput) {
        this.$refs.fileInput.click()
      } else {
        console.error('❌ fileInput ref non trouvé')
        alert('Erreur: impossible d\'accéder au sélecteur de fichier')
      }
    },

    async handleFileSelect(event) {
      const file = event.target.files?.[0]
      if (!file) return

      // Vérifier que c'est un fichier audio
      if (!file.type.startsWith('audio/') && !file.name.match(/\.(mp3|wav|m4a|aac|ogg)$/i)) {
        alert('Veuillez sélectionner un fichier audio (MP3, WAV, M4A, AAC, OGG)')
        return
      }

      // Vérifier la taille du fichier (par exemple, max 100MB)
      const maxSize = 100 * 1024 * 1024 // 100MB
      if (file.size > maxSize) {
        alert(`Le fichier est trop volumineux. Taille maximale : ${(maxSize / 1024 / 1024).toFixed(0)}MB`)
        return
      }

      this.isUploadingAudio = true
      
      try {
        console.log('📤 Envoi fichier audio manuel:', {
          fileName: file.name,
          fileSize: `${(file.size / 1024 / 1024).toFixed(2)} MB`,
          fileType: file.type,
          meetingId: this.meetingId
        })

        await apiService.sendAudioSegment(this.meetingId, file)
        
        console.log('✅ Fichier audio envoyé avec succès')
        alert(`✅ Fichier "${file.name}" envoyé avec succès pour transcription`)
        
        // Rafraîchir les données de la réunion pour voir les nouveaux segments
        await this.fetchMeetingData()
        
        // Réinitialiser l'input file
        if (this.$refs.fileInput) {
          this.$refs.fileInput.value = ''
        }
      } catch (error) {
        console.error('❌ Erreur lors de l\'envoi du fichier audio:', error)
        alert(`❌ Erreur lors de l'envoi du fichier : ${error?.message || 'Erreur inconnue'}`)
      } finally {
        this.isUploadingAudio = false
      }
    },

    exportTranscript() {
      // Implémentez l'exportation de la transcription (PDF, TXT, etc.)
      alert('Fonction d\'exportation à implémenter')
    }
  }
}
</script>

<style scoped>
.meeting-viewer {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem 1rem;
  color: #333;
}

.viewer-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  padding: 2rem;
}

.meeting-header {
  text-align: center;
  margin-bottom: 2rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid #eee;
}

.meeting-title {
  font-size: 1.8rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.meeting-icon {
  width: 1.5em;
  height: 1.5em;
}

.meeting-meta {
  color: #7f8c8d;
  font-size: 0.95rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
  justify-content: center;
}

.meeting-description {
  margin-top: 1rem;
  color: #555;
  font-size: 1rem;
  line-height: 1.6;
  max-width: 800px;
  margin-left: auto;
  margin-right: auto;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
}

.status-scheduled {
  background: #e3f2fd;
  color: #1976d2;
}

.status-in_progress {
  background: #fff3e0;
  color: #f57c00;
}

.status-completed {
  background: #e8f5e9;
  color: #388e3c;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.status-icon {
  width: 14px;
  height: 14px;
}

.meeting-header-completed {
  background: linear-gradient(135deg, rgba(232, 245, 233, 0.3) 0%, rgba(200, 230, 201, 0.2) 100%);
  border: 2px solid #c8e6c9;
  border-radius: 12px;
  padding: 2rem;
  margin-bottom: 2rem;
}

.meeting-header-completed .meeting-title {
  color: #388e3c;
}

.completed-check-icon {
  width: 1.2em;
  height: 1.2em;
  color: #4caf50;
  margin-left: 0.5rem;
  vertical-align: middle;
}

.status-cancelled {
  background: #ffebee;
  color: #d32f2f;
}

.meeting-actions-bar {
  display: flex;
  gap: 1rem;
  justify-content: center;
  align-items: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.completed-message {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 1.5rem;
  background: #e8f5e9;
  color: #388e3c;
  border-radius: 8px;
  font-weight: 500;
  border: 2px solid #c8e6c9;
}

.completed-message svg {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

.btn-danger {
  background-color: #e74c3c;
  color: white;
}

.btn-danger:hover:not(:disabled) {
  background-color: #c0392b;
}

.no-audio-message {
  text-align: center;
  padding: 2rem;
  background: #f8f9fa;
  border-radius: 8px;
  margin-bottom: 2rem;
  color: #6b7280;
}

.player-controls {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 2rem;
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 8px;
}

.btn-icon {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #3498db;
  transition: background-color 0.2s;
}

.btn-icon:hover {
  background-color: rgba(52, 152, 219, 0.1);
}

.btn-icon:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-icon svg {
  width: 24px;
  height: 24px;
}

.progress-container {
  flex: 1;
  position: relative;
  height: 4px;
  background: #e0e0e0;
  border-radius: 2px;
  margin: 0 1rem;
  cursor: pointer;
}

.progress-bar {
  position: absolute;
  top: 0;
  left: 0;
  height: 100%;
  background: #3498db;
  border-radius: 2px;
  transition: width 0.1s linear;
}

.time-current,
.time-total {
  position: absolute;
  top: 10px;
  font-size: 0.75rem;
  color: #7f8c8d;
}

.time-current {
  left: 0;
  transform: translateY(100%);
}

.time-total {
  right: 0;
  transform: translateY(100%);
}

.transcript-container {
  margin-top: 2rem;
}

.transcript-container h3 {
  font-size: 1.3rem;
  color: #2c3e50;
  margin-bottom: 1.5rem;
  padding-bottom: 0.75rem;
  border-bottom: 2px solid #3498db;
  display: inline-block;
}

.transcript-filters {
  background: #f8fafc;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  display: flex;
  gap: 1.5rem;
  flex-wrap: wrap;
  align-items: flex-end;
}

.filter-group {
  flex: 1;
  min-width: 250px;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.filter-label {
  font-weight: 500;
  color: #374151;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.filter-icon {
  width: 18px;
  height: 18px;
  color: #6366f1;
}

.search-input-container {
  position: relative;
  display: flex;
  align-items: center;
}

.filter-input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid #e5e7eb;
  border-radius: 0.5rem;
  font-size: 0.95rem;
  transition: all 0.3s ease;
}

.filter-input:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgb(99 102 241 / 0.1);
}

.clear-filter-btn {
  position: absolute;
  right: 0.5rem;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  color: #6b7280;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 0.25rem;
  transition: all 0.2s;
}

.clear-filter-btn:hover {
  background: #f3f4f6;
  color: #374151;
}

.clear-filter-btn svg {
  width: 16px;
  height: 16px;
}

.filter-select {
  padding: 0.75rem 1rem;
  border: 2px solid #e5e7eb;
  border-radius: 0.5rem;
  background-color: white;
  font-size: 0.95rem;
  color: #2c3e50;
  cursor: pointer;
  transition: all 0.3s ease;
}

.filter-select:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgb(99 102 241 / 0.1);
}

.results-count {
  margin-bottom: 1rem;
  padding: 0.75rem 1rem;
  background: #e0e7ff;
  border-left: 4px solid #6366f1;
  border-radius: 0.5rem;
  color: #4338ca;
  font-weight: 500;
  font-size: 0.9rem;
}

.no-segments-message {
  text-align: center;
  padding: 3rem 2rem;
  color: #6b7280;
  background: #f8fafc;
  border-radius: 8px;
  border: 1px dashed #d1d5db;
}

.transcript-segments {
  max-height: 500px;
  overflow-y: auto;
  padding-right: 0.5rem;
  margin-bottom: 2rem;
  border: 1px solid #eee;
  border-radius: 8px;
  padding: 1rem;
}

.transcript-segment {
  margin-bottom: 1.5rem;
  padding: 1rem;
  border-radius: 8px;
  transition: background-color 0.2s, transform 0.1s;
  cursor: pointer;
  position: relative;
  border-left: 3px solid transparent;
}

.transcript-segment:hover {
  background-color: #f8f9fa;
}

.transcript-segment.active {
  background-color: #e8f4fd;
  border-left-color: #3498db;
  transform: translateX(4px);
}

.segment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.segment-speaker {
  font-weight: 600;
  color: #2c3e50;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  transition: all 0.2s;
  user-select: none;
}

.segment-speaker:hover {
  background-color: rgba(52, 152, 219, 0.1);
}

.speaker-name {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.speaker-name.unassigned {
  color: #e74c3c;
  font-style: italic;
}

.speaker-name.unassigned .icon {
  width: 14px;
  height: 14px;
}

.edit-icon {
  width: 14px;
  height: 14px;
  opacity: 0.5;
  transition: opacity 0.2s;
}

.segment-speaker:hover .edit-icon {
  opacity: 1;
}

.segment-speaker::before {
  content: '';
  display: inline-block;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: #3498db;
}

.speaker-1 .segment-speaker::before { background-color: #3498db; }
.speaker-2 .segment-speaker::before { background-color: #2ecc71; }
.speaker-3 .segment-speaker::before { background-color: #e74c3c; }
.speaker-4 .segment-speaker::before { background-color: #9b59b6; }

.segment-text {
  line-height: 1.6;
  color: #34495e;
  margin-bottom: 0.5rem;
}

.segment-text mark {
  background: #fef08a;
  color: #92400e;
  padding: 0.1rem 0.2rem;
  border-radius: 0.25rem;
  font-weight: 600;
}

.segment-time {
  font-size: 0.8rem;
  color: #7f8c8d;
  font-weight: 500;
}

.speaker-selector {
  margin-top: 0.75rem;
  padding: 1rem;
  background: #f8f9fa;
  border: 2px solid #3498db;
  border-radius: 8px;
  animation: slideDown 0.2s ease-out;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.selector-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
  font-weight: 600;
  color: #2c3e50;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  color: #7f8c8d;
  cursor: pointer;
  padding: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.2s;
}

.close-btn:hover {
  background-color: rgba(0, 0, 0, 0.1);
  color: #2c3e50;
}

.participant-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.participant-btn {
  padding: 0.75rem 1rem;
  border: 2px solid #e5e7eb;
  border-radius: 6px;
  background: white;
  cursor: pointer;
  text-align: left;
  font-size: 0.95rem;
  color: #2c3e50;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.participant-btn:hover {
  background-color: #f3f4f6;
  border-color: #3498db;
}

.participant-btn.active {
  background-color: #e8f4fd;
  border-color: #3498db;
  font-weight: 600;
}

.participant-btn.active::before {
  content: '✓';
  color: #3498db;
  font-weight: bold;
}

.participant-btn.remove-btn {
  border-color: #e74c3c;
  color: #e74c3c;
}

.participant-btn.remove-btn:hover {
  background-color: #fde8e8;
  border-color: #c0392b;
}

.action-buttons {
  display: flex;
  justify-content: space-between;
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid #eee;
}

.btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.btn-primary {
  background-color: #3498db;
  color: white;
}

.btn-primary:hover {
  background-color: #2980b9;
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.btn-secondary {
  background-color: #f1f1f1;
  color: #2c3e50;
}

.btn-secondary:hover {
  background-color: #e0e0e0;
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* Styles pour le chargement et les états vides */
.loading-state,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem 2rem;
  text-align: center;
  color: #7f8c8d;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid rgba(52, 152, 219, 0.3);
  border-radius: 50%;
  border-top-color: #3498db;
  animation: spin 1s ease-in-out infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-state {
  background-color: #fde8e8;
  border-left: 4px solid #e74c3c;
  padding: 1rem;
  margin: 1rem 0;
  border-radius: 4px;
  color: #c0392b;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.error-icon {
  width: 24px;
  height: 24px;
  color: #e74c3c;
}

/* Styles responsifs */
@media (max-width: 768px) {
  .meeting-viewer {
    padding: 1rem 0.5rem;
  }
  
  .viewer-container {
    padding: 1rem;
  }
  
  .meeting-title {
    font-size: 1.5rem;
  }
  
  .player-controls {
    flex-direction: column;
    align-items: stretch;
    gap: 0.5rem;
  }
  
  .progress-container {
    margin: 0.5rem 0;
  }
  
  .action-buttons {
    flex-direction: column;
    gap: 1rem;
  }
  
  .btn {
    width: 100%;
  }
}
</style>
