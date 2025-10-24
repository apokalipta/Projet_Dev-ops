<template>
  <div class="setup-meeting">
    <div class="setup-container">
      <div class="setup-header">
        <h1 class="setup-title">
          <svg class="setup-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="10"/>
            <path d="M8 12h8"/>
            <path d="M12 8v8"/>
          </svg>
          Configuration de la Réunion
        </h1>
        <p class="setup-subtitle">
          Configurez les paramètres de votre réunion pour une transcription optimale
        </p>
      </div>

      <form @submit.prevent="createMeeting" class="setup-form">
        <div class="form-grid">
          <!-- Nom de la réunion -->
          <div class="form-group">
            <label for="meetingName" class="form-label">
              <svg class="label-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14,2 14,8 20,8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
                <polyline points="10,9 9,9 8,9"/>
              </svg>
              Nom de la réunion *
            </label>
            <input
              type="text"
              id="meetingName"
              v-model="meetingData.name"
              class="form-input"
              placeholder="Ex: Réunion équipe marketing"
              required
            />
            <div v-if="errors.name" class="error-message">{{ errors.name }}</div>
          </div>

          <!-- Date de la réunion -->
          <div class="form-group">
            <label for="meetingDate" class="form-label">
              <svg class="label-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                <line x1="16" y1="2" x2="16" y2="6"/>
                <line x1="8" y1="2" x2="8" y2="6"/>
                <line x1="3" y1="10" x2="21" y2="10"/>
              </svg>
              Date de la réunion *
            </label>
            <input
              type="datetime-local"
              id="meetingDate"
              v-model="meetingData.date"
              class="form-input"
              required
            />
            <div v-if="errors.date" class="error-message">{{ errors.date }}</div>
          </div>

          <!-- Nombre de participants -->
          <div class="form-group">
            <label for="participants" class="form-label">
              <svg class="label-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
                <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
              </svg>
              Nombre de participants *
            </label>
            <select
              id="participants"
              v-model="meetingData.participants"
              class="form-select"
              required
            >
              <option value="">Sélectionnez le nombre</option>
              <option v-for="num in 50" :key="num" :value="num">{{ num }} participant{{ num > 1 ? 's' : '' }}</option>
            </select>
            <div v-if="errors.participants" class="error-message">{{ errors.participants }}</div>
          </div>

          <!-- Durée prévue -->
          <div class="form-group">
            <label for="duration" class="form-label">
              <svg class="label-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12,6 12,12 16,14"/>
              </svg>
              Durée prévue *
            </label>
            <div class="duration-container">
              <select
                id="duration"
                v-model="durationType"
                class="form-select duration-type"
                @change="onDurationTypeChange"
              >
                <option value="preset">Durées prédéfinies</option>
                <option value="custom">Durée personnalisée</option>
              </select>
              
              <!-- Options prédéfinies -->
              <select
                v-if="durationType === 'preset'"
                v-model="meetingData.duration"
                class="form-select duration-value"
                required
              >
                <option value="">Sélectionnez la durée</option>
                <option value="15">15 minutes</option>
                <option value="30">30 minutes</option>
                <option value="45">45 minutes</option>
                <option value="60">1 heure</option>
                <option value="90">1h30</option>
                <option value="120">2 heures</option>
                <option value="180">3 heures</option>
                <option value="240">4 heures</option>
              </select>
              
              <!-- Durée personnalisée -->
              <div v-if="durationType === 'custom'" class="custom-duration">
                <div class="duration-inputs">
                  <input
                    type="number"
                    v-model="customHours"
                    class="form-input duration-input"
                    placeholder="0"
                    min="0"
                    max="12"
                    @input="updateCustomDuration"
                  />
                  <span class="duration-label">heures</span>
                  <input
                    type="number"
                    v-model="customMinutes"
                    class="form-input duration-input"
                    placeholder="0"
                    min="0"
                    max="59"
                    @input="updateCustomDuration"
                  />
                  <span class="duration-label">minutes</span>
                </div>
                <div class="duration-preview" v-if="customDurationText">
                  Durée totale : {{ customDurationText }}
                </div>
              </div>
            </div>
            <div v-if="errors.duration" class="error-message">{{ errors.duration }}</div>
          </div>
        </div>

        <!-- Description (optionnelle) -->
        <div class="form-group full-width">
            <label for="description" class="form-label">
              <svg class="label-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14,2 14,8 20,8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
                <polyline points="10,9 9,9 8,9"/>
              </svg>
              Description de la réunion
              <span class="optional">(optionnel)</span>
            </label>
          <textarea
            id="description"
            v-model="meetingData.description"
            class="form-textarea"
            placeholder="Décrivez l'objectif et les points à aborder lors de cette réunion..."
            rows="4"
          ></textarea>
          <div class="char-count">{{ meetingData.description.length }}/500 caractères</div>
        </div>

        <!-- Sélection du microphone -->
        <div class="microphone-section">
          <h3 class="section-title">
            <svg class="section-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M9 18V5l12-2v13"/>
              <circle cx="6" cy="18" r="3"/>
              <circle cx="18" cy="16" r="3"/>
            </svg>
            Configuration Audio
          </h3>
          
          <div class="form-group">
            <label for="microphone" class="form-label">
              <svg class="label-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/>
                <path d="M19 10v2a7 7 0 0 1-14 0v-2"/>
                <line x1="12" y1="19" x2="12" y2="23"/>
                <line x1="8" y1="23" x2="16" y2="23"/>
              </svg>
              Microphone
            </label>
            <div class="microphone-container">
              <select
                id="microphone"
                v-model="meetingData.selectedMicrophone"
                class="form-select microphone-select"
                @change="onMicrophoneChange"
              >
                <option value="">Sélectionnez un microphone</option>
                <option 
                  v-for="device in audioDevices" 
                  :key="device.deviceId" 
                  :value="device.deviceId"
                  :title="device.label || `Microphone ${device.deviceId.slice(0, 8)}`"
                >
                  {{ truncateDeviceName(device.label || `Microphone ${device.deviceId.slice(0, 8)}`) }}
                </option>
              </select>
              <button 
                type="button" 
                @click="refreshAudioDevices" 
                class="btn btn-refresh"
                :disabled="isScanning"
                :title="isScanning ? 'Scan en cours...' : 'Scanner les microphones'"
              >
                <svg v-if="isScanning" class="icon-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M21 12a9 9 0 11-6.219-8.56"/>
                </svg>
                <svg v-else class="icon-refresh" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/>
                  <path d="M21 3v5h-5"/>
                  <path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/>
                  <path d="M3 21v-5h5"/>
                </svg>
                <span class="btn-text">{{ isScanning ? 'Scan...' : 'Scanner' }}</span>
              </button>
            </div>
            <div class="microphone-info">
              <p v-if="audioDevices.length === 0" class="info-text">
                Aucun microphone détecté. Vérifiez vos périphériques audio.
              </p>
              <p v-else class="info-text">
                {{ audioDevices.length }} microphone{{ audioDevices.length > 1 ? 's' : '' }} détecté{{ audioDevices.length > 1 ? 's' : '' }}
              </p>
            </div>
          </div>
        </div>

        <!-- Options avancées -->
        <div class="advanced-options">
          <h3 class="options-title">
            <svg class="options-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="3"/>
              <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1 1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/>
            </svg>
            Options avancées
          </h3>
          
          <div class="options-grid">
            <div class="option-item">
              <label class="checkbox-label">
                <input
                  type="checkbox"
                  v-model="meetingData.autoStart"
                  class="checkbox-input"
                />
                <span class="checkbox-custom"></span>
                Démarrer automatiquement la transcription
              </label>
            </div>

            <div class="option-item">
              <label class="checkbox-label">
                <input
                  type="checkbox"
                  v-model="meetingData.sendReminders"
                  class="checkbox-input"
                />
                <span class="checkbox-custom"></span>
                Envoyer des rappels aux participants
              </label>
            </div>
          </div>
        </div>

        <!-- Boutons d'action -->
        <div class="form-actions">
          <button
            type="button"
            @click="goBack"
            class="btn btn-secondary"
          >
            ← Retour
          </button>
            <button
              type="submit"
              :disabled="isLoading"
              class="btn btn-primary"
            >
              <svg v-if="isLoading" class="icon-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 12a9 9 0 11-6.219-8.56"/>
              </svg>
              <svg v-else class="icon-rocket" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09z"/>
                <path d="M12 15l-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2z"/>
                <path d="M9 12H4s.55-3.03 2-4c1.62-1.08 5 0 5 0"/>
                <path d="M12 15v5s3.03-.55 4-2c1.08-1.62 0-5 0-5"/>
              </svg>
              {{ isLoading ? 'Création en cours...' : 'Créer la Réunion' }}
            </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SetupMeeting',
  data() {
    return {
      meetingData: {
        name: '',
        date: '',
        participants: '',
        duration: '',
        description: '',
        selectedMicrophone: '',
        autoStart: true,
        sendReminders: false
      },
      durationType: 'preset',
      customHours: 0,
      customMinutes: 0,
      audioDevices: [],
      isScanning: false,
      errors: {},
      isLoading: false
    }
  },
  computed: {
    customDurationText() {
      if (this.durationType === 'custom') {
        const totalMinutes = (this.customHours * 60) + this.customMinutes
        if (totalMinutes === 0) return ''
        
        if (this.customHours > 0 && this.customMinutes > 0) {
          return `${this.customHours}h ${this.customMinutes}min`
        } else if (this.customHours > 0) {
          return `${this.customHours}h`
        } else {
          return `${this.customMinutes}min`
        }
      }
      return ''
    }
  },
  async mounted() {
    // Scanner les périphériques audio au chargement du composant
    await this.refreshAudioDevices()
  },
  methods: {
    async refreshAudioDevices() {
      this.isScanning = true
      
      try {
        // Demander l'autorisation d'accès au microphone
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
        
        // Obtenir la liste des périphériques audio
        const devices = await navigator.mediaDevices.enumerateDevices()
        
        // Filtrer uniquement les microphones (input audio)
        this.audioDevices = devices.filter(device => device.kind === 'audioinput')
        
        // Arrêter le stream pour libérer le microphone
        stream.getTracks().forEach(track => track.stop())
        
        // Sélectionner automatiquement le premier microphone si disponible
        if (this.audioDevices.length > 0 && !this.meetingData.selectedMicrophone) {
          this.meetingData.selectedMicrophone = this.audioDevices[0].deviceId
        }
        
      } catch (error) {
        console.error('Erreur lors du scan des microphones:', error)
        this.audioDevices = []
        
        // Afficher un message d'erreur selon le type d'erreur
        if (error.name === 'NotAllowedError') {
          alert('❌ Accès au microphone refusé. Veuillez autoriser l\'accès au microphone dans les paramètres de votre navigateur.')
        } else if (error.name === 'NotFoundError') {
          alert('❌ Aucun microphone détecté. Vérifiez que votre microphone est connecté.')
        } else {
          alert('❌ Erreur lors de la détection des microphones.')
        }
      } finally {
        this.isScanning = false
      }
    },
    
    onMicrophoneChange() {
      console.log('Microphone sélectionné:', this.meetingData.selectedMicrophone)
      // Ici vous pourriez tester le microphone sélectionné
    },
    
    truncateDeviceName(name, maxLength = 40) {
      if (name.length <= maxLength) return name
      return name.substring(0, maxLength - 3) + '...'
    },
    
    validateForm() {
      this.errors = {}
      
      if (!this.meetingData.name.trim()) {
        this.errors.name = 'Le nom de la réunion est requis'
      }
      
      if (!this.meetingData.date) {
        this.errors.date = 'La date de la réunion est requise'
      } else {
        const selectedDate = new Date(this.meetingData.date)
        const now = new Date()
        if (selectedDate <= now) {
          this.errors.date = 'La date doit être dans le futur'
        }
      }
      
      if (!this.meetingData.participants) {
        this.errors.participants = 'Le nombre de participants est requis'
      }
      
      if (this.durationType === 'preset' && !this.meetingData.duration) {
        this.errors.duration = 'La durée prévue est requise'
      } else if (this.durationType === 'custom') {
        const totalMinutes = (this.customHours * 60) + this.customMinutes
        if (totalMinutes === 0) {
          this.errors.duration = 'Veuillez spécifier une durée personnalisée'
        } else if (totalMinutes < 5) {
          this.errors.duration = 'La durée doit être d\'au moins 5 minutes'
        } else if (totalMinutes > 480) {
          this.errors.duration = 'La durée ne peut pas dépasser 8 heures'
        }
      }
      
      return Object.keys(this.errors).length === 0
    },
    
    onDurationTypeChange() {
      // Réinitialiser les valeurs quand on change de type
      if (this.durationType === 'preset') {
        this.meetingData.duration = ''
      } else {
        this.customHours = 0
        this.customMinutes = 0
      }
    },
    
    updateCustomDuration() {
      // Calculer la durée totale en minutes
      const totalMinutes = (this.customHours * 60) + this.customMinutes
      this.meetingData.duration = totalMinutes.toString()
    },
    
    async createMeeting() {
      if (!this.validateForm()) {
        return
      }
      
      // Préparer les données finales
      const finalData = { ...this.meetingData }
      if (this.durationType === 'custom') {
        const totalMinutes = (this.customHours * 60) + this.customMinutes
        finalData.duration = totalMinutes.toString()
        finalData.durationType = 'custom'
        finalData.durationText = this.customDurationText
      } else {
        finalData.durationType = 'preset'
      }
      
      this.isLoading = true
      
      try {
        // TODO: Remplacer par l'appel API réel
        // const response = await fetch('/api/meetings/create', {
        //   method: 'POST',
        //   headers: {
        //     'Content-Type': 'application/json',
        //     'Authorization': `Bearer ${token}`
        //   },
        //   body: JSON.stringify(finalData)
        // })
        
        // Simulation d'un appel API
        await new Promise(resolve => setTimeout(resolve, 2000))
        
        // Log des données pour le développement
        console.log('📋 Données de la réunion à envoyer:', finalData)
        console.log('🔗 Endpoint à configurer: POST /api/meetings/create')
        
        // Émettre un événement pour rediriger vers l'assignation des participants
        this.$emit('meeting-created', {
          ...finalData,
          meetingId: 'temp-id-' + Date.now(), // ID temporaire pour le développement
          status: 'created'
        })
        
      } catch (error) {
        console.error('Erreur lors de la création:', error)
        alert('❌ Erreur lors de la création de la réunion')
      } finally {
        this.isLoading = false
      }
    },
    
    goBack() {
      this.$emit('back')
    }
  }
}
</script>

