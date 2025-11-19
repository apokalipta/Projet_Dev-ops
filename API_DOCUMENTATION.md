# 📚 Documentation des API - Transcription Service

## Base URL

```
http://localhost:8082/api
```

## Documentation interactive (Swagger UI)

Accédez à la documentation interactive Swagger UI :
```
http://localhost:8082/openapi
```

---

## 🎯 Vue d'ensemble

Le service de transcription gère :
- **Transcriptions** : Enregistrements de réunions avec leurs métadonnées
- **Segments** : Portions de transcription avec texte, timestamps et locuteur
- **Locuteurs** : Intervenants identifiés dans les transcriptions

---

## 📋 Endpoints disponibles

### 1. Créer une transcription

**POST** `/api/start_transcription/{id_reunion}`

Crée une nouvelle transcription pour une réunion.

**Paramètres :**
- `id_reunion` (path) : ID de la réunion ou transcription (Long)

**Body (JSON) :**
```json
{
  "idFat": 1,
  "recordFileName": "reunion_1.mp3"
}
```

**Réponse :**
- **201 Created** : Transcription créée
```json
{
  "id": 1,
  "idReunion": 1,
  "recordFileName": "reunion_1.mp3",
  "idFat": 1,
  "createdAt": "2025-01-15T10:00:00",
  "updatedAt": "2025-01-15T10:00:00"
}
```

**Exemple avec curl :**
```bash
curl -X POST http://localhost:8082/api/start_transcription/1 \
  -H "Content-Type: application/json" \
  -d '{}'
```

---

### 2. Envoyer un segment audio pour transcription

**POST** `/api/transcription/{id_reunion}/send_segment`

Envoie un fichier audio au service IA pour transcription. Le service transmet automatiquement le fichier à l'IA qui effectue la transcription et la diarisation.

**Paramètres :**
- `id_reunion` (path) : ID de la réunion (Long)

**Body (multipart/form-data) :**
- `file` : Fichier audio (mp3, wav, etc.)

**Réponse :**
- **202 Accepted** : Segment envoyé pour transcription
```json
"Segment envoyé pour transcription"
```

**Exemple avec curl :**
```bash
curl -X POST http://localhost:8082/api/transcription/1/send_segment \
  -F "file=@audio_segment.mp3"
```

**Note :** Cette API transmet le fichier à l'IA qui :
1. Transcrit l'audio
2. Identifie les locuteurs (diarisation)
3. Envoie les segments transcrits via `/api/transcription/{id_reunion}/segment_to_bdd`

---

### 3. Sauvegarder des segments en base de données

**POST** `/api/transcription/{id_reunion}/segment_to_bdd`

Sauvegarde un ou plusieurs segments de transcription en base de données. Utilisé par l'IA après transcription.

**Paramètres :**
- `id_reunion` (path) : ID de la réunion (Long)

**Body (JSON) :** Segment unique ou tableau de segments
```json
{
  "speaker": "SPEAKER_00",
  "start": 0.0,
  "end": 5.5,
  "text": "Bonjour, je voudrais commencer la réunion."
}
```

Ou tableau :
```json
[
  {
    "speaker": "SPEAKER_00",
    "start": 0.0,
    "end": 5.5,
    "text": "Bonjour, je voudrais commencer la réunion."
  },
  {
    "speaker": "SPEAKER_01",
    "start": 5.5,
    "end": 10.2,
    "text": "D'accord, commençons."
  }
]
```

**Champs :**
- `speaker` : Identifiant du locuteur (ex: "SPEAKER_00", "SPEAKER_01")
- `start` : Timestamp de début en secondes (Double)
- `end` : Timestamp de fin en secondes (Double)
- `text` : Texte transcrit (String)

**Réponse :**
- **202 Accepted** : Segment(s) sauvegardé(s) en base
```json
"Segment(s) sauvegardé(s) en base"
```

**Exemple avec curl :**
```bash
curl -X POST http://localhost:8082/api/transcription/1/segment_to_bdd \
  -H "Content-Type: application/json" \
  -d '{
    "speaker": "SPEAKER_00",
    "start": 0.0,
    "end": 5.5,
    "text": "Bonjour, je voudrais commencer la réunion."
  }'
```

---

### 4. Récupérer tous les segments d'une réunion

**GET** `/api/transcription/{id_reunion}/segment/all`

Récupère tous les segments de transcription pour une réunion donnée.

**Paramètres :**
- `id_reunion` (path) : ID de la réunion ou transcription (Long)

