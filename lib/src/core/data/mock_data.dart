/// Données mockées pour le développement et les tests
/// 
/// Ce fichier contient des données réalistes pour simuler le fonctionnement
/// de l'application sans backend.

class MockData {
  // ============================================================================
  // RÉUNIONS
  // ============================================================================
  
  static final List<Map<String, dynamic>> meetings = [
    {
      'id': 'meeting-001',
      'title': 'Réunion équipe Dev - Sprint Planning',
      'description': 'Planification du sprint Q4 2024 avec l\'équipe de développement',
      'date': '2024-11-07T14:00:00Z',
      'duration': 3600, // 1 heure en secondes
      'status': 'completed',
      'language': 'FR',
      'location': 'Salle de réunion A',
      'createdAt': '2024-11-01T10:00:00Z',
      'updatedAt': '2024-11-07T15:00:00Z',
    },
    {
      'id': 'meeting-002',
      'title': 'Revue de code Backend API',
      'description': 'Revue du code des nouvelles APIs REST et GraphQL',
      'date': '2024-11-06T10:30:00Z',
      'duration': 5400, // 1h30 en secondes
      'status': 'completed',
      'language': 'FR',
      'location': 'Visioconférence',
      'createdAt': '2024-10-30T09:00:00Z',
      'updatedAt': '2024-11-06T12:00:00Z',
    },
    {
      'id': 'meeting-003',
      'title': 'Présentation Client - Démo Q4',
      'description': 'Démonstration des nouvelles fonctionnalités au client',
      'date': '2024-11-05T16:00:00Z',
      'duration': 2700, // 45 min en secondes
      'status': 'completed',
      'language': 'FR',
      'location': 'Salle de conférence',
      'createdAt': '2024-10-28T14:00:00Z',
      'updatedAt': '2024-11-05T16:45:00Z',
    },
    {
      'id': 'meeting-004',
      'title': 'Daily Standup',
      'description': 'Point quotidien de l\'équipe',
      'date': '2024-11-08T09:00:00Z',
      'duration': 900, // 15 min en secondes
      'status': 'scheduled',
      'language': 'FR',
      'location': 'Open Space',
      'createdAt': '2024-11-07T18:00:00Z',
      'updatedAt': '2024-11-07T18:00:00Z',
    },
    {
      'id': 'meeting-005',
      'title': 'Rétrospective Sprint 12',
      'description': 'Rétrospective du sprint 12 - Points positifs et axes d\'amélioration',
      'date': '2024-11-04T15:00:00Z',
      'duration': 4500, // 1h15 en secondes
      'status': 'completed',
      'language': 'FR',
      'location': 'Salle de réunion B',
      'createdAt': '2024-10-25T11:00:00Z',
      'updatedAt': '2024-11-04T16:15:00Z',
    },
    {
      'id': 'meeting-006',
      'title': 'Formation Flutter Avancé',
      'description': 'Session de formation sur les patterns avancés en Flutter',
      'date': '2024-11-10T14:00:00Z',
      'duration': 7200, // 2 heures en secondes
      'status': 'scheduled',
      'language': 'FR',
      'location': 'Salle de formation',
      'createdAt': '2024-11-02T10:00:00Z',
      'updatedAt': '2024-11-02T10:00:00Z',
    },
  ];

  // ============================================================================
  // PARTICIPANTS
  // ============================================================================
  
  static final List<Map<String, dynamic>> participants = [
    {
      'id': 'participant-001',
      'name': 'Alice Dupont',
      'email': 'alice.dupont@company.com',
      'role': 'Tech Lead',
      'avatar': 'https://i.pravatar.cc/150?img=1',
    },
    {
      'id': 'participant-002',
      'name': 'Bob Martin',
      'email': 'bob.martin@company.com',
      'role': 'Développeur Backend',
      'avatar': 'https://i.pravatar.cc/150?img=2',
    },
    {
      'id': 'participant-003',
      'name': 'Claire Leroy',
      'email': 'claire.leroy@company.com',
      'role': 'Développeuse Frontend',
      'avatar': 'https://i.pravatar.cc/150?img=3',
    },
    {
      'id': 'participant-004',
      'name': 'David Chen',
      'email': 'david.chen@company.com',
      'role': 'Product Owner',
      'avatar': 'https://i.pravatar.cc/150?img=4',
    },
    {
      'id': 'participant-005',
      'name': 'Emma Wilson',
      'email': 'emma.wilson@company.com',
      'role': 'UX Designer',
      'avatar': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'id': 'participant-006',
      'name': 'François Dubois',
      'email': 'francois.dubois@company.com',
      'role': 'Scrum Master',
      'avatar': 'https://i.pravatar.cc/150?img=6',
    },
  ];

