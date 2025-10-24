<template>
  <div class="assign-participants">
    <div class="assign-container">
      <div class="assign-header">
        <h1 class="assign-title">
          <svg class="assign-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
            <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
          </svg>
          Assigner les Participants
        </h1>
        <p class="assign-subtitle">
          Ajoutez les participants à votre réunion "{{ meeting.name }}"
        </p>
      </div>

      <div class="meeting-info">
        <div class="info-card">
          <h3>Informations de la Réunion</h3>
          <div class="info-grid">
            <div class="info-item">
              <svg class="info-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14,2 14,8 20,8"/>
              </svg>
              <span class="info-label">Nom :</span>
              <span class="info-value">{{ meeting.name }}</span>
            </div>
            <div class="info-item">
              <svg class="info-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                <line x1="16" y1="2" x2="16" y2="6"/>
                <line x1="8" y1="2" x2="8" y2="6"/>
              </svg>
              <span class="info-label">Date :</span>
              <span class="info-value">{{ formatDate(meeting.date) }}</span>
            </div>
            <div class="info-item">
              <svg class="info-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12,6 12,12 16,14"/>
              </svg>
              <span class="info-label">Durée :</span>
              <span class="info-value">{{ formatDuration(meeting.duration) }}</span>
            </div>
            <div class="info-item">
              <svg class="info-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
              </svg>
              <span class="info-label">Participants :</span>
              <span class="info-value">{{ participants.length }} / {{ meeting.participants }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="participants-section">
        <div class="section-header">
          <h2>Ajouter des Participants</h2>
          <button 
            @click="addParticipant" 
            class="btn btn-add"
            :disabled="participants.length >= meeting.participants"
          >
            <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/>
              <path d="M12 8v8"/>
              <path d="M8 12h8"/>
            </svg>
            Ajouter un Participant
          </button>
        </div>

        <div class="participants-list">
          <div 
            v-for="(participant, index) in participants" 
            :key="index"
            class="participant-card"
          >
            <div class="participant-info">
              <div class="participant-avatar">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                  <circle cx="12" cy="7" r="4"/>
                </svg>
              </div>
              <div class="participant-details">
                <input
                  v-model="participant.name"
                  type="text"
                  class="participant-input"
                  placeholder="Nom du participant"
                  @input="validateParticipant(index)"
                />
                <input
                  v-model="participant.email"
                  type="email"
                  class="participant-input"
                  placeholder="Email du participant"
                  @input="validateParticipant(index)"
                />
              </div>
            </div>
            <button 
              @click="removeParticipant(index)"
              class="btn btn-remove"
              :disabled="participants.length <= 1"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="18" y1="6" x2="6" y2="18"/>
                <line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </div>
        </div>

        <div v-if="participants.length === 0" class="empty-state">
          <svg class="empty-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
          </svg>
          <p>Aucun participant ajouté</p>
          <button @click="addParticipant" class="btn btn-primary">
            Ajouter le premier participant
          </button>
        </div>
      </div>

      <div class="assign-actions">
        <button @click="goBack" class="btn btn-secondary">
          ← Retour
        </button>
        <button 
          @click="assignParticipants" 
          class="btn btn-primary"
          :disabled="!canAssignParticipants"
        >
          <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09z"/>
            <path d="M12 15l-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2z"/>
          </svg>
          Finaliser l'Assignation
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AssignParticipants',
  props: {
    meeting: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      participants: []
    }
  },
  computed: {
    canAssignParticipants() {
      return this.participants.length > 0 && 
             this.participants.every(p => p.name.trim() && p.email.trim() && this.isValidEmail(p.email))
    }
  },
  methods: {
    addParticipant() {
      if (this.participants.length < this.meeting.participants) {
        this.participants.push({
          name: '',
          email: '',
          isValid: false
        })
      }
    },
    
    removeParticipant(index) {
      if (this.participants.length > 1) {
        this.participants.splice(index, 1)
      }
    },
    
    validateParticipant(index) {
      const participant = this.participants[index]
      participant.isValid = participant.name.trim() !== '' && 
                          participant.email.trim() !== '' && 
                          this.isValidEmail(participant.email)
    },
    
    isValidEmail(email) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      return emailRegex.test(email)
    },
    
    formatDate(dateString) {
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
    
    formatDuration(minutes) {
      const hours = Math.floor(minutes / 60)
      const mins = minutes % 60
      
      if (hours > 0) {
        return `${hours}h ${mins}min`
      } else {
        return `${mins}min`
      }
    },
    
    async assignParticipants() {
      if (!this.canAssignParticipants) {
        return
      }
      
      try {
        // TODO: Appel API pour assigner les participants
        // const response = await fetch(`/api/meetings/${this.meeting.meetingId}/participants`, {
        //   method: 'POST',
        //   headers: {
        //     'Content-Type': 'application/json',
        //     'Authorization': `Bearer ${token}`
        //   },
        //   body: JSON.stringify({ participants: this.participants })
        // })
        
        console.log('📋 Participants à assigner:', this.participants)
        console.log('🔗 Endpoint à configurer: POST /api/meetings/{id}/participants')
        
        // Émettre l'événement avec les participants assignés
        this.$emit('participants-assigned', this.participants)
        
      } catch (error) {
        console.error('Erreur lors de l\'assignation:', error)
        alert('❌ Erreur lors de l\'assignation des participants')
      }
    },
    
    goBack() {
      this.$emit('back')
    }
  }
}
</script>

