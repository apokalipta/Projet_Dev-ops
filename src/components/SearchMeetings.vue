<template>
  <div class="search-meetings">
    <div class="search-container">
      <div class="search-header">
        <h1 class="search-title">
          <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="11" cy="11" r="8"/>
            <path d="m21 21-4.35-4.35"/>
          </svg>
          Rechercher une réunion
        </h1>
        <p class="search-subtitle">
          Recherchez vos réunions par titre
        </p>
      </div>

      <!-- Barre de recherche -->
      <div class="search-bar-container">
        <div class="search-input-wrapper">
          <svg class="search-input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="11" cy="11" r="8"/>
            <path d="m21 21-4.35-4.35"/>
          </svg>
          <input
            type="text"
            v-model="searchQuery"
            @input="onSearchInput"
            @keyup.enter="performSearch"
            class="search-input"
            placeholder="Tapez le titre de la réunion..."
          />
          <button 
            v-if="searchQuery" 
            @click="clearSearch" 
            class="clear-button"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="18" y1="6" x2="6" y2="18"/>
              <line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>
        <button @click="performSearch" class="btn btn-primary search-button" :disabled="!searchQuery.trim()">
          Rechercher
        </button>
      </div>

      <!-- Loading State -->
      <div v-if="isLoading" class="loading-state">
        <svg class="loading-spinner" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 12a9 9 0 11-6.219-8.56"/>
        </svg>
        <p>Recherche en cours...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="error-state">
        <svg class="error-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="10"/>
          <line x1="12" y1="8" x2="12" y2="12"/>
          <line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
        <p class="error-message">{{ error }}</p>
        <button @click="performSearch" class="btn btn-primary">
          Réessayer
        </button>
      </div>

      <!-- Results -->
      <div v-else-if="hasSearched">
        <div v-if="meetings.length > 0" class="results-section">
          <h2 class="results-title">
            {{ meetings.length }} réunion{{ meetings.length > 1 ? 's' : '' }} trouvée{{ meetings.length > 1 ? 's' : '' }}
          </h2>
          <div class="meetings-grid">
            <div 
              v-for="meeting in meetings" 
              :key="meeting.id"
              class="meeting-card"
              :class="{ 'meeting-completed': meeting.status === 'completed' }"
              @click="viewMeeting(meeting.id)"
            >
              <div class="meeting-card-header">
                <div class="meeting-status-badge" :class="`status-${meeting.status}`">
                  <svg v-if="meeting.status === 'completed'" class="status-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M20 6L9 17l-5-5"/>
                  </svg>
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
                <button class="btn-view" @click.stop="viewMeeting(meeting.id)">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                    <circle cx="12" cy="12" r="3"/>
                  </svg>
                  Voir la réunion
                </button>
              </div>
            </div>
          </div>
        </div>
        <div v-else class="empty-state">
          <svg class="empty-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="11" cy="11" r="8"/>
            <path d="m21 21-4.35-4.35"/>
          </svg>
          <h3>Aucune réunion trouvée</h3>
          <p>Aucune réunion ne correspond à votre recherche "{{ searchQuery }}"</p>
        </div>
      </div>

      <!-- Empty State (avant recherche) -->
      <div v-else class="empty-state initial-state">
        <svg class="empty-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="11" cy="11" r="8"/>
          <path d="m21 21-4.35-4.35"/>
        </svg>
        <h3>Recherchez une réunion</h3>
        <p>Tapez le titre d'une réunion dans la barre de recherche ci-dessus</p>
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
      </div>
    </div>
  </div>
</template>

<script>
import { apiService } from '../services/api.js'

