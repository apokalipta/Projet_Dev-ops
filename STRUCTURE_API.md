# Structure de l'intégration API

## 📁 Arborescence des fichiers

```
Projet_Dev-ops-dev-mobile/
│
├── 📄 API_SPECIFICATION.md          # Spécification des endpoints API
├── 📄 INTEGRATION_API.md            # Guide d'intégration complet
├── 📄 API_INTEGRATION_SUMMARY.md    # Résumé et checklist
├── 📄 CHANGELOG_API.md              # Historique des modifications
├── 📄 STRUCTURE_API.md              # Ce fichier
├── 📄 README.md                     # Documentation principale (mise à jour)
│
└── lib/
    └── src/
        └── core/
            └── api/
                ├── 📄 api_config.dart                    # Configuration (URLs, timeouts)
                ├── 📄 api_services.dart                  # Export centralisé
                ├── 📄 dio_client.dart                    # Client HTTP Dio
                ├── 📄 dio_client.g.dart                  # Code généré
                ├── 📄 meeting_api_service.dart           # Service Meeting
                ├── 📄 meeting_api_service.g.dart         # Code généré
                ├── 📄 transcription_api_service.dart     # Service Transcription
                ├── 📄 transcription_api_service.g.dart   # Code généré
                ├── 📄 README.md                          # Documentation technique
                └── 📄 EXAMPLE_USAGE.dart                 # Exemples de code
```

---

## 🔄 Flux de données

```
┌─────────────────────────────────────────────────────────────────┐
│                         APPLICATION                              │
└─────────────────────────────────────────────────────────────────┘
                                ▲
                                │
                                │ Données
                                │
┌─────────────────────────────────────────────────────────────────┐
│                    WIDGETS (Présentation)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Meeting     │  │ Transcription│  │   Autres     │          │
│  │  Screens     │  │   Screens    │  │   Screens    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                                ▲
                                │
                                │ AsyncValue<T>
                                │
┌─────────────────────────────────────────────────────────────────┐
│                  PROVIDERS (Gestion d'état)                      │
│  ┌──────────────┐  ┌──────────────┐                             │
│  │  Meetings    │  │Transcriptions│  ← À CRÉER                  │
│  │  Provider    │  │   Provider   │                             │
│  └──────────────┘  └──────────────┘                             │
└─────────────────────────────────────────────────────────────────┘
                                ▲
                                │
                                │ Models (Meeting, Transcription)
                                │
┌─────────────────────────────────────────────────────────────────┐
│                 REPOSITORIES (Logique métier)                    │
│  ┌──────────────┐  ┌──────────────┐                             │
│  │  Meeting     │  │Transcription │  ← À CRÉER                  │
│  │  Repository  │  │  Repository  │                             │
│  └──────────────┘  └──────────────┘                             │
└─────────────────────────────────────────────────────────────────┘
                                ▲
                                │
                                │ Response (Dio)
                                │
┌─────────────────────────────────────────────────────────────────┐
│                   SERVICES API (Réseau)                          │
│  ┌──────────────┐  ┌──────────────┐                             │
│  │  Meeting     │  │Transcription │  ✅ CRÉÉ                    │
│  │  API Service │  │  API Service │                             │
│  └──────────────┘  └──────────────┘                             │
└─────────────────────────────────────────────────────────────────┘
                                ▲
                                │
                                │ HTTP Requests
                                │
┌─────────────────────────────────────────────────────────────────┐
│                      DIO CLIENT                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │  • Configuration (baseUrl, timeouts)                │        │
│  │  • Intercepteurs (auth, erreurs)                    │  ✅    │
│  │  • Headers automatiques                             │        │
│  └─────────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
                                ▲
                                │
                                │ HTTP/HTTPS
                                │
┌─────────────────────────────────────────────────────────────────┐
│                      BACKEND API                                 │
│  ┌──────────────┐  ┌──────────────┐                             │
│  │   Meeting    │  │Transcription │                             │
│  │   Endpoints  │  │  Endpoints   │                             │
│  └──────────────┘  └──────────────┘                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Endpoints disponibles

### Meeting API (Sous-projet N°1)

| Endpoint | Méthode | Service | Status |
|----------|---------|---------|--------|
| `/api/meeting` | POST | `createMeeting()` | ✅ |
| `/api/meeting/all` | GET | `getAllMeetings()` | ✅ |
| `/api/meeting/:id` | GET | `getMeetingById()` | ✅ |
| `/api/meeting/:id/participant/all` | GET | `getMeetingParticipants()` | ✅ |
| `/api/meeting/:id/participant/:pid` | DELETE | `removeParticipant()` | ✅ |
| `/api/meeting/:id/participant/` | POST | `addParticipant()` | ✅ |
| `/api/meeting/search/byTitle` | GET | `searchMeetingByTitle()` | ✅ |

### Transcription API (Sous-projet N°2)

| Endpoint | Méthode | Service | Status |
|----------|---------|---------|--------|
| `/api/transcribe` | POST | `transcribeAudio()` | ✅ |
| `/api/transcription/:id/segment/all` | GET | `getAllSegments()` | ✅ |
| `/api/transcription/:id/segment/:sid` | GET | `getSegmentById()` | ✅ |
| `/api/transcription/:id/segment/:sid` | PUT | `updateSegmentText()` | ✅ |
| `/api/transcription/:id/segment/:sid/locuteur/all` | GET | `getSegmentSpeakers()` | ✅ |
| `/api/transcription/:id/segment/:sid/locuteur/:pid` | PUT | `updateSegmentSpeaker()` | ✅ |
| `/api/transcription/:id/record_file` | GET | `getRecordFile()` | ✅ |
| `/api/transcription/:id/segment/:sid/time_depart` | GET | `getSegmentStartTime()` | ✅ |
| `/api/transcription/:id/segment/:sid/time_fin` | GET | `getSegmentEndTime()` | ✅ |

**Légende** : ✅ Implémenté | ⏳ En cours | ❌ Non implémenté

---

## 🔧 Configuration

### Environnements

```dart
// api_config.dart

