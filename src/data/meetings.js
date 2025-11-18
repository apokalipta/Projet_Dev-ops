// Données de test pour les réunions
export const mockMeetings = [
  {
    "id": "1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p",
    "title": "Réunion de lancement de projet",
    "description": "Présentation du projet et des objectifs à atteindre",
    "scheduledAt": "2025-11-10T09:30:00Z",
    "durationMinutes": 60,
    "participantSlots": 8,
    "status": "scheduled",
    "participants": [
      {
        "id": "p1a2b3c4d-5e6f-7g8h-9i0j",
        "fullName": "Marie Martin",
        "email": "marie.martin@example.com"
      },
      {
        "id": "p2b3c4d5e-6f7g-8h9i-0j1k",
        "fullName": "Thomas Dubois",
        "email": "thomas.dubois@example.com"
      }
    ],
    "metadata": {
      "autoStart": true,
      "sendReminders": true
    },
    "createdAt": "2025-11-07T10:00:00Z",
    "updatedAt": "2025-11-07T10:00:00Z"
  },
  {
    "id": "2b3c4d5e-6f7g-8h9i-0j1k-2l3m4n5o6p7q",
    "title": "Revue de code hebdomadaire",
    "description": "Revue des pull requests et discussions techniques",
    "scheduledAt": "2025-11-12T14:00:00Z",
    "durationMinutes": 90,
    "participantSlots": 6,
    "status": "scheduled",
    "participants": [
      {
        "id": "p3c4d5e6f-7g8h-9i0j-1k2l",
        "fullName": "Sophie Leroy",
        "email": "sophie.leroy@example.com"
      },
      {
        "id": "p4d5e6f7g-8h9i-0j1k-2l3m",
        "fullName": "Nicolas Moreau",
        "email": "nicolas.moreau@example.com"
      },
      {
        "id": "p5e6f7g8h-9i0j-1k2l-3m4n",
        "fullName": "Laura Petit",
        "email": "laura.petit@example.com"
      }
    ],
    "metadata": {
      "autoStart": true,
      "sendReminders": true
    },
    "createdAt": "2025-11-05T15:30:00Z",
    "updatedAt": "2025-11-06T09:15:00Z"
  },
  {
    "id": "3c4d5e6f-7g8h-9i0j-1k2l-3m4n5o6p7q8r",
    "title": "Rétrospective de sprint",
    "description": "Analyse des succès et axes d'amélioration du sprint écoulé",
    "scheduledAt": "2025-11-15T10:00:00Z",
    "durationMinutes": 120,
    "participantSlots": 10,
    "status": "scheduled",
    "participants": [
      {
        "id": "p6f7g8h9i-0j1k-2l3m-4n5o",
        "fullName": "Julien Bernard",
        "email": "julien.bernard@example.com"
      },
      {
        "id": "p7g8h9i0j-1k2l-3m4n-5o6p",
        "fullName": "Camille Roux",
        "email": "camille.roux@example.com"
      },
      {
        "id": "p8h9i0j1k-2l3m-4n5o-6p7q",
        "fullName": "Antoine Laurent",
        "email": "antoine.laurent@example.com"
      },
      {
        "id": "p9i0j1k2l-3m4n-5o6p-7q8r",
        "fullName": "Émilie Girard",
        "email": "emilie.girard@example.com"
      }
    ],
    "metadata": {
      "autoStart": true,
      "sendReminders": true
    },
    "createdAt": "2025-11-01T11:20:00Z",
    "updatedAt": "2025-11-07T08:45:00Z"
  }
];

// Fonction utilitaire pour formater les données pour l'affichage
export const formatMeetingForDisplay = (meeting) => ({
  id: meeting.id,
  title: meeting.title,
  description: meeting.description,
  duration: meeting.durationMinutes,
  participantSlots: meeting.participantSlots,
  participants: meeting.participants.map(p => ({
    name: p.fullName,
    email: p.email
  }))
});

// Exemple d'utilisation :
// const displayData = mockMeetings.map(formatMeetingForDisplay);
