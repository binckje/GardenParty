# État du projet (passage de relais entre conversations)

Branche de travail : `claude/new-session-7hha19`.

## Fait
- Étape 0 : squelette Flutter, thème, navigation 4 onglets, modèles.
- Étape 1 : base drift (`lib/data/db/`), repositories garden/plant/care, providers Riverpod (`lib/data/providers.dart`). 7 tests OK chez l'utilisateur (CachyOS, Flutter ≥ 3.38).
- `scripts/dev.sh` : git → préparation → tests → lancement (linux, chrome, web-server pour iPhone).
- Web drift : `web/` versionné (index.html, manifest en FR, couleurs du thème). `sqlite3.wasm` et `drift_worker.js` téléchargés par `dev.sh` (étape préparation) selon les versions de `pubspec.lock`, non versionnés. Vérifié dans Chromium : stockage IndexedDB, plan conservé après rechargement.
- Étape 2 : éditeur du plan (`lib/features/garden/`) : `plan_geometry.dart` (calculs, aimantation 0,25 m, taille mini 0,5 m), `plan_painter.dart` (grille 1 m, pièces au-dessus des zones, portes avec arc, fenêtres), `garden_screen.dart` (ajout pièce/zone, glisser = déplacer, rond bas-droit = redimensionner, pincer/molette = zoom, glisser dans le vide = défiler, renommer, supprimer, portes/fenêtres : mur, position, largeur). 14 tests OK. Validé par l'utilisateur sur Linux.

- Étape 5 : lumière (`lib/features/light/`). Bouton ☀️ de l'écran Jardin = mode lumière : choix du moment (matin/midi/fin d'après-midi) ou « Bilan » (niveau médian), toucher une pièce = mesurer, toucher un point existant = détail/nouvelle mesure/suppression ; carte de chaleur colorée par niveau + légende. Sources : capteur (Android), caméra (Android/web, calibrage stocké en base, table `settings`, schéma v2), saisie (repères ou lux). `LightAnalysis.bestSpots` prêt pour les suggestions (UI à faire avec l'étape 3). `dev.sh` : web-server en HTTPS auto-signé (caméra iPhone). 21 tests OK ici (Flutter 3.38+ compatible : `camera` < 0.12, `camera_platform_interface` < 2.15). **À valider par l'utilisateur** (Android, Linux, iPhone).

## En attente de décision
- Étape 4 : `flutter_local_notifications` ne marche pas sur le web ; sur iPhone les notifications PWA demandent Web Push (serveur). À trancher (alertes dans l'app seulement ?).

## Points d'attention
- Projet à garder sur une partition Linux (ext4/btrfs, ici `~/dev/GardenParty`) : sur NTFS, les liens de plugins Flutter (`linux/flutter/ephemeral/.plugin_symlinks`) cassent le build Linux.
- Web hors-ligne complet : `flutter build web --no-web-resources-cdn` (sinon CanvasKit vient de gstatic).

## Prochaine étape
Étape 3 : plantes (base locale JSON FR, fiche, ajout au jardin, placement sur le plan).
