# Transcript IA - Frontend

Application web frontend pour la transcription automatique de réunions en temps réel avec intelligence artificielle.

## 📋 Table des matières

- [Description](#description)
- [Technologies](#technologies)
- [Fonctionnalités](#fonctionnalités)
- [Installation](#installation)
- [Configuration](#configuration)
- [Structure du projet](#structure-du-projet)
- [Utilisation](#utilisation)
- [Développement](#développement)
- [Build et déploiement](#build-et-déploiement)
- [Tests](#tests)

## 📖 Description

Transcript IA est une application web moderne permettant de :
- Planifier et gérer des réunions
- Enregistrer des réunions en temps réel avec transcription automatique
- Visualiser et éditer les transcriptions
- Analyser les réunions avec des statistiques détaillées
- Générer des résumés automatiques

L'application utilise Vue.js 3 avec Vite pour une expérience de développement rapide et une performance optimale.

## 🛠 Technologies

- **Vue.js 3** - Framework JavaScript progressif
- **Vite** - Build tool et serveur de développement
- **lamejs** - Encodage MP3 côté client pour l'enregistrement audio
- **Web Audio API** - Capture audio en temps réel
- **Fetch API** - Communication avec les services backend

## ✨ Fonctionnalités

### Gestion des réunions
- ✅ Création et planification de réunions
- ✅ Gestion des participants
- ✅ Statuts de réunion (planifiée, en cours, terminée)
- ✅ Recherche et filtrage des réunions

### Enregistrement et transcription
- ✅ Enregistrement audio en temps réel (format MP3)
- ✅ Envoi de segments audio pour transcription
- ✅ Transcription automatique via service AI
- ✅ Upload manuel de fichiers audio

### Visualisation et édition
- ✅ Affichage des transcriptions avec timestamps
- ✅ Recherche par mot-clé dans les transcriptions
- ✅ Filtrage par locuteur
- ✅ Attribution manuelle des locuteurs aux segments
- ✅ Correction du texte des segments
- ✅ Fusion de segments
- ✅ Scission de segments

### Synthèse et statistiques
- ✅ Calcul de la durée totale de la réunion
- ✅ Temps de parole par locuteur avec pourcentages
- ✅ Génération automatique de résumés
- ✅ Statistiques visuelles avec graphiques

### Cache et performance
- ✅ Système de cache pour les données API
- ✅ Gestion automatique de l'invalidation du cache
- ✅ Fallback sur cache en cas d'erreur réseau

## 🚀 Installation

### Prérequis

- Node.js >= 16.x
- npm >= 8.x

### Installation des dépendances

```bash
cd frontend
npm install
```

## ⚙️ Configuration

### Variables d'environnement

Créez un fichier `.env` à la racine du dossier `frontend` :

```env
# URL de l'API backend (Meeting Service)
VITE_API_URL=http://localhost:8081/api

# URL du service de transcription
VITE_TRANSCRIPTION_URL=http://localhost:8082/api
```

### Configuration API

Les URLs des services sont configurées dans `src/config/api.js`. Par défaut :
- **Meeting Service** : `http://localhost:8081/api`
- **Transcription Service** : `http://localhost:8082/api`

## 📁 Structure du projet

```
frontend/
├── src/
│   ├── components/          # Composants Vue
│   │   ├── SetupMeeting.vue      # Création de réunion
│   │   ├── MeetingsList.vue      # Liste des réunions
│   │   ├── MeetingViewer.vue      # Visualisation et synthèse
│   │   ├── RecordMeeting.vue     # Enregistrement audio
│   │   ├── SearchMeetings.vue    # Recherche de réunions
│   │   ├── StartMeeting.vue      # Démarrage de réunion
│   │   ├── ManageParticipants.vue # Gestion participants
│   │   └── AssignParticipants.vue # Attribution participants
│   ├── services/            # Services API
│   │   ├── api.js                # Service principal API
│   │   └── cacheService.js       # Gestion du cache
│   ├── config/              # Configuration
│   │   ├── api.js                # Configuration API
│   │   └── constants.js          # Constantes
│   ├── utils/               # Utilitaires
│   │   └── helpers.js            # Fonctions helper
│   ├── App.vue              # Composant racine
│   ├── main.js              # Point d'entrée
│   └── style.css            # Styles globaux
├── public/                  # Fichiers statiques
│   └── lame.all.js          # Bibliothèque lamejs
├── test-segments.json       # Fichier de test pour segments
├── index.html               # Template HTML
├── vite.config.js           # Configuration Vite
├── package.json             # Dépendances
└── README.md                # Ce fichier
```

## 💻 Utilisation

### Démarrage en mode développement

```bash
npm run dev
```

L'application sera accessible sur `http://localhost:3000`

### Build pour la production

```bash
npm run build
```

Les fichiers de production seront générés dans le dossier `dist/`

### Prévisualisation du build

```bash
npm run preview
```

## 🎯 Fonctionnalités détaillées

### Enregistrement audio

L'application utilise le Web Audio API pour capturer l'audio du microphone et l'encoder en MP3 en temps réel avec `lamejs`. Les segments audio sont envoyés automatiquement au service de transcription.

**Fonctionnalités :**
- Enregistrement en MP3 (pas de conversion WebM)
- Envoi de segments en temps réel
- Validation des fichiers MP3 avant envoi
- Gestion des erreurs et retry automatique

### Chargement de segments de test

Pour tester rapidement sans backend, vous pouvez charger des segments depuis un fichier JSON :

1. Cliquez sur "Charger segments (test)" dans la page de visualisation
2. Sélectionnez un fichier JSON avec le format suivant :

```json
[
  {
    "id": "test_1",
    "texte": "Texte du segment",
    "timeDepart": 0,
    "timeFin": 5,
    "locuteurId": 1
  }
]
```

Un fichier d'exemple est disponible : `test-segments.json`

### Synthèse de réunion

La vue synthèse permet de :
- Voir les statistiques globales (durée, participants, segments)
- Analyser le temps de parole par locuteur
- Consulter le résumé automatique
- Éditer les segments (corriger, fusionner, scinder, réassigner)

**Actions disponibles sur les segments :**
- ✏️ **Corriger** : Modifier le texte d'un segment
- 👤 **Réassigner** : Changer le locuteur d'un segment
- 🔗 **Fusionner** : Combiner un segment avec le suivant
- ✂️ **Scinder** : Diviser un segment en deux parties

## 🔧 Développement

### Architecture

L'application suit une architecture modulaire :

- **Composants** : Composants Vue réutilisables et isolés
- **Services** : Logique métier et communication API
- **Config** : Configuration centralisée
- **Utils** : Fonctions utilitaires

### Cache API

Le système de cache stocke les réponses GET dans un fichier JSON local (`.api-cache/`). Le cache :
- Durée de vie : 1 heure par défaut
- Invalidation automatique après TTL
- Fallback automatique en cas d'erreur réseau

### Gestion des erreurs

- Gestion robuste des erreurs API
- Messages d'erreur utilisateur-friendly
- Logs détaillés en console pour le débogage
- Retry automatique pour les opérations critiques

## 🐳 Déploiement avec Docker

### Build de l'image Docker

```bash
docker build -t transcript-ia-frontend .
```

### Lancement avec Docker Compose

```bash
docker compose up -d
```

L'application sera accessible sur le port configuré (par défaut 80).

## 📝 Scripts disponibles

- `npm run dev` - Démarre le serveur de développement
- `npm run build` - Build pour la production
- `npm run preview` - Prévisualise le build de production

## 🧪 Tests

### Test manuel avec segments

1. Créer une réunion via l'interface
2. Ouvrir la réunion
3. Cliquer sur "Charger segments (test)"
4. Sélectionner `test-segments.json`
5. Vérifier l'affichage dans les vues Transcription et Synthèse

### Test de l'enregistrement

1. Démarrer une réunion
2. Cliquer sur "Démarrer l'enregistrement"
3. Autoriser l'accès au microphone
4. Parler pendant quelques secondes
5. Vérifier l'envoi des segments dans la console

## 🔌 Intégration avec les services backend

### Meeting Service (Port 8081)

Endpoints utilisés :
- `GET /api/meeting/all` - Liste des réunions
- `GET /api/meeting/:id` - Détails d'une réunion
- `POST /api/meeting` - Créer une réunion
- `POST /api/meeting/:id/start` - Démarrer une réunion
- `POST /api/meeting/:id/end` - Terminer une réunion
- `GET /api/meeting/:id/participant/all` - Participants d'une réunion

### Transcription Service (Port 8082)

Endpoints utilisés :
- `POST /api/transcription/:id/send_segment` - Envoyer un segment audio
- `POST /api/transcription/:id/save_record_file` - Sauvegarder l'enregistrement complet
- `GET /api/transcription/:id/segment/all` - Tous les segments
- `POST /api/transcription/:id/start_transcription` - Démarrer la transcription

## 🐛 Dépannage

### Problème : Erreur de connexion au backend

Vérifiez que :
- Les services backend sont démarrés
- Les URLs dans `src/config/api.js` sont correctes
- Aucun firewall ne bloque les connexions

### Problème : Enregistrement audio ne fonctionne pas

Vérifiez que :
- Le navigateur autorise l'accès au microphone
- `lame.all.js` est chargé (vérifier la console)
- Le navigateur supporte le Web Audio API

### Problème : Cache obsolète

Supprimez le dossier `.api-cache/` à la racine du projet et rechargez l'application.

## 📄 Licence

MIT

## 👥 Auteurs

Équipe Transcript IA

## 🔗 Liens utiles

- [Documentation Vue.js](https://vuejs.org/)
- [Documentation Vite](https://vitejs.dev/)
- [Web Audio API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API)
