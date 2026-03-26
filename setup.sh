#!/bin/bash
# Script d'installation rapide du projet Carte Flutter
# Usage : ./setup.sh

set -e

echo "=== Carte Flutter - Installation ==="
echo ""

# 1. Vérifier Flutter
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter n'est pas installé. Installez-le depuis https://flutter.dev"
  exit 1
fi
echo "✅ Flutter détecté : $(flutter --version | head -1)"

# 2. Vérifier PocketBase
if ! command -v pocketbase &> /dev/null; then
  echo "❌ PocketBase n'est pas installé."
  echo "   → brew install pocketbase"
  echo "   → ou télécharger depuis https://pocketbase.io/docs/"
  exit 1
fi
echo "✅ PocketBase détecté"

# 3. Installer les dépendances Flutter
echo ""
echo "📦 Installation des dépendances Flutter..."
flutter pub get

# 4. Lancer PocketBase en arrière-plan
echo ""
echo "🚀 Lancement de PocketBase..."
pocketbase serve &
PB_PID=$!
sleep 2

# 5. Vérifier que PocketBase répond
if curl -s http://127.0.0.1:8090/api/health | grep -q "healthy"; then
  echo "✅ PocketBase lancé sur http://127.0.0.1:8090"
else
  echo "❌ PocketBase n'a pas démarré correctement"
  kill $PB_PID 2>/dev/null
  exit 1
fi

# 6. Créer la collection "points" via l'API si elle n'existe pas
echo ""
echo "📋 Création de la collection 'points'..."
# On tente de lire la collection ; si 404, on la crée
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8090/api/collections/points)
if [ "$STATUS" = "200" ]; then
  echo "✅ Collection 'points' existe déjà"
else
  echo "⚠️  La collection 'points' n'existe pas encore."
  echo ""
  echo "   Ouvrez http://127.0.0.1:8090/_/ dans votre navigateur"
  echo "   et créez la collection 'points' avec les champs :"
  echo ""
  echo "   | Champ     | Type   |"
  echo "   |-----------|--------|"
  echo "   | name      | Text   |"
  echo "   | latitude  | Number |"
  echo "   | longitude | Number |"
  echo ""
  echo "   Puis dans API Rules, laissez toutes les règles vides (accès public)."
fi

echo ""
echo "=== Installation terminée ==="
echo ""
echo "Pour lancer l'app :"
echo "  flutter run"
echo ""
echo "PocketBase tourne en arrière-plan (PID: $PB_PID)"
echo "Pour l'arrêter : kill $PB_PID"
