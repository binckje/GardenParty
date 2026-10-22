# GardenParty 🪴

Application cosy & kawaii de gestion des plantes d'intérieur et d'extérieur (Flutter : mobile, tablette, Linux, web).

- Cahier des charges : [docs/CAHIER_DES_CHARGES.md](docs/CAHIER_DES_CHARGES.md)
- Architecture et sources de données : [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Avancement : [docs/ROADMAP.md](docs/ROADMAP.md)

## Démarrer
Prérequis : Flutter SDK ≥ 3.22.

```bash
flutter create --project-name garden_party --platforms=android,ios,linux,web .
flutter pub get
flutter test
flutter run -d linux   # ou chrome, ou un appareil Android
```

`flutter create .` génère les dossiers de plateformes (android/, ios/, linux/, web/) sans écraser `lib/` ni `pubspec.yaml` existants.
