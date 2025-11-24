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

          <!-- Participants (optionnel) -->
          <div class="form-group form-group-full">
            <div class="participants-header">
              <label class="form-label">
                <svg class="label-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                  <circle cx="9" cy="7" r="4"/>
                  <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                  <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                </svg>
                Participants (optionnel)
              </label>
              <button type="button" @click="addParticipantRow" class="btn-add-participant">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <circle cx="12" cy="12" r="10"/>
                  <path d="M12 8v8"/>
                  <path d="M8 12h8"/>
                </svg>
                Ajouter un participant
              </button>
            </div>
            <div v-if="participantsList.length > 0" class="participants-list-setup">
              <div v-for="(participant, index) in participantsList" :key="index" class="participant-row">
                <input
                  v-model="participant.firstname"
                  type="text"
                  class="form-input-small"
                  placeholder="Prénom"
                />
                <input
                  v-model="participant.lastname"
                  type="text"
                  class="form-input-small"
                  placeholder="Nom"
                />
                <input
                  v-model="participant.email"
                  type="email"
                  class="form-input-small"
                  placeholder="email@example.com"
                />
                <button type="button" @click="removeParticipantRow(index)" class="btn-remove-participant">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="18" y1="6" x2="6" y2="18"/>
                    <line x1="6" y1="6" x2="18" y2="18"/>
                  </svg>
                </button>
              </div>
            </div>
            <p class="form-hint">Vous pourrez ajouter des participants plus tard</p>
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

          <!-- Langue de la réunion -->
          <div class="form-group">
            <label for="language" class="form-label">
              <svg class="label-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <path d="M2 12h20"/>
                <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
              </svg>
              Langue de la réunion *
            </label>
            <select
              id="language"
              v-model="meetingData.language"
              class="form-select"
              required
            >
              <option value="fr">Français</option>
              <option value="en">English</option>
              <option value="es">Español</option>
              <option value="de">Deutsch</option>
              <option value="it">Italiano</option>
              <option value="pt">Português</option>
              <option value="ar">العربية</option>
            </select>
            <div v-if="errors.language" class="error-message">{{ errors.language }}</div>
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
import { apiService } from '../services/api.js'

export default {
  name: 'SetupMeeting',
  data() {
    return {
      meetingData: {
        name: '',
        date: '',
        duration: '',
        language: 'fr',
        description: '',
        autoStart: true,
        sendReminders: false
      },
      participantsList: [],
      durationType: 'preset',
      customHours: 0,
      customMinutes: 0,
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
  methods: {
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
    
    addParticipantRow() {
      this.participantsList.push({
        firstname: '',
        lastname: '',
        email: ''
      })
    },
    
    removeParticipantRow(index) {
      this.participantsList.splice(index, 1)
    },
    
    async clearMeetingsCache() {
      try {
        // Vider le cache pour la route /api/meeting/all
        const { cacheService } = await import('../services/cacheService.js')
        const cacheKey = 'GET:http://localhost:8081/api/meeting/all'
        await cacheService.delete(cacheKey)
        console.log('🗑️ Cache invalidé pour:', cacheKey)
      } catch (error) {
        console.warn('Erreur lors de l\'invalidation du cache:', error)
      }
    },
    
    async createMeeting() {
      if (!this.validateForm()) {
        return
      }
      
      const isCustom = this.durationType === 'custom'
      const totalMinutes = isCustom
        ? (this.customHours * 60) + this.customMinutes
        : Number(this.meetingData.duration)

      // Filtrer les participants valides (avec au moins un email)
      const validParticipants = this.participantsList
        .filter(p => p.email && p.email.trim())
        .map(p => ({
          firstname: p.firstname.trim() || undefined,
          lastname: p.lastname.trim() || undefined,
          email: p.email.trim()
        }))
      
      const payload = {
        name: this.meetingData.name.trim(),
        date: new Date(this.meetingData.date).toISOString(),
        duration: Number.isFinite(totalMinutes) ? Number(totalMinutes) : undefined,
        participants: validParticipants, // Liste de ParticipantRequest
        language: this.meetingData.language || 'fr',
        description: this.meetingData.description?.trim?.() || '',
        status: 'scheduled', // Statut par défaut
        autoStart: Boolean(this.meetingData.autoStart),
        sendReminders: Boolean(this.meetingData.sendReminders),
        metadata: {
          durationType: this.durationType,
          customDurationText: this.customDurationText || null
        }
      }
      
      this.isLoading = true
      
      try {
        console.log('📤 Création de la réunion avec payload:', payload)
        const response = await apiService.createMeeting(payload)
        console.log('✅ Réponse reçue du backend:', response)
        
        // Le backend retourne directement l'objet MeetingResponse
        // ou peut-être dans response.data selon le format
        const meeting = response?.data || response
        console.log('📋 Objet meeting extrait:', meeting)
        
        if (!meeting || !meeting.id) {
          console.error('❌ Pas d\'ID dans la réponse:', meeting)
          throw new Error('Réponse inattendue du serveur.')
        }

        console.log('🎉 Réunion créée avec succès, ID:', meeting.id)
        
        // Invalider le cache pour forcer le rechargement de la liste
        await this.clearMeetingsCache()
        
        alert(`✅ Réunion "${meeting.title}" créée avec succès !`)
        this.$emit('meeting-created', meeting)
      } catch (error) {
        console.error('Erreur lors de la création:', error)
        const details = error?.details?.errors
        if (details) {
          this.errors = {
            ...this.errors,
            ...details
          }
        }
        alert(error?.message || '❌ Erreur lors de la création de la réunion')
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
.icon-rocket {
  width: 18px;
  height: 18px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
}

/* Styles pour les participants */
.form-group-full {
  grid-column: 1 / -1;
}

.participants-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.btn-add-participant {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: #10b981;
  color: white;
  border: none;
  border-radius: 0.5rem;
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-add-participant:hover {
  background: #059669;
  transform: translateY(-1px);
}

.btn-add-participant svg {
  width: 16px;
  height: 16px;
}

.participants-list-setup {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.participant-row {
  display: grid;
  grid-template-columns: 1fr 1fr 1.5fr auto;
  gap: 0.5rem;
  align-items: center;
}

.form-input-small {
  padding: 0.625rem 0.875rem;
  border: 2px solid #e5e7eb;
  border-radius: 0.5rem;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.form-input-small:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgb(99 102 241 / 0.1);
}

.btn-remove-participant {
  padding: 0.5rem;
  background: #ef4444;
  color: white;
  border: none;
  border-radius: 0.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-remove-participant:hover {
  background: #dc2626;
  transform: scale(1.05);
}

.btn-remove-participant svg {
  width: 16px;
  height: 16px;
}

.form-hint {
  font-size: 0.85rem;
  color: #6b7280;
  font-style: italic;
}

.icon-spin {
  width: 18px;
  height: 18px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  animation: spin 1s linear infinite;
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
}
</style>
