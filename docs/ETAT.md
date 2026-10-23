# État du projet (passage de relais entre conversations)

Branche de travail : `claude/new-session-7hha19`.

## Fait
- Étape 0 : squelette Flutter, thème, navigation 4 onglets, modèles.
- Étape 1 : base drift (`lib/data/db/`), repositories garden/plant/care, providers Riverpod (`lib/data/providers.dart`).
- `scripts/dev.sh` : git → préparation → tests → lancement (linux, chrome, web-server pour iPhone).
- Web drift : `web/` versionné. `sqlite3.wasm` et `drift_worker.js` téléchargés par `dev.sh` selon `pubspec.lock`, non versionnés.
- Étape 2 : éditeur du plan (`lib/features/garden/`). Validé par l'utilisateur sur Linux.
- Étape 3 : catalogue `assets/plants_fr.json` (260 espèces FR depuis l'étape 6 : intérieur, fleuries, succulentes, aromatiques, potager, fruitiers, ornementales d'extérieur ; clé `image` = emoji ; une URL `http…` ou un chemin `assets/…` sera affiché comme image), copié au lancement dans `plant_species` sans écraser l'existant (`speciesCatalogProvider`). Écrans `lib/features/plants/` : liste « Mes plantes », catalogue avec recherche sans accents, fiche espèce, fiche plante (renommer, supprimer, placer/déplacer, retirer du plan). Placement : `placingPlantProvider` + onglet Jardin, appui sur une pièce/zone ; pastilles emoji déplaçables par glisser. Position des plantes relative au coin de leur pièce (elles suivent son déplacement). Dialogues communs : `lib/features/dialogs.dart`. 20 tests OK. Validé par l'utilisateur sur Linux.
- Étape 4 : calendrier des soins.
  - `lib/features/calendar/` : `care_planner.dart` (génération des tâches, intervalle doublé hors saison), `care_service.dart` (validation, alertes, synchro, providers), `ics_export.dart`, écran (En retard / Aujourd'hui / À venir, bouton « Fait ✓ », export .ics 90 jours).
  - Soins créés automatiquement quand une plante est ajoutée (`CareAlerts` dans `main.dart` écoute `ownedPlantsProvider`), puis au démarrage, au retour dans l'app et toutes les 15 min.
  - Pastille du nombre de soins dus sur l'onglet Calendrier.
  - `lib/services/care_notifications.dart` : Android = rappels programmés à 9 h ; Linux = rappel à l'ouverture ; web = idem, à activer dans Réglages (autorisation navigateur).
  - `lib/services/google/` : synchro vers un agenda dédié « GardenParty 🌱 » (portée `calendar.app.created`). Linux/Android : client OAuth « bureau » + retour 127.0.0.1, jeton stocké. Web : `http://localhost:8080` seulement, jeton 1 h.
  - Réglages : notifications, Google Agenda (connecter / synchroniser / déconnecter).
  - `scripts/patch_android.py` : desugaring + récepteurs de notifications dans `android/` (appelé par `dev.sh`). `dev.sh` passe `google_oauth.env` en `--dart-define-from-file` et fixe le port 8080 pour chrome.
  - 29 tests OK (Flutter 3.47). Build web vérifié dans Chromium. Builds Linux/Android non testés ici (pas de GTK ni SDK Android).
- Étape 5 : lumière (`lib/features/light/`).
  - Bouton ☀️ de l'écran Jardin = mode lumière : moment (matin / midi / fin d'après-midi, présélectionné selon l'heure) ou « Bilan » (niveau médian par point). Toucher une pièce = mesurer ; toucher un point existant = détail des 3 moments, nouvelle mesure, suppression. Carte de chaleur colorée par niveau + légende.
  - Sources : capteur (Android, paquet `light`), caméra (Android/web : luminance moyenne × facteur de calibrage dans `SharedPreferences`), saisie (5 repères qualitatifs ou lux d'un luxmètre). Pas de caméra sur Linux.
  - `LightAnalysis.bestSpots(spaces, species.light)` : emplacements conseillés, pas encore affichés.
  - `dev.sh` : web-server en HTTPS (certificat auto-signé dans `.dart_tool/dev_cert`), nécessaire à la caméra sur iPhone.
  - 35 tests OK (Flutter 3.47). Validé par l'utilisateur.
- Étape 6 (couche données sans UI, choix utilisateur) : `lib/data/api/` (Perenual, GBIF, Pl@ntNet, cache SQLite, `PlantLookupService`), providers dans `providers.dart`, table `api_cache_entries` (schemaVersion 2). Clés dans `.env` (modèle `.env.example`), passées par `dev.sh`. 42 tests OK (7 nouveaux, réseau simulé). Non testé contre les vraies API (réseau du conteneur bloqué) : à valider par l'utilisateur. Wikipedia reporté.
  - Écran (catalogue) : tuile « Chercher « … » en ligne » sous les résultats locaux (appel seulement au toucher, pour le quota), résultats Perenual → fiche chargée et enregistrée → fiche espèce (ajout au jardin). Bouton 📷 : `image_picker` (photo ou galerie ; galerie seule sur Linux) → Pl@ntNet → choix parmi 5 propositions → fiche. Fichier `lib/features/plants/online_search.dart`. 49 tests OK, build web OK.
  - Retour utilisateur : « quota atteint » Perenual = fiche hors offre gratuite (Perenual répond 429 « Please Upgrade Plan » pour les espèces n° > 3000, ex. Monstera 5257) : ces résultats (et toute espèce sans résultat Perenual, clé absente ou quota) donnent une fiche simplifiée GBIF (id `gbif-<clé>`, nom français GBIF, entretien moyen par défaut, bandeau « Fiche simplifiée ») ; attente bloquée corrigée (dialogue sur le navigateur racine).
  - Éditeur de fiche (`lib/features/plants/species_editor.dart`) : bouton « Créer une fiche » du catalogue (id `perso-<uuid>`) et « Modifier » sur toute fiche espèce (id conservé ; une fiche du catalogue modifiée n'est plus écrasée par `addMissingSpecies`). Tous les champs ; photo (appareil/galerie, 600 px) stockée en data URI dans `imageUrl`, ou emoji. 51 tests OK.
  - Recherche de bases alternatives (réseau bloqué ici, recherche web seulement) : Trefle actif à nouveau (dépôt mis à jour en oct. 2026, jeton gratuit) ; Tela Botanica eFlore/baseflor (sans clé, indicateurs écologiques de la flore de France, API parfois en panne) ; API plantes d'intérieur (Zyla, Apify) payantes ; Plants For A Future sans API. Intégration de Trefle et Tela en attente des tests curl de l'utilisateur.

## Tests reportés (étape 4)
Calendrier v1 validé par l'utilisateur. Tests ci-dessous à faire plus tard :
1. `./scripts/dev.sh` → 1 (pubspec.lock a changé : `flutter clean` automatique).
2. Linux : ajoute une plante (onglet Plantes) → Calendrier : arrosage + engrais aujourd'hui, pastille, notification système. « Fait ✓ » → le soin suivant passe dans « À venir ».
3. Bouton partage (Calendrier, en haut à droite) → `gardenparty-soins.ics` → l'importer dans Google Agenda (web : Paramètres > Importer et exporter) ou l'ouvrir sur iPhone.
4. Google Agenda (facultatif) : suivre `google_oauth.env.example`, créer `google_oauth.env`, relancer, Réglages → « Connecter Google Agenda » → agenda « GardenParty 🌱 » visible dans Google Agenda.
5. Android : notification à 9 h le jour d'un soin, même app fermée.


## En attente de décision
- Caméra en exposition automatique (aucune plateforme n'expose ISO / temps de pose via `camera`) : estimation grossière, préférer capteur ou saisie.
- Google sur iPhone : impossible depuis `http://<ip>` (Google exige https ou localhost). Contournement : synchro depuis Linux/Android, l'iPhone voit l'agenda via le compte Google ; sinon héberger le web en HTTPS (ex. GitHub Pages).

## Points d'attention
- Premier build après changement de `pubspec.lock` : `sqlite3` télécharge SQLite depuis GitHub ; en cas de « Connection reset by peer », relancer.
- Projet à garder sur une partition Linux (ext4/btrfs, ici `~/dev/GardenParty`) : sur NTFS, les liens de plugins Flutter cassent le build Linux.
- Web hors-ligne complet : `flutter build web --no-web-resources-cdn`.
- Écran de consentement Google en mode « Test » : jeton de rafraîchissement valable 7 jours, reconnecter ensuite.
- Le secret du client OAuth « bureau » est embarqué dans l'app (normal pour ce type de client selon Google) : ne pas réutiliser ce client ailleurs.

## Prochaine étape
Valider la recherche en ligne avec les vraies clés (Linux, puis iPhone pour la photo), puis afficher les emplacements conseillés (`LightAnalysis.bestSpots`) sur la fiche plante / espèce.
