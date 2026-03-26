# Carte Flutter

Application Flutter permettant de placer et gérer des points sur une carte interactive avec persistance des données.

## Fonctionnalités

- Carte interactive OpenStreetMap (zoom, déplacement)
- Ajout de points en tapant sur la carte
- Recherche d'adresse (ex: "42 rue Raspail") avec géocodage Nominatim
- Attribution d'un nom à chaque point
- Liste scrollable de tous les points avec coordonnées
- Renommage et suppression de points
- Persistance des données via PocketBase

## Choix techniques

| Composant | Choix | Raison |
|-----------|-------|--------|
| Carte | `flutter_map` + OpenStreetMap | Gratuit, pas de clé API requise |
| Géocodage | API Nominatim | Gratuit, pas de clé API, intégré à OSM |
| Backend | PocketBase | Un seul binaire, simple à configurer, SDK Dart officiel |
| State management | `setState` + lift state up | Suffisant pour 2 écrans, pas de dépendance supplémentaire |

## Prérequis

- [Flutter SDK](https://flutter.dev) >= 3.11
- [PocketBase](https://pocketbase.io) (`brew install pocketbase` sur macOS)

## Installation rapide

```bash
git clone https://github.com/yonilancry/carte_flutter.git
cd carte_flutter
./setup.sh
```

Le script `setup.sh` vérifie les prérequis, installe les dépendances et lance PocketBase.

## Installation manuelle

### 1. Lancer PocketBase

```bash
pocketbase serve
```

### 2. Configurer la collection

Ouvrir `http://127.0.0.1:8090/_/` et créer une collection **`points`** avec :

| Champ | Type | Requis |
|-------|------|--------|
| `name` | Text | Oui |
| `latitude` | Number | Oui |
| `longitude` | Number | Oui |

Puis dans **API Rules**, laisser toutes les règles **vides** (accès public).

### 3. Lancer l'application

```bash
flutter pub get
flutter run
```

> **Emulateur Android** : modifier l'URL dans `lib/services/pocketbase_service.dart` → `http://10.0.2.2:8090`

## Structure du projet

```
lib/
├── main.dart                     # Point d'entrée, état global, navigation par onglets
├── models/
│   └── map_point.dart            # Modèle MapPoint (id, name, latitude, longitude)
├── services/
│   ├── pocketbase_service.dart   # CRUD vers PocketBase
│   └── geocoding_service.dart    # Recherche d'adresse via Nominatim
├── screens/
│   ├── map_screen.dart           # Carte interactive + barre de recherche
│   └── list_screen.dart          # Liste scrollable des points
└── widgets/
    └── point_dialog.dart         # Dialog réutilisable pour nommer un point
```

## Comment contribuer

1. L'état est centralisé dans `HomePage` (`main.dart`) — les écrans reçoivent les données en props
2. Pour ajouter un écran : créer dans `screens/`, l'ajouter comme onglet dans `main.dart`
3. Pour ajouter un champ au modèle : modifier `MapPoint`, `toJson()`, `fromRecord()`, et le schéma PocketBase
4. Lancer `flutter analyze` avant de commit pour vérifier le code

## Captures d'écran

<!-- Remplacer par de vraies captures -->

| Carte | Liste |
|-------|-------|
| *capture carte* | *capture liste* |
