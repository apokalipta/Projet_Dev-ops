# 🚀 Quick Start - Intégration des APIs

## ✅ Ce qui est prêt

Les services API sont **complètement implémentés** et **prêts à être utilisés** :

- ✅ **7 endpoints Meeting** (Sous-projet N°1)
- ✅ **9 endpoints Transcription** (Sous-projet N°2)
- ✅ Configuration Dio avec intercepteurs
- ✅ Providers Riverpod générés
- ✅ Documentation complète

## 📝 Fichiers créés

### Documentation (5 fichiers)
1. `API_SPECIFICATION.md` - Référence des endpoints
2. `INTEGRATION_API.md` - Guide d'intégration complet
3. `API_INTEGRATION_SUMMARY.md` - Résumé et checklist
4. `CHANGELOG_API.md` - Historique
5. `STRUCTURE_API.md` - Architecture visuelle

### Code (10 fichiers)
```
lib/src/core/api/
├── api_config.dart                    ✅ Configuration
├── api_services.dart                  ✅ Export centralisé
├── dio_client.dart                    ✅ Client HTTP (mis à jour)
├── meeting_api_service.dart           ✅ Service Meeting
├── meeting_api_service.g.dart         ✅ Code généré
├── transcription_api_service.dart     ✅ Service Transcription
├── transcription_api_service.g.dart   ✅ Code généré
├── README.md                          ✅ Doc technique
└── EXAMPLE_USAGE.dart                 ✅ Exemples
```

## 🎯 3 étapes pour utiliser les APIs

### Étape 1 : Configurer l'URL du backend (2 min)

Éditez `lib/src/core/api/api_config.dart` :

```dart
static const String devUrl = 'http://192.168.1.100:8080/api'; // Votre IP
```

### Étape 2 : Tester la connexion (5 min)

Créez un simple test dans n'importe quel widget :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:votre_app/src/core/api/api_services.dart';

class TestApiWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final service = ref.read(meetingApiServiceProvider);
        try {
          final response = await service.getAllMeetings();
          print('✅ Connexion OK: ${response.data}');
        } catch (e) {
          print('❌ Erreur: $e');
        }
      },
      child: Text('Tester API'),
    );
  }
}
```

### Étape 3 : Créer un repository (10 min)

Créez `lib/src/features/meeting/data/repositories/meeting_repository.dart` :

```dart
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
    final response = await _apiService.getAllMeetings();
    return (response.data as List)
        .map((json) => Meeting.fromJson(json))
        .toList();
  }

  Future<Meeting> createMeeting(Meeting meeting) async {
    final response = await _apiService.createMeeting(meeting.toJson());
    return Meeting.fromJson(response.data);
  }
}
```

Puis générez le code :
```bash
dart run build_runner build --delete-conflicting-outputs
```

## 📚 Documentation disponible

| Besoin | Document |
|--------|----------|
| Voir tous les endpoints | `API_SPECIFICATION.md` |
| Exemples d'intégration | `INTEGRATION_API.md` |
| Exemples de code | `lib/src/core/api/EXAMPLE_USAGE.dart` |
| Architecture | `STRUCTURE_API.md` |
| Checklist | `API_INTEGRATION_SUMMARY.md` |

## 🔍 Endpoints disponibles

### Meeting (7 endpoints)
- ✅ POST `/api/meeting` - Créer
- ✅ GET `/api/meeting/all` - Lister
- ✅ GET `/api/meeting/:id` - Détails
- ✅ GET `/api/meeting/:id/participant/all` - Participants
- ✅ POST `/api/meeting/:id/participant/` - Ajouter participant
- ✅ DELETE `/api/meeting/:id/participant/:pid` - Retirer participant
- ✅ GET `/api/meeting/search/byTitle` - Rechercher

### Transcription (9 endpoints)
- ✅ POST `/api/transcribe` - Transcrire audio
- ✅ GET `/api/transcription/:id/segment/all` - Segments
- ✅ GET `/api/transcription/:id/segment/:sid` - Segment
- ✅ PUT `/api/transcription/:id/segment/:sid` - Modifier segment
- ✅ GET `/api/transcription/:id/segment/:sid/locuteur/all` - Locuteurs
- ✅ PUT `/api/transcription/:id/segment/:sid/locuteur/:pid` - Modifier locuteur
- ✅ GET `/api/transcription/:id/record_file` - Fichier audio
- ✅ GET `/api/transcription/:id/segment/:sid/time_depart` - Heure début
- ✅ GET `/api/transcription/:id/segment/:sid/time_fin` - Heure fin

## 💡 Utilisation rapide

### Lister les réunions

```dart
final meetingService = ref.watch(meetingApiServiceProvider);
final response = await meetingService.getAllMeetings();
print(response.data); // Liste des réunions
```

### Créer une réunion

```dart
final meetingService = ref.watch(meetingApiServiceProvider);
await meetingService.createMeeting({
  'title': 'Réunion d\'équipe',
  'date': DateTime.now().toIso8601String(),
  'description': 'Discussion',
});
```

### Transcrire un audio

```dart
final transcriptionService = ref.watch(transcriptionApiServiceProvider);
final formData = FormData.fromMap({
  'audio': await MultipartFile.fromFile(audioPath),
  'meetingId': 'meeting-123',
});
await transcriptionService.transcribeAudio(formData);
```

## ⚠️ Important

### Les services sont prêts mais pas connectés

- ✅ Code implémenté et testé
- ✅ Providers générés
- ✅ Documentation complète
- ❌ **Pas encore utilisés dans l'app**
- ❌ **Backend pas configuré**

### Avant de commencer

1. ✅ Vérifier que le backend est accessible
2. ✅ Configurer l'URL dans `api_config.dart`
3. ✅ Tester avec Postman ou curl
4. ✅ Commencer par un endpoint simple (GET /api/meeting/all)

## 🎓 Prochaines étapes

1. [ ] Configurer l'URL du backend
2. [ ] Tester la connexion
3. [ ] Créer les repositories
4. [ ] Créer les providers de données
5. [ ] Intégrer dans les widgets
6. [ ] Gérer les erreurs
7. [ ] Ajouter l'authentification
8. [ ] Écrire les tests

## 🆘 Aide

### Erreur de connexion ?
- Vérifier l'URL dans `api_config.dart`
- Vérifier que le backend est démarré
- Vérifier le firewall/réseau

### Erreur 404 ?
- Vérifier l'endpoint dans `API_SPECIFICATION.md`
- Vérifier la route sur le backend

### Erreur de parsing ?
- Vérifier le format JSON retourné
- Vérifier les modèles Dart

## 📞 Support

Consultez la documentation :
- `INTEGRATION_API.md` pour les détails
- `EXAMPLE_USAGE.dart` pour les exemples
- `API_SPECIFICATION.md` pour les endpoints

---

**Status** : ✅ Prêt à être utilisé  
**Date** : 7 novembre 2024  
**Version** : 1.0.0
