# Architecture GardenParty

## Choix techniques
| Sujet | Choix | Raison |
|---|---|---|
| Framework | Flutter (Dart 3) | Un code : Android, iOS, tablette, Linux desktop, web |
| État | Riverpod | Simple, testable |
| Navigation | go_router (4 onglets : Jardin, Plantes, Calendrier, Réglages) | Standard Flutter |
| Stockage | Local hors-ligne, SQLite via `drift` (wasm sur le web) | Pas de compte, pas de serveur |
| Notifications | `flutter_local_notifications` | Rappels arrosage/engrais, alertes d'oubli |
| Plan 2D | `CustomPainter` + gestes (drag / pinch / poignées de redimensionnement) | Pas de dépendance lourde |
| Lumière | `camera` : exposition verrouillée, luminance moyenne de l'image → lux estimé (calibrage). Capteur de lumière Android en bonus | iOS n'expose pas le capteur de lumière |
| Style | Thème pastel, police Nunito, coins arrondis 24 px | « cosy & kawaii » |

## Structure
```
lib/
  app/         thème, routeur
  models/      garden.dart (pièces, ouvertures, mesures lumière)
               plant.dart (fiche espèce, plante possédée)
               care.dart (tâches d'entretien)
  features/    garden/ plants/ calendar/ settings/
  data/        (à venir) base drift, clients API, cache
```

## Modèle de lumière
- 5 niveaux communs : `shade` <250 lx, `lowLight` <1 000, `brightIndirect` <5 000, `partialSun` <20 000, `fullSun`.
- Mesures par point × 3 moments (matin, midi, fin d'après-midi) → carte de chaleur par pièce.
- Compatibilité : niveau médian du point ∈ `PlantSpecies.light` ⇒ emplacement conseillé.

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