<style scoped>
.assign-participants {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 6rem 0 2rem 0;
}

.assign-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 0 2rem;
}

.assign-header {
  text-align: center;
  margin-bottom: 3rem;
  color: white;
}

.assign-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
}

.assign-icon {
  width: 3rem;
  height: 3rem;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  flex-shrink: 0;
}

.assign-subtitle {
  font-size: 1.25rem;
  opacity: 0.9;
  max-width: 600px;
  margin: 0 auto;
}

.meeting-info {
  margin-bottom: 3rem;
}

.info-card {
  background: white;
  border-radius: 1rem;
  padding: 2rem;
  box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1);
}

.info-card h3 {
  font-size: 1.5rem;
  font-weight: 600;
  color: #374151;
  margin-bottom: 1.5rem;
  text-align: center;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem;
  background: #f8fafc;
  border-radius: 0.75rem;
  border: 1px solid #e5e7eb;
}

.info-icon {
  width: 20px;
  height: 20px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  color: #6366f1;
  flex-shrink: 0;
}

.info-label {
  font-weight: 600;
  color: #374151;
  min-width: 100px;
}

.info-value {
  color: #6b7280;
  font-weight: 500;
}

.participants-section {
  background: white;
  border-radius: 1rem;
  padding: 2rem;
  box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1);
  margin-bottom: 2rem;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.section-header h2 {
  font-size: 1.5rem;
  font-weight: 600;
  color: #374151;
}

.btn-add {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  border: none;
  border-radius: 0.75rem;
  padding: 0.75rem 1.5rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

.btn-add:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 15px -3px rgb(0 0 0 / 0.2);
}

.btn-add:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.participants-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.participant-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
  background: #f8fafc;
  border-radius: 0.75rem;
  border: 1px solid #e5e7eb;
  transition: all 0.3s ease;
}

.participant-card:hover {
  border-color: #6366f1;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}

.participant-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex: 1;
}

.participant-avatar {
  width: 48px;
  height: 48px;
  background: #6366f1;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.participant-avatar svg {
  width: 24px;
  height: 24px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.participant-details {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  flex: 1;
}

.participant-input {
  padding: 0.5rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.5rem;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.participant-input:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgb(99 102 241 / 0.1);
}

.btn-remove {
  background: #ef4444;
  color: white;
  border: none;
  border-radius: 0.5rem;
  padding: 0.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
}

.btn-remove:hover:not(:disabled) {
  background: #dc2626;
  transform: scale(1.05);
}

.btn-remove:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-remove svg {
  width: 16px;
  height: 16px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.empty-state {
  text-align: center;
  padding: 3rem 2rem;
  color: #6b7280;
}

.empty-icon {
  width: 4rem;
  height: 4rem;
  stroke: currentColor;
  stroke-width: 1.5;
  stroke-linecap: round;
  stroke-linejoin: round;
  margin: 0 auto 1rem;
  color: #9ca3af;
}

.empty-state p {
  font-size: 1.1rem;
  margin-bottom: 1.5rem;
}

.assign-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
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
  box-shadow: 0 8px 15px -3px rgb(0 0 0 / 0.2);
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

.btn-icon {
  width: 18px;
  height: 18px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
}

/* Responsive Design */
@media (max-width: 768px) {
  .assign-title {
    font-size: 2rem;
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .assign-container {
    padding: 0 1rem;
  }
  
  .info-grid {
    grid-template-columns: 1fr;
  }
  
  .section-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
  
  .participant-card {
    flex-direction: column;
    align-items: stretch;
  }
  
  .participant-info {
    flex-direction: column;
    align-items: stretch;
  }
  
  .assign-actions {
    flex-direction: column;
  }
  
  .btn {
    width: 100%;
    justify-content: center;
  }
}
</style>