class ApiConfig {
  // Développement
  static const String devUrl = 'http://localhost:8080/api';
  
  // Staging
  static const String stagingUrl = 'https://staging-api.domaine.com/api';
  
  // Production
  static const String prodUrl = 'https://api.domaine.com/api';
  
  // Sélection automatique
  static String getBaseUrl() {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    switch (env) {
      case 'prod': return prodUrl;
      case 'staging': return stagingUrl;
      default: return devUrl;
    }
  }
}
```

### Timeouts

| Type | Durée | Description |
|------|-------|-------------|
| Connect | 5s | Temps max pour établir la connexion |
| Receive | 3s | Temps max pour recevoir les données |
| Send | 10s | Temps max pour envoyer les données |

---

## 📦 Providers Riverpod

### Services (Créés automatiquement)

```dart
// Utilisation dans un widget
final meetingService = ref.watch(meetingApiServiceProvider);
final transcriptionService = ref.watch(transcriptionApiServiceProvider);
```

### Repositories (À créer)

```dart
// À créer dans lib/src/features/meeting/data/repositories/
@riverpod
MeetingRepository meetingRepository(MeetingRepositoryRef ref) {
  return MeetingRepository(ref.watch(meetingApiServiceProvider));
}

// À créer dans lib/src/features/transcription/data/repositories/
@riverpod
TranscriptionRepository transcriptionRepository(TranscriptionRepositoryRef ref) {
  return TranscriptionRepository(ref.watch(transcriptionApiServiceProvider));
}
```

### Data Providers (À créer)

```dart
// À créer dans lib/src/features/meeting/presentation/providers/
@riverpod
Future<List<Meeting>> meetings(MeetingsRef ref) async {
  final repository = ref.watch(meetingRepositoryProvider);
  return await repository.getAllMeetings();
}

// À créer dans lib/src/features/transcription/presentation/providers/
@riverpod
Future<List<Segment>> segments(SegmentsRef ref, String meetingId) async {
  final repository = ref.watch(transcriptionRepositoryProvider);
  return await repository.getSegments(meetingId);
}
```

---

## 🛠️ Utilisation

### Exemple 1 : Lister les réunions

```dart
// 1. Dans le widget
class MeetingsListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsProvider);
    
    return meetingsAsync.when(
      data: (meetings) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Erreur: $error'),
    );
  }
}