<style scoped>
.setup-meeting {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 6rem 0 2rem 0; /* Ajout de padding-top pour compenser la navbar fixe */
}

.setup-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 0 2rem;
}

.setup-header {
  text-align: center;
  margin-bottom: 3rem;
  color: white;
}

.setup-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
}

.setup-icon {
  width: 3rem;
  height: 3rem;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  flex-shrink: 0;
}

.setup-subtitle {
  font-size: 1.25rem;
  opacity: 0.9;
  max-width: 600px;
  margin: 0 auto;
}

.setup-form {
  background: white;
  border-radius: 1rem;
  padding: 2.5rem;
  box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1);
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group.full-width {
  grid-column: 1 / -1;
}

.form-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  color: #374151;
  margin-bottom: 0.5rem;
  font-size: 0.95rem;
}

.label-icon {
  width: 18px;
  height: 18px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  flex-shrink: 0;
}

.optional {
  color: #6b7280;
  font-weight: 400;
  font-size: 0.85rem;
}

.form-input,
.form-select,
.form-textarea {
  padding: 0.875rem 1rem;
  border: 2px solid #e5e7eb;
  border-radius: 0.5rem;
  font-size: 1rem;
  transition: all 0.3s ease;
  background: white;
}

.form-input:focus,
.form-select:focus,
.form-textarea:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgb(99 102 241 / 0.1);
}

