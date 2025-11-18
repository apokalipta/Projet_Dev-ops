# Guide d'intégration des APIs Meeting-service

## 📋 Vue d'ensemble

Ce document explique comment utiliser les APIs du backend Meeting-service dans l'application Flutter.

## 🔗 Configuration

### URL de base

L'URL de base est configurée dans `lib/src/core/api/api_config.dart` :

```dart
static const String baseUrl = 'http://localhost:8080/api';
```

Pour Android Emulator, utilisez `http://10.0.2.2:8080/api` au lieu de `localhost`.

### Environnements

- **Dev** : `http://localhost:8080/api`
- **Staging** : À configurer
- **Production** : À configurer

## 📡 APIs disponibles

### Réunions

#### 1. Lister toutes les réunions
```dart
GET /api/meeting/all
```

**Utilisation** :
```dart
final dataSource = ref.read(meetingRemoteDataSourceProvider);
final meetings = await dataSource.fetchMeetings();
```

**Réponse** : Liste de `MeetingModel`

---

#### 2. Détail d'une réunion
```dart
GET /api/meeting/{id}
```

**Utilisation** :
```dart
final meeting = await dataSource.getMeetingById(1);
```

**Réponse** : `MeetingModel`

---

#### 3. Créer une réunion
```dart
POST /api/meeting
```

**Body** :
```json
{
  "title": "Sprint Planning",
  "description": "Planification du sprint",
  "scheduledAt": "2025-11-08T10:00:00",
  "durationMinutes": 45,
  "status": "scheduled",
  "participants": [
    {
      "fullName": "Alice Durand",
      "email": "alice@example.com"
    }
  ]
}
```

**Utilisation** :
```dart
final meetingData = {
  'title': 'Sprint Planning',
  'description': 'Planification du sprint',
  'scheduledAt': '2025-11-08T10:00:00',
  'durationMinutes': 45,
  'status': 'scheduled',
  'participants': [
    {
      'fullName': 'Alice Durand',
      'email': 'alice@example.com'
    }
  ]
};

final meeting = await dataSource.createMeeting(meetingData);
```

**Réponse** : `MeetingModel` créé

---

#### 4. Rechercher par titre
```dart
GET /api/meeting/search/byTitle?title=planning
```

**Utilisation** :
```dart
final meetings = await dataSource.searchMeetingsByTitle('planning');
```

**Réponse** : Liste de `MeetingModel`

---

#### 5. Démarrer une réunion
```dart
PUT /api/meeting/{id}/start
```

**Utilisation** :
```dart
final meeting = await dataSource.startMeeting(1);
```

**Effet** : Transition `scheduled` → `in_progress`

**Réponse** : `MeetingModel` mis à jour

---

#### 6. Terminer une réunion
```dart
PUT /api/meeting/{id}/end
```

**Utilisation** :
```dart
final meeting = await dataSource.endMeeting(1);
```

**Effet** : Transition `in_progress` → `completed`

**Réponse** : `MeetingModel` mis à jour

---

### Participants

#### 7. Lister les participants d'une réunion
```dart
GET /api/meeting/{id}/participant/all
```

**Utilisation** :
```dart
final participants = await dataSource.getMeetingParticipants(1);
```

**Réponse** : Liste de participants

---

#### 8. Lister tous les participants
```dart
GET /api/participant/all
```

**Utilisation** :
```dart
final allParticipants = await dataSource.getAllParticipants();
```

**Réponse** : Liste de tous les participants enregistrés

---

#### 9. Ajouter un participant
```dart
POST /api/meeting/{id}/participant
```

**Body (nouveau participant)** :
```json
{
  "firstname": "Bob",
  "lastname": "Martin",
  "email": "bob@example.com"
}
```

**Body (participant existant)** :
```json
{
  "id": 2
}
```

**Utilisation** :
```dart
// Nouveau participant
final participantData = {
  'firstname': 'Bob',
  'lastname': 'Martin',
  'email': 'bob@example.com'
};

final participant = await dataSource.addParticipant(1, participantData);
```

**Erreur** : HTTP 409 si la réunion est `completed`

---

#### 10. Retirer un participant
```dart
DELETE /api/meeting/{id}/participant/{participantId}
```

**Utilisation** :
```dart
await dataSource.removeParticipant(1, 2);
```

**Erreur** : HTTP 409 si la réunion est `completed`

---

## 🔄 Gestion des erreurs

### Codes HTTP

- **200** : Succès
- **201** : Créé
- **400** : Requête invalide
- **404** : Ressource non trouvée
- **409** : Conflit (ex: modification d'une réunion terminée)
- **500** : Erreur serveur

### Exemple de gestion d'erreur

```dart
try {
  final meeting = await dataSource.getMeetingById(1);
} on DioException catch (e) {
  if (e.response?.statusCode == 404) {
    // Réunion non trouvée
    print('Réunion non trouvée');
  } else if (e.response?.statusCode == 409) {
    // Conflit (réunion terminée)
    print('Impossible de modifier une réunion terminée');
  } else {
    // Autre erreur
    print('Erreur: ${e.message}');
  }
}
```

---

## 📝 Notes importantes

### Statuts des réunions

- `scheduled` (Planifiée)
- `in_progress` (En cours)
- `completed` (Terminée)

### Langues supportées

- `fr` (Français)
- `en` (Anglais)
- `es` (Espagnol)
- `de` (Allemand)
- `it` (Italien)
- `pt` (Portugais)
- `ar` (Arabe)

### Restrictions

- ❌ **Impossible d'ajouter/retirer des participants** si la réunion est `completed`
- ✅ **Transitions de statut** : `scheduled` → `in_progress` → `completed`

---

## 🚀 Prochaines étapes

1. **Tester les APIs** avec le backend en local
2. **Adapter les providers** pour utiliser les vraies APIs au lieu des mocks
3. **Gérer les états de chargement** et les erreurs dans l'UI
4. **Implémenter la synchronisation** des données

---

## 🔧 Configuration Android Emulator

Pour accéder au backend depuis l'émulateur Android :

```dart
// Dans api_config.dart
static const String devUrl = 'http://10.0.2.2:8080/api';
```

`10.0.2.2` est l'alias pour `localhost` de la machine hôte depuis l'émulateur.

---

## 📚 Ressources

- [Documentation Dio](https://pub.dev/packages/dio)
- [Documentation Riverpod](https://riverpod.dev/)
- [Backend Meeting-service](../Meeting-service/README.md)
