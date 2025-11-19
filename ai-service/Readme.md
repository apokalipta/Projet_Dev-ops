Démarrage de l'API IA : 

Etape 1 : Création d'un environnement virtuel (venv) si non existant 
    python -m venv venv

Etape 2 : Démarrage environnement virtuel
    . venv/bin/activate

Etape 3 : Installation des requirements 
    pip install -r resuirements.txt

Etape 4 : Démarrage API (faut avoir AI_API.py et Transcription_AI.py dans même niveau d'arborescence)
    python -m uvicorn AI_API:app --reload

Etape 5 : Regarder dans le terminal les réponses des print + dans l'arborescence s'il y a création des fichiers lors de la réce^tion des requêtes