.form-textarea {
  resize: vertical;
  min-height: 100px;
}

.char-count {
  font-size: 0.8rem;
  color: #6b7280;
  text-align: right;
  margin-top: 0.25rem;
}

.error-message {
  color: #ef4444;
  font-size: 0.85rem;
  margin-top: 0.25rem;
}

.advanced-options {
  margin: 2rem 0;
  padding: 1.5rem;
  background: #f8fafc;
  border-radius: 0.75rem;
  border: 1px solid #e5e7eb;
}

.options-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.1rem;
  font-weight: 600;
  color: #374151;
  margin-bottom: 1rem;
}

.options-icon {
  width: 20px;
  height: 20px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  flex-shrink: 0;
}

.options-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.option-item {
  display: flex;
  align-items: center;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
  font-weight: 500;
  color: #374151;
}

.checkbox-input {
  display: none;
}

.checkbox-custom {
  width: 20px;
  height: 20px;
  border: 2px solid #d1d5db;
  border-radius: 0.375rem;
  position: relative;
  transition: all 0.3s ease;
}

.checkbox-input:checked + .checkbox-custom {
  background: #6366f1;
  border-color: #6366f1;
}

.checkbox-input:checked + .checkbox-custom::after {
  content: '✓';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: white;
  font-weight: bold;
  font-size: 0.75rem;
}

