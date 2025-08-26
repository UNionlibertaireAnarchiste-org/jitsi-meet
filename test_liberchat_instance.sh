#!/bin/bash

# Script de test pour l'instance LiberChat Vidéo
# Usage: ./test_liberchat_instance.sh [URL]

URL="${1:-https://test.cnt-ait-contact.noho.st/}"
LOGFILE="test_liberchat_$(date +%Y%m%d_%H%M%S).log"

echo "=== TEST LIBERCHAT VIDÉO ===" | tee "$LOGFILE"
echo "URL testée: $URL" | tee -a "$LOGFILE"
echo "Date: $(date)" | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

# Test 1: Connectivité de base
echo "1. Test de connectivité..." | tee -a "$LOGFILE"
if curl -s --head "$URL" | head -n 1 | grep -q "200 OK"; then
    echo "✅ Site accessible" | tee -a "$LOGFILE"
else
    echo "❌ Site non accessible" | tee -a "$LOGFILE"
    exit 1
fi

# Test 2: Vérification du titre LiberChat
echo "" | tee -a "$LOGFILE"
echo "2. Vérification du branding LiberChat..." | tee -a "$LOGFILE"
TITLE=$(curl -s "$URL" | grep -o '<title>[^<]*</title>' | sed 's/<[^>]*>//g')
if echo "$TITLE" | grep -qi "liberchat"; then
    echo "✅ Titre LiberChat détecté: $TITLE" | tee -a "$LOGFILE"
else
    echo "⚠️  Titre: $TITLE" | tee -a "$LOGFILE"
fi

# Test 3: Vérification du CSS personnalisé
echo "" | tee -a "$LOGFILE"
echo "3. Vérification du CSS personnalisé..." | tee -a "$LOGFILE"
if curl -s "$URL" | grep -q "custom.css"; then
    echo "✅ CSS personnalisé détecté" | tee -a "$LOGFILE"
else
    echo "⚠️  CSS personnalisé non détecté" | tee -a "$LOGFILE"
fi

# Test 4: Vérification du logo
echo "" | tee -a "$LOGFILE"
echo "4. Vérification du logo..." | tee -a "$LOGFILE"
if curl -s "$URL" | grep -q "liberchat-logo"; then
    echo "✅ Logo LiberChat détecté" | tee -a "$LOGFILE"
else
    echo "⚠️  Logo LiberChat non détecté" | tee -a "$LOGFILE"
fi

# Test 5: Test des ressources JavaScript
echo "" | tee -a "$LOGFILE"
echo "5. Test des ressources JavaScript..." | tee -a "$LOGFILE"
JS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${URL}libs/lib-jitsi-meet.min.js")
if [ "$JS_STATUS" = "200" ]; then
    echo "✅ Bibliothèques JavaScript accessibles" | tee -a "$LOGFILE"
else
    echo "⚠️  Bibliothèques JavaScript: HTTP $JS_STATUS" | tee -a "$LOGFILE"
fi

# Test 6: Test de l'API Jitsi
echo "" | tee -a "$LOGFILE"
echo "6. Test de l'API Jitsi..." | tee -a "$LOGFILE"
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${URL}config.js")
if [ "$API_STATUS" = "200" ]; then
    echo "✅ Configuration Jitsi accessible" | tee -a "$LOGFILE"
else
    echo "⚠️  Configuration Jitsi: HTTP $API_STATUS" | tee -a "$LOGFILE"
fi

# Test 7: Vérification HTTPS
echo "" | tee -a "$LOGFILE"
echo "7. Vérification HTTPS..." | tee -a "$LOGFILE"
if echo "$URL" | grep -q "https://"; then
    SSL_INFO=$(curl -s -I "$URL" 2>&1 | grep -i "ssl\|tls" || echo "SSL OK")
    echo "✅ HTTPS activé" | tee -a "$LOGFILE"
else
    echo "⚠️  HTTP utilisé (recommandé: HTTPS)" | tee -a "$LOGFILE"
fi

# Test 8: Test de création de salle
echo "" | tee -a "$LOGFILE"
echo "8. Test de création de salle..." | tee -a "$LOGFILE"
ROOM_URL="${URL}TestLiberChat$(date +%H%M%S)"
ROOM_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$ROOM_URL")
if [ "$ROOM_STATUS" = "200" ]; then
    echo "✅ Création de salle fonctionnelle: $ROOM_URL" | tee -a "$LOGFILE"
else
    echo "⚠️  Création de salle: HTTP $ROOM_STATUS" | tee -a "$LOGFILE"
fi

# Résumé
echo "" | tee -a "$LOGFILE"
echo "=== RÉSUMÉ DU TEST ===" | tee -a "$LOGFILE"
echo "Log sauvegardé dans: $LOGFILE" | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

# Recommandations
echo "=== RECOMMANDATIONS ===" | tee -a "$LOGFILE"
echo "1. Testez manuellement une vidéoconférence" | tee -a "$LOGFILE"
echo "2. Vérifiez l'audio/vidéo avec plusieurs participants" | tee -a "$LOGFILE"
echo "3. Testez sur différents navigateurs (Chrome, Firefox, Safari)" | tee -a "$LOGFILE"
echo "4. Vérifiez les fonctionnalités: partage d'écran, chat, etc." | tee -a "$LOGFILE"
echo "5. Testez depuis différents réseaux (mobile, wifi, etc.)" | tee -a "$LOGFILE"

echo "" | tee -a "$LOGFILE"
echo "Test terminé !" | tee -a "$LOGFILE"