**Réponse :**
- **200 OK** : Liste des segments
```json
[
  {
    "id": 1,
    "transcriptionId": 1,
    "locuteurId": 1,
    "timeDepart": 0.0,
    "timeEnd": 5.5,
    "texte": "Bonjour, je voudrais commencer la réunion."
  },
  {
    "id": 2,
    "transcriptionId": 1,
    "locuteurId": 2,
    "timeDepart": 5.5,
    "timeEnd": 10.2,
    "texte": "D'accord, commençons."
  }
]
```

**Exemple avec curl :**
```bash
curl http://localhost:8082/api/transcription/1/segment/all
```

---

### 5. Récupérer un segment spécifique

**GET** `/api/transcription/{id_reunion}/segment/{id_segment}`

Récupère les détails d'un segment spécifique.

**Paramètres :**
- `id_reunion` (path) : ID de la réunion ou transcription (Long)
- `id_segment` (path) : ID du segment (Long)

**Réponse :**
- **200 OK** : Détails du segment
```json
{
  "id": 1,
  "transcriptionId": 1,
  "locuteurId": 1,
  "timeDepart": 0.0,
  "timeEnd": 5.5,
  "texte": "Bonjour, je voudrais commencer la réunion."
}
```

- **404 Not Found** : Segment introuvable

**Exemple avec curl :**
```bash
curl http://localhost:8082/api/transcription/1/segment/1
```

---

### 6. Modifier le texte d'un segment

**PUT** `/api/transcription/{id_reunion}/segment/{id_segment}`

Met à jour le texte d'un segment.

**Paramètres :**
- `id_reunion` (path) : ID de la réunion ou transcription (Long)
- `id_segment` (path) : ID du segment (Long)

**Body (JSON) :**
```json
{
  "texte": "Texte modifié du segment"
}
```

**Réponse :**
- **200 OK** : Segment mis à jour
```json
{
  "id": 1,
  "transcriptionId": 1,
  "locuteurId": 1,
  "timeDepart": 0.0,
  "timeEnd": 5.5,
  "texte": "Texte modifié du segment"
}
```

- **404 Not Found** : Segment introuvable

**Exemple avec curl :**
```bash
curl -X PUT http://localhost:8082/api/transcription/1/segment/1 \
  -H "Content-Type: application/json" \
  -d '{"texte": "Texte modifié du segment"}'
```

---

### 7. Récupérer le locuteur d'un segment

**GET** `/api/transcription/{id_reunion}/segment/{id_segment}/locuteur/all`

Récupère le nom du locuteur associé à un segment.

**Paramètres :**
- `id_reunion` (path) : ID de la réunion ou transcription (Long)
- `id_segment` (path) : ID du segment (Long)

**Réponse :**
- **200 OK** : Nom du locuteur
```json
"00"
```

- **404 Not Found** : Segment introuvable

**Exemple avec curl :**
```bash
curl http://localhost:8082/api/transcription/1/segment/1/locuteur/all
```

---

### 8. Modifier le locuteur d'un segment

**PUT** `/api/transcription/{id_reunion}/segment/{id_segment}/locuteur/{id_participant}`

Associe un locuteur (participant) à un segment.

**Paramètres :**
- `id_reunion` (path) : ID de la réunion ou transcription (Long)
- `id_segment` (path) : ID du segment (Long)
- `id_participant` (path) : ID du locuteur/participant (Long)

**Réponse :**
- **200 OK** : Segment mis à jour avec le nouveau locuteur
```json
{
  "id": 1,
  "transcriptionId": 1,
  "locuteurId": 2,
  "timeDepart": 0.0,
  "timeEnd": 5.5,
  "texte": "Bonjour, je voudrais commencer la réunion."
}
```

- **404 Not Found** : Segment ou locuteur introuvable

**Exemple avec curl :**
```bash
curl -X PUT http://localhost:8082/api/transcription/1/segment/1/locuteur/2
```

---

### 9. Récupérer le nom du fichier audio d'une réunion

**GET** `/api/transcription/{id_reunion}/obtain_record_file`

Récupère le nom du fichier audio enregistré pour une réunion.

**Paramètres :**
- `id_reunion` (path) : ID de la réunion (Long)

**Réponse :**
- **200 OK** : Nom du fichier
```json
"recording_reunion_1.mp3"
```

- **404 Not Found** : Transcription introuvable

**Exemple avec curl :**
```bash
curl http://localhost:8082/api/transcription/1/obtain_record_file
```

---

### 10. Sauvegarder le fichier audio d'une réunion

