<template>
  <div class="meetings-list-page">
    <div class="meetings-container">
      <div class="meetings-header">
        <h1 class="meetings-title">
          <svg class="meetings-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
            <circle cx="12" cy="12" r="3"/>
          </svg>
          Mes réunions
        </h1>
        <p class="meetings-subtitle">
          Consultez et visualisez toutes vos réunions enregistrées
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

      <!-- Meetings Grid -->
      <div v-else-if="meetings.length > 0" class="meetings-grid">
        <div 
          v-for="meeting in meetings" 
          :key="meeting.id"
          class="meeting-card-view"
          @click="viewMeetingDetails(meeting.id)"
        >
          <div class="meeting-card-header">
            <div class="meeting-status-badge" :class="`status-${meeting.status}`">
              {{ getStatusLabel(meeting.status) }}
            </div>
          </div>

          <div class="meeting-card-body">
            <h3 class="meeting-card-title">{{ meeting.title }}</h3>
            <p class="meeting-card-description" v-if="meeting.description">
              {{ meeting.description }}
            </p>

            <div class="meeting-card-details">
              <div class="detail-row">
                <svg class="detail-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                  <line x1="16" y1="2" x2="16" y2="6"/>
                  <line x1="8" y1="2" x2="8" y2="6"/>
                </svg>
                <span>{{ formatDate(meeting.scheduledAt) }}</span>
              </div>
              <div class="detail-row">
                <svg class="detail-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <circle cx="12" cy="12" r="10"/>
                  <polyline points="12,6 12,12 16,14"/>
                </svg>
                <span>{{ formatDuration(meeting.durationMinutes) }}</span>
              </div>
              <div class="detail-row">
                <svg class="detail-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                  <circle cx="9" cy="7" r="4"/>
                </svg>
                <span>{{ meeting.participants?.length || 0 }} participants</span>
              </div>
            </div>
          </div>

          <div class="meeting-card-footer">
            <button class="btn-view" @click.stop="viewMeetingDetails(meeting.id)">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                <circle cx="12" cy="12" r="3"/>
              </svg>
              Voir la réunion
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
        <h3>Aucune réunion disponible</h3>
        <p>Vous n'avez pas encore de réunions enregistrées.</p>
        <button @click="goToPlan" class="btn btn-primary">
          Planifier une réunion
        </button>
      </div>

      <!-- Action Buttons -->
      <div class="action-bar">
        <button @click="goBack" class="btn btn-secondary">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="19" y1="12" x2="5" y2="12"/>
            <polyline points="12,19 5,12 12,5"/>
          </svg>
          Retour
        </button>
        <button @click="refreshMeetings" class="btn btn-outline">
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
  name: 'MeetingsList',
  
  data() {
    return {
      meetings: [],
      isLoading: false,
      error: null
    }
  },

  async mounted() {
    await this.loadMeetings()
  },

  methods: {
    async loadMeetings() {
      this.isLoading = true
      this.error = null

      try {
        const response = await apiService.getAllMeetings()
        
        if (Array.isArray(response)) {
          this.meetings = response
        } else if (response.data && Array.isArray(response.data)) {
          this.meetings = response.data
        } else {
          this.meetings = []
        }
      } catch (error) {
        console.error('Erreur lors du chargement des réunions:', error)
        this.error = 'Impossible de charger les réunions. Veuillez réessayer.'
      } finally {
        this.isLoading = false
      }
    },

    refreshMeetings() {
      this.loadMeetings()
    },

    viewMeetingDetails(meetingId) {
      this.$emit('view-meeting', meetingId)
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

    formatDuration(minutes) {
      const hours = Math.floor(minutes / 60)
      const mins = minutes % 60
      if (hours > 0) {
        return `${hours}h${mins > 0 ? ` ${mins}min` : ''}`
      }
      return `${mins} min`
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
.meetings-list-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 2rem 1rem;
}

.meetings-container {
  max-width: 1200px;
  margin: 0 auto;
}

.meetings-header {
  text-align: center;
  margin-bottom: 3rem;
  color: white;
}

.meetings-title {
  font-size: 2.5rem;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
}

.meetings-icon {
  width: 2.5rem;
  height: 2.5rem;
}

.meetings-subtitle {
  font-size: 1.1rem;
  opacity: 0.9;
}

/* Meetings Grid */
.meetings-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
}

.meeting-card-view {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  display: flex;
  flex-direction: column;
}

.meeting-card-view:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
}

.meeting-card-header {
  padding: 1rem;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  display: flex;
  justify-content: flex-end;
}

.meeting-status-badge {
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
}

.status-cancelled {
  background: #ffebee;
  color: #d32f2f;
}

.meeting-card-body {
  padding: 1.5rem;
  flex: 1;
}

.meeting-card-title {
  font-size: 1.5rem;
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.meeting-card-description {
  color: #7f8c8d;
  margin-bottom: 1.5rem;
  line-height: 1.5;
}

.meeting-card-details {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.detail-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #555;
  font-size: 0.95rem;
}

.detail-icon {
  width: 18px;
  height: 18px;
  color: #667eea;
}

.meeting-card-footer {
  padding: 1rem 1.5rem;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
}

.btn-view {
  width: 100%;
  padding: 0.75rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
}

.btn-view:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.btn-view svg {
  width: 18px;
  height: 18px;
}

/* Action Bar */
.action-bar {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  margin-top: 2rem;
}

.btn {
  padding: 0.875rem 1.5rem;
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
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(16, 185, 129, 0.3);
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.3);
  backdrop-filter: blur(10px);
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
}

.btn-outline {
  background: transparent;
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.4);
}

.btn-outline:hover {
  background: rgba(255, 255, 255, 0.15);
  border-color: rgba(255, 255, 255, 0.7);
  transform: translateY(-2px);
}

/* Loading State */
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem 2rem;
  color: white;
}

.loading-spinner-large {
  width: 48px;
  height: 48px;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Error State */
.error-state {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.3);
  padding: 2rem;
  border-radius: 12px;
  text-align: center;
  color: white;
}

.error-icon {
  width: 48px;
  height: 48px;
  margin-bottom: 1rem;
}

.error-message {
  margin-bottom: 1.5rem;
  font-size: 1.1rem;
}

/* Empty State */
.empty-state {
  background: rgba(255, 255, 255, 0.1);
  border: 2px dashed rgba(255, 255, 255, 0.3);
  border-radius: 12px;
  padding: 4rem 2rem;
  text-align: center;
  color: white;
}

.empty-icon {
  width: 64px;
  height: 64px;
  margin: 0 auto 1.5rem;
  opacity: 0.7;
}

.empty-state h3 {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
}

.empty-state p {
  margin-bottom: 2rem;
  opacity: 0.9;
}

/* Responsive */
@media (max-width: 768px) {
  .meetings-grid {
    grid-template-columns: 1fr;
  }

  .meetings-title {
    font-size: 2rem;
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