.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
  padding-top: 2rem;
  border-top: 1px solid #e5e7eb;
}

.btn {
  padding: 0.875rem 2rem;
  border: none;
  border-radius: 0.5rem;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-primary {
  background: #10b981;
  color: white;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

.btn-primary:hover:not(:disabled) {
  background: #059669;
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  background: #f3f4f6;
  color: #374151;
  border: 1px solid #d1d5db;
}

.btn-secondary:hover {
  background: #e5e7eb;
}

.loading-spinner {
  width: 16px;
  height: 16px;
  border: 2px solid transparent;
  border-top: 2px solid currentColor;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

/* Styles pour la durée personnalisée */
.duration-container {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.duration-type {
  width: 100%;
}

.duration-value {
  width: 100%;
}

.custom-duration {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.duration-inputs {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.duration-input {
  width: 80px;
  text-align: center;
}

.duration-label {
  font-weight: 500;
  color: #6b7280;
  font-size: 0.9rem;
  white-space: nowrap;
}

.duration-preview {
  background: #f0f9ff;
  border: 1px solid #0ea5e9;
  border-radius: 0.5rem;
  padding: 0.5rem 0.75rem;
  font-weight: 500;
  color: #0369a1;
  font-size: 0.9rem;
  text-align: center;
}

/* Styles pour la sélection du microphone */
.microphone-section {
  margin: 2rem 0;
  padding: 1.5rem;
  background: #f8fafc;
  border-radius: 0.75rem;
  border: 1px solid #e5e7eb;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.1rem;
  font-weight: 600;
  color: #374151;
  margin-bottom: 1rem;
}

.section-icon {
  width: 20px;
  height: 20px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  flex-shrink: 0;
}

.microphone-container {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.microphone-select {
  flex: 1;
  min-width: 0; /* Permet au select de se rétrécir */
  max-width: 100%;
}

.microphone-select option {
  padding: 0.5rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.btn-refresh {
  padding: 0.75rem 1rem;
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  color: white;
  border: none;
  border-radius: 0.75rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  min-width: 120px;
  justify-content: center;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  position: relative;
  overflow: hidden;
}

.btn-refresh::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: left 0.5s;
}

.btn-refresh:hover:not(:disabled)::before {
  left: 100%;
}

.btn-refresh:hover:not(:disabled) {
  background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
  transform: translateY(-2px);
  box-shadow: 0 8px 15px -3px rgb(0 0 0 / 0.2);
}

.btn-refresh:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.icon-refresh,
.icon-spin {
  width: 18px;
  height: 18px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.icon-spin {
  animation: spin 1s linear infinite;
}

.icon-rocket {
  width: 18px;
  height: 18px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.btn-text {
  font-size: 0.9rem;
  font-weight: 500;
}

.microphone-info {
  margin-top: 0.75rem;
}

.info-text {
  font-size: 0.9rem;
  color: #6b7280;
  margin: 0;
}

/* Responsive Design */
@media (max-width: 768px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
  
  .setup-title {
    font-size: 2rem;
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .setup-form {
    padding: 1.5rem;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .btn {
    width: 100%;
    justify-content: center;
  }
  
  .duration-inputs {
    justify-content: center;
  }
  
  .duration-input {
    width: 70px;
  }
  
  .microphone-container {
    flex-direction: column;
    align-items: stretch;
  }
  
  .btn-refresh {
    width: 100%;
  }
  
  .microphone-select {
    font-size: 0.9rem;
  }
}
</style>
