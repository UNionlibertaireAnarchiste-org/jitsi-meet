#!/bin/bash
# Script de configuration des forks LiberChat
# Clone et configure automatiquement les forks depuis UNionlibertaireAnarchiste-org

set -e

# Configuration
GITHUB_ORG="UNionlibertaireAnarchiste-org"
JITSI_REPO="jitsi-meet"
YUNOHOST_REPO="jitsi_ynh"
WORK_DIR="${1:-./liberchat-workspace}"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions utilitaires
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

# Vérifier les prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier git
    if ! command -v git &> /dev/null; then
        log_error "Git n'est pas installé"
        exit 1
    fi
    
    # Vérifier la connectivité GitHub
    if ! git ls-remote "https://github.com/$GITHUB_ORG/$JITSI_REPO.git" &> /dev/null; then
        log_error "Impossible d'accéder au repository $GITHUB_ORG/$JITSI_REPO"
        exit 1
    fi
    
    if ! git ls-remote "https://github.com/$GITHUB_ORG/$YUNOHOST_REPO.git" &> /dev/null; then
        log_error "Impossible d'accéder au repository $GITHUB_ORG/$YUNOHOST_REPO"
        exit 1
    fi
    
    log_success "Prérequis vérifiés"
}

# Créer le répertoire de travail
setup_workspace() {
    log_info "Configuration de l'espace de travail: $WORK_DIR"
    
    if [ -d "$WORK_DIR" ]; then
        log_warning "Le répertoire $WORK_DIR existe déjà"
        read -p "Voulez-vous le supprimer et recommencer ? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$WORK_DIR"
            log_info "Répertoire supprimé"
        else
            log_info "Utilisation du répertoire existant"
        fi
    fi
    
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
    log_success "Espace de travail configuré"
}

# Cloner les repositories
clone_repositories() {
    log_info "Clonage des repositories..."
    
    # Cloner Jitsi Meet
    if [ ! -d "jitsi-meet" ]; then
        log_info "Clonage de $GITHUB_ORG/$JITSI_REPO..."
        git clone "https://github.com/$GITHUB_ORG/$JITSI_REPO.git" jitsi-meet
        log_success "Jitsi Meet cloné"
    else
        log_info "Mise à jour de jitsi-meet..."
        cd jitsi-meet
        git pull origin main || git pull origin master
        cd ..
        log_success "Jitsi Meet mis à jour"
    fi
    
    # Cloner YunoHost
    if [ ! -d "jitsi_ynh" ]; then
        log_info "Clonage de $GITHUB_ORG/$YUNOHOST_REPO..."
        git clone "https://github.com/$GITHUB_ORG/$YUNOHOST_REPO.git" jitsi_ynh
        log_success "YunoHost cloné"
    else
        log_info "Mise à jour de jitsi_ynh..."
        cd jitsi_ynh
        git pull origin main || git pull origin master
        cd ..
        log_success "YunoHost mis à jour"
    fi
}

# Copier les scripts de personnalisation
copy_customization_scripts() {
    log_info "Copie des scripts de personnalisation..."
    
    # Copier les scripts depuis le répertoire parent
    local script_dir="$(dirname "$(realpath "$0")")"
    
    for script in "customize_jitsi_liberchat.py" "customize_jitsi_liberchat.sh" "validate_customization.sh" "README_PERSONNALISATION.md"; do
        if [ -f "$script_dir/$script" ]; then
            cp "$script_dir/$script" .
            chmod +x "$script" 2>/dev/null || true
            log_success "Script copié: $script"
        else
            log_warning "Script non trouvé: $script"
        fi
    done
}

