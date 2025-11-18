<template>
  <div class="manage-participants">
    <div class="manage-container">
      <div class="manage-header">
        <h1 class="manage-title">
          <svg class="manage-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
            <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
          </svg>
          Gérer les Participants
        </h1>
        <p class="manage-subtitle">
          {{ meeting.title }}
        </p>
      </div>

      <!-- Informations de la réunion -->
      <div class="meeting-info-card">
        <div class="info-item">
          <span class="info-label">Statut:</span>
          <span class="info-value status-badge" :class="`status-${meeting.status}`">
            {{ getStatusLabel(meeting.status) }}
          </span>
        </div>
        <div class="info-item">
          <span class="info-label">Date:</span>
          <span class="info-value">{{ formatDate(meeting.scheduledAt) }}</span>
        </div>
        <div class="info-item">
          <span class="info-label">Durée:</span>
          <span class="info-value">{{ formatDuration(meeting.durationMinutes) }}</span>
        </div>
      </div>

      <!-- Liste des participants actuels -->
      <div class="participants-section">
        <div class="section-header">
          <h2>Participants ({{ participants.length }})</h2>
          <button 
            @click="showAddForm = !showAddForm" 
            class="btn btn-primary"
            :disabled="meeting.status === 'completed'"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/>
              <path d="M12 8v8"/>
              <path d="M8 12h8"/>
            </svg>
            Ajouter un participant
          </button>
        </div>

        <!-- Formulaire d'ajout -->
        <div v-if="showAddForm" class="add-participant-form">
          <div class="form-row">
            <div class="form-group">
              <label>Prénom</label>
              <input v-model="newParticipant.firstname" type="text" class="form-input" placeholder="Prénom" />
            </div>
            <div class="form-group">
              <label>Nom</label>
              <input v-model="newParticipant.lastname" type="text" class="form-input" placeholder="Nom" />
            </div>
          </div>
          <div class="form-group">
            <label>Email *</label>
            <input v-model="newParticipant.email" type="email" class="form-input" placeholder="email@example.com" required />
          </div>
          <div class="form-actions">
            <button @click="addParticipant" class="btn btn-primary" :disabled="!canAddParticipant || isAdding">
              {{ isAdding ? 'Ajout...' : 'Ajouter' }}
            </button>
            <button @click="cancelAdd" class="btn btn-secondary">Annuler</button>
          </div>
        </div>

        <!-- Liste des participants -->
        <div v-if="participants.length > 0" class="participants-list">
          <div 
            v-for="participant in participants" 
            :key="participant.id"
            class="participant-item"
          >
            <div class="participant-avatar">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
            </div>
            <div class="participant-info">
              <div class="participant-name">{{ participant.fullName }}</div>
              <div class="participant-email">{{ participant.email }}</div>
            </div>
            <button 
              @click="removeParticipant(participant.id)"
              class="btn btn-danger"
              :disabled="meeting.status === 'completed' || isRemoving"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="18" y1="6" x2="6" y2="18"/>
                <line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </div>
        </div>
        <div v-else class="empty-state">
          <p>Aucun participant pour cette réunion</p>
        </div>
      </div>

      <!-- Actions -->
      <div class="action-bar">
        <button @click="goBack" class="btn btn-secondary">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="19" y1="12" x2="5" y2="12"/>
            <polyline points="12,19 5,12 12,5"/>
          </svg>
          Retour
        </button>
        <button @click="refreshParticipants" class="btn btn-outline" :disabled="isLoading">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="23,4 23,10 17,10"/>
            <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/>
          </svg>
          Actualiser
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { apiService } from '../services/api.js'