  // ============================================================================
  // PARTICIPANTS PAR RÉUNION
  // ============================================================================
  
  static final Map<String, List<Map<String, dynamic>>> meetingParticipants = {
    'meeting-001': [
      {
        'participantId': 'participant-001',
        'speakTime': 1200, // 20 min en secondes
        'interventions': 15,
      },
      {
        'participantId': 'participant-002',
        'speakTime': 900, // 15 min
        'interventions': 12,
      },
      {
        'participantId': 'participant-003',
        'speakTime': 1050, // 17.5 min
        'interventions': 18,
      },
      {
        'participantId': 'participant-004',
        'speakTime': 450, // 7.5 min
        'interventions': 8,
      },
    ],
    'meeting-002': [
      {
        'participantId': 'participant-001',
        'speakTime': 2100, // 35 min
        'interventions': 25,
      },
      {
        'participantId': 'participant-002',
        'speakTime': 1800, // 30 min
        'interventions': 20,
      },
      {
        'participantId': 'participant-003',
        'speakTime': 1500, // 25 min
        'interventions': 22,
      },
    ],
    'meeting-003': [
      {
        'participantId': 'participant-001',
        'speakTime': 600, // 10 min
        'interventions': 5,
      },
      {
        'participantId': 'participant-004',
        'speakTime': 1200, // 20 min
        'interventions': 8,
      },
      {
        'participantId': 'participant-005',
        'speakTime': 900, // 15 min
        'interventions': 6,
      },
    ],
    'meeting-005': [
      {
        'participantId': 'participant-001',
        'speakTime': 900, // 15 min
        'interventions': 10,
      },
      {
        'participantId': 'participant-002',
        'speakTime': 1050, // 17.5 min
        'interventions': 14,
      },
      {
        'participantId': 'participant-003',
        'speakTime': 1200, // 20 min
        'interventions': 16,
      },
      {
        'participantId': 'participant-006',
        'speakTime': 1350, // 22.5 min
        'interventions': 12,
      },
    ],
  };

  // ============================================================================
  // SEGMENTS DE TRANSCRIPTION
  // ============================================================================
  
