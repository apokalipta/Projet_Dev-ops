#!/bin/bash

# Script pour créer un zip portable du projet

echo "📦 Création du zip portable du projet..."
echo ""

# Vérifier que le dossier ai-service existe
if [ ! -d "ai-service" ]; then
    echo "❌ Erreur: Le dossier ai-service n'existe pas."
    echo "   Lancez d'abord: ./prepare-portable.sh"
    exit 1
fi

# Vérifier que le .env est correct
if ! grep -q "AI_SERVICE_PATH=./ai-service" .env 2>/dev/null; then
    echo "⚠️  Attention: Le fichier .env ne semble pas configuré correctement."
    echo "   Vérifiez qu'il contient: AI_SERVICE_PATH=./ai-service"
    read -p "Continuer quand même? (o/N): " continue_anyway
    if [[ ! $continue_anyway =~ ^[Oo]$ ]]; then
        exit 1
    fi
fi

# Nom du fichier zip
ZIP_NAME="transcription-service-portable.zip"

# Supprimer l'ancien zip si il existe
if [ -f "$ZIP_NAME" ]; then
    echo "🗑️  Suppression de l'ancien zip..."
    rm "$ZIP_NAME"
fi

echo "📦 Création du zip (cela peut prendre quelques instants)..."
echo ""

# Créer le zip en excluant les fichiers inutiles
zip -r "$ZIP_NAME" . \
    -x '*.git*' \
    -x '*/build/*' \
    -x '*/bin/*' \
    -x '*/__pycache__/*' \
    -x '*/Reunions/*' \
    -x '*.class' \
    -x '*.jar' \
    -x '.DS_Store' \
    -x '*.log' \
    -x 'node_modules/*' \
    > /dev/null 2>&1

if [ $? -eq 0 ]; then
    # Afficher la taille du zip
    SIZE=$(du -h "$ZIP_NAME" | cut -f1)
    echo "✅ Zip créé avec succès: $ZIP_NAME"
    echo "   Taille: $SIZE"
    echo ""
    echo "📝 Contenu du zip:"
    unzip -l "$ZIP_NAME" | head -20
    echo ""
    echo "🎉 Le projet est maintenant portable !"
    echo ""
    echo "📋 Pour utiliser sur un autre PC:"
    echo "   1. Extraire le zip"
    echo "   2. cd dans le dossier extrait"
    echo "   3. docker-compose up -d"
else
    echo "❌ Erreur lors de la création du zip"
    exit 1
fi

