# 📋 Configuration des Endpoints API

## 🚀 Endpoint de Création de Réunion

### **POST /api/meetings/create**

**Description :** Créer une nouvelle réunion avec les paramètres configurés

**URL :** `POST /api/meetings/create`

**Headers :**
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {token}"
}
```

**Body Request :**
```json
{
  "name": "string",                    // Nom de la réunion (requis)
  "date": "2024-01-15T14:30:00Z",     // Date et heure ISO (requis)
  "participants": 5,                   // Nombre de participants (requis)
  "duration": 60,                      // Durée en minutes (requis)
  "description": "string",            // Description (optionnel)
  "selectedMicrophone": "device-id",  // ID du microphone sélectionné
  "autoStart": true,                  // Démarrer automatiquement (booléen)
  "sendReminders": false              // Envoyer des rappels (booléen)
}
```

**Response Success (201) :**
```json
{
  "success": true,
  "message": "Réunion créée avec succès",
  "data": {
    "meetingId": "uuid-string",
    "meetingName": "string",
    "status": "created",
    "createdAt": "2024-01-15T14:30:00Z",
    "participants": {
      "total": 5,
      "assigned": 0,
      "pending": 5
    }
  }
}
```

**Response Error (400) :**
```json
{
  "success": false,
  "message": "Données de réunion invalides",
  "errors": {
    "name": "Le nom de la réunion est requis",
    "date": "La date doit être dans le futur"
  }
}
```

**Response Error (401) :**
```json
{
  "success": false,
  "message": "Token d'authentification invalide"
}
```

**Response Error (500) :**
```json
{
  "success": false,
  "message": "Erreur interne du serveur"
}
```

---

## 🔧 Configuration Requise

### **Variables d'Environnement :**
```env
API_BASE_URL=http://localhost:8000/api
AUTH_TOKEN=your-jwt-token-here
```

### **Middleware Requis :**
- ✅ **Authentification JWT** : Vérification du token Bearer
- ✅ **Validation des données** : Validation des champs requis
- ✅ **CORS** : Configuration pour les requêtes cross-origin
- ✅ **Rate Limiting** : Limitation des requêtes par utilisateur

### **Base de Données :**
- **Table `meetings`** : Stockage des réunions créées
- **Table `participants`** : Gestion des participants assignés
- **Table `meeting_settings`** : Configuration audio et options

---

## 📝 Notes d'Implémentation

### **À Configurer Plus Tard :**
1. **Endpoint Backend** : Implémentation du POST /api/meetings/create
2. **Base de Données** : Création des tables et relations
3. **Authentification** : Système de tokens JWT
4. **Validation** : Règles de validation côté serveur
5. **Notifications** : Système d'envoi de rappels
6. **Audio** : Configuration des périphériques microphone

### **Flux Utilisateur :**
1. **Setup Réunion** → POST /api/meetings/create
2. **Création Réussie** → Redirection vers Assignation Participants
3. **Assignation** → Interface de gestion des participants
4. **Validation** → Confirmation et démarrage de la réunion

---

## 🎯 Prochaines Étapes

- [ ] Implémenter l'endpoint POST /api/meetings/create
- [ ] Créer la base de données et les tables
- [ ] Configurer l'authentification JWT
- [ ] Développer l'interface d'assignation des participants
- [ ] Tester le flux complet de création de réunion
