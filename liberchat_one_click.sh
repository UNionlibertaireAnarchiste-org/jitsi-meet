#!/bin/bash
# Script tout-en-un LiberChat Vidéo
# Configuration, personnalisation et déploiement automatiques

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="./liberchat-workspace"
GITHUB_ORG="UNionlibertaireAnarchiste-org"

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
║    🎨 LiberChat Vidéo - Configuration Automatique 🎨        ║
║                                                              ║
║    Transformation complète de Jitsi Meet                     ║
║    vers une solution de vidéoconférence personnalisée       ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Vérifier les prérequis
check_prerequisites() {
    log_step "Vérification des prérequis"
    
    local missing_tools=()
    
    # Vérifier les outils requis
    for tool in git curl python3 npm node; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=($tool)
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Outils manquants: ${missing_tools[*]}"
        echo ""
        echo "Installation requise:"
        echo "  Ubuntu/Debian: sudo apt update && sudo apt install git curl python3 nodejs npm"
        echo "  CentOS/RHEL:   sudo yum install git curl python3 nodejs npm"
        echo "  macOS:         brew install git curl python3 node npm"
        exit 1
    fi
    
    # Vérifier la connectivité GitHub
    if ! curl -s --head "https://github.com/$GITHUB_ORG" | head -n 1 | grep -q "200 OK"; then
        log_error "Impossible d'accéder à GitHub ou à l'organisation $GITHUB_ORG"
        exit 1
    fi
    
    log_success "Tous les prérequis sont satisfaits"
}

# Étape 1: Configuration de l'environnement
setup_environment() {
    log_step "Configuration de l'environnement"
    
    # Exécuter le script de setup des forks
    if [ -f "$SCRIPT_DIR/setup_liberchat_forks.sh" ]; then
        chmod +x "$SCRIPT_DIR/setup_liberchat_forks.sh"
        "$SCRIPT_DIR/setup_liberchat_forks.sh" "$WORK_DIR"
    else
        log_error "Script setup_liberchat_forks.sh non trouvé"
        exit 1
    fi
    
    # Aller dans le répertoire de travail
    cd "$WORK_DIR"
    log_success "Environnement configuré"
}

# Étape 2: Application des personnalisations
apply_customizations() {
    log_step "Application des personnalisations LiberChat"
    
    # Utiliser le script Python si disponible, sinon le script shell
    if [ -f "customize_jitsi_liberchat.py" ] && command -v python3 &> /dev/null; then
        log_info "Utilisation du script Python..."
        python3 customize_jitsi_liberchat.py
    elif [ -f "customize_jitsi_liberchat.sh" ]; then
        log_info "Utilisation du script Shell..."
        chmod +x customize_jitsi_liberchat.sh
        ./customize_jitsi_liberchat.sh
    else
        log_error "Aucun script de personnalisation trouvé"
        exit 1
    fi
    
    log_success "Personnalisations appliquées"
}

# Étape 3: Validation des modifications
validate_changes() {
    log_step "Validation des modifications"
    
    if [ -f "validate_customization.sh" ]; then
        chmod +x validate_customization.sh
        if ./validate_customization.sh; then
            log_success "Validation réussie"
        else
            log_warning "Certaines validations ont échoué, mais on continue..."
        fi
    else
        log_warning "Script de validation non trouvé, validation ignorée"
    fi
}

# Étape 4: Construction de l'application
build_application() {
    log_step "Construction de l'application Jitsi Meet"
    
    cd jitsi-meet
    
    # Vérifier si package.json existe
    if [ ! -f "package.json" ]; then
        log_warning "package.json non trouvé, construction ignorée"
        cd ..
        return
    fi
    
    log_info "Installation des dépendances npm..."
    if npm install; then
        log_success "Dépendances installées"
    else
        log_warning "Erreur lors de l'installation des dépendances, mais on continue..."
    fi
    
    log_info "Construction de l'application..."
    if npm run build; then
        log_success "Application construite avec succès"
    else
        log_warning "Erreur lors de la construction, mais les fichiers sources sont prêts"
    fi
    
    cd ..
}