**POST** `/api/transcription/{id_reunion}/save_record_file`

Sauvegarde le fichier audio complet d'une réunion. Utilisé par l'IA après fusion de tous les segments audio.

**Paramètres :**
- `id_reunion` (path) : ID de la réunion (Long)

**Body (multipart/form-data) :**
- `file` : Fichier audio complet (mp3, wav, etc.)

**Réponse :**
- **202 Accepted** : Fichier enregistré avec succès
```json
"Fichier enregistré avec succès"
```

- **404 Not Found** : Transcription introuvable
- **400 Bad Request** : Aucun fichier fourni

**Exemple avec curl :**
```bash
curl -X POST http://localhost:8082/api/transcription/1/save_record_file \
  -F "file=@recording_complete.mp3"
```

---

### 11. Récupérer le timestamp de début d'un segment

**GET** `/api/transcription/{id_reunion}/segment/{id_segment}/time_depart`

Récupère le timestamp de début d'un segment.

**Paramètres :**
- `id_reunion` (path) : ID de la réunion ou transcription (Long)
- `id_segment` (path) : ID du segment (Long)

**Réponse :**
- **200 OK** : Timestamp de début
```json
0.0
```

- **404 Not Found** : Segment introuvable

**Exemple avec curl :**
```bash
curl -X GET "http://localhost:8082/api/transcription/1/segment/1/time_depart"
```

---

### 12. Récupérer le timestamp de fin d'un segment

**GET** `/api/transcription/{id_reunion}/segment/{id_segment}/time_fin`

Récupère le timestamp de fin d'un segment.

**Paramètres :**
- `id_reunion` (path) : ID de la réunion ou transcription (Long)
- `id_segment` (path) : ID du segment (Long)

**Réponse :**
- **200 OK** : Timestamp de fin
```json
5.5
```

- **404 Not Found** : Segment introuvable

**Exemple avec curl :**
```bash
curl -X GET "http://localhost:8082/api/transcription/1/segment/1/time_fin"
```

---

## 🔄 Flux de travail typique

### Scénario : Transcription d'une réunion complète

1. **Créer la transcription**
   ```bash
   curl -X POST "/api/start_transcription/1"
   -H ....
   -d
   ```

2. **Envoyer des segments audio** (répété pour chaque segment)
   ```bash
   curl -X POST /api/transcription/1/send_segment
   ```
   - Le service transmet à l'IA
   - L'IA transcrit et envoie les segments via `segment_to_bdd`

3. **L'IA envoie les segments transcrits** (automatique)
   ```bash
   POST /api/transcription/1/segment_to_bdd
   ```

4. **L'IA envoie le fichier audio fusionné** (automatique)
   ```bash
   POST /api/transcription/1/save_record_file
   ```

5. **Récupérer tous les segments**
   ```bash
   GET /api/transcription/1/segment/all
   ```

---

## 📊 Codes de statut HTTP

- **200 OK** : Requête réussie
- **201 Created** : Ressource créée avec succès
- **202 Accepted** : Requête acceptée, traitement en cours
- **400 Bad Request** : Requête invalide
- **404 Not Found** : Ressource introuvable
- **500 Internal Server Error** : Erreur serveur

---

## 🔗 Communication avec l'IA

Le service communique avec le service IA via HTTP :

- **Transcription-service → IA** : Envoi de fichiers audio pour transcription
  - Endpoint IA : `POST /transcribe/?ID_reunion={id_reunion}`

- **IA → Transcription-service** : Envoi des segments transcrits
  - Endpoint : `POST /api/transcription/{id_reunion}/segment_to_bdd`

- **IA → Transcription-service** : Envoi du fichier audio fusionné
  - Endpoint : `POST /api/transcription/{id_reunion}/save_record_file`

---

## 🛠️ Outils de test

### Swagger UI
Accédez à `http://localhost:8082/openapi` pour tester les API directement depuis votre navigateur.

### Postman
Importez les endpoints depuis Swagger ou créez une collection manuellement.

### curl
Tous les exemples ci-dessus utilisent `curl` pour faciliter les tests en ligne de commande.

---

## ⚠️ Notes importantes

1. **Ordre des opérations** : Créez toujours la transcription avant d'envoyer des segments
2. **Format audio** : Les formats MP3, WAV sont supportés
3. **Segments** : Les segments sont automatiquement associés à des locuteurs par l'IA
4. **Timestamps** : Les timestamps sont en secondes (Double)
5. **Locuteurs** : Les locuteurs sont créés automatiquement lors de la sauvegarde des segments

