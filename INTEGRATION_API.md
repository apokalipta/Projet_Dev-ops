# Guide d'intégration des APIs

Ce document explique comment intégrer et utiliser les services API dans l'application Flutter.

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Configuration initiale](#configuration-initiale)
3. [Utilisation des services](#utilisation-des-services)
4. [Exemples d'intégration](#exemples-dintégration)
5. [Gestion des états](#gestion-des-états)
6. [Bonnes pratiques](#bonnes-pratiques)

---

## Vue d'ensemble

Les services API ont été créés selon la spécification définie dans `API_SPECIFICATION.md`. Ils sont prêts à être utilisés mais **ne sont pas encore connectés au backend**.

### Fichiers créés

```
lib/src/core/api/
├── api_config.dart                    # Configuration des URLs et timeouts
├── api_services.dart                  # Export centralisé
├── dio_client.dart                    # Client HTTP configuré
├── meeting_api_service.dart           # Service Meeting (Sous-projet N°1)
├── transcription_api_service.dart     # Service Transcription (Sous-projet N°2)
└── README.md                          # Documentation détaillée
```

---

## Configuration initiale

### 1. Configurer l'URL du backend

Modifiez `lib/src/core/api/api_config.dart` :

```dart
class ApiConfig {
  // Remplacez par l'URL réelle de votre backend
  static const String devUrl = 'http://192.168.1.100:8080/api'; // IP locale
  static const String prodUrl = 'https://api.votre-domaine.com/api';
  
  // ...
}
```

### 2. Tester la connexion

Créez un simple test de connexion :

```dart
// Dans un widget de test
final meetingService = ref.watch(meetingApiServiceProvider);

try {
  final response = await meetingService.getAllMeetings();
  print('Connexion réussie: ${response.data}');
} catch (e) {
  print('Erreur de connexion: $e');
}
```

---

## Utilisation des services

### Service Meeting

Le service `MeetingApiService` expose les méthodes suivantes :

```dart
// Créer une réunion
Future<Response> createMeeting(Map<String, dynamic> meetingData)

// Lister toutes les réunions
Future<Response> getAllMeetings()

// Obtenir une réunion par ID
Future<Response> getMeetingById(String meetingId)

// Lister les participants
Future<Response> getMeetingParticipants(String meetingId)

// Ajouter un participant
Future<Response> addParticipant(String meetingId, Map<String, dynamic> participantData)

// Retirer un participant
Future<Response> removeParticipant(String meetingId, String participantId)

// Rechercher par titre
Future<Response> searchMeetingByTitle(String title)
```

### Service Transcription

Le service `TranscriptionApiService` expose les méthodes suivantes :

```dart
// Transcrire un audio
Future<Response> transcribeAudio(FormData audioData)

// Obtenir tous les segments
Future<Response> getAllSegments(String reunionId)

// Obtenir un segment spécifique
Future<Response> getSegmentById(String reunionId, String segmentId)

// Modifier le texte d'un segment
Future<Response> updateSegmentText(String reunionId, String segmentId, Map<String, dynamic> textData)

// Lister les locuteurs d'un segment
Future<Response> getSegmentSpeakers(String reunionId, String segmentId)

// Modifier le locuteur d'un segment
Future<Response> updateSegmentSpeaker(String reunionId, String segmentId, String participantId)

// Récupérer le fichier audio
Future<Response> getRecordFile(String reunionId)

// Obtenir l'heure de début d'un segment
Future<Response> getSegmentStartTime(String reunionId, String segmentId)

// Obtenir l'heure de fin d'un segment
Future<Response> getSegmentEndTime(String reunionId, String segmentId)
```

---

## Exemples d'intégration

### Exemple 1 : Créer un repository pour Meeting

Créez un repository qui utilise le service API :

```dart
// lib/src/features/meeting/data/repositories/meeting_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/api/api_services.dart';
import '../models/meeting_model.dart';

part 'meeting_repository.g.dart';

@riverpod
MeetingRepository meetingRepository(MeetingRepositoryRef ref) {
  return MeetingRepository(ref.watch(meetingApiServiceProvider));
}

class MeetingRepository {
  final MeetingApiService _apiService;

  MeetingRepository(this._apiService);

  Future<List<Meeting>> getAllMeetings() async {
    try {
      final response = await _apiService.getAllMeetings();
      final List<dynamic> data = response.data;
      return data.map((json) => Meeting.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réunions: $e');
    }
  }

  Future<Meeting> createMeeting(Meeting meeting) async {
    try {
      final response = await _apiService.createMeeting(meeting.toJson());
      return Meeting.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la création de la réunion: $e');
    }
  }

  Future<Meeting> getMeetingById(String id) async {
    try {
      final response = await _apiService.getMeetingById(id);
      return Meeting.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la réunion: $e');
    }
  }
}
```

### Exemple 2 : Créer un provider pour lister les réunions

```dart
// lib/src/features/meeting/presentation/providers/meetings_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/meeting_repository.dart';
import '../../data/models/meeting_model.dart';

part 'meetings_provider.g.dart';

@riverpod
Future<List<Meeting>> meetings(MeetingsRef ref) async {
  final repository = ref.watch(meetingRepositoryProvider);
  return await repository.getAllMeetings();
}
```

### Exemple 3 : Utiliser dans un widget

```dart
// lib/src/features/meeting/presentation/screens/meetings_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/meetings_provider.dart';

class MeetingsListScreen extends ConsumerWidget {
  const MeetingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Réunions')),
      body: meetingsAsync.when(
        data: (meetings) => ListView.builder(
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            final meeting = meetings[index];
            return ListTile(
              title: Text(meeting.title),
              subtitle: Text(meeting.description ?? ''),
              onTap: () {
                // Navigation vers les détails
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }
}
```

### Exemple 4 : Upload audio pour transcription

```dart
// lib/src/features/transcription/data/repositories/transcription_repository.dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/api/api_services.dart';

part 'transcription_repository.g.dart';

@riverpod
TranscriptionRepository transcriptionRepository(TranscriptionRepositoryRef ref) {
  return TranscriptionRepository(ref.watch(transcriptionApiServiceProvider));
}

class TranscriptionRepository {
  final TranscriptionApiService _apiService;

  TranscriptionRepository(this._apiService);

  Future<Map<String, dynamic>> transcribeAudio(String audioPath, String meetingId) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioPath,
          filename: audioPath.split('/').last,
        ),
        'meetingId': meetingId,
      });

      final response = await _apiService.transcribeAudio(formData);
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de la transcription: $e');
    }
  }

  Future<List<dynamic>> getSegments(String meetingId) async {
    try {
      final response = await _apiService.getAllSegments(meetingId);
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des segments: $e');
    }
  }
}
```

---

## Gestion des états

### Utiliser AsyncValue pour gérer les états de chargement

```dart
@riverpod
class MeetingsNotifier extends _$MeetingsNotifier {
  @override
  Future<List<Meeting>> build() async {
    final repository = ref.watch(meetingRepositoryProvider);
    return await repository.getAllMeetings();
  }

  Future<void> createMeeting(Meeting meeting) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(meetingRepositoryProvider);
      await repository.createMeeting(meeting);
      return await repository.getAllMeetings();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(meetingRepositoryProvider);
      return await repository.getAllMeetings();
    });
  }
}
```

---

## Bonnes pratiques

### 1. Séparer les responsabilités

- **Services API** : Appels HTTP bruts
- **Repositories** : Logique métier et transformation des données
- **Providers** : Gestion d'état et cache
- **Widgets** : Affichage uniquement

### 2. Gestion des erreurs

Toujours entourer les appels API de try-catch :

```dart
try {
  final result = await apiService.getSomething();
  return result;
} on DioException catch (e) {
  if (e.response?.statusCode == 404) {
    throw NotFoundException('Ressource non trouvée');
  } else if (e.type == DioExceptionType.connectionTimeout) {
    throw TimeoutException('Délai d\'attente dépassé');
  }
  throw ApiException('Erreur API: ${e.message}');
} catch (e) {
  throw UnknownException('Erreur inconnue: $e');
}
```

### 3. Utiliser des modèles typés

Ne pas utiliser `Map<String, dynamic>` directement, créer des modèles :

```dart
// ❌ Mauvais
Future<Map<String, dynamic>> getMeeting(String id);

// ✅ Bon
Future<Meeting> getMeeting(String id);
```

### 4. Implémenter le cache

Utiliser Riverpod pour mettre en cache les données :

```dart
@Riverpod(keepAlive: true) // Cache persistant
Future<List<Meeting>> meetings(MeetingsRef ref) async {
  // Les données seront mises en cache automatiquement
  final repository = ref.watch(meetingRepositoryProvider);
  return await repository.getAllMeetings();
}
```

### 5. Tester les services

Créer des tests unitaires avec des mocks :

```dart
void main() {
  test('getAllMeetings returns list of meetings', () async {
    // Arrange
    final mockDio = MockDio();
    final service = MeetingApiService(mockDio);
    
    when(mockDio.get('/meeting/all')).thenAnswer(
      (_) async => Response(
        data: [{'id': '1', 'title': 'Test'}],
        statusCode: 200,
        requestOptions: RequestOptions(path: '/meeting/all'),
      ),
    );

    // Act
    final response = await service.getAllMeetings();

    // Assert
    expect(response.statusCode, 200);
    expect(response.data, isA<List>());
  });
}
```

---

## Prochaines étapes

1. **Configurer l'URL du backend** dans `api_config.dart`
2. **Créer les repositories** pour chaque feature
3. **Créer les providers** pour gérer l'état
4. **Intégrer dans les widgets** existants
5. **Tester** avec le backend réel
6. **Implémenter l'authentification** si nécessaire
7. **Ajouter la gestion des erreurs** personnalisée
8. **Créer les tests unitaires** et d'intégration

---

## Support

Pour plus d'informations :
- Consultez `API_SPECIFICATION.md` pour la documentation complète des endpoints
- Consultez `lib/src/core/api/README.md` pour les détails techniques
- Consultez la documentation Dio : https://pub.dev/packages/dio
- Consultez la documentation Riverpod : https://riverpod.dev
