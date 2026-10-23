# État du projet (passage de relais entre conversations)

Branche de travail : `claude/new-session-7hha19`.

## Fait
- Étape 0 : squelette Flutter, thème, navigation 4 onglets, modèles.
- Étape 1 : base drift (`lib/data/db/`), repositories garden/plant/care, providers Riverpod (`lib/data/providers.dart`).
- `scripts/dev.sh` : git → préparation → tests → lancement (linux, chrome, web-server pour iPhone).
- Web drift : `web/` versionné. `sqlite3.wasm` et `drift_worker.js` téléchargés par `dev.sh` selon `pubspec.lock`, non versionnés.
- Étape 2 : éditeur du plan (`lib/features/garden/`). Validé par l'utilisateur sur Linux.
- Étape 3 : catalogue `assets/plants_fr.json` (25 espèces FR, clé `image` = emoji ; une URL `http…` ou un chemin `assets/…` sera affiché comme image), copié au lancement dans `plant_species` sans écraser l'existant (`speciesCatalogProvider`). Écrans `lib/features/plants/` : liste « Mes plantes », catalogue avec recherche sans accents, fiche espèce, fiche plante (renommer, supprimer, placer/déplacer, retirer du plan). Placement : `placingPlantProvider` + onglet Jardin, appui sur une pièce/zone ; pastilles emoji déplaçables par glisser. Position des plantes relative au coin de leur pièce (elles suivent son déplacement). Dialogues communs : `lib/features/dialogs.dart`. 20 tests OK. Validé par l'utilisateur sur Linux.
- Étape 4 : calendrier des soins.
  - `lib/features/calendar/` : `care_planner.dart` (génération des tâches, intervalle doublé hors saison), `care_service.dart` (validation, alertes, synchro, providers), `ics_export.dart`, écran (En retard / Aujourd'hui / À venir, bouton « Fait ✓ », export .ics 90 jours).
  - Soins créés automatiquement quand une plante est ajoutée (`CareAlerts` dans `main.dart` écoute `ownedPlantsProvider`), puis au démarrage, au retour dans l'app et toutes les 15 min.
  - Pastille du nombre de soins dus sur l'onglet Calendrier.
  - `lib/services/care_notifications.dart` : Android = rappels programmés à 9 h ; Linux = rappel à l'ouverture ; web = idem, à activer dans Réglages (autorisation navigateur).
  - `lib/services/google/` : synchro vers un agenda dédié « GardenParty 🌱 » (portée `calendar.app.created`). Linux/Android : client OAuth « bureau » + retour 127.0.0.1, jeton stocké. Web : `http://localhost:8080` seulement, jeton 1 h.
  - Réglages : notifications, Google Agenda (connecter / synchroniser / déconnecter).
  - `scripts/patch_android.py` : desugaring + récepteurs de notifications dans `android/` (appelé par `dev.sh`). `dev.sh` passe `google_oauth.env` en `--dart-define-from-file` et fixe le port 8080 pour chrome.
  - 29 tests OK (Flutter 3.47). Build web vérifié dans Chromium. Builds Linux/Android non testés ici (pas de GTK ni SDK Android).

## Tests reportés (étape 4)
Calendrier v1 validé par l'utilisateur. Tests ci-dessous à faire plus tard :
1. `./scripts/dev.sh` → 1 (pubspec.lock a changé : `flutter clean` automatique).
2. Linux : ajoute une plante (onglet Plantes) → Calendrier : arrosage + engrais aujourd'hui, pastille, notification système. « Fait ✓ » → le soin suivant passe dans « À venir ».
3. Bouton partage (Calendrier, en haut à droite) → `gardenparty-soins.ics` → l'importer dans Google Agenda (web : Paramètres > Importer et exporter) ou l'ouvrir sur iPhone.
4. Google Agenda (facultatif) : suivre `google_oauth.env.example`, créer `google_oauth.env`, relancer, Réglages → « Connecter Google Agenda » → agenda « GardenParty 🌱 » visible dans Google Agenda.
5. Android : notification à 9 h le jour d'un soin, même app fermée.

## En attente de décision
- Étape 5 : `camera` web ne verrouille pas l'exposition ; mesure de lumière moins fiable sur iPhone, calibrage séparé.
- Google sur iPhone : impossible depuis `http://<ip>` (Google exige https ou localhost). Contournement : synchro depuis Linux/Android, l'iPhone voit l'agenda via le compte Google ; sinon héberger le web en HTTPS (ex. GitHub Pages).

## Points d'attention
- Projet à garder sur une partition Linux (ext4/btrfs, ici `~/dev/GardenParty`) : sur NTFS, les liens de plugins Flutter cassent le build Linux.
- Web hors-ligne complet : `flutter build web --no-web-resources-cdn`.
- Écran de consentement Google en mode « Test » : jeton de rafraîchissement valable 7 jours, reconnecter ensuite.
- Le secret du client OAuth « bureau » est embarqué dans l'app (normal pour ce type de client selon Google) : ne pas réutiliser ce client ailleurs.

## Prochaine étape
Étape 5 : lumière (mesure caméra, calibrage, carte de chaleur, suggestions d'emplacement).
