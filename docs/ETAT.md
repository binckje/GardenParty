# État du projet (passage de relais entre conversations)

Branche de travail : `claude/new-session-7hha19`.

## Fait
- Étape 0 : squelette Flutter, thème, navigation 4 onglets, modèles.
- Étape 1 : base drift (`lib/data/db/`), repositories garden/plant/care, providers Riverpod (`lib/data/providers.dart`). 7 tests OK chez l'utilisateur (CachyOS, Flutter ≥ 3.38).
- `scripts/dev.sh` : git → préparation → tests → lancement (linux, chrome, web-server pour iPhone).
- Web drift : `web/` versionné (index.html, manifest en FR, couleurs du thème). `sqlite3.wasm` et `drift_worker.js` téléchargés par `dev.sh` (étape préparation) selon les versions de `pubspec.lock`, non versionnés. Vérifié dans Chromium : stockage IndexedDB, plan conservé après rechargement.
- Étape 2 : éditeur du plan (`lib/features/garden/`) : `plan_geometry.dart` (calculs, aimantation 0,25 m, taille mini 0,5 m), `plan_painter.dart` (grille 1 m, pièces au-dessus des zones, portes avec arc, fenêtres), `garden_screen.dart` (ajout pièce/zone, glisser = déplacer, rond bas-droit = redimensionner, pincer/molette = zoom, glisser dans le vide = défiler, renommer, supprimer, portes/fenêtres : mur, position, largeur). 14 tests OK. Validé par l'utilisateur sur Linux.

- Étape 3 : catalogue `assets/plants_fr.json` (25 espèces FR, clé `image` = emoji ; une URL `http…` ou un chemin `assets/…` sera affiché comme image), copié au lancement dans `plant_species` sans écraser l'existant (`speciesCatalogProvider`). Écrans `lib/features/plants/` : liste « Mes plantes », catalogue avec recherche sans accents, fiche espèce, fiche plante (renommer, supprimer, placer/déplacer, retirer du plan). Placement : `placingPlantProvider` + onglet Jardin, appui sur une pièce/zone ; pastilles emoji déplaçables par glisser. Position des plantes relative au coin de leur pièce (elles suivent son déplacement). Dialogues communs : `lib/features/dialogs.dart`. 20 tests OK. Validé par l'utilisateur sur Linux.

## En attente de décision
- Étape 4 : `flutter_local_notifications` ne marche pas sur le web ; sur iPhone les notifications PWA demandent Web Push (serveur). À trancher. Piste recommandée : alertes dans l'app + notifications Android/Linux + export `.ics` vers Calendrier pour iOS (une web app n'a pas accès à Calendrier/Rappels ; alternatives : abonnement `webcal://` avec serveur, ou Raccourci iOS appelé par lien `shortcuts://`). À vérifier : Safari iPhone accepte-t-il le `.ics` téléchargé depuis l'app Flutter web ?
  Option préférée ensuite : synchro Google Agenda (API Calendar v3, agenda dédié « GardenParty », événements récurrents + rappels, mis à jour par id). Prérequis : projet Google Cloud, client OAuth Web (+ client Bureau pour Linux, `google_sign_in` non dispo sur Linux), app en mode test (utilisateur testeur), web servi en HTTPS (ex. GitHub Pages ; `http://IP-locale` refusé par Google). Jeton web valable 1 h : reconsentement à la synchro.
- Étape 5 : `camera` web ne verrouille pas l'exposition ; mesure de lumière moins fiable sur iPhone, calibrage séparé.

## Points d'attention
- Projet à garder sur une partition Linux (ext4/btrfs, ici `~/dev/GardenParty`) : sur NTFS, les liens de plugins Flutter (`linux/flutter/ephemeral/.plugin_symlinks`) cassent le build Linux.
- Web hors-ligne complet : `flutter build web --no-web-resources-cdn` (sinon CanvasKit vient de gstatic).

## Prochaine étape
Étape 4 : calendrier d'entretien (décision notifications à prendre).