# Créer le logo LiberChat si nécessaire
create_logo() {
    log_info "Configuration du logo LiberChat..."
    
    local logo_dir="jitsi-meet/images"
    mkdir -p "$logo_dir"
    
    # Télécharger le logo depuis une source fiable ou créer un placeholder
    if command -v curl &> /dev/null; then
        # Essayer de télécharger depuis plusieurs sources
        local logo_urls=(
            "https://raw.githubusercontent.com/UNionlibertaireAnarchiste-org/jitsi-meet/main/images/liberchat-logo.png"
            "https://raw.githubusercontent.com/Liberchat/Liberchat/main/icon.png"
            "https://avatars.githubusercontent.com/u/UNionlibertaireAnarchiste-org"
        )
        
        for url in "${logo_urls[@]}"; do
            if curl -s --head "$url" | head -n 1 | grep -q "200 OK"; then
                curl -s "$url" -o "$logo_dir/liberchat-logo.png"
                log_success "Logo téléchargé depuis: $url"
                return 0
            fi
        done
        
        log_warning "Impossible de télécharger le logo, création d'un placeholder"
    fi
    
    # Créer un fichier placeholder SVG
    cat > "$logo_dir/liberchat-logo.svg" << 'EOF'
<svg width="120" height="40" xmlns="http://www.w3.org/2000/svg">
  <rect width="120" height="40" fill="#8B0000"/>
  <text x="60" y="25" font-family="Arial, sans-serif" font-size="12" fill="white" text-anchor="middle">LiberChat</text>
</svg>
EOF
    
    log_success "Logo placeholder créé"
}

# Configurer les remotes Git pour contribution
setup_git_remotes() {
    log_info "Configuration des remotes Git..."
    
    cd jitsi-meet
    if ! git remote | grep -q "upstream"; then
        git remote add upstream https://github.com/jitsi/jitsi-meet.git
        log_success "Remote upstream ajouté pour jitsi-meet"
    fi
    cd ..
    
    cd jitsi_ynh
    if ! git remote | grep -q "upstream"; then
        git remote add upstream https://github.com/YunoHost-Apps/jitsi_ynh.git
        log_success "Remote upstream ajouté pour jitsi_ynh"
    fi
    cd ..
}

# Créer un script de mise à jour
create_update_script() {
    log_info "Création du script de mise à jour..."
    
    cat > "update_forks.sh" << 'EOF'
#!/bin/bash
# Script de mise à jour des forks LiberChat

set -e

echo "🔄 Mise à jour des forks LiberChat..."

# Mise à jour Jitsi Meet
echo "📥 Mise à jour jitsi-meet..."
cd jitsi-meet
git fetch origin
git pull origin main || git pull origin master
git fetch upstream || echo "⚠️  Impossible de récupérer upstream jitsi-meet"
cd ..

# Mise à jour YunoHost
echo "📥 Mise à jour jitsi_ynh..."
cd jitsi_ynh
git fetch origin
git pull origin main || git pull origin master
git fetch upstream || echo "⚠️  Impossible de récupérer upstream jitsi_ynh"
cd ..

echo "✅ Mise à jour terminée!"
echo "💡 N'oubliez pas de relancer la personnalisation si nécessaire"
EOF
    
    chmod +x "update_forks.sh"
    log_success "Script de mise à jour créé: update_forks.sh"
}

# Créer un script de déploiement complet
create_full_deployment_script() {
    log_info "Création du script de déploiement complet..."
    
    cat > "deploy_full_liberchat.sh" << 'EOF'
#!/bin/bash
# Script de déploiement complet LiberChat Vidéo

set -e

echo "🚀 Déploiement complet LiberChat Vidéo"
echo "====================================="

# 1. Mise à jour des forks
echo "1️⃣ Mise à jour des repositories..."
./update_forks.sh

# 2. Application des personnalisations
echo "2️⃣ Application des personnalisations..."
if [ -f "customize_jitsi_liberchat.py" ]; then
    python3 customize_jitsi_liberchat.py
elif [ -f "customize_jitsi_liberchat.sh" ]; then
    ./customize_jitsi_liberchat.sh
else
    echo "❌ Aucun script de personnalisation trouvé"
    exit 1
fi

# 3. Validation
echo "3️⃣ Validation des modifications..."
if [ -f "validate_customization.sh" ]; then
    ./validate_customization.sh
fi

# 4. Construction
echo "4️⃣ Construction de l'application..."
cd jitsi-meet
if [ -f "package.json" ]; then
    echo "📦 Installation des dépendances..."
    npm install
    echo "🔨 Construction..."
    npm run build
fi
cd ..

# 5. Préparation du package YunoHost
echo "5️⃣ Préparation du package YunoHost..."
cd jitsi_ynh
# Ici vous pouvez ajouter des commandes spécifiques pour YunoHost
echo "📋 Package YunoHost prêt"
cd ..

echo ""
echo "✅ Déploiement complet terminé!"
echo "📁 Votre LiberChat Vidéo est prêt à être installé"
echo ""
echo "📋 Prochaines étapes:"
echo "   • Testez localement l'interface"
echo "   • Installez sur YunoHost: yunohost app install ./jitsi_ynh"
echo "   • Configurez votre domaine et certificats"
EOF
    
    chmod +x "deploy_full_liberchat.sh"
    log_success "Script de déploiement complet créé: deploy_full_liberchat.sh"
}

