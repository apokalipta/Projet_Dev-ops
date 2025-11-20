# 🎙️ Meeting App - Application de Gestion de Réunions

Application Flutter pour la gestion de réunions avec enregistrement audio, transcription automatique et analyse par IA.

## ✨ Fonctionnalités

- 📝 **Création et gestion de réunions**
- 🎤 **Enregistrement audio en temps réel** (segments de 1min30)
- 📊 **Transcription automatique** via WhisperX
- 👥 **Identification des locuteurs** avec Pyannote
- 🔍 **Analyse IA** des transcriptions
- 💾 **Stockage local et synchronisation cloud**
- 🗑️ **Suppression de réunions**

## 📚 Documentation

- **[INDEX_DOCUMENTATION.md](INDEX_DOCUMENTATION.md)** - Index de la documentation

## 🚀 Démarrage rapide

### Prérequis

- Flutter SDK (>=3.5.4)
- Dart SDK (>=3.5.4)
- Android Studio / VS Code
- Un émulateur Android ou un appareil physique

### Installation

1. Cloner le projet
2. Installer les dépendances :
   ```bash
   flutter pub get
   ```
3. Générer les fichiers de code :
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Lancer l'application :
   ```bash
   flutter run
   ```

## 🏗️ Architecture

Le projet suit une architecture en couches avec Riverpod pour la gestion d'état :

```
lib/
├── src/
│   ├── core/              # Fonctionnalités communes
│   │   ├── api/          # Services API et configuration
│   │   ├── navigation/   # Système de navigation
│   │   └── theme/        # Thème de l'application
│   └── features/         # Fonctionnalités métier
│       ├── meeting/      # Gestion des réunions
│       └── transcription/ # Gestion des transcriptions
```

## 🔌 Services Backend

### Meeting-service (Port 8081)

Service Quarkus pour la gestion des réunions et participants.

**Endpoints principaux** :
- `POST /api/meeting` - Créer une réunion
- `GET /api/meeting/all` - Liste des réunions
- `GET /api/meeting/{id}` - Détails d'une réunion
- `DELETE /api/meeting/{id}` - Supprimer une réunion
- `POST /api/meeting/{id}/participant` - Ajouter un participant
- `PUT /api/meeting/{id}/start` - Démarrer une réunion
- `PUT /api/meeting/{id}/end` - Terminer une réunion

### Transcription-service (Port 8082)

Service Quarkus pour la gestion des transcriptions.

**Endpoints principaux** :
- `POST /api/transcription/{id}/send_segment` - Envoyer un segment audio
- `GET /api/transcription/{id}/segment/all` - Récupérer tous les segments
- `PUT /api/transcription/{id}/segment/{segmentId}/locuteur/{participantId}` - Assigner un locuteur

### AI-service (Port 8000)

Service Python FastAPI pour la transcription et l'analyse IA.

**Technologies** :
- WhisperX (transcription)
- Pyannote (diarisation des locuteurs)
- FastAPI (API REST)

## 🐳 Docker

### Démarrer les services

```bash
# Meeting-service
cd Projet_Dev-ops-dev-meeting-service
docker-compose up -d

# Transcription-service + AI-service
cd Projet_Dev-ops-dev-transcription-service
docker-compose -f Pull_dock.yaml up -d
```

### Vérifier les services

```bash
docker ps
```

### Voir les logs

```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker logs -f ai-service
```

## 📦 Packages principaux

### Frontend (Flutter)
- **flutter_riverpod** (2.6.1) - Gestion d'état
- **go_router** (14.6.2) - Navigation
- **dio** (5.7.0) - Client HTTP
- **record** (5.1.2) - Enregistrement audio
- **just_audio** (0.9.42) - Lecture audio
- **freezed** (2.5.7) - Classes immuables
- **json_serializable** (6.8.0) - Sérialisation JSON

### Backend
- **Quarkus** (3.15.1) - Framework Java
- **MySQL** (8.0) - Base de données
- **FastAPI** - Framework Python
- **WhisperX** - Transcription audio
- **Pyannote** - Diarisation des locuteurs

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test
```

## 📱 Build

```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## 🔧 Configuration

### Flutter App

Modifier `lib/src/core/config/app_config.dart` :

```dart
static const String apiBaseUrl = 'http://localhost:8081/api';
static const bool debugMode = true;
```

### Hugging Face Token (pour Pyannote)

1. Créer un compte sur https://huggingface.co
2. Générer un token : https://huggingface.co/settings/tokens
3. Accepter les conditions :
   - https://huggingface.co/pyannote/embedding
   - https://huggingface.co/pyannote/speaker-diarization-3.1
4. Ajouter le token dans `Pull_dock.yaml` :
   ```yaml
   environment:
     - HF_TOKEN=hf_xxxxxxxxxxxxxxxxxx
   ```

## 🚦 Workflow d'enregistrement

1. **Créer une réunion** → Titre, description, nombre de participants
2. **Définir les participants** → Noms des participants
3. **Démarrer l'enregistrement** → Segments de 1min30 envoyés automatiquement
4. **Terminer** → Transcription et analyse IA
5. **Consulter les résultats** → Transcription avec identification des locuteurs

## 🤝 Contribution

1. Créer une branche feature
2. Commiter les changements
3. Pousser vers la branche
4. Créer une Pull Request

## 📄 Licence

Ce projet est un projet académique DevOps.
