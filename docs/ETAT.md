# État du projet (passage de relais entre conversations)

Branche de travail : `claude/new-session-7hha19`.

## Fait
- Étape 0 : squelette Flutter, thème, navigation 4 onglets, modèles.
- Étape 1 : base drift (`lib/data/db/`), repositories garden/plant/care, providers Riverpod (`lib/data/providers.dart`). 7 tests OK chez l'utilisateur (CachyOS, Flutter ≥ 3.38).
- `scripts/dev.sh` : git → préparation → tests → lancement (linux, chrome, web-server pour iPhone).

## En attente de décision
- Configuration web de drift (`web/sqlite3.wasm`, `web/drift_worker.js`) : nécessaire pour iPhone/iPad (PWA). Proposé de l'avancer avant l'étape 7.
- Étape 4 : `flutter_local_notifications` ne marche pas sur le web ; sur iPhone les notifications PWA demandent Web Push (serveur). À trancher (alertes dans l'app seulement ?).
- Étape 5 : `camera` web ne verrouille pas l'exposition ; mesure de lumière moins fiable sur iPhone, calibrage séparé.

## Prochaine étape
Étape 2 : éditeur 2D du plan (voir docs/ROADMAP.md).