export default {
  name: 'ManageParticipants',
  
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
        durationMinutes: 0,
        status: 'scheduled'
      },
      participants: [],
      isLoading: false,
      error: null,
      showAddForm: false,
      isAdding: false,
      isRemoving: false,
      newParticipant: {
        firstname: '',
        lastname: '',
        email: ''
      }
    }
  },
  
  computed: {
    canAddParticipant() {
      return this.newParticipant.email.trim() && 
             (this.newParticipant.firstname.trim() || this.newParticipant.lastname.trim())
    }
  },
  
  async mounted() {
    await this.loadMeeting()
    await this.loadParticipants()
  },
  
  methods: {
    async loadMeeting() {
      try {
        const response = await apiService.getMeetingById(this.meetingId)
        this.meeting = response
      } catch (error) {
        console.error('Erreur lors du chargement de la réunion:', error)
        this.error = 'Impossible de charger les informations de la réunion'
      }
    },
    
    async loadParticipants() {
      this.isLoading = true
      this.error = null
      
      try {
        const response = await apiService.getParticipantsByMeeting(this.meetingId)
        this.participants = Array.isArray(response) ? response : []
      } catch (error) {
        console.error('Erreur lors du chargement des participants:', error)
        this.error = 'Impossible de charger les participants'
      } finally {
        this.isLoading = false
      }
    },
    
    async addParticipant() {
      if (!this.canAddParticipant) return
      
      this.isAdding = true
      
      try {
        const participantData = {
          firstname: this.newParticipant.firstname.trim(),
          lastname: this.newParticipant.lastname.trim(),
          email: this.newParticipant.email.trim()
        }
        
        await apiService.addParticipant(this.meetingId, participantData)
        
        // Réinitialiser le formulaire
        this.newParticipant = { firstname: '', lastname: '', email: '' }
        this.showAddForm = false
        
        // Recharger la liste
        await this.loadParticipants()
        
        alert('✅ Participant ajouté avec succès')
      } catch (error) {
        console.error('Erreur lors de l\'ajout du participant:', error)
        alert(error?.message || '❌ Erreur lors de l\'ajout du participant')
      } finally {
        this.isAdding = false
      }
    },
    
    async removeParticipant(participantId) {
      if (!confirm('Êtes-vous sûr de vouloir retirer ce participant ?')) {
        return
      }
      
      this.isRemoving = true
      
      try {
        await apiService.removeParticipant(this.meetingId, participantId)
        
        // Recharger la liste
        await this.loadParticipants()
        
        alert('✅ Participant retiré avec succès')
      } catch (error) {
        console.error('Erreur lors de la suppression du participant:', error)
        alert(error?.message || '❌ Erreur lors de la suppression du participant')
      } finally {
        this.isRemoving = false
      }
    },
    
    cancelAdd() {
      this.newParticipant = { firstname: '', lastname: '', email: '' }
      this.showAddForm = false
    },
    
    async refreshParticipants() {
      await this.loadParticipants()
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
    
    formatDate(dateString) {
      if (!dateString) return 'Date non définie'
      const date = new Date(dateString)
      return date.toLocaleDateString('fr-FR', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    },
    
    formatDuration(minutes) {
      if (!minutes) return 'Durée non définie'
      const hours = Math.floor(minutes / 60)
      const mins = minutes % 60
      if (hours > 0) {
        return `${hours}h ${mins}min`
      }
      return `${mins}min`
    },
    
    goBack() {
      this.$emit('back')
    }
  }
}
</script>

<style scoped>
.manage-participants {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 2rem 1rem;
}

.manage-container {
  max-width: 1000px;
  margin: 0 auto;
}

.manage-header {
  text-align: center;
  margin-bottom: 2rem;
  color: white;
}

.manage-title {
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
}

.manage-icon {
  width: 2.5rem;
  height: 2.5rem;
}

.manage-subtitle {
  font-size: 1.2rem;
  opacity: 0.9;
}

.meeting-info-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 2rem;
  display: flex;
  gap: 2rem;
  flex-wrap: wrap;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-label {
  font-size: 0.85rem;
  color: #6b7280;
  font-weight: 500;
}

.info-value {
  font-size: 1rem;
  color: #374151;
  font-weight: 600;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.85rem;
  display: inline-block;
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
}

.participants-section {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  margin-bottom: 2rem;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.section-header h2 {
  font-size: 1.5rem;
  color: #374151;
}

.add-participant-form {
  background: #f8fafc;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 2rem;
  border: 1px solid #e5e7eb;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  font-weight: 500;
  color: #374151;
  font-size: 0.9rem;
}

.form-input {
  padding: 0.75rem;
  border: 2px solid #e5e7eb;
  border-radius: 0.5rem;
  font-size: 1rem;
  transition: all 0.3s ease;
}

.form-input:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgb(99 102 241 / 0.1);
}

.form-actions {
  display: flex;
  gap: 1rem;
  margin-top: 1rem;
}

.participants-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.participant-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: #f8fafc;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
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
}

.participant-info {
  flex: 1;
}

.participant-name {
  font-weight: 600;
  color: #374151;
  margin-bottom: 0.25rem;
}

.participant-email {
  font-size: 0.9rem;
  color: #6b7280;
}

.btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 0.5rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.btn svg {
  width: 18px;
  height: 18px;
}

.btn-primary {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.btn-secondary {
  background: #f3f4f6;
  color: #374151;
  border: 1px solid #d1d5db;
}

.btn-secondary:hover {
  background: #e5e7eb;
}

.btn-danger {
  background: #ef4444;
  color: white;
  padding: 0.5rem;
  min-width: 40px;
}

.btn-danger:hover:not(:disabled) {
  background: #dc2626;
}

.btn-outline {
  background: transparent;
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.4);
}

.btn-outline:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.15);
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.action-bar {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
}

.empty-state {
  text-align: center;
  padding: 3rem 2rem;
  color: #6b7280;
}

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }
  
  .section-header {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }
  
  .action-bar {
    flex-direction: column;
  }
  
  .btn {
    width: 100%;
    justify-content: center;
  }
}
</style>

