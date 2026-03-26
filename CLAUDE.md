# CLAUDE.md — Guide pour les développeurs et assistants IA

## Commandes essentielles

```bash
# Installation
flutter pub get

# Lancer l'app
pocketbase serve    # dans un terminal
flutter run          # dans un autre terminal

# Analyse statique
flutter analyze

# Tests
flutter test
```

## Architecture

```
lib/
├── main.dart                   # Point d'entrée, état global, navigation par onglets
├── models/
│   └── map_point.dart          # Modèle MapPoint (id, name, latitude, longitude)
├── services/
│   ├── pocketbase_service.dart # CRUD vers PocketBase (collection "points")
│   └── geocoding_service.dart  # Recherche d'adresse via API Nominatim
├── screens/
│   ├── map_screen.dart         # Carte OpenStreetMap interactive
│   └── list_screen.dart        # Liste scrollable des points
└── widgets/
    └── point_dialog.dart       # Dialog réutilisable pour saisir un nom
```

## Flux de données

L'état est centralisé dans `HomePage` (main.dart) :
- `_points` est la source de vérité unique
- Les écrans reçoivent les points en props + un callback `onPointsChanged`
- Après chaque opération CRUD, `onPointsChanged()` → `_loadPoints()` → `setState()` → rebuild

## Conventions

- Pas de state management externe (Provider, Bloc, etc.) — le lift state up suffit ici
- Les services sont instanciés directement (pas d'injection de dépendances)
- Les commentaires sont en français
- L'URL PocketBase est en dur dans `pocketbase_service.dart` (modifier pour Android émulateur : `10.0.2.2:8090`)

## PocketBase

Collection `points` avec 3 champs : `name` (Text), `latitude` (Number), `longitude` (Number).
Les API Rules doivent être vides (accès public sans auth).
