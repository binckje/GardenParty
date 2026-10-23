# Consignes projet

- `scripts/dev.sh` est le script de dev de l'utilisateur (git → préparation → tests → lancement). Le mettre à jour dès qu'une étape change la mise en route : nouvelle plateforme, nouvelle génération de code, assets web (sqlite3.wasm, drift_worker.js), variables d'environnement, clés API, etc.
- Après modification des tables drift : `dart run build_runner build` et commiter `database.g.dart`.
- Plateformes : android, linux, web (iPhone/iPad via le web, pas d'iOS natif).
- `web/` est versionné ; `sqlite3.wasm` / `drift_worker.js` sont téléchargés par `dev.sh` (ne pas les commiter).