  static final Map<String, List<Map<String, dynamic>>> transcriptionSegments = {
    'meeting-001': [
      {
        'id': 'segment-001-001',
        'meetingId': 'meeting-001',
        'speakerId': 'participant-001',
        'text': 'Bonjour à tous, merci d\'être présents pour cette réunion de planification du sprint. Aujourd\'hui, nous allons définir les objectifs du prochain sprint et répartir les tâches.',
        'startTime': 0.0,
        'endTime': 12.5,
        'confidence': 0.95,
      },
      {
        'id': 'segment-001-002',
        'meetingId': 'meeting-001',
        'speakerId': 'participant-004',
        'text': 'Parfait Alice. J\'ai préparé une liste des user stories prioritaires. On a 8 stories à traiter ce sprint.',
        'startTime': 12.5,
        'endTime': 20.3,
        'confidence': 0.92,
      },
      {
        'id': 'segment-001-003',
        'meetingId': 'meeting-001',
        'speakerId': 'participant-002',
        'text': 'Super David. De mon côté, j\'ai terminé l\'intégration des APIs backend. On peut commencer à travailler sur les nouvelles fonctionnalités.',
        'startTime': 20.3,
        'endTime': 29.8,
        'confidence': 0.94,
      },
      {
        'id': 'segment-001-004',
        'meetingId': 'meeting-001',
        'speakerId': 'participant-003',
        'text': 'Excellent ! J\'ai quelques questions sur la partie transcription. Comment va-t-on gérer la diarisation des locuteurs ?',
        'startTime': 29.8,
        'endTime': 38.2,
        'confidence': 0.88,
      },
      {
        'id': 'segment-001-005',
        'meetingId': 'meeting-001',
        'speakerId': 'participant-001',
        'text': 'Bonne question Claire. La diarisation se fait automatiquement par l\'IA, mais on peut corriger manuellement après si nécessaire. L\'algorithme a un taux de précision de 95%.',
        'startTime': 38.2,
        'endTime': 50.7,
        'confidence': 0.96,
      },
    ],
    'meeting-002': [
      {
        'id': 'segment-002-001',
        'meetingId': 'meeting-002',
        'speakerId': 'participant-001',
        'text': 'Commençons la revue de code. Bob, peux-tu nous présenter les changements que tu as apportés aux APIs ?',
        'startTime': 0.0,
        'endTime': 8.5,
        'confidence': 0.93,
      },
      {
        'id': 'segment-002-002',
        'meetingId': 'meeting-002',
        'speakerId': 'participant-002',
        'text': 'Bien sûr. J\'ai refactorisé les endpoints REST pour améliorer les performances. J\'ai aussi ajouté la pagination et le cache Redis.',
        'startTime': 8.5,
        'endTime': 18.2,
        'confidence': 0.91,
      },
      {
        'id': 'segment-002-003',
        'meetingId': 'meeting-002',
        'speakerId': 'participant-003',
        'text': 'C\'est génial ! Est-ce que tu as pensé à ajouter des tests unitaires pour ces nouvelles fonctionnalités ?',
        'startTime': 18.2,
        'endTime': 25.6,
        'confidence': 0.89,
      },
    ],
    'meeting-003': [
      {
        'id': 'segment-003-001',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'Bonjour Thomas, merci d\'avoir pris le temps pour cette présentation. J\'ai hâte de découvrir les nouveautés que vous avez préparées pour notre projet.',
        'startTime': 0.0,
        'endTime': 8.0,
        'confidence': 0.96,
      },
      {
        'id': 'segment-003-002',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'Bonjour Sophie ! Merci de votre confiance. Aujourd\'hui, je vais vous présenter l\'avancement de notre plateforme de gestion de réunions. Nous avons fait des progrès significatifs ces dernières semaines.',
        'startTime': 8.0,
        'endTime': 20.0,
        'confidence': 0.94,
      },
      {
        'id': 'segment-003-003',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'Parfait. Commençons si vous voulez bien. Quelle est la première fonctionnalité que vous souhaitez me montrer ?',
        'startTime': 20.0,
        'endTime': 26.0,
        'confidence': 0.95,
      },
      {
        'id': 'segment-003-004',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'Alors, la première grande nouveauté, c\'est l\'enregistrement audio avec une qualité optimisée. Nous avons intégré un système qui détecte automatiquement les bruits de fond et les filtre en temps réel.',
        'startTime': 26.0,
        'endTime': 40.0,
        'confidence': 0.93,
      },
      {
        'id': 'segment-003-005',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'C\'est intéressant ! Est-ce que ça fonctionne bien dans des environnements bruyants, comme des open spaces par exemple ?',
        'startTime': 40.0,
        'endTime': 48.0,
        'confidence': 0.97,
      },
      {
        'id': 'segment-003-006',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'Absolument. Nous avons fait des tests en conditions réelles et les résultats sont très concluants. Le système arrive à isoler les voix des participants même avec un niveau de bruit ambiant élevé. Je peux vous montrer une démo si vous voulez.',
        'startTime': 48.0,
        'endTime': 65.0,
        'confidence': 0.92,
      },
      {
        'id': 'segment-003-007',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'Oui, avec plaisir ! Montrez-moi ce que ça donne concrètement.',
        'startTime': 65.0,
        'endTime': 70.0,
        'confidence': 0.98,
      },
      {
        'id': 'segment-003-008',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'Voilà, vous voyez ici l\'interface d\'enregistrement. Le bouton rouge permet de démarrer, et on a des indicateurs visuels qui montrent le niveau sonore capté. La transcription se lance automatiquement en arrière-plan.',
        'startTime': 70.0,
        'endTime': 88.0,
        'confidence': 0.91,
      },
      {
        'id': 'segment-003-009',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'Très bien. Et pour la transcription justement, vous avez mentionné la diarisation lors de notre dernier échange. Comment ça se passe au niveau de l\'identification des locuteurs ?',
        'startTime': 88.0,
        'endTime': 102.0,
        'confidence': 0.94,
      },
      {
        'id': 'segment-003-010',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'Excellente question. La diarisation fonctionne en deux temps. D\'abord, l\'intelligence artificielle identifie automatiquement les différentes voix et crée des groupes de locuteurs. Ensuite, on peut associer manuellement chaque locuteur à un participant de la réunion.',
        'startTime': 102.0,
        'endTime': 124.0,
        'confidence': 0.89,
      },
      {
        'id': 'segment-003-011',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'D\'accord, donc si je comprends bien, même si l\'IA ne reconnaît pas immédiatement qui parle, on peut corriger après coup ?',
        'startTime': 124.0,
        'endTime': 133.0,
        'confidence': 0.95,
      },
      {
        'id': 'segment-003-012',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'Exactement ! Et avec le temps, le système apprend à reconnaître les empreintes vocales récurrentes, ce qui améliore la précision pour les réunions futures avec les mêmes participants.',
        'startTime': 133.0,
        'endTime': 148.0,
        'confidence': 0.93,
      },
      {
        'id': 'segment-003-013',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'C\'est vraiment intelligent comme approche. Parlons maintenant de la synthèse des réunions. J\'ai vu que vous proposez des statistiques sur le temps de parole. Comment est-ce calculé ?',
        'startTime': 148.0,
        'endTime': 163.0,
        'confidence': 0.96,
      },
      {
        'id': 'segment-003-014',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'Alors, pour chaque segment de transcription, on enregistre l\'horodatage de début et de fin. On agrège ensuite tous les segments par locuteur pour calculer leur temps de parole total. Ça permet d\'avoir une vue d\'ensemble très claire de la participation de chacun.',
        'startTime': 163.0,
        'endTime': 185.0,
        'confidence': 0.90,
      },
      {
        'id': 'segment-003-015',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'Intéressant. Et vous affichez ça sous quelle forme ? Des graphiques, des tableaux ?',
        'startTime': 185.0,
        'endTime': 192.0,
        'confidence': 0.97,
      },
      {
        'id': 'segment-003-016',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'On propose plusieurs visualisations. Un graphique en barres pour comparer facilement, un diagramme circulaire pour voir les proportions, et un tableau détaillé avec les chiffres exacts. L\'utilisateur peut choisir ce qui lui convient le mieux.',
        'startTime': 192.0,
        'endTime': 212.0,
        'confidence': 0.88,
      },
      {
        'id': 'segment-003-017',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'Parfait. Une question importante : quid de la sécurité des données ? Nos réunions contiennent souvent des informations confidentielles.',
        'startTime': 212.0,
        'endTime': 222.0,
        'confidence': 0.94,
      },
      {
        'id': 'segment-003-018',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'C\'est une préoccupation légitime. Toutes les données sont chiffrées de bout en bout. Les enregistrements audio et les transcriptions sont stockés de manière sécurisée, et on ne conserve rien sur des serveurs tiers. Tout reste sur votre infrastructure.',
        'startTime': 222.0,
        'endTime': 244.0,
        'confidence': 0.91,
      },
      {
        'id': 'segment-003-019',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'Très bien, ça me rassure. Maintenant, parlons compatibilité. L\'application fonctionne sur quels supports ?',
        'startTime': 244.0,
        'endTime': 253.0,
        'confidence': 0.96,
      },
      {
        'id': 'segment-003-020',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'On a développé trois interfaces : une application web en Vue.js accessible depuis n\'importe quel navigateur moderne, une application mobile Flutter qui fonctionne sur Android et iOS, et tout ça communique avec un backend en microservices Quarkus.',
        'startTime': 253.0,
        'endTime': 275.0,
        'confidence': 0.87,
      },
      {
        'id': 'segment-003-021',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'Donc nos équipes pourront utiliser l\'outil depuis leur ordinateur, leur téléphone ou leur tablette sans problème ?',
        'startTime': 275.0,
        'endTime': 284.0,
        'confidence': 0.95,
      },
      {
        'id': 'segment-003-022',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'Exactement. Et les données sont synchronisées en temps réel entre tous les appareils. Si quelqu\'un commence un enregistrement sur mobile et veut le consulter plus tard sur le web, tout est accessible immédiatement.',
        'startTime': 284.0,
        'endTime': 302.0,
        'confidence': 0.92,
      },
      {
        'id': 'segment-003-023',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'C\'est vraiment bien pensé. Est-ce qu\'on peut exporter les transcriptions dans différents formats ? Parfois on a besoin de les partager avec des personnes externes.',
        'startTime': 302.0,
        'endTime': 316.0,
        'confidence': 0.93,
      },
      {
        'id': 'segment-003-024',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'Bien sûr ! On supporte l\'export en PDF pour l\'impression, en Word pour l\'édition, et en JSON pour l\'intégration avec d\'autres systèmes. On peut aussi générer des résumés automatiques si besoin.',
        'startTime': 316.0,
        'endTime': 335.0,
        'confidence': 0.89,
      },
      {
        'id': 'segment-003-025',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'Excellent. Dernière question technique : comment gérez-vous les réunions avec beaucoup de participants ? On a parfois des réunions à quinze ou vingt personnes.',
        'startTime': 335.0,
        'endTime': 348.0,
        'confidence': 0.94,
      },
      {
        'id': 'segment-003-026',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'L\'architecture en microservices nous permet de scaler facilement. On a testé avec des réunions jusqu\'à trente participants et la performance reste excellente. La diarisation devient un peu plus complexe avec autant de voix, mais elle reste fiable.',
        'startTime': 348.0,
        'endTime': 371.0,
        'confidence': 0.86,
      },
      {
        'id': 'segment-003-027',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'Parfait. Bon, je dois dire que je suis très impressionnée par ce que vous avez accompli. Maintenant, parlons calendrier. Quand est-ce que nous pourrions commencer à utiliser la plateforme en conditions réelles ?',
        'startTime': 371.0,
        'endTime': 390.0,
        'confidence': 0.95,
      },
      {
        'id': 'segment-003-028',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'On est en phase finale de tests. Je dirais qu\'on peut envisager un déploiement pilote dans deux semaines, avec un groupe restreint d\'utilisateurs. Ça permettra de valider tout en conditions réelles avant le déploiement général.',
        'startTime': 390.0,
        'endTime': 412.0,
        'confidence': 0.91,
      },
      {
        'id': 'segment-003-029',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'Deux semaines, c\'est parfait. On pourrait faire un test avec l\'équipe marketing dans un premier temps. Ils ont des réunions fréquentes et seraient de bons testeurs.',
        'startTime': 412.0,
        'endTime': 426.0,
        'confidence': 0.96,
      },
      {
        'id': 'segment-003-030',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'Excellente idée ! On pourra aussi organiser une formation rapide pour eux. L\'interface est intuitive, mais une petite session de prise en main est toujours utile.',
        'startTime': 426.0,
        'endTime': 441.0,
        'confidence': 0.93,
      },
      {
        'id': 'segment-003-031',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'Très bien. Au niveau du budget, on reste dans l\'enveloppe initiale qu\'on avait définie ?',
        'startTime': 441.0,
        'endTime': 449.0,
        'confidence': 0.97,
      },
      {
        'id': 'segment-003-032',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'Oui, on est même légèrement en dessous. On a optimisé certains aspects techniques qui nous ont permis de réduire les coûts d\'infrastructure.',
        'startTime': 449.0,
        'endTime': 462.0,
        'confidence': 0.92,
      },
      {
        'id': 'segment-003-033',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'C\'est une excellente nouvelle ! Bon, je pense qu\'on a fait le tour. Je suis vraiment satisfaite de ce que vous avez présenté aujourd\'hui. On valide le planning et on se reparle la semaine prochaine pour organiser le pilote ?',
        'startTime': 462.0,
        'endTime': 482.0,
        'confidence': 0.94,
      },
      {
        'id': 'segment-003-034',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-002',
        'speakerName': 'Thomas Blanc',
        'text': 'Parfait Sophie ! Je vous envoie un récapitulatif par email dans la journée avec le planning détaillé et les prochaines étapes. Merci encore pour votre confiance et à très bientôt !',
        'startTime': 482.0,
        'endTime': 500.0,
        'confidence': 0.95,
      },
      {
        'id': 'segment-003-035',
        'meetingId': 'meeting-003',
        'speakerId': 'participant-005',
        'speakerName': 'Sophie Rousseau',
        'text': 'Merci à vous Thomas. Excellente présentation. À bientôt !',
        'startTime': 500.0,
        'endTime': 506.0,
        'confidence': 0.98,
      },
    ],
    // Segments pour la réunion avec l'ID du mock datasource
    '550e8400-e29b-41d4-a716-446655440004': [
      {
        'id': 'segment-004-001',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'Bonjour Thomas, merci d\'avoir pris le temps pour cette présentation. J\'ai hâte de découvrir les nouveautés que vous avez préparées pour notre projet.',
        'startTime': 0.0,
        'endTime': 8.0,
        'confidence': 0.96,
      },
      {
        'id': 'segment-004-002',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'Bonjour Sophie ! Merci de votre confiance. Aujourd\'hui, je vais vous présenter l\'avancement de notre plateforme de gestion de réunions. Nous avons fait des progrès significatifs ces dernières semaines.',
        'startTime': 8.0,
        'endTime': 20.0,
        'confidence': 0.94,
      },
      {
        'id': 'segment-004-003',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'Parfait. Commençons si vous voulez bien. Quelle est la première fonctionnalité que vous souhaitez me montrer ?',
        'startTime': 20.0,
        'endTime': 26.0,
        'confidence': 0.95,
      },
      {
        'id': 'segment-004-004',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'Alors, la première grande nouveauté, c\'est l\'enregistrement audio avec une qualité optimisée. Nous avons intégré un système qui détecte automatiquement les bruits de fond et les filtre en temps réel.',
        'startTime': 26.0,
        'endTime': 40.0,
        'confidence': 0.93,
      },
      {
        'id': 'segment-004-005',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'C\'est intéressant ! Est-ce que ça fonctionne bien dans des environnements bruyants, comme des open spaces par exemple ?',
        'startTime': 40.0,
        'endTime': 48.0,
        'confidence': 0.97,
      },
      {
        'id': 'segment-004-006',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'Absolument. Nous avons fait des tests en conditions réelles et les résultats sont très concluants. Le système arrive à isoler les voix des participants même avec un niveau de bruit ambiant élevé. Je peux vous montrer une démo si vous voulez.',
        'startTime': 48.0,
        'endTime': 65.0,
        'confidence': 0.92,
      },
      {
        'id': 'segment-004-007',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'Oui, avec plaisir ! Montrez-moi ce que ça donne concrètement.',
        'startTime': 65.0,
        'endTime': 70.0,
        'confidence': 0.98,
      },
      {
        'id': 'segment-004-008',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'Voilà, vous voyez ici l\'interface d\'enregistrement. Le bouton rouge permet de démarrer, et on a des indicateurs visuels qui montrent le niveau sonore capté. La transcription se lance automatiquement en arrière-plan.',
        'startTime': 70.0,
        'endTime': 88.0,
        'confidence': 0.91,
      },
      {
        'id': 'segment-004-009',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'Très bien. Et pour la transcription justement, vous avez mentionné la diarisation lors de notre dernier échange. Comment ça se passe au niveau de l\'identification des locuteurs ?',
        'startTime': 88.0,
        'endTime': 102.0,
        'confidence': 0.94,
      },
      {
        'id': 'segment-004-010',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'Excellente question. La diarisation fonctionne en deux temps. D\'abord, l\'intelligence artificielle identifie automatiquement les différentes voix et crée des groupes de locuteurs. Ensuite, on peut associer manuellement chaque locuteur à un participant de la réunion.',
        'startTime': 102.0,
        'endTime': 124.0,
        'confidence': 0.89,
      },
      {
        'id': 'segment-004-011',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'D\'accord, donc si je comprends bien, même si l\'IA ne reconnaît pas immédiatement qui parle, on peut corriger après coup ?',
        'startTime': 124.0,
        'endTime': 133.0,
        'confidence': 0.95,
      },
      {
        'id': 'segment-004-012',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'Exactement ! Et avec le temps, le système apprend à reconnaître les empreintes vocales récurrentes, ce qui améliore la précision pour les réunions futures avec les mêmes participants.',
        'startTime': 133.0,
        'endTime': 148.0,
        'confidence': 0.93,
      },
      {
        'id': 'segment-004-013',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'C\'est vraiment intelligent comme approche. Parlons maintenant de la synthèse des réunions. J\'ai vu que vous proposez des statistiques sur le temps de parole. Comment est-ce calculé ?',
        'startTime': 148.0,
        'endTime': 163.0,
        'confidence': 0.96,
      },
      {
        'id': 'segment-004-014',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'Alors, pour chaque segment de transcription, on enregistre l\'horodatage de début et de fin. On agrège ensuite tous les segments par locuteur pour calculer leur temps de parole total. Ça permet d\'avoir une vue d\'ensemble très claire de la participation de chacun.',
        'startTime': 163.0,
        'endTime': 185.0,
        'confidence': 0.90,
      },
      {
        'id': 'segment-004-015',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'Intéressant. Et vous affichez ça sous quelle forme ? Des graphiques, des tableaux ?',
        'startTime': 185.0,
        'endTime': 192.0,
        'confidence': 0.97,
      },
      {
        'id': 'segment-004-016',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'On propose plusieurs visualisations. Un graphique en barres pour comparer facilement, un diagramme circulaire pour voir les proportions, et un tableau détaillé avec les chiffres exacts. L\'utilisateur peut choisir ce qui lui convient le mieux.',
        'startTime': 192.0,
        'endTime': 212.0,
        'confidence': 0.88,
      },
      {
        'id': 'segment-004-017',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'Parfait. Une question importante : quid de la sécurité des données ? Nos réunions contiennent souvent des informations confidentielles.',
        'startTime': 212.0,
        'endTime': 222.0,
        'confidence': 0.94,
      },
      {
        'id': 'segment-004-018',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'C\'est une préoccupation légitime. Toutes les données sont chiffrées de bout en bout. Les enregistrements audio et les transcriptions sont stockés de manière sécurisée, et on ne conserve rien sur des serveurs tiers. Tout reste sur votre infrastructure.',
        'startTime': 222.0,
        'endTime': 244.0,
        'confidence': 0.91,
      },
      {
        'id': 'segment-004-019',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'Très bien, ça me rassure. Maintenant, parlons compatibilité. L\'application fonctionne sur quels supports ?',
        'startTime': 244.0,
        'endTime': 253.0,
        'confidence': 0.96,
      },
      {
        'id': 'segment-004-020',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'On a développé trois interfaces : une application web en Vue.js accessible depuis n\'importe quel navigateur moderne, une application mobile Flutter qui fonctionne sur Android et iOS, et tout ça communique avec un backend en microservices Quarkus.',
        'startTime': 253.0,
        'endTime': 275.0,
        'confidence': 0.87,
      },
      {
        'id': 'segment-004-021',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'Donc nos équipes pourront utiliser l\'outil depuis leur ordinateur, leur téléphone ou leur tablette sans problème ?',
        'startTime': 275.0,
        'endTime': 284.0,
        'confidence': 0.95,
      },
      {
        'id': 'segment-004-022',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'Exactement. Et les données sont synchronisées en temps réel entre tous les appareils. Si quelqu\'un commence un enregistrement sur mobile et veut le consulter plus tard sur le web, tout est accessible immédiatement.',
        'startTime': 284.0,
        'endTime': 302.0,
        'confidence': 0.92,
      },
      {
        'id': 'segment-004-023',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'C\'est vraiment bien pensé. Est-ce qu\'on peut exporter les transcriptions dans différents formats ? Parfois on a besoin de les partager avec des personnes externes.',
        'startTime': 302.0,
        'endTime': 316.0,
        'confidence': 0.93,
      },
      {
        'id': 'segment-004-024',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'Bien sûr ! On supporte l\'export en PDF pour l\'impression, en Word pour l\'édition, et en JSON pour l\'intégration avec d\'autres systèmes. On peut aussi générer des résumés automatiques si besoin.',
        'startTime': 316.0,
        'endTime': 335.0,
        'confidence': 0.89,
      },
      {
        'id': 'segment-004-025',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'Excellent. Dernière question technique : comment gérez-vous les réunions avec beaucoup de participants ? On a parfois des réunions à quinze ou vingt personnes.',
        'startTime': 335.0,
        'endTime': 348.0,
        'confidence': 0.94,
      },
      {
        'id': 'segment-004-026',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'L\'architecture en microservices nous permet de scaler facilement. On a testé avec des réunions jusqu\'à trente participants et la performance reste excellente. La diarisation devient un peu plus complexe avec autant de voix, mais elle reste fiable.',
        'startTime': 348.0,
        'endTime': 371.0,
        'confidence': 0.86,
      },
      {
        'id': 'segment-004-027',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'Parfait. Bon, je dois dire que je suis très impressionnée par ce que vous avez accompli. Maintenant, parlons calendrier. Quand est-ce que nous pourrions commencer à utiliser la plateforme en conditions réelles ?',
        'startTime': 371.0,
        'endTime': 390.0,
        'confidence': 0.95,
      },
      {
        'id': 'segment-004-028',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'On est en phase finale de tests. Je dirais qu\'on peut envisager un déploiement pilote dans deux semaines, avec un groupe restreint d\'utilisateurs. Ça permettra de valider tout en conditions réelles avant le déploiement général.',
        'startTime': 390.0,
        'endTime': 412.0,
        'confidence': 0.91,
      },
      {
        'id': 'segment-004-029',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'Deux semaines, c\'est parfait. On pourrait faire un test avec l\'équipe marketing dans un premier temps. Ils ont des réunions fréquentes et seraient de bons testeurs.',
        'startTime': 412.0,
        'endTime': 426.0,
        'confidence': 0.96,
      },
      {
        'id': 'segment-004-030',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'Excellente idée ! On pourra aussi organiser une formation rapide pour eux. L\'interface est intuitive, mais une petite session de prise en main est toujours utile.',
        'startTime': 426.0,
        'endTime': 441.0,
        'confidence': 0.93,
      },
      {
        'id': 'segment-004-031',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'Très bien. Au niveau du budget, on reste dans l\'enveloppe initiale qu\'on avait définie ?',
        'startTime': 441.0,
        'endTime': 449.0,
        'confidence': 0.97,
      },
      {
        'id': 'segment-004-032',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'Oui, on est même légèrement en dessous. On a optimisé certains aspects techniques qui nous ont permis de réduire les coûts d\'infrastructure.',
        'startTime': 449.0,
        'endTime': 462.0,
        'confidence': 0.92,
      },
      {
        'id': 'segment-004-033',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'C\'est une excellente nouvelle ! Bon, je pense qu\'on a fait le tour. Je suis vraiment satisfaite de ce que vous avez présenté aujourd\'hui. On valide le planning et on se reparle la semaine prochaine pour organiser le pilote ?',
        'startTime': 462.0,
        'endTime': 482.0,
        'confidence': 0.94,
      },
      {
        'id': 'segment-004-034',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p12',
        'speakerName': 'Thomas Blanc',
        'text': 'Parfait Sophie ! Je vous envoie un récapitulatif par email dans la journée avec le planning détaillé et les prochaines étapes. Merci encore pour votre confiance et à très bientôt !',
        'startTime': 482.0,
        'endTime': 500.0,
        'confidence': 0.95,
      },
      {
        'id': 'segment-004-035',
        'meetingId': '550e8400-e29b-41d4-a716-446655440004',
        'speakerId': 'p11',
        'speakerName': 'Sophie Rousseau',
        'text': 'Merci à vous Thomas. Excellente présentation. À bientôt !',
        'startTime': 500.0,
        'endTime': 506.0,
        'confidence': 0.98,
      },
    ],
  };

