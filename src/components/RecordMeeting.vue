<template>
  <div class="record-meeting">
    <div class="record-container">
      <!-- En-tête avec informations de la réunion -->
      <div class="record-header">
        <div class="meeting-info-bar">
          <h1 class="meeting-title">{{ meeting.title }}</h1>
          <div class="status-badge" :class="getStatusBadgeClass()">
            <span v-if="isRecording" class="recording-dot"></span>
            {{ getStatusText() }}
          </div>
        </div>
        <p class="meeting-meta">{{ formatDate(meeting.scheduledAt) }} • {{ meeting.participants?.length || 0 }} participants</p>
      </div>

      <!-- Contrôles d'enregistrement principaux -->
      <div class="recording-controls">
        <div class="timer-display">
          <svg class="timer-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="10"/>
            <polyline points="12,6 12,12 16,14"/>
          </svg>
          <span class="timer-text">{{ formattedTime }}</span>
        </div>

        <!-- Boutons de contrôle -->
        <div class="control-buttons">
          <button 
            v-if="!isRecording && !isPaused" 
            @click="startRecording" 
            class="btn-control btn-start"
            :disabled="isProcessing"
          >
            <svg viewBox="0 0 24 24" fill="currentColor">
              <circle cx="12" cy="12" r="10"/>
            </svg>
            <span>Démarrer l'enregistrement</span>
          </button>

          <button 
            v-if="isRecording" 
            @click="pauseRecording" 
            class="btn-control btn-pause"
          >
            <svg viewBox="0 0 24 24" fill="currentColor">
              <rect x="6" y="4" width="4" height="16"/>
              <rect x="14" y="4" width="4" height="16"/>
            </svg>
            <span>Pause</span>
          </button>

          <button 
            v-if="isPaused" 
            @click="resumeRecording" 
            class="btn-control btn-resume"
          >
            <svg viewBox="0 0 24 24" fill="currentColor">
              <polygon points="5,3 19,12 5,21"/>
            </svg>
            <span>Reprendre</span>
          </button>

          <button 
            v-if="isRecording || isPaused" 
            @click="stopRecording" 
            class="btn-control btn-stop"
            :disabled="isProcessing"
          >
            <svg viewBox="0 0 24 24" fill="currentColor">
              <rect x="6" y="6" width="12" height="12" rx="2"/>
            </svg>
            <span>Terminer l'enregistrement</span>
          </button>
        </div>

        <!-- Indicateurs visuels -->
        <div class="audio-visualizer" v-if="isRecording">
          <div class="wave-bar" v-for="i in 20" :key="i" :style="{ animationDelay: `${i * 0.05}s` }"></div>
        </div>
      </div>

      <!-- Participants de la réunion -->
      <div class="participants-panel">
        <h3 class="panel-title">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
            <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
          </svg>
          Participants ({{ participants.length }})
        </h3>
        <div class="participants-list">
          <div v-for="participant in participants" :key="participant.id" class="participant-item">
            <div class="participant-avatar">
              {{ getInitials(participant.fullName) }}
            </div>
            <div class="participant-info">
              <span class="participant-name">{{ participant.fullName }}</span>
              <span class="participant-email">{{ participant.email }}</span>
            </div>
          </div>
          <div v-if="participants.length === 0" class="no-participants">
            Aucun participant
          </div>
        </div>
      </div>

      <!-- Notes et transcription en direct -->
      <div class="notes-panel">
        <h3 class="panel-title">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
            <polyline points="14,2 14,8 20,8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
            <polyline points="10,9 9,9 8,9"/>
          </svg>
          Notes de réunion
        </h3>
        <textarea 
          v-model="notes" 
          class="notes-textarea"
          placeholder="Prenez des notes pendant la réunion..."
        ></textarea>
      </div>

      <!-- Boutons d'action -->
      <div class="action-buttons">
        <button @click="goBack" class="btn btn-secondary" :disabled="isRecording">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="19" y1="12" x2="5" y2="12"/>
            <polyline points="12,19 5,12 12,5"/>
          </svg>
          Retour
        </button>
        <button @click="endMeeting" class="btn btn-danger" :disabled="isRecording || isProcessing">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="6" y="6" width="12" height="12" rx="2"/>
          </svg>
          Clore la réunion
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { apiService } from '../services/api.js'

