#!/bin/bash

# Script de lancement local LiberChat avec améliorations UI
echo "🚀 Lancement de LiberChat Vidéo en local"
echo "========================================"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

# Vérification des prérequis
print_status "Vérification des prérequis..."

if [[ ! -d "jitsi-meet" ]]; then
    print_error "Dossier jitsi-meet non trouvé"
    exit 1
fi

if [[ ! -f "jitsi-meet/package.json" ]]; then
    print_error "package.json non trouvé"
    exit 1
fi

print_success "Prérequis validés"

# Compilation des CSS avec les améliorations
print_status "Compilation des CSS LiberChat..."

cd jitsi-meet

# Compiler les CSS
./node_modules/.bin/sass css/main.scss css/all.bundle.css
if [[ $? -eq 0 ]]; then
    print_success "CSS compilé avec succès"
else
    print_error "Erreur de compilation CSS"
    exit 1
fi

# Minifier les CSS
./node_modules/.bin/cleancss --skip-rebase css/all.bundle.css > css/all.css
rm -f css/all.bundle.css

print_success "CSS optimisé et minifié"

# Préparer les assets nécessaires
print_status "Préparation des assets..."

# Créer le dossier libs s'il n'existe pas
mkdir -p libs

# Copier les assets essentiels
cp node_modules/@jitsi/rnnoise-wasm/dist/rnnoise.wasm libs/ 2>/dev/null || true
cp node_modules/lib-jitsi-meet/dist/umd/lib-jitsi-meet.* libs/ 2>/dev/null || true
cp node_modules/@matrix-org/olm/olm.wasm libs/ 2>/dev/null || true

print_success "Assets préparés"

# Lancement du serveur avec configuration simplifiée
print_status "Démarrage du serveur de développement..."

# Utiliser un serveur HTTP simple avec Python
print_status "Lancement avec serveur HTTP Python..."

# Créer un serveur HTTP simple
cat > server.py << 'EOF'
#!/usr/bin/env python3
import http.server
import socketserver
import os
import webbrowser
from threading import Timer

PORT = 8080

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

def open_browser():
    webbrowser.open(f'http://localhost:{PORT}')

if __name__ == "__main__":
    os.chdir('.')
    
    with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
        print(f"🌐 Serveur démarré sur http://localhost:{PORT}")
        print(f"📁 Répertoire: {os.getcwd()}")
        print("🔥 LiberChat Vidéo avec améliorations UI disponible !")
        print("⏹️  Appuyez sur Ctrl+C pour arrêter")
        
        # Ouvrir le navigateur après 2 secondes
        Timer(2.0, open_browser).start()
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n🛑 Serveur arrêté")
            httpd.shutdown()
EOF

# Lancer le serveur Python
python3 server.py &
SERVER_PID=$!

echo ""
print_success "🎉 LiberChat Vidéo lancé avec succès !"
echo ""
echo "📋 Informations de connexion:"
echo "  🌐 URL locale: http://localhost:8080"
echo "  📱 URL réseau: http://$(hostname -I | awk '{print $1}'):8080"
echo "  🎨 Interface: Améliorations UI appliquées"
echo ""
echo "🔍 Fonctionnalités testables:"
echo "  ✅ Nouvelle typographie Inter"
echo "  ✅ Contraste amélioré"
echo "  ✅ Thème LiberChat rouge/noir"
echo "  ✅ Interface responsive"
echo "  ✅ Accessibilité renforcée"
echo ""
echo "⚠️  Note: Pour une expérience complète, utilisez HTTPS en production"
echo ""

# Attendre l'arrêt
read -p "Appuyez sur Entrée pour arrêter le serveur..." -r

# Arrêter le serveur
kill $SERVER_PID 2>/dev/null
print_success "Serveur arrêté"

cd ..