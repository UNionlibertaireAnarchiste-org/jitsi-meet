#!/bin/bash

# Test rapide de fonctionnalité iframe LiberChat
# Usage: ./quick_iframe_test.sh

TEST_URL="https://test.cnt-ait-contact.noho.st/"
TEST_ROOM="TestRoom123"

echo "🧪 Test rapide LiberChat Iframe"
echo "================================"
echo "URL de test: $TEST_URL"
echo ""

# Test 1: Connectivité de base
echo "1. Test de connectivité..."
if curl -s --head "$TEST_URL" | head -n 1 | grep -q "200 OK"; then
    echo "✅ Serveur accessible"
else
    echo "❌ Serveur non accessible"
    exit 1
fi

# Test 2: Vérifier les en-têtes de sécurité
echo ""
echo "2. Vérification des en-têtes de sécurité..."
HEADERS=$(curl -s -I "$TEST_URL")

if echo "$HEADERS" | grep -qi "X-Frame-Options.*DENY"; then
    echo "⚠️  X-Frame-Options: DENY détecté - iframe bloqué"
elif echo "$HEADERS" | grep -qi "X-Frame-Options.*SAMEORIGIN"; then
    echo "⚠️  X-Frame-Options: SAMEORIGIN - iframe limité"
else
    echo "✅ Pas de restriction X-Frame-Options"
fi

if echo "$HEADERS" | grep -qi "Content-Security-Policy.*frame-ancestors"; then
    echo "ℹ️  CSP frame-ancestors présent"
else
    echo "✅ Pas de restriction CSP frame-ancestors"
fi

# Test 3: Vérifier le contenu LiberChat
echo ""
echo "3. Vérification du branding LiberChat..."
CONTENT=$(curl -s "$TEST_URL")

if echo "$CONTENT" | grep -qi "liberchat"; then
    echo "✅ Branding LiberChat détecté"
else
    echo "⚠️  Branding LiberChat non détecté"
fi

# Test 4: Vérifier la configuration Jitsi
echo ""
echo "4. Vérification de la configuration Jitsi..."
if echo "$CONTENT" | grep -q "config.js" && echo "$CONTENT" | grep -q "interface_config.js"; then
    echo "✅ Configuration Jitsi présente"
else
    echo "❌ Configuration Jitsi manquante"
fi

# Test 5: Test d'une salle spécifique
echo ""
echo "5. Test d'accès à une salle..."
ROOM_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "${TEST_URL}${TEST_ROOM}")
if [ "$ROOM_RESPONSE" = "200" ]; then
    echo "✅ Accès salle de test OK"
else
    echo "⚠️  Code de réponse salle: $ROOM_RESPONSE"
fi

echo ""
echo "📋 Résumé du test:"
echo "   URL testée: $TEST_URL"
echo "   Salle de test: $TEST_ROOM"
echo ""
echo "🔗 Pour test manuel, ouvrez:"
echo "   $TEST_URL$TEST_ROOM"
echo ""
echo "🖼️  Pour test iframe, utilisez:"
echo "   <iframe src=\"$TEST_URL$TEST_ROOM\" allow=\"camera; microphone; fullscreen\"></iframe>"