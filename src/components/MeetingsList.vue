<template>
  <div class="meetings-list-page">
    <div class="meetings-container">
      <div class="meetings-header">
        <div class="header-content">
          <div class="header-text">
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
          
          <!-- Barre de recherche intégrée dans le header -->
          <div class="header-search-bar">
            <div class="search-input-wrapper">
              <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="8"/>
                <path d="m21 21-4.35-4.35"/>
              </svg>
              <input
                type="text"
                v-model="searchQuery"
                @input="filterMeetings"
                class="search-input"
                placeholder="Rechercher une réunion par nom..."
              />
              <button 
                v-if="searchQuery" 
                @click="clearSearch" 
                class="clear-search-btn"
                title="Effacer la recherche"
              >
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <line x1="18" y1="6" x2="6" y2="18"/>
                  <line x1="6" y1="6" x2="18" y2="18"/>
                </svg>
              </button>
            </div>
          </div>
        </div>
        
        <!-- Contrôles de tri -->
        <div class="sort-controls-bar">
          <label class="sort-label">
            <svg class="sort-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="6 9 12 15 18 9"/>
            </svg>
            Trier par date :
          </label>
          <select v-model="sortOrder" @change="filterMeetings" class="sort-select">
            <option value="desc">Plus récentes d'abord</option>
            <option value="asc">Plus anciennes d'abord</option>
          </select>
        </div>
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
      <div v-else-if="filteredMeetings.length > 0" class="meetings-grid">
        <div 
          v-for="meeting in filteredMeetings" 
          :key="meeting.id"
          class="meeting-card-view"
          @click="viewMeetingDetails(meeting)"
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
            <button class="btn-view" @click.stop="viewMeetingDetails(meeting)">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                <circle cx="12" cy="12" r="3"/>
              </svg>
              Voir la réunion
            </button>
            <button 
              v-if="meeting.status !== 'completed'"
              class="btn-manage" 
              @click.stop="manageParticipants(meeting.id)"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
                <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
              </svg>
              Participants
            </button>
            <button 
              class="btn-delete" 
              @click.stop="confirmDeleteMeeting(meeting)"
              title="Supprimer la réunion"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="3 6 5 6 21 6"/>
                <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                <line x1="10" y1="11" x2="10" y2="17"/>
                <line x1="14" y1="11" x2="14" y2="17"/>
              </svg>
              Supprimer
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
        <h3 v-if="searchQuery">Aucune réunion trouvée</h3>
        <h3 v-else>Aucune réunion disponible</h3>
        <p v-if="searchQuery">Aucune réunion ne correspond à votre recherche "{{ searchQuery }}"</p>
        <p v-else>Vous n'avez pas encore de réunions enregistrées.</p>
        <button v-if="searchQuery" @click="clearSearch" class="btn btn-secondary">
          Effacer la recherche
        </button>
        <button v-else @click="goToPlan" class="btn btn-primary">
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
      isLoading: false,
      error: null,
      meetings: [],
      searchQuery: '',
      sortOrder: 'desc', // 'asc' ou 'desc'
      filteredMeetings: []
    }
  },
  
  async mounted() {
    // Vider le cache avant de charger pour avoir les données fraîches
    await this.clearCache()
    await this.loadMeetings()
  },
  
  watch: {
    meetings() {
      this.filterMeetings()
    }
  },
  
  methods: {
    async clearCache() {
      try {
        const { cacheService } = await import('../services/cacheService.js')
        const cacheKey = 'GET:http://localhost:8081/api/meeting/all'
        await cacheService.delete(cacheKey)
        console.log('🗑️ Cache vidé avant chargement des réunions')
      } catch (error) {
        console.warn('Erreur lors du vidage du cache:', error)
      }
    },
    async loadMeetings() {
      this.isLoading = true
      this.error = null
      
      try {
        console.log('📡 Chargement des réunions depuis /api/meeting/all...')
        const response = await apiService.getAllMeetings()
        console.log('📥 Réponse brute reçue:', response)
        console.log('📊 Type de réponse:', typeof response, 'Est un tableau?', Array.isArray(response))
        
        // Gérer différents formats de réponse
        if (Array.isArray(response)) {
          this.meetings = response
          console.log('✅ Format tableau détecté, nombre de réunions:', response.length)
        } else if (response?.data && Array.isArray(response.data)) {
          this.meetings = response.data
          console.log('✅ Format response.data détecté, nombre de réunions:', response.data.length)
        } else if (response?.meetings && Array.isArray(response.meetings)) {
          this.meetings = response.meetings
          console.log('✅ Format response.meetings détecté, nombre de réunions:', response.meetings.length)
        } else {
          console.warn('⚠️ Format de réponse non reconnu, initialisation à tableau vide')
          this.meetings = []
        }
        
        console.log('📋 Réunions chargées dans this.meetings:', this.meetings.length, this.meetings)
        
        // Appliquer les filtres après le chargement
        this.filterMeetings()
        console.log('🔍 Après filtrage, réunions affichées:', this.filteredMeetings.length, this.filteredMeetings)
      } catch (err) {
        console.error('❌ Erreur lors du chargement des réunions:', err)
        this.error = err?.message || 'Impossible de charger les réunions. Veuillez réessayer.'
        this.filteredMeetings = []
      } finally {
        this.isLoading = false
      }
    },
    
    async refreshMeetings() {
      await this.clearCache()
      await this.loadMeetings()
    },
    
    filterMeetings() {
      let filtered = [...this.meetings]
      
      // Filtrer par nom/titre
      if (this.searchQuery.trim()) {
        const query = this.searchQuery.trim().toLowerCase()
        filtered = filtered.filter(meeting => 
          meeting.title?.toLowerCase().includes(query) ||
          meeting.description?.toLowerCase().includes(query)
        )
      }
      
      // Trier par date
      filtered.sort((a, b) => {
        const dateA = new Date(a.scheduledAt || a.createdAt || 0)
        const dateB = new Date(b.scheduledAt || b.createdAt || 0)
        
        if (this.sortOrder === 'asc') {
          return dateA - dateB
        } else {
          return dateB - dateA
        }
      })
      
      this.filteredMeetings = filtered
    },
    
    clearSearch() {
      this.searchQuery = ''
      this.filterMeetings()
    },

    viewMeetingDetails(meeting) {
      this.$emit('view-meeting', meeting)
    },
    
    manageParticipants(meetingId) {
      this.$emit('manage-participants', meetingId)
    },

    confirmDeleteMeeting(meeting) {
      if (confirm(`Êtes-vous sûr de vouloir supprimer la réunion "${meeting.title}" ?\n\nCette action est irréversible.`)) {
        this.deleteMeeting(meeting.id)
      }
    },

    async deleteMeeting(meetingId) {
      try {
        console.log(`🗑️ Suppression de la réunion ID: ${meetingId}...`)
        await apiService.deleteMeeting(meetingId)
        
        // Supprimer localement de la liste
        this.meetings = this.meetings.filter(m => m.id !== meetingId)
        
        // Vider le cache et recharger pour être sûr
        await this.clearCache()
        
        alert('✅ Réunion supprimée avec succès !')
        console.log('✅ Réunion supprimée')
      } catch (error) {
        console.error('❌ Erreur lors de la suppression:', error)
        alert(error?.message || '❌ Erreur lors de la suppression de la réunion')
      }
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
  margin-bottom: 2rem;
  color: white;
}

.header-content {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.header-text {
  text-align: center;
}

.meetings-title {
  font-size: 2.5rem;
  margin-bottom: 0.75rem;
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

/* Barre de recherche intégrée dans le header */
.header-search-bar {
  width: 100%;
  max-width: 700px;
  margin: 0 auto;
}

.search-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  background: white;
  border-radius: 50px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transition: all 0.3s ease;
}

.search-input-wrapper:focus-within {
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
  transform: translateY(-2px);
}

.search-icon {
  position: absolute;
  left: 1.5rem;
  width: 20px;
  height: 20px;
  color: #6b7280;
  pointer-events: none;
  z-index: 1;
}

.search-input {
  width: 100%;
  padding: 1rem 1rem 1rem 3.5rem;
  border: none;
  border-radius: 50px;
  font-size: 1rem;
  background: transparent;
  color: #1f2937;
  outline: none;
}

.search-input::placeholder {
  color: #9ca3af;
}

.clear-search-btn {
  position: absolute;
  right: 0.75rem;
  background: #f3f4f6;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  color: #6b7280;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.2s;
  width: 32px;
  height: 32px;
}

.clear-search-btn:hover {
  background: #e5e7eb;
  color: #374151;
  transform: scale(1.1);
}

.clear-search-btn svg {
  width: 16px;
  height: 16px;
}

/* Barre de tri */
.sort-controls-bar {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.2);
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
  display: flex;
  gap: 0.5rem;
}

.btn-view {
  flex: 1;
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

.btn-manage {
  padding: 0.75rem;
  background: #f3f4f6;
  color: #374151;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
  min-width: 120px;
}

.btn-manage:hover {
  background: #e5e7eb;
  transform: translateY(-2px);
}

.btn-manage svg {
  width: 18px;
  height: 18px;
}

.btn-delete {
  padding: 0.75rem;
  background: #fee2e2;
  color: #991b1b;
  border: 1px solid #fca5a5;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
  min-width: 120px;
}

.btn-delete:hover {
  background: #fecaca;
  border-color: #f87171;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

.btn-delete svg {
  width: 18px;
  height: 18px;
}

.btn-view:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.btn-view svg {
  width: 18px;
  height: 18px;
}

.sort-label {
  font-weight: 500;
  color: white;
  white-space: nowrap;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.sort-icon {
  width: 18px;
  height: 18px;
}

.sort-select {
  padding: 0.75rem 1.25rem;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 8px;
  font-size: 1rem;
  background: rgba(255, 255, 255, 0.95);
  color: #1f2937;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 220px;
  font-weight: 500;
}

.sort-select:focus {
  outline: none;
  border-color: rgba(255, 255, 255, 0.6);
  background: white;
  box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.2);
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

  .header-content {
    gap: 1rem;
  }

  .header-search-bar {
    max-width: 100%;
  }

  .search-input {
    padding: 0.875rem 1rem 0.875rem 3rem;
    font-size: 0.95rem;
  }

  .search-icon {
    left: 1rem;
  }

  .sort-controls-bar {
    flex-direction: column;
    align-items: stretch;
    gap: 0.75rem;
  }

  .sort-select {
    width: 100%;
    min-width: auto;
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