// Variable pour stocker lamejs une fois chargé
let lamejsModule = null

export default {
  name: 'RecordMeeting',
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
        scheduledAt: null,
        participants: []
      },
      participants: [],
      isRecording: false,
      isPaused: false,
      isProcessing: false,
      recordingTime: 0,
      timerInterval: null,
      audioChunks: [],
      notes: '',
      stream: null,
      segmentCounter: 0, // Compteur pour incrémenter les segments
      audioContext: null,
      mediaStreamSource: null,
      scriptProcessor: null,
      mp3Encoder: null,
      mp3Data: [],
      sampleRate: 44100,
      numChannels: 1
    }
  },
  computed: {
    formattedTime() {
      const hours = Math.floor(this.recordingTime / 3600)
      const minutes = Math.floor((this.recordingTime % 3600) / 60)
      const seconds = this.recordingTime % 60
      
      if (hours > 0) {
        return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
      }
      return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
    }
  },
  async mounted() {
    await this.loadMeetingData()
    
    // Ajouter un listener pour détecter la fermeture de la page
    window.addEventListener('beforeunload', this.handlePageUnload)
  },
  beforeUnmount() {
    this.cleanup()
    this.autoEndMeeting()
    window.removeEventListener('beforeunload', this.handlePageUnload)
  },
  methods: {
    async loadMeetingData() {
      try {
        const response = await apiService.getMeetingById(this.meetingId)
        this.meeting = response
        
        // Charger les participants
        try {
          const participantsResponse = await apiService.getParticipantsByMeeting(this.meetingId)
          this.participants = Array.isArray(participantsResponse) ? participantsResponse : []
        } catch (err) {
          console.warn('Impossible de charger les participants:', err)
        }

        // Démarrer la transcription si la réunion est en cours ou planifiée
        if (this.meeting.status === 'in_progress' || this.meeting.status === 'scheduled') {
          try {
            await apiService.startTranscription(this.meetingId, {})
            console.log('✅ Transcription initialisée')
          } catch (err) {
            console.warn('⚠️ La transcription pourrait déjà être démarrée:', err)
          }
        }
      } catch (error) {
        console.error('Erreur lors du chargement de la réunion:', error)
        alert('❌ Impossible de charger les informations de la réunion')
      }
    },
    
    async startRecording() {
      try {
        this.isProcessing = true
        
        // Charger lamejs depuis window.lamejs ou via import dynamique
        if (!lamejsModule) {
          console.log('🔄 Chargement de lamejs...')
          
          // Essayer d'abord window.lamejs (si le bundle est chargé)
          if (window.lamejs && window.lamejs.Mp3Encoder) {
            lamejsModule = window.lamejs
            console.log('✅ lamejs trouvé dans window.lamejs')
          } else {
            // Si window.lamejs n'est pas disponible, charger le bundle dynamiquement
            console.log('⚠️ window.lamejs non disponible, chargement dynamique du bundle...')
            
            try {
              // Charger directement depuis node_modules via fetch
              console.log('🔄 Chargement du bundle depuis node_modules...')
              
              const response = await fetch('/node_modules/lamejs/lame.all.js')
              if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`)
              }
              
              const code = await response.text()
              console.log('✅ Code du bundle récupéré, taille:', code.length, 'caractères')
              
              // Exécuter le code dans un script
              const script = document.createElement('script')
              script.textContent = code
              document.head.appendChild(script)
              
              // Attendre que lamejs soit initialisé (le bundle appelle lamejs() à la fin)
              let attempts = 0
              const maxAttempts = 50
              
              while (!window.lamejs || !window.lamejs.Mp3Encoder) {
                if (attempts >= maxAttempts) {
                  console.error('❌ window.lamejs non défini après', maxAttempts, 'tentatives')
                  throw new Error('Bundle chargé mais window.lamejs non défini après initialisation')
                }
                await new Promise(resolve => setTimeout(resolve, 100))
                attempts++
              }
              
              lamejsModule = window.lamejs
              console.log('✅ lamejs chargé depuis node_modules avec succès')
            } catch (e) {
              console.error('❌ Erreur lors du chargement du bundle:', e)
              throw new Error('Impossible de charger lamejs: ' + e.message)
            }
          }
        }
        
        // Démarrer officiellement la réunion si elle n'est pas déjà en cours
        if (this.meeting.status !== 'in_progress') {
          try {
            await apiService.startMeeting(this.meetingId)
            this.meeting.status = 'in_progress'
            console.log('✅ Réunion démarrée officiellement')
          } catch (error) {
            console.warn('⚠️ Impossible de démarrer la réunion (peut-être déjà démarrée):', error)
            // Continuer même si le démarrage échoue (la réunion est peut-être déjà démarrée)
          }
        }
        
        // Demander l'accès au microphone
        this.stream = await navigator.mediaDevices.getUserMedia({ 
          audio: {
            echoCancellation: true,
            noiseSuppression: true,
            sampleRate: 44100
          } 
        })
        
        // Créer l'AudioContext pour capturer l'audio directement en MP3
        this.audioContext = new (window.AudioContext || window.webkitAudioContext)({
          sampleRate: this.sampleRate
        })
        
        // Créer une source depuis le stream
        this.mediaStreamSource = this.audioContext.createMediaStreamSource(this.stream)
        
        // Créer un ScriptProcessorNode pour capturer les données audio
        const bufferSize = 4096
        this.scriptProcessor = this.audioContext.createScriptProcessor(bufferSize, this.numChannels, this.numChannels)
        
        // Initialiser l'encodeur MP3
        if (!lamejsModule || !lamejsModule.Mp3Encoder) {
          throw new Error('lamejs.Mp3Encoder n\'est pas disponible. Le module n\'a pas été chargé correctement.')
        }
        
        try {
          this.mp3Encoder = new lamejsModule.Mp3Encoder(this.numChannels, this.sampleRate, 128) // 128 kbps
        } catch (error) {
          console.error('Erreur lors de la création de Mp3Encoder:', error)
          throw new Error('Impossible de créer l\'encodeur MP3: ' + error.message)
        }
        this.mp3Data = []
        this.audioChunks = []
        
        // Capturer les données audio et les encoder en MP3
        let segmentStartTime = Date.now()
        const segmentInterval = 30000 // 30 secondes
        
        this.scriptProcessor.onaudioprocess = (e) => {
          if (!this.isRecording || this.isPaused) return
          
          // Récupérer les données audio
          const inputData = e.inputBuffer.getChannelData(0)
          
          // Convertir Float32Array en Int16Array pour lamejs
          const samples = new Int16Array(inputData.length)
          for (let i = 0; i < inputData.length; i++) {
            const s = Math.max(-1, Math.min(1, inputData[i]))
            samples[i] = s < 0 ? s * 0x8000 : s * 0x7FFF
          }
          
          // Encoder en MP3 par blocs
          const sampleBlockSize = 1152
          for (let i = 0; i < samples.length; i += sampleBlockSize) {
            const sampleChunk = samples.subarray(i, i + sampleBlockSize)
            const mp3buf = this.mp3Encoder.encodeBuffer(sampleChunk)
            if (mp3buf.length > 0) {
              this.mp3Data.push(mp3buf)
            }
          }
          
          // Envoyer un segment toutes les 30 secondes
          const currentTime = Date.now()
          if (currentTime - segmentStartTime >= segmentInterval) {
            this.sendMp3Segment()
            segmentStartTime = currentTime
          }
        }
        
        // Connecter les nœuds
        this.mediaStreamSource.connect(this.scriptProcessor)
        this.scriptProcessor.connect(this.audioContext.destination)
        
        this.isRecording = true
        this.isPaused = false
        this.segmentCounter = 0
        
        // Démarrer le timer
        this.startTimer()
        
        console.log('🎙️ Enregistrement MP3 démarré avec envoi automatique des segments toutes les 30 secondes')
      } catch (error) {
        console.error('Erreur lors du démarrage de l\'enregistrement:', error)
        alert('❌ Impossible d\'accéder au microphone. Vérifiez les permissions.')
      } finally {
        this.isProcessing = false
      }
    },
    
    sendMp3Segment() {
      if (this.mp3Data.length === 0) return
      
      // Finaliser l'encodage du segment
      const mp3buf = this.mp3Encoder.flush()
      if (mp3buf.length > 0) {
        this.mp3Data.push(mp3buf)
      }
      
      // Créer un blob MP3
      const mp3Blob = new Blob(this.mp3Data, { type: 'audio/mpeg' })
      
      // Sauvegarder pour l'enregistrement complet
      this.audioChunks.push(mp3Blob)
      
      // Envoyer le segment
      this.segmentCounter++
      this.sendSegmentToTranscription(mp3Blob).catch(err => {
        console.error('❌ Erreur lors de l\'envoi du segment:', err)
      })
      
      // Réinitialiser pour le prochain segment
      this.mp3Data = []
      if (lamejsModule) {
        this.mp3Encoder = new lamejsModule.Mp3Encoder(this.numChannels, this.sampleRate, 128)
      }
    },
    
    async sendSegmentToTranscription(mp3Blob) {
      try {
        const timestamp = Date.now()
        const segmentNumber = this.segmentCounter.toString().padStart(3, '0') // Format: 001, 002, 003...
        const fileName = `segment_${this.meetingId}_${segmentNumber}_${timestamp}.mp3`
        const audioFile = new File([mp3Blob], fileName, { type: 'audio/mpeg' })
        
        console.log(`📤 Envoi segment #${this.segmentCounter} audio (MP3) pour transcription:`, fileName, (mp3Blob.size / 1024).toFixed(2), 'KB')
        
        // Envoyer au service de transcription
        await apiService.sendAudioSegment(this.meetingId, audioFile)
        console.log(`✅ Segment #${this.segmentCounter} envoyé avec succès`)
      } catch (error) {
        console.error(`❌ Erreur lors de l'envoi du segment #${this.segmentCounter}:`, error)
        // Ne pas bloquer l'enregistrement si l'envoi échoue
      }
    },
    
    pauseRecording() {
      if (this.isRecording && !this.isPaused) {
        this.isPaused = true
        this.stopTimer()
        console.log('⏸️ Enregistrement en pause')
      }
    },
    
    resumeRecording() {
      if (this.isRecording && this.isPaused) {
        this.isPaused = false
        this.startTimer()
        console.log('▶️ Enregistrement repris')
      }
    },
    
    async stopRecording() {
      if (this.isRecording || this.isPaused) {
        this.isProcessing = true
        this.isRecording = false
        this.isPaused = false
        this.stopTimer()
        
        // Finaliser le dernier segment
        if (this.mp3Data.length > 0) {
          this.sendMp3Segment()
        }
        
        // Nettoyer les ressources audio
        if (this.scriptProcessor) {
          this.scriptProcessor.disconnect()
          this.scriptProcessor = null
        }
        if (this.mediaStreamSource) {
          this.mediaStreamSource.disconnect()
          this.mediaStreamSource = null
        }
        if (this.audioContext) {
          await this.audioContext.close()
          this.audioContext = null
        }
        
        console.log(`⏹️ Enregistrement arrêté (${this.segmentCounter} segment(s) envoyé(s))`)
        
        // Sauvegarder l'enregistrement complet
        await this.saveRecording()
        
        // Passer automatiquement la réunion en "completed" après l'arrêt de l'enregistrement
        await this.autoEndMeeting()
      }
    },
    
    async saveRecording() {
      try {
        // Fusionner tous les segments MP3 en un seul fichier
        const mp3Blob = new Blob(this.audioChunks, { type: 'audio/mpeg' })
        
        // Créer un fichier MP3
        const fileName = `recording_${this.meetingId}_${Date.now()}.mp3`
        const audioFile = new File([mp3Blob], fileName, { type: 'audio/mpeg' })
        
        console.log('💾 Sauvegarde enregistrement complet (MP3):', fileName, 'Taille:', (mp3Blob.size / 1024 / 1024).toFixed(2), 'MB')
        
        // Envoyer le fichier audio complet au service de transcription
        try {
          await apiService.saveRecordFile(this.meetingId, audioFile)
          console.log('✅ Fichier audio complet sauvegardé sur le serveur')
          
          // Si aucun segment n'a été envoyé pendant l'enregistrement, 
          // déclencher la transcription du fichier complet
          if (this.segmentCounter === 0) {
            console.log('🔄 Aucun segment envoyé, déclenchement de la transcription du fichier complet...')
            try {
              const recordFileName = fileName
              await apiService.startTranscription(this.meetingId, {
                recordFileName: recordFileName
              })
              console.log('✅ Transcription du fichier complet déclenchée')
            } catch (transcriptionError) {
              console.warn('⚠️ Erreur lors du déclenchement de la transcription:', transcriptionError)
            }
          }
          
          alert(`✅ Enregistrement sauvegardé (${(mp3Blob.size / 1024 / 1024).toFixed(2)} MB)${this.segmentCounter === 0 ? '. Transcription en cours...' : ''}`)
        } catch (error) {
          console.error('❌ Erreur lors de la sauvegarde sur le serveur:', error)
          alert('⚠️ Enregistrement local réussi, mais échec de l\'envoi au serveur')
        }
        
        // Réinitialiser
        this.audioChunks = []
        this.mp3Data = []
      } catch (error) {
        console.error('Erreur lors de la sauvegarde:', error)
        alert('❌ Erreur lors de la sauvegarde de l\'enregistrement')
      } finally {
        this.isProcessing = false
      }
    },
    
    startTimer() {
      this.timerInterval = setInterval(() => {
        this.recordingTime++
      }, 1000)
    },
    
    stopTimer() {
      if (this.timerInterval) {
        clearInterval(this.timerInterval)
        this.timerInterval = null
      }
    },
    
    cleanup() {
      this.stopTimer()
      
      if (this.stream) {
        this.stream.getTracks().forEach(track => track.stop())
        this.stream = null
      }
      
      if (this.scriptProcessor) {
        this.scriptProcessor.disconnect()
        this.scriptProcessor = null
      }
      
      if (this.mediaStreamSource) {
        this.mediaStreamSource.disconnect()
        this.mediaStreamSource = null
      }
      
      if (this.audioContext) {
        this.audioContext.close().catch(console.error)
        this.audioContext = null
      }
      
      this.mp3Data = []
      this.mp3Encoder = null
    },
    
    async autoEndMeeting() {
      // Fonction silencieuse pour terminer automatiquement la réunion
      // Appelée quand la page se ferme ou l'enregistrement s'arrête
      try {
        console.log('🔄 Passage automatique de la réunion en "terminée"...')
        await apiService.endMeeting(this.meetingId)
        console.log('✅ Réunion automatiquement passée en "terminée"')
      } catch (error) {
        // Ignorer l'erreur 409 si la réunion est déjà terminée ou n'a pas été démarrée
        if (error?.status === 409) {
          console.log('ℹ️ La réunion est déjà terminée ou n\'a pas été démarrée')
        } else {
          console.error('⚠️ Erreur lors du passage automatique en terminée:', error)
        }
        // Ne pas afficher d'alerte pour ne pas perturber l'utilisateur
      }
    },
    
    handlePageUnload(event) {
      // Appelé quand l'utilisateur ferme la page/onglet
      if (this.isRecording) {
        // Avertir l'utilisateur qu'il a un enregistrement en cours
        event.preventDefault()
        event.returnValue = 'Un enregistrement est en cours. Êtes-vous sûr de vouloir quitter ?'
      }
      // Terminer automatiquement la réunion
      this.autoEndMeeting()
    },
    
    async endMeeting() {
      if (!confirm('Êtes-vous sûr de vouloir clore cette réunion ?')) {
        return
      }
      
      this.isProcessing = true
      
      try {
        await apiService.endMeeting(this.meetingId)
        alert('✅ Réunion clôturée avec succès !')
        this.$emit('meeting-ended', this.meetingId)
        this.$emit('back')
      } catch (error) {
        console.error('Erreur lors de la clôture:', error)
        alert(error?.message || '❌ Erreur lors de la clôture de la réunion')
      } finally {
        this.isProcessing = false
      }
    },
    
    getInitials(fullName) {
      if (!fullName) return '?'
      const parts = fullName.trim().split(' ')
      if (parts.length >= 2) {
        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
      }
      return fullName.substring(0, 2).toUpperCase()
    },
    
    formatDate(dateString) {
      if (!dateString) return 'Date non définie'
      const date = new Date(dateString)
      return date.toLocaleDateString('fr-FR', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    },
    
    goBack() {
      if (this.isRecording) {
        alert('⚠️ Veuillez arrêter l\'enregistrement avant de quitter')
        return
      }
      this.$emit('back')
    },

    getStatusBadgeClass() {
      if (this.isRecording) {
        return 'status-recording'
      }
      const status = this.meeting.status
      if (status === 'completed') {
        return 'status-completed'
      } else if (status === 'in_progress') {
        return 'status-in-progress'
      } else if (status === 'scheduled') {
        return 'status-scheduled'
      }
      return 'status-recording'
    },

    getStatusText() {
      if (this.isRecording) {
        return 'En cours d\'enregistrement'
      }
      const status = this.meeting.status
      if (status === 'completed') {
        return 'Réunion terminée'
      } else if (status === 'in_progress') {
        return 'Réunion en cours'
      } else if (status === 'scheduled') {
        return 'Réunion planifiée'
      }
      return 'Prêt à enregistrer'
    }
  }
}
</script>

<style scoped>
.record-meeting {
  min-height: 100vh;
  background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
  padding: 2rem 1rem;
}

.record-container {
  max-width: 1200px;
  margin: 0 auto;
}

.record-header {
  text-align: center;
  margin-bottom: 3rem;
  color: white;
}

.meeting-info-bar {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1.5rem;
  margin-bottom: 0.5rem;
  flex-wrap: wrap;
}

.meeting-title {
  font-size: 2rem;
  font-weight: 700;
  margin: 0;
}

.status-badge {
  padding: 0.5rem 1rem;
  border-radius: 2rem;
  font-size: 0.9rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.status-recording {
  background: rgba(239, 68, 68, 0.2);
  border: 2px solid #ef4444;
  color: #fca5a5;
}

.status-scheduled {
  background: rgba(59, 130, 246, 0.2);
  border: 2px solid #3b82f6;
  color: #93c5fd;
}

.status-in-progress {
  background: rgba(245, 158, 11, 0.2);
  border: 2px solid #f59e0b;
  color: #fcd34d;
}

.status-completed {
  background: rgba(16, 185, 129, 0.2);
  border: 2px solid #10b981;
  color: #6ee7b7;
}

.recording-dot {
  width: 10px;
  height: 10px;
  background: #ef4444;
  border-radius: 50%;
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.5;
    transform: scale(1.2);
  }
}

.meeting-meta {
  font-size: 1rem;
  opacity: 0.8;
  margin: 0;
}

.recording-controls {
  background: white;
  border-radius: 1.5rem;
  padding: 3rem 2rem;
  margin-bottom: 2rem;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
}

.timer-display {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 2rem;
}

.timer-icon {
  width: 3rem;
  height: 3rem;
  color: #6366f1;
}

.timer-text {
  font-size: 3.5rem;
  font-weight: 700;
  color: #1e293b;
  font-variant-numeric: tabular-nums;
  font-family: 'Courier New', monospace;
}

.control-buttons {
  display: flex;
  justify-content: center;
  gap: 1rem;
  flex-wrap: wrap;
  margin-bottom: 2rem;
}

.btn-control {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 2rem;
  border: none;
  border-radius: 1rem;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  color: white;
}

.btn-control svg {
  width: 24px;
  height: 24px;
}

.btn-control:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-start {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  box-shadow: 0 8px 20px rgba(239, 68, 68, 0.4);
}

.btn-start:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 12px 30px rgba(239, 68, 68, 0.5);
}

.btn-pause {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  box-shadow: 0 8px 20px rgba(245, 158, 11, 0.4);
}

.btn-pause:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 30px rgba(245, 158, 11, 0.5);
}

.btn-resume {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  box-shadow: 0 8px 20px rgba(16, 185, 129, 0.4);
}

.btn-resume:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 30px rgba(16, 185, 129, 0.5);
}

