# Carte Flutter

Application Flutter permettant de placer et gérer des points sur une carte interactive.

## Fonctionnalités

- Carte interactive OpenStreetMap (zoom, déplacement)
- Ajout de points en tapant sur la carte
- Attribution d'un nom à chaque point
- Liste scrollable de tous les points avec coordonnées
- Renommage et suppression de points
- Persistance des données via PocketBase

## Choix techniques

| Composant | Choix | Raison |
|-----------|-------|--------|
| Carte | `flutter_map` + OpenStreetMap | Gratuit, pas de clé API requise |
| Backend | PocketBase | Un seul binaire, simple à configurer, SDK Dart officiel |

## Prérequis

- Flutter SDK >= 3.11
- PocketBase (télécharger depuis https://pocketbase.io/docs/)

## Installation et lancement

### 1. Configurer PocketBase

```bash
# Télécharger PocketBase puis lancer le serveur
./pocketbase serve
```

Ouvrir l'interface admin sur `http://127.0.0.1:8090/_/` et créer une collection **`points`** avec les champs suivants :

| Champ | Type | Requis |
|-------|------|--------|
| `name` | Text | Oui |
| `latitude` | Number | Oui |
| `longitude` | Number | Oui |

Dans les **API Rules** de la collection, autoriser toutes les opérations (List, View, Create, Update, Delete) en laissant les règles vides (accès public).

### 2. Lancer l'application Flutter

```bash
flutter pub get
flutter run
```

> Sur un émulateur Android, modifier l'URL dans `lib/services/pocketbase_service.dart` :
> `http://10.0.2.2:8090` au lieu de `http://127.0.0.1:8090`

## Structure du projet

```
lib/
├── main.dart                  # Point d'entrée, navigation par onglets
├── models/
│   └── map_point.dart         # Modèle de données Point
├── services/
│   └── pocketbase_service.dart # Service CRUD PocketBase
├── screens/
│   ├── map_screen.dart        # Écran carte interactive
│   └── list_screen.dart       # Écran liste des points
└── widgets/
    └── point_dialog.dart      # Dialog de saisie du nom
```

## Captures d'écran

<!-- TODO: Ajouter des captures d'écran -->

| Carte | Liste |
|-------|-------|
| *capture carte* | *capture liste* |