export default {
  name: 'SearchMeetings',
  
  data() {
    return {
      searchQuery: '',
      meetings: [],
      isLoading: false,
      error: null,
      hasSearched: false,
      searchTimeout: null
    }
  },
  
  methods: {
    onSearchInput() {
      // Debounce la recherche
      if (this.searchTimeout) {
        clearTimeout(this.searchTimeout)
      }
      
      if (this.searchQuery.trim().length >= 2) {
        this.searchTimeout = setTimeout(() => {
          this.performSearch()
        }, 500)
      } else {
        this.meetings = []
        this.hasSearched = false
      }
    },
    
    async performSearch() {
      if (!this.searchQuery.trim()) {
        return
      }
      
      this.isLoading = true
      this.error = null
      this.hasSearched = true
      
      try {
        const response = await apiService.searchMeetingsByTitle(this.searchQuery.trim())
        
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
      } catch (err) {
        console.error('Erreur lors de la recherche:', err)
        this.error = err?.message || 'Impossible de rechercher les réunions. Veuillez réessayer.'
        this.meetings = []
      } finally {
        this.isLoading = false
      }
    },
    
    clearSearch() {
      this.searchQuery = ''
      this.meetings = []
      this.hasSearched = false
      this.error = null
    },
    
    viewMeeting(meetingId) {
      this.$emit('view-meeting', meetingId)
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
      if (!minutes) return 'Durée non définie'
      const hours = Math.floor(minutes / 60)
      const mins = minutes % 60
      if (hours > 0) {
        return `${hours}h${mins > 0 ? ` ${mins}min` : ''}`
      }
      return `${mins} min`
    },
    
    goBack() {
      this.$emit('back')
    }
  },
  
  beforeUnmount() {
    if (this.searchTimeout) {
      clearTimeout(this.searchTimeout)
    }
  }
}
</script>

<style scoped>
.search-meetings {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 2rem 1rem;
}

.search-container {
  max-width: 1200px;
  margin: 0 auto;
}

.search-header {
  text-align: center;
  margin-bottom: 3rem;
  color: white;
}

.search-title {
  font-size: 2.5rem;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
}

.search-icon {
  width: 2.5rem;
  height: 2.5rem;
}

.search-subtitle {
  font-size: 1.1rem;
  opacity: 0.9;
}

.search-bar-container {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  margin-bottom: 2rem;
  display: flex;
  gap: 1rem;
  align-items: center;
}

.search-input-wrapper {
  flex: 1;
  position: relative;
  display: flex;
  align-items: center;
}

.search-input-icon {
  position: absolute;
  left: 1rem;
  width: 20px;
  height: 20px;
  color: #6b7280;
  pointer-events: none;
}

.search-input {
  width: 100%;
  padding: 0.875rem 1rem 0.875rem 3rem;
  border: 2px solid #e5e7eb;
  border-radius: 0.5rem;
  font-size: 1rem;
  transition: all 0.3s ease;
}

.search-input:focus {
  outline: none;
  border-color: #6366f1;
  box-shadow: 0 0 0 3px rgb(99 102 241 / 0.1);
}

.clear-button {
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

.clear-button:hover {
  background: #f3f4f6;
  color: #374151;
}

.clear-button svg {
  width: 18px;
  height: 18px;
}

.search-button {
  white-space: nowrap;
}

.results-section {
  margin-bottom: 2rem;
}

.results-title {
  color: white;
  font-size: 1.5rem;
  margin-bottom: 1.5rem;
}

.meetings-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
}

.meeting-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  display: flex;
  flex-direction: column;
}

.meeting-card:hover {
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
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.status-icon {
  width: 14px;
  height: 14px;
}

.meeting-completed {
  opacity: 0.85;
  position: relative;
  border: 2px solid #c8e6c9;
}

.meeting-completed::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(56, 142, 60, 0.05) 0%, rgba(200, 230, 201, 0.1) 100%);
  pointer-events: none;
  border-radius: 12px;
}

.meeting-completed .meeting-card-title {
  color: #4caf50;
  position: relative;
}

.meeting-completed .meeting-card-title::after {
  content: '✓';
  margin-left: 0.5rem;
  color: #388e3c;
  font-weight: bold;
}

.status-cancelled {
  background: #ffebee;
  color: #d32f2f;
}

.status-postponed {
  background: #f3e5f5;
  color: #7b1fa2;
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

.loading-state,
.error-state,
.empty-state {
  background: white;
  border-radius: 12px;
  padding: 4rem 2rem;
  text-align: center;
  margin-bottom: 2rem;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
  color: #667eea;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-icon,
.empty-icon {
  width: 64px;
  height: 64px;
  margin: 0 auto 1.5rem;
  opacity: 0.7;
  color: #9ca3af;
}

.error-message {
  color: #ef4444;
  margin-bottom: 1.5rem;
}

.empty-state h3 {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
  color: #374151;
}

.empty-state p {
  color: #6b7280;
}

.action-bar {
  display: flex;
  justify-content: flex-start;
  gap: 1rem;
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

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(16, 185, 129, 0.3);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
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

@media (max-width: 768px) {
  .meetings-grid {
    grid-template-columns: 1fr;
  }
  
  .search-bar-container {
    flex-direction: column;
  }
  
  .search-button {
    width: 100%;
  }
}
</style>

