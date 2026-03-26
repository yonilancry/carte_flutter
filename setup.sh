#!/bin/bash
# Script d'installation rapide du projet Carte Flutter
# Usage : ./setup.sh

set -e

SETUP_EMAIL="setup@carte.local"
SETUP_PASS="SetupPass123!"
PB_URL="http://127.0.0.1:8090"

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
echo "✅ PocketBase détecté : $(pocketbase --version)"

# 3. Installer les dépendances Flutter
echo ""
echo "📦 Installation des dépendances Flutter..."
flutter pub get

# 4. Créer un superuser pour pouvoir configurer PocketBase via l'API
echo ""
echo "🔑 Création du superuser PocketBase..."
pocketbase superuser upsert "$SETUP_EMAIL" "$SETUP_PASS" 2>/dev/null || true

# 5. Lancer PocketBase en arrière-plan
echo ""
echo "🚀 Lancement de PocketBase..."
pocketbase serve &
PB_PID=$!
sleep 2

# 6. Vérifier que PocketBase répond
if ! curl -s "$PB_URL/api/health" | grep -q "healthy"; then
  echo "❌ PocketBase n'a pas démarré correctement"
  kill $PB_PID 2>/dev/null
  exit 1
fi
echo "✅ PocketBase lancé sur $PB_URL"

# 7. S'authentifier en superuser
echo ""
echo "📋 Configuration de la base de données..."
TOKEN=$(curl -s -X POST "$PB_URL/api/collections/_superusers/auth-with-password" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$SETUP_EMAIL\",\"password\":\"$SETUP_PASS\"}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")

if [ -z "$TOKEN" ]; then
  echo "❌ Impossible de s'authentifier auprès de PocketBase"
  kill $PB_PID 2>/dev/null
  exit 1
fi

# 8. Créer la collection "points" si elle n'existe pas
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$PB_URL/api/collections/points" \
  -H "Authorization: Bearer $TOKEN")

if [ "$STATUS" = "200" ]; then
  echo "✅ Collection 'points' existe déjà"
else
  echo "   Création de la collection 'points'..."
  RESULT=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$PB_URL/api/collections" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "points",
      "type": "base",
      "listRule": "",
      "viewRule": "",
      "createRule": "",
      "updateRule": "",
      "deleteRule": "",
      "fields": [
        {
          "name": "name",
          "type": "text",
          "required": true
        },
        {
          "name": "latitude",
          "type": "number",
          "required": true
        },
        {
          "name": "longitude",
          "type": "number",
          "required": true
        }
      ]
    }')

  if [ "$RESULT" = "200" ]; then
    echo "✅ Collection 'points' créée avec succès"
  else
    echo "❌ Erreur lors de la création de la collection (HTTP $RESULT)"
    kill $PB_PID 2>/dev/null
    exit 1
  fi
fi

# 9. Vérifier que tout fonctionne
echo ""
HEALTH=$(curl -s "$PB_URL/api/collections/points/records" | python3 -c "import sys,json; d=json.load(sys.stdin); print('OK' if 'items' in d else 'FAIL')" 2>/dev/null)
if [ "$HEALTH" = "OK" ]; then
  echo "✅ API points accessible publiquement"
else
  echo "❌ La collection n'est pas accessible. Vérifiez les API Rules."
fi

echo ""
echo "=== Installation terminée ==="
echo ""
echo "Pour lancer l'app :"
echo "  flutter run"
echo ""
echo "PocketBase tourne en arrière-plan (PID: $PB_PID)"
echo "Pour l'arrêter : kill $PB_PID"
