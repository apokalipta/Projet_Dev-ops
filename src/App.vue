<template>
  <div id="app">
    <!-- Navigation -->
    <nav class="navbar">
      <div class="nav-container">
        <div class="nav-logo">
          <h2>
            <svg class="logo-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/>
              <path d="M19 10v2a7 7 0 0 1-14 0v-2"/>
              <line x1="12" y1="19" x2="12" y2="23"/>
              <line x1="8" y1="23" x2="16" y2="23"/>
            </svg>
            Transcript IA
          </h2>
        </div>
        <div class="nav-menu" v-if="currentPage === 'home'">
          <a href="#accueil" class="nav-link">Accueil</a>
          <a href="#fonctionnalites" class="nav-link">Fonctionnalités</a>
          <a href="#contact" class="nav-link">Contact</a>
        </div>
        <div class="nav-menu" v-else>
          <button class="btn btn-primary" @click="backToHome">
            ← Retour à l'accueil
          </button>
        </div>
      </div>
    </nav>

    <!-- Page d'accueil -->
    <div v-if="currentPage === 'home'" class="home-page">
      <!-- Section Hero Moderne -->
      <section class="hero-modern">
        <div class="hero-container-modern">
          <div class="welcome-section">
            <div class="welcome-badge">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/>
                <path d="M19 10v2a7 7 0 0 1-14 0v-2"/>
              </svg>
              Transcript IA
            </div>
            <h1 class="hero-title-modern">
              Bienvenue sur votre
              <span class="gradient-text-modern">espace de transcription</span>
            </h1>
            <p class="hero-subtitle-modern">
              Gérez vos réunions, démarrez des transcriptions et consultez vos enregistrements en un clic.
            </p>
          </div>

          <!-- Statistiques rapides -->
          <div class="stats-grid">
            <div class="stat-card">
              <div class="stat-icon stat-icon-primary">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                  <line x1="16" y1="2" x2="16" y2="6"/>
                  <line x1="8" y1="2" x2="8" y2="6"/>
                  <line x1="3" y1="10" x2="21" y2="10"/>
                </svg>
              </div>
              <div class="stat-content">
                <h3 class="stat-number">{{ stats.scheduledMeetings }}</h3>
                <p class="stat-label">Réunions planifiées</p>
              </div>
            </div>

            <div class="stat-card">
              <div class="stat-icon stat-icon-success">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <polyline points="9,11 12,14 22,4"/>
                  <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
                </svg>
              </div>
              <div class="stat-content">
                <h3 class="stat-number">{{ stats.completedMeetings }}</h3>
                <p class="stat-label">Réunions terminées</p>
              </div>
            </div>
          </div>

          <!-- Actions rapides -->
          <div class="quick-actions">
            <h2 class="section-title-modern">Actions rapides</h2>
            <div class="actions-grid">
              <div class="action-card action-primary" @click="planMeeting">
                <div class="action-icon">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                    <line x1="16" y1="2" x2="16" y2="6"/>
                    <line x1="8" y1="2" x2="8" y2="6"/>
                    <line x1="3" y1="10" x2="21" y2="10"/>
                  </svg>
                </div>
                <div class="action-content">
                  <h3>Planifier une réunion</h3>
                  <p>Créez une nouvelle réunion et invitez des participants</p>
                </div>
                <div class="action-arrow">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="5" y1="12" x2="19" y2="12"/>
                    <polyline points="12,5 19,12 12,19"/>
                  </svg>
                </div>
              </div>

              <div class="action-card action-secondary" @click="startMeeting">
                <div class="action-icon">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="10"/>
                    <polygon points="10,8 16,12 10,16 10,8"/>
                  </svg>
                </div>
                <div class="action-content">
                  <h3>Commencer une réunion</h3>
                  <p>Démarrez la transcription d'une réunion planifiée</p>
                </div>
                <div class="action-arrow">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="5" y1="12" x2="19" y2="12"/>
                    <polyline points="12,5 19,12 12,19"/>
                  </svg>
                </div>
              </div>

              <div class="action-card action-tertiary" @click="viewMeetingsList">
                <div class="action-icon">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                    <circle cx="12" cy="12" r="3"/>
                  </svg>
                </div>
                <div class="action-content">
                  <h3>Voir mes réunions</h3>
                  <p>Consultez et visualisez toutes vos réunions enregistrées</p>
                </div>
                <div class="action-arrow">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="5" y1="12" x2="19" y2="12"/>
                    <polyline points="12,5 19,12 12,19"/>
                  </svg>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Section Fonctionnalités -->
      <section class="features" id="fonctionnalites">
        <div class="container">
          <h2 class="section-title">Fonctionnalités Avancées</h2>
          <div class="features-grid">
          <div class="feature-card">
            <div class="feature-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <path d="M8 12h8"/>
                <path d="M12 8v8"/>
              </svg>
            </div>
            <h3>Précision Exceptionnelle</h3>
            <p>Technologie IA de pointe pour une transcription avec 99% de précision, même dans des environnements bruyants.</p>
          </div>
          <div class="feature-card">
            <div class="feature-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polygon points="13,2 3,14 12,14 11,22 21,10 12,10 13,2"/>
              </svg>
            </div>
            <h3>Temps Réel</h3>
            <p>Transcription instantanée pendant vos réunions avec mise à jour en direct de tous les participants.</p>
          </div>
          <div class="feature-card">
            <div class="feature-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
                <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
              </svg>
            </div>
            <h3>Reconnaissance des Intervenants</h3>
            <p>Identification automatique des différents participants et attribution des paroles à chacun.</p>
          </div>
          <div class="feature-card">
            <div class="feature-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M18 20V10"/>
                <path d="M12 20V4"/>
                <path d="M6 20v-6"/>
              </svg>
            </div>
            <h3>Analytics Avancés</h3>
            <p>Statistiques détaillées : temps de parole, mots-clés, sentiment et résumés automatiques.</p>
          </div>
          <div class="feature-card">
            <div class="feature-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                <circle cx="12" cy="16" r="1"/>
                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
              </svg>
            </div>
            <h3>Sécurité Maximale</h3>
            <p>Chiffrement de bout en bout et conformité RGPD pour protéger vos données sensibles.</p>
          </div>
          <div class="feature-card">
            <div class="feature-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <path d="M2 12h20"/>
                <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
              </svg>
            </div>
            <h3>Multi-langues</h3>
            <p>Support de plus de 50 langues avec détection automatique de la langue parlée.</p>
          </div>
          </div>
        </div>
      </section>

      <!-- Section CTA -->
      <section class="cta">
        <div class="container">
          <div class="cta-content">
            <h2>Prêt à révolutionner vos réunions ?</h2>
            <p>Rejoignez des milliers d'entreprises qui font confiance à notre solution</p>
          </div>
        </div>
      </section>

      <!-- Footer -->
      <footer class="footer">
        <div class="container">
          <div class="footer-content">
          <div class="footer-section">
            <h3>
              <svg class="footer-logo-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/>
                <path d="M19 10v2a7 7 0 0 1-14 0v-2"/>
                <line x1="12" y1="19" x2="12" y2="23"/>
                <line x1="8" y1="23" x2="16" y2="23"/>
              </svg>
              Transcript IA
            </h3>
            <p>La solution de transcription de réunion la plus avancée du marché.</p>
          </div>
            <div class="footer-section">
              <h4>Produit</h4>
              <ul>
                <li><a href="#">Fonctionnalités</a></li>
                <li><a href="#">Tarifs</a></li>
                <li><a href="#">API</a></li>
              </ul>
            </div>
            <div class="footer-section">
              <h4>Support</h4>
              <ul>
                <li><a href="#">Documentation</a></li>
                <li><a href="#">Contact</a></li>
                <li><a href="#">FAQ</a></li>
              </ul>
            </div>
            <div class="footer-section">
              <h4>Légal</h4>
              <ul>
                <li><a href="#">Mentions légales</a></li>
                <li><a href="#">RGPD</a></li>
                <li><a href="#">CGU</a></li>
              </ul>
            </div>
          </div>
          <div class="footer-bottom">
            <p>&copy; 2024 Transcript IA. Tous droits réservés.</p>
          </div>
        </div>
      </footer>
    </div>

    <!-- Page de Setup de Réunion -->
    <div v-if="currentPage === 'setup'">
      <SetupMeeting @back="backToHome" @meeting-created="onMeetingCreated" />
    </div>

    <!-- Page d'Assignation des Participants -->
    <div v-if="currentPage === 'assign-participants'">
      <AssignParticipants 
        :meeting="createdMeeting" 
        @back="backToSetup" 
        @participants-assigned="onParticipantsAssigned" 
      />
    </div>

    <!-- Page Liste des Réunions -->
    <div v-if="currentPage === 'meetings-list'">
      <MeetingsList 
        @back="backToHome" 
        @go-to-plan="planMeeting"
        @view-meeting="viewMeeting"
        @manage-participants="manageParticipants"
      />
    </div>

    <!-- Page de Visualisation de Réunion -->
    <div v-if="currentPage === 'view'" class="meeting-viewer">
      <MeetingViewer 
        :meeting-id="currentMeetingId" 
        @back="backToMeetingsList"
        @manage-participants="manageParticipants"
      />
    </div>

    <!-- Page de Démarrage de Réunion -->
    <div v-if="currentPage === 'start-meeting'">
      <StartMeeting 
        @back="backToHome" 
        @go-to-plan="planMeeting"
        @meeting-started="onMeetingStarted"
        @view-meeting="viewMeeting"
      />
    </div>

    <!-- Page de Gestion des Participants -->
    <div v-if="currentPage === 'manage-participants'">
      <ManageParticipants 
        :meeting-id="currentMeetingId"
        @back="backToMeetingsList"
      />
    </div>

    <!-- Page d'Enregistrement de Réunion -->
    <div v-if="currentPage === 'record'">
      <RecordMeeting 
        :meeting-id="currentMeetingId"
        @back="backFromRecord"
        @meeting-ended="onMeetingEnded"
      />
    </div>
  </div>
</template>

<script>
import { ref } from 'vue';
import SetupMeeting from './components/SetupMeeting.vue';
import MeetingsList from './components/MeetingsList.vue';
import AssignParticipants from './components/AssignParticipants.vue';
import StartMeeting from './components/StartMeeting.vue';
import MeetingViewer from './components/MeetingViewer.vue';
import ManageParticipants from './components/ManageParticipants.vue';
import RecordMeeting from './components/RecordMeeting.vue';
import { apiService } from './services/api.js';

export default {
  name: 'App',
  components: {
    SetupMeeting,
    AssignParticipants,
    MeetingsList,
    StartMeeting,
    MeetingViewer,
    ManageParticipants,
    RecordMeeting
  },
  data() {
    return {
      currentPage: 'home',
      createdMeeting: null,
      currentMeetingId: null,
      previousPage: null, // Pour mémoriser d'où on vient
      stats: {
        scheduledMeetings: 0,
        completedMeetings: 0
      }
    };
  },
  async mounted() {
    await this.loadStats();
  },
  methods: {
    async loadStats() {
      try {
        // Charger toutes les réunions
        const meetings = await apiService.getAllMeetings();
        const meetingsArray = Array.isArray(meetings) ? meetings : [];
        
        // Calculer les statistiques des réunions
        this.stats.scheduledMeetings = meetingsArray.filter(m => m.status === 'scheduled').length;
        this.stats.completedMeetings = meetingsArray.filter(m => m.status === 'completed').length;
        
        console.log('📊 Statistiques chargées:', this.stats);
      } catch (error) {
        console.error('❌ Erreur lors du chargement des statistiques:', error);
        // Garder les valeurs par défaut (0) en cas d'erreur
      }
    },
    planMeeting() {
      this.currentPage = 'setup';
    },
    startMeeting() {
      this.currentPage = 'start-meeting';
    },
    viewMeetingsList() {
      this.currentPage = 'meetings-list';
    },
    async backToHome() {
      this.currentPage = 'home';
      // Recharger les statistiques quand on revient à l'accueil
      await this.loadStats();
    },
    backToMeetingsList() {
      this.currentPage = 'meetings-list';
    },
    backToSetup() {
      this.currentPage = 'setup';
    },
    viewMeeting(meeting) {
      // Vérifier si on reçoit un objet meeting ou juste un ID (rétrocompatibilité)
      if (typeof meeting === 'object' && meeting !== null) {
        this.currentMeetingId = meeting.id;
        
        // Si la réunion est terminée, afficher la page de visualisation avec transcription
        if (meeting.status === 'completed') {
          this.currentPage = 'view';
          console.log('📄 Redirection vers la page de visualisation (réunion terminée)');
        } else {
          // Sinon, afficher la page d'enregistrement (scheduled ou in_progress)
          this.previousPage = 'meetings-list';
          this.currentPage = 'record';
          console.log('🎙️ Redirection vers la page d\'enregistrement (réunion active)');
        }
      } else {
        // Rétrocompatibilité : si on reçoit juste un ID
        this.currentMeetingId = meeting;
        this.currentPage = 'view';
      }
    },
    manageParticipants(meetingId) {
      this.currentMeetingId = meetingId;
      this.currentPage = 'manage-participants';
    },
    onMeetingCreated(meetingData) {
      this.createdMeeting = meetingData;
      console.log('✅ Réunion créée dans App.vue:', meetingData);
      // Rediriger vers la liste des réunions au lieu d'assign-participants
      // car les participants sont maintenant créés directement avec la réunion
      this.currentPage = 'meetings-list';
    },
    onParticipantsAssigned(participants) {
      console.log('Participants assignés:', participants);
      // Logique supplémentaire si nécessaire
    },
    onMeetingStarted(data) {
      console.log('Réunion démarrée:', data);
      // Mémoriser qu'on vient de "Commencer une réunion"
      this.previousPage = 'start-meeting';
      // Rediriger vers la page d'enregistrement
      this.currentMeetingId = data.meeting.id;
      this.currentPage = 'record';
    },
    backFromRecord() {
      // Retourner à la page d'où on vient (start-meeting ou meetings-list)
      if (this.previousPage === 'meetings-list') {
        this.currentPage = 'meetings-list';
      } else {
        this.currentPage = 'start-meeting';
      }
      this.previousPage = null;
    },
    onMeetingEnded(meetingId) {
      console.log('Réunion terminée:', meetingId);
      // Recharger les stats et retourner à l'accueil
      this.loadStats();
    }
  }
};
</script>
