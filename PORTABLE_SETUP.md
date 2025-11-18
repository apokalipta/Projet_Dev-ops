# 📦 Guide pour créer une version portable du projet

## 🎯 Objectif

Créer un fichier zip contenant **transcription-service** et **ai-service** pour pouvoir faire `docker-compose up` sur n'importe quel PC sans configuration supplémentaire.

## ✅ Solution

Le projet est maintenant configuré pour être **100% portable** ! Le dossier IA sera copié dans le projet principal.

## 🚀 Étapes pour créer la version portable

### Option 1 : Script automatique (recommandé)

```bash
# 1. Préparer le projet (copie le dossier IA dans le projet)
./prepare-portable.sh

# 2. Vérifier que tout est en place
ls -la ai-service/

# 3. Créer le zip
zip -r transcription-service-portable.zip . \
  -x '*.git*' \
  -x '*/build/*' \
  -x '*/bin/*' \
  -x '*/__pycache__/*' \
  -x '*/Reunions/*' \
  -x '*.class' \
  -x '.env'
```

### Option 2 : Manuel

1. **Copier le dossier IA dans le projet** :
   ```bash
   mkdir -p ai-service
   cp "/Users/falla/Documents/ISEN/2025-2026/Projet DevOps/Transcription_AI/IA/"*.py ai-service/
   cp "/Users/falla/Documents/ISEN/2025-2026/Projet DevOps/Transcription_AI/IA/"requirements.txt ai-service/
   cp "/Users/falla/Documents/ISEN/2025-2026/Projet DevOps/Transcription_AI/IA/"Dockerfile ai-service/
   ```

2. **Créer le fichier .env** :
   ```bash
   echo "AI_SERVICE_PATH=./ai-service" > .env
   ```

3. **Créer le zip** :
   ```bash
   zip -r transcription-service-portable.zip . \
     -x '*.git*' '*/build/*' '*/bin/*' '*/__pycache__/*' '*/Reunions/*'
   ```

## 📋 Structure du projet portable

```
Projet_Dev-ops/
├── Transcription-service/     # Service Quarkus
├── ai-service/                 # Service IA (copié)
│   ├── AI_API.py
│   ├── Transcription_AI.py
│   ├── requirements.txt
│   └── Dockerfile
├── docker-compose.yml          # Configuration Docker
├── .env                        # Configuration (AI_SERVICE_PATH=./ai-service)
└── ...
```

## 🎁 Utilisation sur un autre PC

1. **Extraire le zip** :
   ```bash
   unzip transcription-service-portable.zip
   cd Projet_Dev-ops
   ```

2. **Vérifier la configuration** :
   ```bash
   cat .env
   # Doit contenir: AI_SERVICE_PATH=./ai-service
   ```

3. **Lancer Docker Compose** :
   ```bash
   docker-compose up -d
   ```

4. **Vérifier que tout fonctionne** :
   ```bash
   docker-compose ps
   docker-compose logs -f
   ```

## ✅ Avantages de cette approche

- ✅ **Aucune configuration nécessaire** : Le fichier `.env` est déjà configuré
- ✅ **Chemin relatif** : Fonctionne sur n'importe quel PC
- ✅ **Tout inclus** : Transcription-service + IA dans un seul zip
- ✅ **Prêt à l'emploi** : `docker-compose up` et c'est parti !

## 📝 Fichiers à exclure du zip

Pour réduire la taille du zip, excluez :
- `.git/` (si versionné)
- `build/` (fichiers compilés)
- `bin/` (fichiers compilés)
- `__pycache__/` (cache Python)
- `Reunions/` (données, seront dans un volume Docker)
- `.env` (peut être recréé si nécessaire)

## 🔧 Vérification avant création du zip

```bash
# Vérifier que le dossier IA est présent
ls -la ai-service/

# Vérifier que le .env est correct
cat .env

# Tester la configuration docker-compose
docker-compose config
```

## ⚠️ Notes importantes

1. **Taille du zip** : Le zip peut être volumineux à cause de `requirements.txt` (dépendances Python lourdes). Les dépendances seront installées lors du build Docker.

2. **Premier build** : Le premier `docker-compose build` peut prendre 10-20 minutes car il doit :
   - Télécharger les images de base
   - Installer toutes les dépendances Python
   - Compiler l'application Quarkus

3. **Volumes Docker** : Les données (Reunions, base de données) seront stockées dans des volumes Docker, pas dans le zip.

4. **.env** : Le fichier `.env` est dans `.gitignore` mais peut être inclus dans le zip pour faciliter le déploiement.

## 🎉 Résultat

Une fois le zip créé, vous pouvez :
- Le partager avec n'importe qui
- L'extraire sur n'importe quel PC
- Faire `docker-compose up` sans aucune configuration supplémentaire !

