<template>
  <div class="start-meeting">
    <div class="start-container">
      <div class="start-header">
        <h1 class="start-title">
          <svg class="start-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09z"/>
            <path d="M12 15l-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2z"/>
            <path d="M9 12H4s.55-3.03 2-4c1.62-1.08 5 0 5 0"/>
            <path d="M12 15v5s3.03-.55 4-2c1.08-1.62 0-5 0-5"/>
          </svg>
          Commencer une réunion
        </h1>
        <p class="start-subtitle">
          Sélectionnez une réunion planifiée pour démarrer la transcription
        </p>
      </div>

      <!-- Loading State -->
      <div v-if="isLoading" class="loading-state">
        <svg class="loading-spinner-large" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 12a9 9 0 11-6.219-8.56"/>
        </svg>
        <p>Chargement des réunions...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="error-state">
        <svg class="error-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10"/>
          <line x1="12" y1="8" x2="12" y2="12"/>
          <line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
        <p class="error-message">{{ error }}</p>
        <button @click="loadMeetings" class="btn btn-primary">
          Réessayer
        </button>
      </div>

      <!-- Meetings List -->
      <div v-else-if="meetings.length > 0" class="meetings-list">
        <div 
          v-for="meeting in meetings" 
          :key="meeting.id"
          class="meeting-card"
          :class="{ 'selected': selectedMeeting?.id === meeting.id, 'starting': startingMeetingId === meeting.id }"
        >
          <div class="meeting-card-header">
            <div class="meeting-info">
              <h3 class="meeting-title">{{ meeting.title }}</h3>
              <p class="meeting-description" v-if="meeting.description">
                {{ meeting.description }}
              </p>
            </div>
            <div class="meeting-status" :class="`status-${meeting.status}`">
              {{ getStatusLabel(meeting.status) }}
            </div>
          </div>

          <div class="meeting-details">
            <div class="detail-item">
              <svg class="detail-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                <line x1="16" y1="2" x2="16" y2="6"/>
                <line x1="8" y1="2" x2="8" y2="6"/>
              </svg>
              <span>{{ formatDate(meeting.scheduledAt) }}</span>
            </div>
            <div class="detail-item">
              <svg class="detail-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12,6 12,12 16,14"/>
              </svg>
              <span>{{ formatDuration(meeting.durationMinutes) }}</span>
            </div>
            <div class="detail-item">
              <svg class="detail-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
              </svg>
              <span>{{ meeting.participants?.length || 0 }} / {{ meeting.participantSlots || 0 }} participants</span>
            </div>
          </div>

          <div class="meeting-actions">
            <button 
              @click="$emit('view-meeting', meeting.id)"
              class="btn btn-secondary"
              :disabled="startingMeetingId !== null"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px; margin-right: 6px;">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                <circle cx="12" cy="12" r="3"/>
              </svg>
              Voir la réunion
            </button>
            <button 
              @click="selectMeeting(meeting)"
              class="btn btn-secondary"
              :disabled="startingMeetingId !== null"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 16px; height: 16px; margin-right: 6px;">
                <circle cx="12" cy="12" r="10"/>
                <line x1="12" y1="16" x2="12" y2="12"/>
                <line x1="12" y1="8" x2="12.01" y2="8"/>
              </svg>
              Détails
            </button>
            <button 
              @click="startSelectedMeeting(meeting)"
              class="btn btn-primary"
              :disabled="startingMeetingId !== null || meeting.status === 'completed'"
            >
              <svg v-if="startingMeetingId === meeting.id" class="icon-spin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 12a9 9 0 11-6.219-8.56"/>
              </svg>
              <svg v-else class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09z"/>
                <path d="M12 15l-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2z"/>
              </svg>
              {{ startingMeetingId === meeting.id ? 'Démarrage...' : 'Démarrer la réunion' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state">
        <svg class="empty-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
          <line x1="16" y1="2" x2="16" y2="6"/>
          <line x1="8" y1="2" x2="8" y2="6"/>
          <line x1="3" y1="10" x2="21" y2="10"/>
        </svg>
        <p>Aucune réunion disponible</p>
        <p class="empty-subtitle">Créez une nouvelle réunion pour commencer</p>
        <button @click="goToPlan" class="btn btn-primary">
          Planifier une réunion
        </button>
      </div>

      <!-- Action Buttons -->
      <div class="start-actions">
        <button @click="goBack" class="btn btn-secondary">
          ← Retour à l'accueil
        </button>
        <button @click="refreshMeetings" class="btn btn-secondary" :disabled="isLoading">
          <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/>
            <path d="M21 3v5h-5"/>
            <path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/>
            <path d="M3 21v-5h5"/>
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
  name: 'StartMeeting',
  data() {
    return {
      meetings: [],
      selectedMeeting: null,
      isLoading: false,
      error: null,
      startingMeetingId: null
    }
  },
  async mounted() {
    await this.loadMeetings()
  },
  methods: {
    viewMeeting(meetingId) {
      this.$emit('view-meeting', meetingId);
    },
    async loadMeetings() {
      this.isLoading = true
      this.error = null

      try {
        const response = await apiService.getAllMeetings()
        
        // Gérer différents formats de réponse
        if (Array.isArray(response)) {
          this.meetings = response
        } else if (response?.data && Array.isArray(response.data)) {
          this.meetings = response.data
        } else if (response?.meetings && Array.isArray(response.meetings)) {
          this.meetings = response.meetings
        } else {
          this.meetings = []
        }

        // Trier par date (plus récentes en premier)
        this.meetings.sort((a, b) => {
          return new Date(b.scheduledAt || b.createdAt) - new Date(a.scheduledAt || a.createdAt)
        })
      } catch (error) {
        console.error('Erreur lors du chargement des réunions:', error)
        this.error = error?.message || 'Impossible de charger les réunions'
      } finally {
        this.isLoading = false
      }
    },

    async refreshMeetings() {
      await this.loadMeetings()
    },

    selectMeeting(meeting) {
      this.selectedMeeting = this.selectedMeeting?.id === meeting.id ? null : meeting
    },

    async startSelectedMeeting(meeting) {
      if (this.startingMeetingId) return

      this.startingMeetingId = meeting.id

      try {
        const response = await apiService.startMeeting(meeting.id)
        
        // Émettre un événement pour notifier le parent
        this.$emit('meeting-started', {
          meeting,
          response
        })

        // Afficher un message de succès
        alert('✅ Réunion démarrée avec succès !')
        
      } catch (error) {
        console.error('Erreur lors du démarrage:', error)
        alert(error?.message || '❌ Erreur lors du démarrage de la réunion')
      } finally {
        this.startingMeetingId = null
      }
    },

    getStatusLabel(status) {
      const labels = {
        'scheduled': 'Planifiée',
        'in_progress': 'En cours',
        'completed': 'Terminée',
        'cancelled': 'Annulée'
      }
      return labels[status] || status
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

    formatDuration(minutes) {
      if (!minutes) return 'Durée non définie'
      const hours = Math.floor(minutes / 60)
      const mins = minutes % 60
      
      if (hours > 0) {
        return `${hours}h ${mins}min`
      } else {
        return `${mins}min`
      }
    },

    goBack() {
      this.$emit('back')
    },

    goToPlan() {
      this.$emit('go-to-plan')
    }
  }
}
</script>

<style scoped>
.start-meeting {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 6rem 0 2rem 0;
}

.start-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 0 2rem;
}

.start-header {
  text-align: center;
  margin-bottom: 3rem;
  color: white;
}

.start-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
}