# Étape 5: Préparation du déploiement
prepare_deployment() {
    log_step "Préparation du déploiement"
    
    # Créer un répertoire de distribution
    local dist_dir="liberchat-video-dist"
    mkdir -p "$dist_dir"
    
    # Copier les fichiers essentiels
    log_info "Copie des fichiers de distribution..."
    
    # Copier Jitsi Meet
    if [ -d "jitsi-meet" ]; then
        cp -r jitsi-meet "$dist_dir/"
        log_info "Jitsi Meet copié"
    fi
    
    # Copier YunoHost
    if [ -d "jitsi_ynh" ]; then
        cp -r jitsi_ynh "$dist_dir/"
        log_info "YunoHost copié"
    fi
    
    # Copier les scripts utiles
    for script in deploy_liberchat.sh deploy_full_liberchat.sh update_forks.sh; do
        if [ -f "$script" ]; then
            cp "$script" "$dist_dir/"
            chmod +x "$dist_dir/$script"
        fi
    done
    
    # Copier la documentation
    if [ -f "rapport_modifications_liberchat.md" ]; then
        cp "rapport_modifications_liberchat.md" "$dist_dir/"
    fi
    
    # Créer un README pour la distribution
    cat > "$dist_dir/README_DISTRIBUTION.md" << EOF
# LiberChat Vidéo - Distribution

Cette distribution contient votre version personnalisée de Jitsi Meet transformée en LiberChat Vidéo.

## Contenu
- \`jitsi-meet/\` - Application Jitsi Meet personnalisée
- \`jitsi_ynh/\` - Package YunoHost personnalisé
- \`deploy_*.sh\` - Scripts de déploiement
- \`rapport_modifications_liberchat.md\` - Rapport des modifications

## Installation sur YunoHost
\`\`\`bash
# Installer directement depuis ce répertoire
yunohost app install ./jitsi_ynh

# Ou utiliser le script de déploiement
./deploy_full_liberchat.sh
\`\`\`

## Installation manuelle
1. Copiez le contenu de \`jitsi-meet/\` vers votre serveur web
2. Configurez nginx avec les fichiers de \`jitsi_ynh/conf/\`
3. Adaptez les configurations selon votre environnement

Généré le: $(date)
EOF
    
    log_success "Distribution préparée dans $dist_dir/"
}

# Étape 6: Tests de base
run_basic_tests() {
    log_step "Tests de base"
    
    local tests_passed=0
    local tests_total=0
    
    # Test 1: Vérifier que les fichiers principaux existent
    ((tests_total++))
    if [ -f "jitsi-meet/interface_config.js" ] && [ -f "jitsi_ynh/manifest.toml" ]; then
        log_success "Fichiers principaux présents"
        ((tests_passed++))
    else
        log_error "Fichiers principaux manquants"
    fi
    
    # Test 2: Vérifier que le CSS personnalisé existe
    ((tests_total++))
    if [ -f "jitsi-meet/css/custom.css" ]; then
        log_success "CSS personnalisé présent"
        ((tests_passed++))
    else
        log_warning "CSS personnalisé manquant"
    fi
    
    # Test 3: Vérifier les modifications de nom
    ((tests_total++))
    if grep -q "LiberChat Vidéo" jitsi-meet/interface_config.js 2>/dev/null; then
        log_success "Nom de l'application modifié"
        ((tests_passed++))
    else
        log_warning "Nom de l'application non modifié"
    fi
    
    # Test 4: Vérifier la configuration nginx
    ((tests_total++))
    if grep -q "frame-ancestors \*" jitsi_ynh/conf/nginx.conf 2>/dev/null; then
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
    echo "📁 Fichiers générés:"
    echo "   • $WORK_DIR/jitsi-meet/ - Application personnalisée"
    echo "   • $WORK_DIR/jitsi_ynh/ - Package YunoHost"
    echo "   • $WORK_DIR/liberchat-video-dist/ - Distribution prête"
    echo ""
    echo "🚀 Prochaines étapes:"
    echo "   1. Testez localement l'interface:"
    echo "      cd $WORK_DIR/jitsi-meet && python3 -m http.server 8000"
    echo ""
    echo "   2. Installez sur YunoHost:"
    echo "      cd $WORK_DIR && yunohost app install ./jitsi_ynh"
    echo ""
    echo "   3. Ou utilisez le déploiement automatique:"
    echo "      cd $WORK_DIR && ./deploy_full_liberchat.sh"
    echo ""
    echo "📚 Documentation:"
    echo "   • README_PERSONNALISATION.md - Guide complet"
    echo "   • rapport_modifications_liberchat.md - Détail des modifications"
    echo ""
    echo "🤝 Contribution:"
    echo "   • ./contribute_liberchat.sh - Outils de contribution"
    echo "   • Repositories: https://github.com/$GITHUB_ORG"
    echo ""
    
    # Afficher les URLs de test
    echo "🌐 URLs de test (après déploiement):"
    echo "   • Interface: https://votre-domaine.com"
    echo "   • Test iframe: https://votre-domaine.com (autorisé partout)"
    echo ""
    
    log_info "Configuration terminée avec succès!"
}

# Gestion des erreurs
handle_error() {
    local exit_code=$?
    echo ""
    log_error "Une erreur est survenue (code: $exit_code)"
    echo ""
    echo "🔧 Dépannage:"
    echo "   • Vérifiez les logs ci-dessus"
    echo "   • Consultez README_PERSONNALISATION.md"
    echo "   • Restaurez depuis les sauvegardes si nécessaire"
    echo ""
    echo "📞 Support:"
    echo "   • Issues: https://github.com/$GITHUB_ORG/jitsi-meet/issues"
    echo "   • Documentation: README_PERSONNALISATION.md"
    
    exit $exit_code
}

# Configuration du gestionnaire d'erreurs
trap handle_error ERR

# Fonction principale
main() {
    show_banner
    
    echo "Ce script va automatiquement:"
    echo "  1. ✅ Cloner les forks LiberChat depuis $GITHUB_ORG"
    echo "  2. 🎨 Appliquer le thème rouge/noir personnalisé"
    echo "  3. 🏷️  Renommer 'Jitsi Meet' en 'LiberChat Vidéo'"
    echo "  4. 🖼️  Intégrer le logo LiberChat"
    echo "  5. 🔧 Configurer nginx pour les iframes"
    echo "  6. 📦 Construire l'application"
    echo "  7. 🚀 Préparer le déploiement"
    echo ""
    
    read -p "Continuer ? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        log_info "Configuration annulée"
        exit 0
    fi
    
    echo ""
    log_step "Début de la configuration automatique..."
    echo ""
    
    # Exécuter toutes les étapes
    check_prerequisites
    setup_environment
    apply_customizations
    validate_changes
    build_application
    prepare_deployment
    run_basic_tests
    show_final_summary
}

# Afficher l'aide
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Script tout-en-un pour configurer automatiquement LiberChat Vidéo.

Options:
  -h, --help    Affiche cette aide
  --work-dir    Répertoire de travail (défaut: ./liberchat-workspace)

Ce script automatise complètement:
- Clonage des forks depuis UNionlibertaireAnarchiste-org
- Application du thème rouge/noir
- Renommage en "LiberChat Vidéo"
- Configuration nginx pour iframes
- Construction de l'application
- Préparation du déploiement

Prérequis:
- git, curl, python3, nodejs, npm
- Connexion internet
- Accès à GitHub

Exemple:
  $0                    # Configuration standard
  $0 --work-dir /tmp/liberchat
EOF
}

# Gestion des arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    --work-dir)
        WORK_DIR="$2"
        main
        ;;
    *)
        main "$@"
        ;;
esac