# Afficher les informations finales
show_final_info() {
    echo ""
    echo "🎉 Configuration terminée avec succès!"
    echo "======================================"
    echo ""
    echo "📁 Structure créée:"
    echo "   $WORK_DIR/"
    echo "   ├── jitsi-meet/                    # Fork Jitsi Meet personnalisé"
    echo "   ├── jitsi_ynh/                     # Fork YunoHost personnalisé"
    echo "   ├── customize_jitsi_liberchat.py   # Script de personnalisation Python"
    echo "   ├── customize_jitsi_liberchat.sh   # Script de personnalisation Shell"
    echo "   ├── validate_customization.sh      # Script de validation"
    echo "   ├── update_forks.sh                # Script de mise à jour"
    echo "   ├── deploy_full_liberchat.sh       # Script de déploiement complet"
    echo "   └── README_PERSONNALISATION.md     # Documentation"
    echo ""
    echo "🚀 Commandes disponibles:"
    echo "   ./customize_jitsi_liberchat.sh     # Appliquer les personnalisations"
    echo "   ./validate_customization.sh        # Valider les modifications"
    echo "   ./update_forks.sh                  # Mettre à jour les forks"
    echo "   ./deploy_full_liberchat.sh         # Déploiement complet"
    echo ""
    echo "📋 Prochaines étapes recommandées:"
    echo "   1. cd $WORK_DIR"
    echo "   2. ./customize_jitsi_liberchat.sh"
    echo "   3. ./validate_customization.sh"
    echo "   4. ./deploy_full_liberchat.sh"
    echo ""
    echo "📚 Documentation: README_PERSONNALISATION.md"
}

# Fonction principale
main() {
    echo "🎨 Configuration des forks LiberChat Vidéo"
    echo "=========================================="
    echo "Organisation: $GITHUB_ORG"
    echo "Jitsi Meet: https://github.com/$GITHUB_ORG/$JITSI_REPO"
    echo "YunoHost: https://github.com/$GITHUB_ORG/$YUNOHOST_REPO"
    echo "Répertoire: $WORK_DIR"
    echo ""
    
    check_prerequisites
    setup_workspace
    clone_repositories
    copy_customization_scripts
    create_logo
    setup_git_remotes
    create_update_script
    create_full_deployment_script
    show_final_info
}

# Afficher l'aide
show_help() {
    cat << EOF
Usage: $0 [WORK_DIR]

Configure automatiquement les forks LiberChat depuis UNionlibertaireAnarchiste-org.

Arguments:
  WORK_DIR      Répertoire de travail (défaut: ./liberchat-workspace)

Options:
  -h, --help    Affiche cette aide

Ce script:
- Clone les forks jitsi-meet et jitsi_ynh
- Configure les remotes Git
- Copie les scripts de personnalisation
- Crée les scripts de mise à jour et déploiement
- Prépare l'environnement complet

Repositories clonés:
- https://github.com/UNionlibertaireAnarchiste-org/jitsi-meet
- https://github.com/UNionlibertaireAnarchiste-org/jitsi_ynh
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