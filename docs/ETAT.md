# État du projet (passage de relais entre conversations)

Branche de travail : `claude/new-session-7hha19`.

## Fait
- Étape 0 : squelette Flutter, thème, navigation 4 onglets, modèles.
- Étape 1 : base drift (`lib/data/db/`), repositories garden/plant/care, providers Riverpod (`lib/data/providers.dart`).
- `scripts/dev.sh` : git → préparation → tests → lancement (linux, chrome, web-server pour iPhone).
- Web drift : `web/` versionné. `sqlite3.wasm` et `drift_worker.js` téléchargés par `dev.sh` selon `pubspec.lock`, non versionnés.
- Étape 2 : éditeur du plan (`lib/features/garden/`). Validé par l'utilisateur sur Linux.
- Étape 4 (faite avant la 3, avec des plantes de démo) : calendrier des soins.
  - `lib/features/calendar/` : `care_planner.dart` (génération des tâches, saison), `care_service.dart` (validation, alertes, synchro, providers), `ics_export.dart`, écran (En retard / Aujourd'hui / À venir, bouton « Fait ✓ », export .ics).
  - Pastille du nombre de soins dus sur l'onglet Calendrier.
  - `lib/services/care_notifications.dart` : Android = rappels programmés ; Linux/web = rappel à l'ouverture (web : à activer dans Réglages, autorisation navigateur).
  - `lib/services/google/` : synchro vers un agenda « GardenParty 🌱 » (Linux/Android : OAuth bureau + 127.0.0.1 ; web : localhost:8080 seulement).
  - Réglages : notifications, Google Agenda (connecter / synchroniser / déconnecter), plantes de démo.
  - `scripts/patch_android.py` : desugaring + récepteurs de notifications dans `android/` (appelé par `dev.sh`).
  - 23 tests OK (Flutter 3.47). Build web vérifié dans Chromium (plantes de démo, calendrier, réglages). Build Linux/Android non testés ici.

## À tester par l'utilisateur
1. `./scripts/dev.sh` → 1 (pubspec.lock a changé : `flutter clean` automatique).
2. Linux : Calendrier → « Ajouter des plantes de démo » → 4 soins aujourd'hui, pastille « 4 », notification système « 4 soins à faire ». « Fait ✓ » → le soin suivant apparaît dans « À venir ».
3. Bouton partage (en haut à droite) → fichier `gardenparty-soins.ics` → l'importer dans Google Agenda (web : Paramètres > Importer).
4. Google Agenda (facultatif) : suivre `google_oauth.env.example`, créer `google_oauth.env`, relancer, Réglages → « Connecter Google Agenda ».
5. Android : notification à 9 h le jour d'un soin, même app fermée.

## En attente de décision
- Étape 5 : `camera` web ne verrouille pas l'exposition ; mesure de lumière moins fiable sur iPhone, calibrage séparé.
- Google sur iPhone : impossible depuis `http://<ip>` (Google exige https ou localhost). Contournement : synchro depuis Linux/Android, l'iPhone voit l'agenda via le compte Google.

## Points d'attention
- Projet à garder sur une partition Linux (ext4/btrfs) : sur NTFS, les liens de plugins Flutter cassent le build Linux.
- Web hors-ligne complet : `flutter build web --no-web-resources-cdn`.
- Écran de consentement Google en mode « Test » : jeton de rafraîchissement valable 7 jours, reconnecter ensuite (ou publier l'app).

## Prochaine étape
Étape 3 : plantes (base locale JSON FR, fiche, ajout au jardin, placement sur le plan). Après ajout d'une plante, appeler `careServiceProvider.ensureTasks()`. Retirer ensuite les plantes de démo (`lib/features/settings/demo_data.dart`).
