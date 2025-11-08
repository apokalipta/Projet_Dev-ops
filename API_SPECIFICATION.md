# Spécification des APIs

Ce document définit les endpoints API pour le projet de gestion de réunions et transcriptions.

## Sous-projet N°1 : Meeting (Table meeting + participant)

### Endpoints Meeting

| Méthode | Endpoint | Description | Réponse |
|---------|----------|-------------|---------|
| POST | `/api/meeting` | Créer une nouvelle réunion | 201 + Meeting |
| GET | `/api/meeting/all` | Lister toutes les réunions | 200 + List |
| GET | `/api/meeting/:Id_meeting` | Obtenir les détails d'une réunion spécifique | 200 + Meeting |
| GET | `/api/meeting/:Id_meeting/participant/all` | Lister les participants d'une réunion | 200 + Meeting |
| DELETE | `/api/meeting/:Id_meeting/participant/:Id_participant` | Retirer un participant d'une réunion | 204 + No Content |
| POST | `/api/meeting/:Id_meeting/participant/` | Ajouter un participant à une réunion | 201 + Participants |
| GET | `/api/meeting/search/byTitle` | Recherche par titre | 200 + Meeting |

---

## Sous-projet N°2 : Transcription (Table transcription + locuteur + segment)

### Endpoints Transcription

| Méthode | Endpoint | Description | Réponse |
|---------|----------|-------------|---------|
| POST | `/api/transcribe` | Envoyer l'audio à l'IA pour la transcription | 201 + Transcribe |
| GET | `/api/transcription/:Id_reunion/segment/all` | Lister les segments de la transcription pour reconstruire la synthèse | 200 + All segments |
| GET | `/api/transcription/:Id_reunion/segment/:Id_segment` | Obtenir un segment spécifique | 200 + Segment |
| PUT | `/api/transcription/:Id_reunion/segment/:Id_segment` | Modifier le texte d'un segment spécifique | 202 + Modif texte |
| GET | `/api/transcription/:Id_reunion/segment/:Id_segment/locuteur/all` | Lister les locuteurs d'un segment | 200 + Locuteurs |
| PUT | `/api/transcription/:Id_reunion/segment/:Id_segment/locuteur/:Id_participant` | Modifier le locuteur d'un segment défini par défaut par l'IA | 202 + Modif locuteur |
| GET | `/api/transcription/:Id_reunion/record_file` | Récupérer pour écouter l'audio de la réunion | 200 + Record file |
| GET | `/api/transcription/:Id_reunion/segment/:Id_segment/time_depart` | Obtenir date démarrage d'enregistrement du segment pour trouver l'audio correspondant | 200 + Temps départ segment |
| GET | `/api/transcription/:Id_reunion/segment/:Id_segment/time_fin` | Obtenir date de fin d'enregistrement du segment pour trouver l'audio correspondant | 200 + Temps fin segment |

---

## Sous-projet N°3 : Web-UI

*À définir*

---

## Sous-projet N°4 : App-UI

*À définir*

---

## Notes d'implémentation

### Structure des données

Les modèles de données correspondants sont définis dans :
- `lib/models/meeting.dart` - Modèle Meeting
- `lib/models/participant.dart` - Modèle Participant
- `lib/models/transcription.dart` - Modèle Transcription
- `lib/models/segment.dart` - Modèle Segment
- `lib/models/speaker.dart` - Modèle Speaker/Locuteur

### Services API

Les services d'appel API seront implémentés dans :
- `lib/services/meeting_service.dart` - Service pour les endpoints Meeting
- `lib/services/transcription_service.dart` - Service pour les endpoints Transcription

### Configuration

L'URL de base de l'API doit être configurée dans :
- `lib/config/api_config.dart` ou équivalent
- Variables d'environnement pour différents environnements (dev, staging, prod)

### Authentification

Si nécessaire, implémenter :
- Headers d'authentification (Bearer token, API key, etc.)
- Gestion du refresh token
- Intercepteurs HTTP pour ajouter automatiquement les tokens

### Gestion des erreurs

Prévoir la gestion des codes d'erreur HTTP :
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found
- 500 Internal Server Error
- Timeout et erreurs réseau