  // ============================================================================
  // SYNTHÈSES PAR RÉUNION
  // ============================================================================
  
  static Map<String, dynamic> getMeetingSynthesis(String meetingId) {
    final meeting = meetings.firstWhere(
      (m) => m['id'] == meetingId,
      orElse: () => {},
    );
    
    if (meeting.isEmpty) return {};
    
    final participants = meetingParticipants[meetingId] ?? [];
    final totalSpeakTime = participants.fold<int>(
      0,
      (sum, p) => sum + (p['speakTime'] as int),
    );
    
    final duration = meeting['duration'] as int;
    final silenceTime = duration - totalSpeakTime;
    
    return {
      'meetingId': meetingId,
      'title': meeting['title'],
      'date': meeting['date'],
      'totalDuration': duration,
      'totalSpeakTime': totalSpeakTime,
      'silenceTime': silenceTime > 0 ? silenceTime : 0,
      'participantCount': participants.length,
      'participants': participants.map((p) {
        final participant = MockData.participants.firstWhere(
          (part) => part['id'] == p['participantId'],
          orElse: () => {},
        );
        return {
          ...participant,
          'speakTime': p['speakTime'],
          'interventions': p['interventions'],
          'speakPercentage': (p['speakTime'] / totalSpeakTime * 100).toStringAsFixed(1),
        };
      }).toList(),
      'status': meeting['status'],
    };
  }

