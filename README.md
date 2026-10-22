# GardenParty 🪴

Application cosy & kawaii de gestion des plantes d'intérieur et d'extérieur (Flutter : mobile, tablette, Linux, web).

- Cahier des charges : [docs/CAHIER_DES_CHARGES.md](docs/CAHIER_DES_CHARGES.md)
- Architecture et sources de données : [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Avancement : [docs/ROADMAP.md](docs/ROADMAP.md)

## Démarrer
Prérequis : Flutter SDK ≥ 3.38 (exigé par drift ≥ 2.35).

```bash
flutter create --project-name garden_party --platforms=android,ios,linux,web .
rm -f test/widget_test.dart   # test généré par défaut, référence MyApp inexistant
flutter pub get
dart run build_runner build   # régénère lib/data/db/database.g.dart après modif des tables
flutter test
flutter run -d linux   # ou chrome, ou un appareil Android
```

`flutter create .` génère les dossiers de plateformes (android/, ios/, linux/, web/) sans écraser `lib/` ni `pubspec.yaml` existants.
