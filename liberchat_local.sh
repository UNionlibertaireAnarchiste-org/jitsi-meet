#!/bin/bash
# Script LiberChat Vidéo pour répertoires locaux existants
# Utilise les forks déjà clonés localement

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JITSI_DIR="${1:-./jitsi-meet}"
YUNOHOST_DIR="${2:-./jitsi_ynh}"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fonctions utilitaires
log_step() {
    echo -e "${PURPLE}🔄 $1${NC}"
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Afficher le banner
show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    🎨 LiberChat Vidéo - Configuration Locale 🎨             ║
║                                                              ║
║    Transformation de vos forks locaux                       ║
║    vers LiberChat Vidéo personnalisé                        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Vérifier les prérequis
check_prerequisites() {
    log_step "Vérification des prérequis"
    
    # Vérifier que les répertoires existent
    if [ ! -d "$JITSI_DIR" ]; then
        log_error "Répertoire Jitsi Meet non trouvé: $JITSI_DIR"
        echo "💡 Assurez-vous que le répertoire existe ou spécifiez le bon chemin:"
        echo "   $0 /chemin/vers/jitsi-meet /chemin/vers/jitsi_ynh"
        exit 1
    fi
    
    if [ ! -d "$YUNOHOST_DIR" ]; then
        log_error "Répertoire YunoHost non trouvé: $YUNOHOST_DIR"
        echo "💡 Assurez-vous que le répertoire existe ou spécifiez le bon chemin:"
        echo "   $0 /chemin/vers/jitsi-meet /chemin/vers/jitsi_ynh"
        exit 1
    fi
    
    # Vérifier les outils requis (optionnels pour la personnalisation de base)
    local missing_tools=()
    for tool in python3; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=($tool)
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_warning "Outils manquants (optionnels): ${missing_tools[*]}"
        log_info "Le script shell sera utilisé à la place"
    fi
    
    log_success "Répertoires locaux trouvés"
    log_info "Jitsi Meet: $JITSI_DIR"
    log_info "YunoHost: $YUNOHOST_DIR"
}

# Étape 1: Application des personnalisations
apply_customizations() {
    log_step "Application des personnalisations LiberChat"
    
    # Utiliser le script Python si disponible, sinon le script shell
    if [ -f "$SCRIPT_DIR/customize_jitsi_liberchat.py" ] && command -v python3 &> /dev/null; then
        log_info "Utilisation du script Python..."
        python3 "$SCRIPT_DIR/customize_jitsi_liberchat.py" --jitsi-path "$JITSI_DIR" --yunohost-path "$YUNOHOST_DIR"
    elif [ -f "$SCRIPT_DIR/customize_jitsi_liberchat.sh" ]; then
        log_info "Utilisation du script Shell..."
        "$SCRIPT_DIR/customize_jitsi_liberchat.sh" "$JITSI_DIR" "$YUNOHOST_DIR"
    else
        log_error "Aucun script de personnalisation trouvé"
        exit 1
    fi
    
    log_success "Personnalisations appliquées"
}

# Étape 2: Validation des modifications
validate_changes() {
    log_step "Validation des modifications"
    
    if [ -f "$SCRIPT_DIR/validate_customization.sh" ]; then
        if "$SCRIPT_DIR/validate_customization.sh" "$JITSI_DIR" "$YUNOHOST_DIR"; then
            log_success "Validation réussie"
        else
            log_warning "Certaines validations ont échoué, mais on continue..."
        fi
    else
        log_warning "Script de validation non trouvé, validation ignorée"
    fi
}

# Étape 3: Construction de l'application (optionnelle)
build_application() {
    log_step "Construction de l'application Jitsi Meet"
    
    if [ ! -f "$JITSI_DIR/package.json" ]; then
        log_warning "package.json non trouvé, construction ignorée"
        return
    fi
    
    # Demander si l'utilisateur veut construire
    read -p "Voulez-vous construire l'application npm ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Construction ignorée"
        return
    fi
    
    cd "$JITSI_DIR"
    
    if ! command -v npm &> /dev/null; then
        log_warning "npm non disponible, construction ignorée"
        cd - > /dev/null
        return
    fi
    
    log_info "Installation des dépendances npm..."
    if npm install; then
        log_success "Dépendances installées"
    else
        log_warning "Erreur lors de l'installation des dépendances"
        cd - > /dev/null
        return
    fi
    
    log_info "Construction de l'application..."
    if npm run build; then
        log_success "Application construite avec succès"
    else
        log_warning "Erreur lors de la construction, mais les fichiers sources sont prêts"
    fi
    
    cd - > /dev/null
}

# Étape 4: Créer les scripts de déploiement
create_deployment_scripts() {
    log_step "Création des scripts de déploiement"
    
    # Script de déploiement local
    cat > "deploy_liberchat_local.sh" << EOF
#!/bin/bash
# Script de déploiement LiberChat Vidéo (local)
# Généré automatiquement

set -e

echo "🚀 Déploiement LiberChat Vidéo (local)..."

JITSI_DIR="$JITSI_DIR"
YUNOHOST_DIR="$YUNOHOST_DIR"
BACKUP_DIR="./backup-\$(date +%Y%m%d-%H%M%S)"

# Créer un backup
echo "📦 Création du backup..."
mkdir -p "\$BACKUP_DIR"
cp -r "\$JITSI_DIR" "\$BACKUP_DIR/" 2>/dev/null || true
cp -r "\$YUNOHOST_DIR" "\$BACKUP_DIR/" 2>/dev/null || true

# Construire Jitsi Meet si possible
if [ -f "\$JITSI_DIR/package.json" ] && command -v npm &> /dev/null; then
    echo "🔨 Construction de Jitsi Meet..."
    cd "\$JITSI_DIR"
    npm install
    npm run build
    cd ..
fi

echo "✅ Déploiement local terminé!"
echo "📁 Backup disponible dans: \$BACKUP_DIR"
echo ""
echo "📋 Prochaines étapes:"
echo "   • Testez localement: cd \$JITSI_DIR && python3 -m http.server 8000"
echo "   • Installez sur YunoHost: yunohost app install \$YUNOHOST_DIR"
EOF
    
    chmod +x "deploy_liberchat_local.sh"
    log_success "Script de déploiement local créé: deploy_liberchat_local.sh"
    
    # Script de test local
    cat > "test_liberchat_local.sh" << EOF
#!/bin/bash
# Script de test local LiberChat Vidéo

set -e

JITSI_DIR="$JITSI_DIR"
PORT=\${1:-8000}

echo "🌐 Démarrage du serveur de test local..."
echo "📁 Répertoire: \$JITSI_DIR"
echo "🔗 URL: http://localhost:\$PORT"
echo ""
echo "💡 Ouvrez votre navigateur sur http://localhost:\$PORT"
echo "   Appuyez sur Ctrl+C pour arrêter"
echo ""

cd "\$JITSI_DIR"
python3 -m http.server \$PORT
EOF
    
    chmod +x "test_liberchat_local.sh"
    log_success "Script de test local créé: test_liberchat_local.sh"
}

# Étape 5: Tests de base
run_basic_tests() {
    log_step "Tests de base"
    
    local tests_passed=0
    local tests_total=0
    
    # Test 1: Vérifier que les fichiers principaux existent
    ((tests_total++))
    if [ -f "$JITSI_DIR/interface_config.js" ] && [ -f "$YUNOHOST_DIR/manifest.toml" ]; then
        log_success "Fichiers principaux présents"
        ((tests_passed++))
    else
        log_error "Fichiers principaux manquants"
    fi
    
    # Test 2: Vérifier que le CSS personnalisé existe
    ((tests_total++))
    if [ -f "$JITSI_DIR/css/custom.css" ]; then
        log_success "CSS personnalisé présent"
        ((tests_passed++))
    else
        log_warning "CSS personnalisé manquant"
    fi
    
    # Test 3: Vérifier les modifications de nom
    ((tests_total++))
    if grep -q "LiberChat Vidéo" "$JITSI_DIR/interface_config.js" 2>/dev/null; then
        log_success "Nom de l'application modifié"
        ((tests_passed++))
    else
        log_warning "Nom de l'application non modifié"
    fi
    
    # Test 4: Vérifier la configuration nginx
    ((tests_total++))
    if grep -q "frame-ancestors \*" "$YUNOHOST_DIR/conf/nginx.conf" 2>/dev/null; then
        log_success "Configuration nginx modifiée"
        ((tests_passed++))
    else
        log_warning "Configuration nginx non modifiée"
    fi
    
    echo ""
    log_info "Tests réussis: $tests_passed/$tests_total"
    
    if [ $tests_passed -eq $tests_total ]; then
        log_success "Tous les tests de base sont passés!"
    else
        log_warning "Certains tests ont échoué, vérifiez la configuration"
    fi
}

# Afficher le résumé final
show_final_summary() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    🎉 CONFIGURATION TERMINÉE 🎉             ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    log_success "LiberChat Vidéo est prêt!"
    echo ""
    echo "📁 Répertoires configurés:"
    echo "   • $JITSI_DIR - Application personnalisée"
    echo "   • $YUNOHOST_DIR - Package YunoHost"
    echo ""
    echo "🚀 Scripts créés:"
    echo "   • deploy_liberchat_local.sh - Déploiement local"
    echo "   • test_liberchat_local.sh - Test en local"
    echo ""
    echo "🌐 Test immédiat:"
    echo "   ./test_liberchat_local.sh"
    echo "   Puis ouvrez: http://localhost:8000"
    echo ""
    echo "📦 Installation YunoHost:"
    echo "   yunohost app install $YUNOHOST_DIR"
    echo ""
    echo "📚 Documentation:"
    if [ -f "README_PERSONNALISATION.md" ]; then
        echo "   • README_PERSONNALISATION.md - Guide complet"
    fi
    if [ -f "rapport_modifications_liberchat.md" ]; then
        echo "   • rapport_modifications_liberchat.md - Détail des modifications"
    fi
    echo ""
    
    log_info "Configuration locale terminée avec succès!"
}

