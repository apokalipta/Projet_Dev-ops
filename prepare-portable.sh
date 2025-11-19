#!/bin/bash

# Script pour préparer le projet en version portable
# Ce script copie le dossier IA dans le projet et configure tout pour être portable

echo "📦 Préparation du projet en version portable..."
echo ""

# Vérifier si le dossier IA source existe
IA_SOURCE="/Users/falla/Documents/ISEN/2025-2026/Projet DevOps/Transcription_AI/IA"
if [ ! -d "$IA_SOURCE" ]; then
    echo "❌ Erreur: Le dossier IA source n'existe pas: $IA_SOURCE"
    echo "   Veuillez ajuster le chemin dans ce script."
    exit 1
fi

# Créer le dossier ai-service dans le projet
AI_TARGET="./ai-service"
echo "📁 Copie du dossier IA vers $AI_TARGET..."

if [ -d "$AI_TARGET" ]; then
    echo "⚠️  Le dossier $AI_TARGET existe déjà."
    read -p "Voulez-vous le remplacer? (o/N): " replace
    if [[ ! $replace =~ ^[Oo]$ ]]; then
        echo "Opération annulée."
        exit 0
    fi
    rm -rf "$AI_TARGET"
fi

# Copier les fichiers nécessaires
mkdir -p "$AI_TARGET"
cp "$IA_SOURCE/AI_API.py" "$AI_TARGET/"
cp "$IA_SOURCE/Transcription_AI.py" "$AI_TARGET/"
cp "$IA_SOURCE/requirements.txt" "$AI_TARGET/"
cp "$IA_SOURCE/Dockerfile" "$AI_TARGET/"
cp "$IA_SOURCE/.dockerignore" "$AI_TARGET/" 2>/dev/null || true
cp "$IA_SOURCE/Readme.md" "$AI_TARGET/" 2>/dev/null || true

# Créer le dossier Reunions (vide, sera monté en volume)
mkdir -p "$AI_TARGET/Reunions/ID"

echo "✅ Fichiers copiés avec succès"
echo ""

# Mettre à jour le fichier .env
echo "⚙️  Configuration du fichier .env..."
cat > .env << 'EOF'
# Configuration pour docker-compose
# Chemin vers le dossier IA (relatif au répertoire du docker-compose.yml)
AI_SERVICE_PATH=./ai-service
EOF

echo "✅ Fichier .env configuré avec le chemin relatif: ./ai-service"
echo ""

# Créer un fichier .gitignore pour ai-service si nécessaire
if [ ! -f "$AI_TARGET/.gitignore" ]; then
    cat > "$AI_TARGET/.gitignore" << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/

# Data (sera dans un volume Docker)
Reunions/
EOF
    echo "✅ Fichier .gitignore créé pour ai-service"
fi

echo ""
echo "🎉 Projet prêt pour être portable !"
echo ""
echo "📝 Prochaines étapes:"
echo "   1. Vérifiez que tous les fichiers sont présents dans ai-service/"
echo "   2. Testez avec: docker-compose build"
echo "   3. Créez un zip du projet entier"
echo ""
echo "💡 Pour créer un zip portable:"
echo "   zip -r transcription-service-portable.zip . -x '*.git*' '*/build/*' '*/bin/*' '*/__pycache__/*' '*/Reunions/*'"