.btn-stop {
  background: linear-gradient(135deg, #64748b 0%, #475569 100%);
  box-shadow: 0 8px 20px rgba(100, 116, 139, 0.4);
}

.btn-stop:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 12px 30px rgba(100, 116, 139, 0.5);
}

.audio-visualizer {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 4px;
  height: 60px;
}

.wave-bar {
  width: 4px;
  background: linear-gradient(to top, #6366f1, #8b5cf6);
  border-radius: 2px;
  animation: wave 1s ease-in-out infinite;
}

@keyframes wave {
  0%, 100% {
    height: 10px;
  }
  50% {
    height: 50px;
  }
}

.participants-panel,
.notes-panel {
  background: white;
  border-radius: 1rem;
  padding: 1.5rem;
  margin-bottom: 2rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.panel-title {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 1.25rem;
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 1rem;
}

.panel-title svg {
  width: 24px;
  height: 24px;
  color: #6366f1;
}

.participants-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.participant-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem;
  background: #f8fafc;
  border-radius: 0.75rem;
  transition: all 0.2s;
}

.participant-item:hover {
  background: #f1f5f9;
  transform: translateX(4px);
}

.participant-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 0.9rem;
}

.participant-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.participant-name {
  font-weight: 600;
  color: #1e293b;
}

