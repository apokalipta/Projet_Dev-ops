# Services API

Ce dossier contient les services d'appel API pour communiquer avec le backend.

## Structure

```
api/
├── api_config.dart              # Configuration des URLs et timeouts
├── api_services.dart            # Export centralisé de tous les services
├── dio_client.dart              # Client HTTP Dio configuré avec intercepteurs
├── meeting_api_service.dart     # Service pour les endpoints Meeting
└── transcription_api_service.dart # Service pour les endpoints Transcription
```

## Configuration

### URL de base

L'URL de base de l'API est configurée dans `api_config.dart`. Par défaut, elle pointe vers `http://localhost:8080/api`.

Pour changer l'environnement, modifiez la variable d'environnement `ENV` :

```bash
# Développement (par défaut)
flutter run

# Staging
flutter run --dart-define=ENV=staging

# Production
flutter run --dart-define=ENV=prod
```

### Timeouts

Les timeouts sont configurés dans `api_config.dart` :
- **Connect timeout** : 5 secondes
- **Receive timeout** : 3 secondes
- **Send timeout** : 10 secondes

## Utilisation

### 1. Importer les services

```dart
import 'package:votre_app/src/core/api/api_services.dart';
```

### 2. Utiliser avec Riverpod

Les services sont exposés via des providers Riverpod :

```dart
// Dans un ConsumerWidget ou ConsumerStatefulWidget
@override
Widget build(BuildContext context, WidgetRef ref) {
  final meetingService = ref.watch(meetingApiServiceProvider);
  
  // Utiliser le service
  // ...
}
```

### 3. Exemples d'appels

#### Meeting Service

```dart
// Créer une réunion
final response = await meetingService.createMeeting({
  'title': 'Réunion d\'équipe',
  'date': '2024-11-07T14:00:00Z',
  'description': 'Discussion sur le projet',
});

// Lister toutes les réunions
final meetings = await meetingService.getAllMeetings();

// Obtenir une réunion spécifique
final meeting = await meetingService.getMeetingById('meeting-id-123');

// Ajouter un participant
await meetingService.addParticipant('meeting-id-123', {
  'name': 'John Doe',
  'email': 'john@example.com',
});

// Rechercher par titre
final results = await meetingService.searchMeetingByTitle('équipe');
```

#### Transcription Service

```dart
// Transcrire un audio
final formData = FormData.fromMap({
  'audio': await MultipartFile.fromFile(
    audioPath,
    filename: 'recording.mp3',
  ),
  'meetingId': 'meeting-id-123',
});
final transcription = await transcriptionService.transcribeAudio(formData);

// Obtenir tous les segments
final segments = await transcriptionService.getAllSegments('meeting-id-123');

// Modifier un segment
await transcriptionService.updateSegmentText(
  'meeting-id-123',
  'segment-id-456',
  {'text': 'Nouveau texte corrigé'},
);

// Récupérer le fichier audio
final audioFile = await transcriptionService.getRecordFile('meeting-id-123');
```

## Gestion des erreurs

Le client Dio est configuré avec des intercepteurs pour gérer automatiquement :

- **401 Unauthorized** : Déconnexion automatique et redirection vers /login
- **500 Internal Server Error** : Affichage d'une notification d'erreur

Pour gérer les erreurs dans votre code :

```dart
try {
  final response = await meetingService.getAllMeetings();
  // Traiter la réponse
} on DioException catch (e) {
  if (e.response?.statusCode == 404) {
    // Ressource non trouvée
  } else if (e.type == DioExceptionType.connectionTimeout) {
    // Timeout de connexion
  } else {
    // Autre erreur
  }
}
```

## Authentification

L'authentification est gérée automatiquement par l'intercepteur dans `dio_client.dart`.

Pour implémenter l'authentification :

1. Créer un provider pour le stockage sécurisé (ex: `flutter_secure_storage`)
2. Stocker le token après connexion
3. Décommenter et adapter le code dans l'intercepteur `onRequest`

```dart
// Dans dio_client.dart
onRequest: (options, handler) async {
  final token = await ref.read(secureStorageProvider).read(key: 'auth_token');
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  return handler.next(options);
},
```

## Génération du code

Les services utilisent `riverpod_annotation` pour générer automatiquement les providers.

Après modification des fichiers, exécutez :

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Tests

Pour tester les services API, créez des tests unitaires avec des mocks :

```dart
// test/services/meeting_api_service_test.dart
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

void main() {
  late MockDio mockDio;
  late MeetingApiService service;

  setUp(() {
    mockDio = MockDio();
    service = MeetingApiService(mockDio);
  });

  test('getAllMeetings returns list of meetings', () async {
    // Arrange
    when(mockDio.get('/meeting/all'))
        .thenAnswer((_) async => Response(
              data: [/* mock data */],
              statusCode: 200,
              requestOptions: RequestOptions(path: '/meeting/all'),
            ));

    // Act
    final response = await service.getAllMeetings();

    // Assert
    expect(response.statusCode, 200);
    verify(mockDio.get('/meeting/all')).called(1);
  });
}
```

## Référence API complète

Consultez le fichier `API_SPECIFICATION.md` à la racine du projet pour la documentation complète des endpoints disponibles.