.start-icon {
  width: 3rem;
  height: 3rem;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  flex-shrink: 0;
}

.start-subtitle {
  font-size: 1.25rem;
  opacity: 0.9;
  max-width: 600px;
  margin: 0 auto;
}

.loading-state,
.error-state,
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  background: white;
  border-radius: 1rem;
  box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1);
  color: #374151;
}

.loading-spinner-large {
  width: 4rem;
  height: 4rem;
  stroke: #6366f1;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  animation: spin 1s linear infinite;
  margin: 0 auto 1.5rem;
}

.error-icon {
  width: 4rem;
  height: 4rem;
  stroke: #ef4444;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  margin: 0 auto 1.5rem;
}

.empty-icon {
  width: 4rem;
  height: 4rem;
  stroke: #9ca3af;
  stroke-width: 1.5;
  stroke-linecap: round;
  stroke-linejoin: round;
  margin: 0 auto 1.5rem;
}

.error-message {
  color: #ef4444;
  font-size: 1.1rem;
  margin-bottom: 1.5rem;
}

.empty-state p {
  font-size: 1.1rem;
  margin-bottom: 0.5rem;
  color: #374151;
}

.empty-subtitle {
  color: #6b7280;
  font-size: 0.95rem;
  margin-bottom: 2rem;
}

.meetings-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.meeting-card {
  background: white;
  border-radius: 1rem;
  padding: 2rem;
  box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.meeting-card:hover {
  box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
  transform: translateY(-2px);
}

.meeting-card.selected {
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgb(99 102 241 / 0.1);
}

.meeting-card.starting {
  opacity: 0.7;
  pointer-events: none;
}

.meeting-card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1.5rem;
  gap: 1rem;
}

.meeting-info {
  flex: 1;
}

.meeting-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: #374151;
  margin-bottom: 0.5rem;
}

.meeting-description {
  color: #6b7280;
  font-size: 0.95rem;
  line-height: 1.5;
}

.meeting-status {
  padding: 0.5rem 1rem;
  border-radius: 0.5rem;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
  white-space: nowrap;
}

.status-scheduled {
  background: #dbeafe;
  color: #1e40af;
}

.status-in_progress {
  background: #fef3c7;
  color: #92400e;
}

.status-completed {
  background: #d1fae5;
  color: #065f46;
}

.status-cancelled {
  background: #fee2e2;
  color: #991b1b;
}

.meeting-details {
  display: flex;
  flex-wrap: wrap;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: #f8fafc;
  border-radius: 0.75rem;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #374151;
  font-size: 0.9rem;
}

.detail-icon {
  width: 18px;
  height: 18px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  color: #6366f1;
  flex-shrink: 0;
}

.meeting-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
}

.start-actions {
  display: flex;
  gap: 1rem;
  justify-content: space-between;
  padding-top: 2rem;
  border-top: 1px solid rgba(255, 255, 255, 0.2);
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
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.btn-secondary:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.2);
}

.btn-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-icon {
  width: 18px;
  height: 18px;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
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

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

/* Responsive Design */
@media (max-width: 768px) {
  .start-title {
    font-size: 2rem;
    flex-direction: column;
    gap: 0.5rem;
  }

  .meeting-card {
    padding: 1.5rem;
  }

  .meeting-card-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .meeting-details {
    flex-direction: column;
    gap: 1rem;
  }

  .meeting-actions {
    flex-direction: column;
  }

  .btn {
    width: 100%;
    justify-content: center;
  }

  .start-actions {
    flex-direction: column;
  }
}
</style>

