<template>
  <div class="meeting-viewer">
    <div class="viewer-container">
      <!-- En-tête avec les informations de la réunion -->
      <div class="meeting-header">
        <h1 class="meeting-title">
          <svg class="meeting-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
            <line x1="16" y1="2" x2="16" y2="6"/>
            <line x1="8" y1="2" x2="8" y2="6"/>
            <line x1="3" y1="10" x2="21" y2="10"/>
          </svg>
          {{ meeting.title }}
        </h1>
        <div class="meeting-meta">
          <span class="meeting-date">{{ formatDate(meeting.date) }}</span>
          <span class="meeting-duration">{{ formatDuration(meeting.duration) }}</span>
        </div>
      </div>

      <!-- Contrôles de lecture -->
      <div class="player-controls">
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

      <!-- Transcription avec sélection du locuteur -->
      <div class="transcript-container">
        <h3>Transcription</h3>
        
        <!-- Sélecteur de locuteur -->
        <div class="speaker-selector" v-if="meeting.participants && meeting.participants.length > 0">
          <label>Filtrer par locuteur :</label>
          <select v-model="selectedSpeaker" class="form-select">
            <option value="">Tous les locuteurs</option>
            <option 
              v-for="participant in meeting.participants" 
              :key="participant.id" 
              :value="participant.id"
            >
              {{ participant.name }}
            </option>
          </select>
        </div>

        <!-- Liste des segments de transcription -->
        <div class="transcript-segments">
          <div 
            v-for="(segment, index) in filteredSegments" 
            :key="index"
            class="transcript-segment"
            :class="{ 
              'active': isSegmentActive(segment),
              'speaker-1': segment.speakerId === 1,
              'speaker-2': segment.speakerId === 2,
              'speaker-3': segment.speakerId === 3
            }"
            @click="seekTo(segment.startTime)"
          >
            <div class="segment-speaker">
              {{ getSpeakerName(segment.speakerId) }}
            </div>
            <div class="segment-text">
              {{ segment.text }}
            </div>
            <div class="segment-time">
              {{ formatTime(segment.startTime) }}
            </div>
          </div>
        </div>
      </div>

      <!-- Boutons d'action -->
      <div class="action-buttons">
        <button @click="$emit('back')" class="btn btn-secondary">
          Retour
        </button>
        <button @click="exportTranscript" class="btn btn-primary">
          Exporter la transcription
        </button>
      </div>
    </div>
  </div>
</template>

<script>
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
        date: new Date(),
        duration: 0,
        audioFile: null,
        participants: [],
        segments: []
      },
      selectedSpeaker: '',
      currentTime: 0,
      duration: 0,
      isPlaying: false,
      audioPlayer: null,
      isLoading: true,
      error: null
    }
  },

  computed: {
    hasAudio() {
      return !!this.meeting.audioFile
    },

    progress() {
      return this.duration > 0 ? (this.currentTime / this.duration) * 100 : 0
    },

    filteredSegments() {
      if (!this.selectedSpeaker) return this.meeting.segments
      return this.meeting.segments.filter(s => s.speakerId == this.selectedSpeaker)
    }
  },

  created() {
    this.fetchMeetingData()
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
        // Ici, vous devrez appeler votre API pour récupérer les données de la réunion
        // Exemple: const response = await apiService.getMeeting(this.meetingId)
        // this.meeting = response.data
        
        // Données factices pour l'exemple
        setTimeout(() => {
          this.meeting = {
            id: this.meetingId,
            title: 'Réunion du projet X',
            date: new Date(),
            duration: 3600, // en secondes
            audioFile: '/path/to/audio.mp3',
            participants: [
              { id: 1, name: 'Jean Dupont', role: 'Chef de projet' },
              { id: 2, name: 'Marie Martin', role: 'Développeuse' },
              { id: 3, name: 'Pierre Durand', role: 'Designer' }
            ],
            segments: [
              { 
                id: 1,
                speakerId: 1,
                startTime: 0,
                endTime: 15,
                text: "Bonjour à tous, bienvenue à cette réunion de suivi du projet X."
              },
              { 
                id: 2,
                speakerId: 2,
                startTime: 16,
                endTime: 30,
                text: "Bonjour Jean, merci. Je vais commencer par faire le point sur l'avancement technique."
              },
              // Ajoutez plus de segments de test si nécessaire
            ]
          }
          this.isLoading = false
          this.initializeAudioPlayer()
        }, 1000)
        
      } catch (error) {
        console.error('Erreur lors du chargement de la réunion:', error)
        this.error = 'Impossible de charger les détails de la réunion. Veuillez réessayer plus tard.'
        this.isLoading = false
      }
    },

    initializeAudioPlayer() {
      if (!this.hasAudio) return
      
      this.audioPlayer = new Audio(this.meeting.audioFile)
      this.audioPlayer.addEventListener('timeupdate', this.updateProgress)
      this.audioPlayer.addEventListener('loadedmetadata', this.setDuration)
      this.audioPlayer.addEventListener('ended', this.onAudioEnd)
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
      return this.currentTime >= segment.startTime && this.currentTime <= segment.endTime
    },

    getSpeakerName(speakerId) {
      const speaker = this.meeting.participants.find(p => p.id === speakerId)
      return speaker ? speaker.name : `Locuteur ${speakerId}`
    },

    formatDate(dateString) {
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
}

.meeting-meta span:not(:last-child)::after {
  content: '•';
  margin: 0 0.5rem;
  color: #bdc3c7;
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

.speaker-selector {
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.speaker-selector label {
  font-weight: 500;
  color: #2c3e50;
}

.form-select {
  padding: 0.5rem 1rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  background-color: white;
  font-size: 0.95rem;
  color: #2c3e50;
  min-width: 200px;
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

.segment-speaker {
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: #2c3e50;
  display: flex;
  align-items: center;
  gap: 0.5rem;
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

.segment-time {
  font-size: 0.8rem;
  color: #7f8c8d;
  text-align: right;
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
  
  .speaker-selector {
    flex-direction: column;
    align-items: flex-start;
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
