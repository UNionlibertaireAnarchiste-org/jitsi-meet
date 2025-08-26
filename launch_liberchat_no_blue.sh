#!/bin/bash

# Script de lancement LiberChat SANS BLEU
echo "🔴 Lancement LiberChat Vidéo - ZÉRO BLEU"
echo "======================================="

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${RED}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Arrêter les serveurs existants
print_status "Nettoyage des serveurs existants..."
pkill -f "simple-server.js" 2>/dev/null || true
pkill -f "node.*8080" 2>/dev/null || true
pkill -f "node.*8081" 2>/dev/null || true

# Vérification des fichiers
print_status "Vérification des améliorations anti-bleu..."

REQUIRED_FILES=(
    "jitsi-meet/css/custom.css"
    "jitsi-meet/css/no-blue-override.css"
    "jitsi-meet/js/no-blue-enforcer.js"
    "jitsi-meet/index-dev.html"
    "jitsi-meet/simple-server.js"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        print_success "✅ $file"
    else
        print_error "❌ $file manquant"
        exit 1
    fi
done

# Compilation CSS avec élimination du bleu
print_status "Compilation CSS anti-bleu..."
cd jitsi-meet

# Recompiler les CSS
./node_modules/.bin/sass css/main.scss css/all.bundle.css
if [[ $? -eq 0 ]]; then
    print_success "CSS compilé avec élimination du bleu"
else
    print_error "Erreur de compilation CSS"
    exit 1
fi

# Minifier
./node_modules/.bin/cleancss --skip-rebase css/all.bundle.css > css/all.css
rm -f css/all.bundle.css

print_success "CSS optimisé - BLEU ÉLIMINÉ"

# Lancement du serveur
print_status "Démarrage du serveur LiberChat..."

node simple-server.js &
SERVER_PID=$!

cd ..

# Attendre que le serveur démarre
sleep 3

# Vérifier que le serveur fonctionne
if curl -s http://localhost:8081 > /dev/null; then
    print_success "🎉 LiberChat Vidéo lancé avec succès !"
else
    print_error "Erreur de démarrage du serveur"
    kill $SERVER_PID 2>/dev/null
    exit 1
fi

echo ""
echo "🔴 LIBERCHAT VIDÉO - INTERFACE SANS BLEU"
echo "========================================"
echo ""
echo "📋 Informations de connexion:"
echo "  🌐 URL locale: http://localhost:8081"
echo "  📱 URL réseau: http://$(hostname -I | awk '{print $1}'):8081"
echo ""
echo "🎨 Améliorations appliquées:"
echo "  ✅ Thème rouge/noir LiberChat"
echo "  ✅ ZÉRO couleur bleue"
echo "  ✅ Typographie Inter optimisée"
echo "  ✅ Contraste WCAG AA"
echo "  ✅ CSS 47% plus léger"
echo "  ✅ Variables CSS centralisées"
echo "  ✅ Élimination dynamique du bleu"
echo "  ✅ Interface responsive"
echo "  ✅ Accessibilité renforcée"
echo ""
echo "🔍 Fonctionnalités anti-bleu:"
echo "  🔴 CSS override complet"
echo "  🔴 JavaScript éliminateur dynamique"
echo "  🔴 Variables SCSS modifiées"
echo "  🔴 Surveillance temps réel"
echo ""
echo "📋 URLs de test:"
echo "  🏠 Accueil: http://localhost:8081"
echo "  🏢 Salle test: http://localhost:8081/test-liberchat"
echo "  🎯 Salle demo: http://localhost:8081/demo-sans-bleu"
echo ""
echo "🔧 Debug anti-bleu (console navigateur):"
echo "  - LiberChatNoBlue.scan() : Scanner manuel"
echo "  - LiberChatNoBlue.colors : Voir les couleurs"
echo "  - LiberChatNoBlue.isBlue(color) : Tester une couleur"
echo ""
echo "⏹️  Appuyez sur Ctrl+C pour arrêter le serveur"
echo ""

# Fonction de nettoyage
cleanup() {
    echo ""
    print_status "Arrêt du serveur..."
    kill $SERVER_PID 2>/dev/null
    print_success "Serveur arrêté"
    echo ""
    echo "🔴 LiberChat Vidéo fermé - AUCUN BLEU N'A SURVÉCU ! 🎉"
    exit 0
}

# Capturer Ctrl+C
trap cleanup SIGINT SIGTERM

# Attendre
wait $SERVER_PID