// 2. Le provider (à créer)
@riverpod
Future<List<Meeting>> meetings(MeetingsRef ref) async {
  final repository = ref.watch(meetingRepositoryProvider);
  return await repository.getAllMeetings();
}

// 3. Le repository (à créer)
class MeetingRepository {
  final MeetingApiService _apiService;
  
  Future<List<Meeting>> getAllMeetings() async {
    final response = await _apiService.getAllMeetings();
    return (response.data as List)
        .map((json) => Meeting.fromJson(json))
        .toList();
  }
}

// 4. Le service (déjà créé)
class MeetingApiService {
  Future<Response> getAllMeetings() async {
    return await _dio.get('/meeting/all');
  }
}
```

### Exemple 2 : Créer une réunion

```dart
// 1. Dans le widget
ElevatedButton(
  onPressed: () async {
    try {
      await ref.read(meetingsNotifierProvider.notifier)
          .createMeeting(newMeeting);
      // Succès
    } catch (e) {
      // Erreur
    }
  },
  child: Text('Créer'),
)

// 2. Le notifier (à créer)
@riverpod
class MeetingsNotifier extends _$MeetingsNotifier {
  @override
  Future<List<Meeting>> build() async {
    return await ref.read(meetingRepositoryProvider).getAllMeetings();
  }
  
  Future<void> createMeeting(Meeting meeting) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(meetingRepositoryProvider).createMeeting(meeting);
      return await ref.read(meetingRepositoryProvider).getAllMeetings();
    });
  }
}
```

---

## 📋 Checklist d'implémentation

### Phase 1 : Configuration (✅ Terminé)
- [x] Créer `api_config.dart`
- [x] Configurer `dio_client.dart`
- [x] Créer `meeting_api_service.dart`
- [x] Créer `transcription_api_service.dart`
- [x] Générer le code avec build_runner

### Phase 2 : Repositories (À faire)
- [ ] Créer `MeetingRepository`
- [ ] Créer `TranscriptionRepository`
- [ ] Implémenter la transformation des données
- [ ] Gérer les erreurs

### Phase 3 : Providers (À faire)
- [ ] Créer les providers de données
- [ ] Créer les notifiers pour les mutations
- [ ] Implémenter le cache
- [ ] Gérer le refresh

### Phase 4 : Intégration UI (À faire)
- [ ] Intégrer dans les écrans existants
- [ ] Remplacer les données mockées
- [ ] Gérer les états de chargement
- [ ] Gérer les erreurs

### Phase 5 : Authentification (À faire)
- [ ] Implémenter le service d'auth
- [ ] Stocker le token
- [ ] Ajouter le token aux headers
- [ ] Gérer le refresh token

### Phase 6 : Tests (À faire)
- [ ] Tests unitaires des services
- [ ] Tests unitaires des repositories
- [ ] Tests d'intégration
- [ ] Tests E2E

---

## 📚 Documentation

| Document | Description | Localisation |
|----------|-------------|--------------|
| API_SPECIFICATION.md | Spécification complète des endpoints | Racine |
| INTEGRATION_API.md | Guide d'intégration avec exemples | Racine |
| API_INTEGRATION_SUMMARY.md | Résumé et checklist | Racine |
| CHANGELOG_API.md | Historique des modifications | Racine |
| README.md (api/) | Documentation technique | lib/src/core/api/ |
| EXAMPLE_USAGE.dart | Exemples de code | lib/src/core/api/ |

---

## 🎓 Ressources

### Documentation externe
- [Dio](https://pub.dev/packages/dio) - Client HTTP
- [Riverpod](https://riverpod.dev) - Gestion d'état
- [Flutter](https://flutter.dev) - Framework

### Tutoriels recommandés
- [Riverpod Architecture](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/)
- [Dio Interceptors](https://pub.dev/documentation/dio/latest/dio/Interceptor-class.html)
- [Error Handling](https://docs.flutter.dev/cookbook/networking/fetch-data)

---

**Dernière mise à jour** : 7 novembre 2024  
**Version** : 1.0.0
