# 🌿 Gestion des branches du projet

## 🔒 Branche master
 - Ne doit en aucun cas être modifiée directement.
 - Cette branche représente la version stable et validée du projet.
 - Seules les mises à jour officielles effectuées par l’intégrateur y sont autorisées.


## 🚀 Branche release
 - Sert uniquement à récupérer (pull) les dernières versions intégrées.
 - Aucun push ne doit être fait dessus par les développeurs.
 - L’intégrateur est le seul autorisé à fusionner les travaux vers cette branche.
 - Elle permet de centraliser et tester les contributions issues des différentes branches de développement.


## 💻 Branches dev-*
 - Ce sont les branches de travail individuelles ou thématiques.
 - Chaque développeur crée ou utilise sa propre branche sous le format : dev-nom
 - Les développements, tests et commits doivent s’y faire avant intégration vers release.


## 🧱 Format des commits
 - Afin d’assurer une bonne traçabilité des changements, tous les messages de commit doivent suivre ce format :  
#[numéro_issue] [feature] : [description du commit]

### ✅ Exemples :
#42 login : ajout de la vérification des identifiants  
#17 ui : correction de l’affichage du menu principal  
#58 api : refactorisation du module d’authentification  

### 🧩 Règles :
 - Le numéro d’issue correspond à celui de GitHub (ex : #42).
 - Le nom de la feature doit être court et explicite (ex : ui, api, login, database, etc.).
 - Le texte du commit doit décrire clairement l’action effectuée, au présent et sans majuscule initiale.
 - Éviter les messages génériques comme “update”, “fix” ou “modifications”.


## ✅ Récapitulatif :
| Branche   | Autorisation push               | Utilisation principale   |
| --------- | ------------------------------- | ------------------------ |
| `master`  | 🚫 Non                          | Version finale et stable |
| `release` | 🚫 Non (intégrateur uniquement) | Mise en commun et tests  |
| `dev-*`   | ✅ Oui                           | Développement individuel |


## 🔁 Souviens-toi :
- Le flux de travail est : dev-* → release → master
