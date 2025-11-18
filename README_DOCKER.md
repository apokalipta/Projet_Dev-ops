# 🐳 Guide de démarrage rapide - Docker

## Configuration en 3 étapes

### 1️⃣ Configuration du chemin IA

**Option A - Script automatique (recommandé) :**
```bash
./setup-docker.sh
```

**Option B - Manuel :**
```bash
cp env.example .env
# Puis éditez .env et ajustez AI_SERVICE_PATH
```

### 2️⃣ Démarrer les services

```bash
docker-compose up -d
```

### 3️⃣ Vérifier que tout fonctionne

- **Transcription-service** : http://localhost:8082/openapi
- **AI Service** : http://localhost:8000/docs
- **MySQL** : localhost:3306

## 📝 Notes importantes

- Le fichier `.env` est ignoré par Git (chemins spécifiques à chaque machine)
- Le chemin `AI_SERVICE_PATH` doit être **relatif** au répertoire du `docker-compose.yml`
- Tous les services redémarrent automatiquement en cas d'erreur

## 🔧 Commandes utiles

```bash
# Voir les logs
docker-compose logs -f

# Arrêter les services
docker-compose down

# Reconstruire les images
docker-compose build --no-cache
```

Pour plus de détails, consultez [DOCKER_SETUP.md](DOCKER_SETUP.md).