.participant-email {
  font-size: 0.85rem;
  color: #64748b;
}

.no-participants {
  text-align: center;
  padding: 2rem;
  color: #94a3b8;
  font-style: italic;
}

.notes-textarea {
  width: 100%;
  min-height: 150px;
  padding: 1rem;
  border: 2px solid #e2e8f0;
  border-radius: 0.75rem;
  font-family: inherit;
  font-size: 1rem;
  resize: vertical;
  transition: all 0.3s;
}

.notes-textarea:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

.action-buttons {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
}

.btn {
  padding: 0.875rem 1.5rem;
  border: none;
  border-radius: 0.75rem;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn svg {
  width: 20px;
  height: 20px;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-secondary {
  background: #f1f5f9;
  color: #475569;
  border: 2px solid #e2e8f0;
}

.btn-secondary:hover:not(:disabled) {
  background: #e2e8f0;
  transform: translateY(-2px);
}

.btn-danger {
  background: #ef4444;
  color: white;
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

.btn-danger:hover:not(:disabled) {
  background: #dc2626;
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(239, 68, 68, 0.4);
}

@media (max-width: 768px) {
  .record-meeting {
    padding: 1rem 0.5rem;
  }
  
  .meeting-title {
    font-size: 1.5rem;
  }
  
  .timer-text {
    font-size: 2.5rem;
  }
  
  .recording-controls {
    padding: 2rem 1rem;
  }
  
  .control-buttons {
    flex-direction: column;
  }
  
  .btn-control {
    width: 100%;
    justify-content: center;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .btn {
    width: 100%;
    justify-content: center;
  }
}
</style>

