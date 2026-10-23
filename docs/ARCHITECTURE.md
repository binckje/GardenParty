# Architecture GardenParty

## Choix techniques
| Sujet | Choix | Raison |
|---|---|---|
| Framework | Flutter (Dart 3) | Un code : Android, tablette, Linux desktop, web. iOS natif hors périmètre (pas de compte Apple Developer ni de Mac) : iPhone/iPad via la version web (PWA) |
| État | Riverpod | Simple, testable |
| Navigation | go_router (4 onglets : Jardin, Plantes, Calendrier, Réglages) | Standard Flutter |
| Stockage | Local hors-ligne, SQLite via `drift` (wasm sur le web) | Pas de compte, pas de serveur |
| Notifications | `flutter_local_notifications` | Rappels arrosage/engrais, alertes d'oubli |
| Plan 2D | `CustomPainter` + gestes (drag / pinch / poignées de redimensionnement) | Pas de dépendance lourde |
| Lumière | Capteur Android (`light`, lux réels) ; `camera` (Android, web) : luminance moyenne de la photo × facteur de calibrage ; saisie manuelle (repères qualitatifs ou luxmètre) | Caméra en exposition auto : estimation grossière. Pas de caméra sur Linux. iPhone : HTTPS requis |
| Style | Thème pastel, police Nunito, coins arrondis 24 px | « cosy & kawaii » |

## Structure
```
lib/
  app/         thème, routeur
  models/      garden.dart (pièces, ouvertures, mesures lumière)
               plant.dart (fiche espèce, plante possédée)
               care.dart (tâches d'entretien)
  features/    garden/ plants/ calendar/ settings/
  data/        db/ tables drift, convertisseurs JSON, AppDatabase (+ database.g.dart généré)
               repositories/ garden, plant, care (modèles métier ⇄ lignes SQL)
               providers.dart  databaseProvider (surchargé en test), repositories, StreamProviders
               (à venir) clients API, cache
```

## Données (drift)
- Tables : `spaces`, `openings`, `light_readings`, `plant_species`, `owned_plants`, `care_tasks`. Enums stockés par nom.
- Sous-objets d'espèce (lumière, programmes de soin, diagnostics, bouture, rempotage) en colonnes JSON.
- Clés étrangères actives : supprimer une pièce supprime ses ouvertures/mesures et « déplace » ses plantes hors plan ; supprimer une plante supprime ses tâches.
- `schemaVersion` = 2 (v2 : table `settings`) : toute modif de table ⇒ incrémenter + migration, puis `dart run build_runner build`.
- Web (étape 7) : copier `sqlite3.wasm` et `drift_worker.js` dans `web/` (voir doc drift « Web »).

## Modèle de lumière
- 5 niveaux communs : `shade` <250 lx, `lowLight` <1 000, `brightIndirect` <5 000, `partialSun` <20 000, `fullSun`.
- Mesures par point × 3 moments (matin, midi, fin d'après-midi) → carte de chaleur par pièce.
- Mesures à moins de 0,4 m = même point ; la plus récente l'emporte par moment.
- Compatibilité : niveau médian du point ∈ `PlantSpecies.light` ⇒ emplacement conseillé (`LightAnalysis.bestSpots`).
- Calibrage caméra : facteur lux/luminance stocké dans `settings` (`camera_lux_factor`).
- Code : `lib/features/light/` (analyse, sources de mesure, feuille de mesure) ; mode lumière dans l'écran du plan.

## Sources de données plantes (point 2 du cahier des charges)
Quotas à revérifier avant intégration (ils changent souvent).

| Source | Usage | Gratuit | Remarque |
|---|---|---|---|
| **Perenual** | Fiche entretien : arrosage, lumière, rusticité, bouturage, maladies | Clé gratuite, quota journalier limité, partie du catalogue seulement | Meilleure couverture « entretien » |
| **Pl@ntNet API** | Identification par photo | Clé gratuite, quota journalier | Ajout d'une plante depuis une photo |
| **GBIF** | Taxonomie, noms vernaculaires FR | Sans clé | Normaliser le nom scientifique |
| **Wikipedia / Wikidata** | Description FR + visuel (Wikimedia Commons) | Sans clé | Licence CC : citer l'auteur |
| **Trefle** | Données botaniques (sol, température, lumière) | Gratuit | Service instable ces dernières années : secours seulement |
| **Base locale curée** (JSON embarqué) | ~50 plantes courantes, en FR | — | Fonctionne hors-ligne, complète les trous des API |

Stratégie : base locale d'abord → Perenual → enrichissement GBIF/Wikipedia ; résultat mis en cache dans SQLite.