  // ============================================================================
  // STATISTIQUES GLOBALES
  // ============================================================================
  
  static Map<String, dynamic> getGlobalStats() {
    final completedMeetings = meetings.where((m) => m['status'] == 'completed').toList();
    final totalDuration = completedMeetings.fold<int>(
      0,
      (sum, m) => sum + (m['duration'] as int),
    );
    
    return {
      'totalMeetings': meetings.length,
      'completedMeetings': completedMeetings.length,
      'scheduledMeetings': meetings.where((m) => m['status'] == 'scheduled').length,
      'totalDuration': totalDuration,
      'averageDuration': completedMeetings.isNotEmpty 
          ? (totalDuration / completedMeetings.length).round()
          : 0,
      'totalParticipants': participants.length,
    };
  }

  // ============================================================================
  // RECHERCHE
  // ============================================================================
  
  static List<Map<String, dynamic>> searchMeetings(String query) {
    if (query.isEmpty) return meetings;
    
    final lowerQuery = query.toLowerCase();
    return meetings.where((m) {
      final title = (m['title'] as String).toLowerCase();
      final description = (m['description'] as String? ?? '').toLowerCase();
      return title.contains(lowerQuery) || description.contains(lowerQuery);
    }).toList();
  }

  // ============================================================================
  // HELPERS
  // ============================================================================
  
  static Map<String, dynamic>? getMeetingById(String id) {
    try {
      return meetings.firstWhere((m) => m['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic>? getParticipantById(String id) {
    try {
      return participants.firstWhere((p) => p['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> getMeetingParticipantsList(String meetingId) {
    final meetingParts = meetingParticipants[meetingId] ?? [];
    return meetingParts.map((mp) {
      final participant = getParticipantById(mp['participantId']);
      return {
        ...?participant,
        'speakTime': mp['speakTime'],
        'interventions': mp['interventions'],
      };
    }).toList();
  }

  static List<Map<String, dynamic>> getSegments(String meetingId) {
    return transcriptionSegments[meetingId] ?? [];
  }
}
