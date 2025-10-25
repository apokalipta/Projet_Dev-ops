# Guide de Développement Local - Application Flutter

## Architecture Actuelle

L'application Flutter est configurée pour fonctionner en mode développement local avec des données mock, conforme à l'architecture documentée dans le document technique.

## Structure des Données

### Entité Meeting

```dart
Meeting {
  id: String (UUID)
  title: String
  date: DateTime
  language: String (default: 'fr')
  status: MeetingStatus (scheduled, inProgress, completed, transcribed, failed)
  duration: int? (en minutes)
  participants: List<Participant>
  createdAt: DateTime?
  updatedAt: DateTime?
}
```

### Entité Participant

```dart
Participant {
  id: String
  name: String
  email: String?
  speakingOrder: int?
}
```

### Statuts de Réunion

- **scheduled** (Planifiée) - Réunion à venir
- **inProgress** (En cours) - Réunion en cours d'enregistrement
- **completed** (Terminée) - Réunion terminée, en attente de transcription
- **transcribed** (Transcrite) - Transcription disponible
- **failed** (Échec) - Échec de la transcription

## Données Mock Disponibles

L'application contient 4 réunions de test :

1. **Réunion d'équipe - Sprint Planning**
   - Statut : Planifiée
   - Date : Dans 2 heures
   - Durée : 60 min
   - 3 participants

2. **Revue de projet - Application Mobile**
   - Statut : Planifiée
   - Date : Demain à 10h
   - Durée : 90 min
   - 3 participants

3. **Brainstorming - Nouvelles Fonctionnalités**
   - Statut : Transcrite
   - Date : Hier
   - Durée : 120 min
   - 4 participants

4. **Réunion Client - Présentation POC**
   - Statut : Terminée
   - Date : Il y a 3 heures
   - Durée : 45 min
   - 2 participants

## Commandes de Développement

### Lancer l'application

```bash
# Sur émulateur Android
flutter run

# Sur Chrome (web)
flutter run -d chrome

# Sur Windows (nécessite Developer Mode)
flutter run -d windows
```

### Générer les fichiers de code

Après modification des modèles (Freezed, Riverpod, JSON) :

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Hot Reload

Pendant l'exécution :
- Appuyez sur `r` pour hot reload
- Appuyez sur `R` pour hot restart
- Appuyez sur `q` pour quitter

## Architecture des Fichiers

```
lib/
├── main.dart
└── src/
    ├── core/
    │   ├── api/
    │   │   └── dio_client.dart (Configuration API - non utilisé en mode mock)
    │   ├── navigation/
    │   │   └── app_router.dart (GoRouter)
    │   └── theme/
    │       └── app_theme.dart
    └── features/
        └── meeting/
            ├── data/
            │   ├── datasources/
            │   │   ├── meeting_mock_datasource.dart ✅ (Utilisé actuellement)
            │   │   └── meeting_remote_datasource.dart (Pour API réelle)
            │   ├── models/
            │   │   └── meeting_model.dart (DTO)
            │   └── repositories/
            │       └── meeting_repository_impl.dart
            ├── domain/
            │   ├── entities/
            │   │   └── meeting.dart (Entités métier)
            │   └── repositories/
            │       └── meeting_repository.dart (Interface)
            └── presentation/
                ├── providers/
                │   └── meeting_provider.dart (Riverpod)
                ├── screens/
                │   └── meeting_list_screen.dart
                └── widgets/
                    └── meeting_card.dart
```

## Passer à l'API Réelle

Quand le backend sera prêt :

### 1. Mettre à jour l'URL de l'API

Dans `lib/src/core/api/dio_client.dart` :

```dart
dio.options.baseUrl = 'http://10.0.2.2:8081/api'; // Pour émulateur Android
// ou
dio.options.baseUrl = 'http://localhost:8081/api'; // Pour web/desktop
```

### 2. Changer le datasource

Dans `lib/src/features/meeting/data/repositories/meeting_repository_impl.dart` :

```dart
// Remplacer
import 'package:meeting_app/src/features/meeting/data/datasources/meeting_mock_datasource.dart';
final MeetingMockDataSource mockDataSource;

// Par
import 'package:meeting_app/src/features/meeting/data/datasources/meeting_remote_datasource.dart';
final MeetingRemoteDataSource remoteDataSource;
```

Et dans le provider :

```dart
@riverpod
MeetingRepository meetingRepository(Ref ref) {
  final remoteDataSource = ref.watch(meetingRemoteDataSourceProvider);
  return MeetingRepositoryImpl(remoteDataSource);
}
```

### 3. Régénérer les fichiers

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Endpoints API Attendus

Selon l'architecture documentée, le Meeting Service doit exposer :

- `GET /api/meetings` - Liste des réunions
- `GET /api/meetings/{id}` - Détail d'une réunion
- `POST /api/meetings` - Créer une réunion
- `PUT /api/meetings/{id}` - Modifier une réunion
- `DELETE /api/meetings/{id}` - Supprimer une réunion
- `POST /api/meetings/{id}/participants` - Ajouter des participants

## Format JSON Attendu

### Réunion (Meeting)

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "title": "Réunion d'équipe",
  "date": "2025-10-25T14:00:00Z",
  "language": "fr",
  "status": "scheduled",
  "duration": 60,
  "participants": [
    {
      "id": "p1",
      "name": "Alice Dupont",
      "email": "alice.dupont@example.com",
      "speakingOrder": 1
    }
  ],
  "createdAt": "2025-10-23T10:00:00Z",
  "updatedAt": "2025-10-24T10:00:00Z"
}
```

## Prochaines Étapes

1. **Phase M1** (En cours)
   - ✅ CRUD réunions (mock)
   - ⏳ Enregistrement audio web/mobile
   - ⏳ Stockage audio
   - ⏳ Intégration avec Recording Service

2. **Phase M2** (À venir)
   - Pipeline transcription
   - Diarisation
   - Consultation segments
   - Synthèse métriques

3. **Phase M3** (À venir)
   - Édition avancée
   - Attribution locuteurs
   - Export PDF/Docx/JSON

## Dépendances Principales

- `flutter_riverpod` - State management
- `freezed` - Immutabilité et code generation
- `dio` - HTTP client
- `go_router` - Navigation
- `json_annotation` - Sérialisation JSON

## Troubleshooting

### Erreur de génération de code

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erreur de connexion réseau

Vérifiez que vous utilisez bien le mock datasource en mode développement local.

### L'application ne se lance pas

```bash
# Vérifier les devices disponibles
flutter devices

# Lancer sur un device spécifique
flutter run -d chrome
```

---

**Dernière mise à jour** : 25 octobre 2025
**Version** : 1.0 - Mode Mock Local