# Gestion des erreurs
handle_error() {
    local exit_code=$?
    echo ""
    log_error "Une erreur est survenue (code: $exit_code)"
    echo ""
    echo "🔧 Dépannage:"
    echo "   • Vérifiez que les répertoires existent:"
    echo "     ls -la $JITSI_DIR"
    echo "     ls -la $YUNOHOST_DIR"
    echo "   • Restaurez depuis les sauvegardes .backup si nécessaire"
    echo "   • Consultez la documentation"
    
    exit $exit_code
}

# Configuration du gestionnaire d'erreurs
trap handle_error ERR

# Fonction principale
main() {
    show_banner
    
    echo "Ce script va automatiquement personnaliser vos forks locaux:"
    echo "  1. 🎨 Appliquer le thème rouge/noir personnalisé"
    echo "  2. 🏷️  Renommer 'Jitsi Meet' en 'LiberChat Vidéo'"
    echo "  3. 🖼️  Intégrer le logo LiberChat"
    echo "  4. 🔧 Configurer nginx pour les iframes"
    echo "  5. 📦 Construire l'application (optionnel)"
    echo "  6. 🚀 Créer les scripts de déploiement"
    echo ""
    echo "📁 Répertoires détectés:"
    echo "   • Jitsi Meet: $JITSI_DIR"
    echo "   • YunoHost: $YUNOHOST_DIR"
    echo ""
    
    read -p "Continuer ? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        log_info "Configuration annulée"
        exit 0
    fi
    
    echo ""
    log_step "Début de la configuration locale..."
    echo ""
    
    # Exécuter toutes les étapes
    check_prerequisites
    apply_customizations
    validate_changes
    build_application
    create_deployment_scripts
    run_basic_tests
    show_final_summary
}

# Afficher l'aide
show_help() {
    cat << EOF
Usage: $0 [JITSI_DIR] [YUNOHOST_DIR]

Script de personnalisation LiberChat Vidéo pour répertoires locaux existants.

Arguments:
  JITSI_DIR     Chemin vers le répertoire Jitsi Meet (défaut: ./jitsi-meet)
  YUNOHOST_DIR  Chemin vers le répertoire YunoHost (défaut: ./jitsi_ynh)

Options:
  -h, --help    Affiche cette aide

Ce script personnalise vos forks locaux existants sans avoir besoin de les cloner.

Exemples:
  $0                                    # Utilise ./jitsi-meet et ./jitsi_ynh
  $0 /path/to/jitsi-meet /path/to/jitsi_ynh
  $0 ../jitsi-meet ../jitsi_ynh

Prérequis:
- Répertoires jitsi-meet et jitsi_ynh existants
- python3 (optionnel, utilise le script shell sinon)
EOF
}

# Gestion des arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac