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
    <div v-if="currentPage === 'home'">
      <!-- Section Hero -->
      <section class="hero">
        <div class="hero-container">
          <div class="hero-content">
            <h1 class="hero-title">
              Transcription de Réunion
              <span class="gradient-text">Intelligente</span>
            </h1>
            <p class="hero-description">
              Transformez vos réunions en texte avec une précision exceptionnelle. 
              Notre IA avancée capture chaque mot, chaque nuance, pour une documentation parfaite.
            </p>
            <div class="hero-buttons">
            <button class="btn btn-primary" @click="planMeeting">
              <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                <line x1="16" y1="2" x2="16" y2="6"/>
                <line x1="8" y1="2" x2="8" y2="6"/>
                <line x1="3" y1="10" x2="21" y2="10"/>
              </svg>
              Planifier la Réunion
            </button>
            <button class="btn btn-secondary" @click="startMeeting">
              <svg class="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09z"/>
                <path d="M12 15l-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2z"/>
                <path d="M9 12H4s.55-3.03 2-4c1.62-1.08 5 0 5 0"/>
                <path d="M12 15v5s3.03-.55 4-2c1.08-1.62 0-5 0-5"/>
              </svg>
              Commencer la Réunion
            </button>
            </div>
          </div>
          <div class="hero-visual">
            <div class="transcription-demo">
              <div class="demo-header">
                <div class="demo-dots">
                  <span class="dot red"></span>
                  <span class="dot yellow"></span>
                  <span class="dot green"></span>
                </div>
                <span class="demo-title">Transcription en cours...</span>
              </div>
              <div class="demo-content">
                <div class="speaking-indicator">
                  <div class="wave"></div>
                  <span>Jean Dupont parle</span>
                </div>
                <div class="transcription-text">
                  <p>"Bonjour à tous, je suis ravi de vous retrouver pour cette réunion importante..."</p>
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
  </div>
</template>

<script>
import SetupMeeting from './components/SetupMeeting.vue'
import AssignParticipants from './components/AssignParticipants.vue'

export default {
  name: 'App',
  components: {
    SetupMeeting,
    AssignParticipants
  },
  data() {
    return {
      currentPage: 'home', // 'home', 'setup', ou 'assign-participants'
      createdMeeting: null
    }
  },
  methods: {
    planMeeting() {
      this.currentPage = 'setup'
    },
    startMeeting() {
      alert('🚀 Fonctionnalité de réunion instantanée bientôt disponible !')
    },
    backToHome() {
      this.currentPage = 'home'
      this.createdMeeting = null
    },
    backToSetup() {
      this.currentPage = 'setup'
    },
    onMeetingCreated(meetingData) {
      this.createdMeeting = meetingData
      this.currentPage = 'assign-participants'
    },
    onParticipantsAssigned(participants) {
      console.log('Participants assignés:', participants)
      // Ici vous pourriez rediriger vers la page de réunion active
      alert('✅ Participants assignés avec succès !')
    }
  }
}
</script>
