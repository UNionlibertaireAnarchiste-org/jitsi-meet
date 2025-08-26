#!/bin/bash
# Script de personnalisation Jitsi Meet → LiberChat Vidéo
# Version shell simplifiée
# Auteur: Assistant IA

set -e

# Configuration
JITSI_DIR="${1:-./jitsi-meet}"
YUNOHOST_DIR="${2:-./jitsi_ynh}"
LOGO_URL="images/liberchat-logo.png"
BACKUP_DIR="./backup-$(date +%Y%m%d-%H%M%S)"

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

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    if [ ! -d "$JITSI_DIR" ]; then
        log_error "Répertoire Jitsi Meet non trouvé: $JITSI_DIR"
        exit 1
    fi
    
    if [ ! -d "$YUNOHOST_DIR" ]; then
        log_error "Répertoire YunoHost non trouvé: $YUNOHOST_DIR"
        exit 1
    fi
    
    # Vérifier les outils nécessaires
    for tool in sed grep find; do
        if ! command -v $tool &> /dev/null; then
            log_error "Outil requis non trouvé: $tool"
            exit 1
        fi
    done
    
    log_success "Prérequis vérifiés"
}

# Créer une sauvegarde
create_backup() {
    log_info "Création du backup dans $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    cp -r "$JITSI_DIR" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$YUNOHOST_DIR" "$BACKUP_DIR/" 2>/dev/null || true
    log_success "Backup créé"
}

# Fonction pour remplacer du texte dans un fichier
replace_in_file() {
    local file="$1"
    local old_text="$2"
    local new_text="$3"
    local description="$4"
    
    if [ ! -f "$file" ]; then
        log_warning "Fichier non trouvé: $file"
        return 1
    fi
    
    # Créer une sauvegarde du fichier
    cp "$file" "$file.backup" 2>/dev/null || true
    
    # Effectuer le remplacement
    if grep -q "$old_text" "$file"; then
        sed -i "s|$old_text|$new_text|g" "$file"
        log_success "Modifié: $file ${description:+($description)}"
        return 0
    else
        log_warning "Texte non trouvé dans $file: $old_text"
        return 1
    fi
}

# Créer le fichier CSS personnalisé
create_custom_css() {
    log_info "Création du CSS personnalisé..."
    
    local css_dir="$JITSI_DIR/css"
    mkdir -p "$css_dir"
    
    cat > "$css_dir/custom.css" << 'EOF'
/* LiberChat Vidéo - Thème personnalisé Rouge/Noir */

:root {
    --primary-color: #8B0000;
    --secondary-color: #000000;
    --accent-color: #FF0000;
}

/* Couleurs principales */
.toolbox-background {
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
}

.header {
    background-color: var(--secondary-color);
}

/* Boutons */
.toolbox-button {
    background-color: var(--primary-color);
    border: 1px solid var(--accent-color);
}

.toolbox-button:hover {
    background-color: var(--accent-color);
}

/* Interface de chat */
.chat-container {
    background-color: rgba(0, 0, 0, 0.8);
    border-left: 3px solid var(--accent-color);
}

/* Participants */
.participant-container {
    border: 2px solid var(--primary-color);
}

/* Page d'accueil */
.welcome-page {
    background: linear-gradient(135deg, var(--secondary-color), var(--primary-color));
}

.welcome-page .header {
    color: white;
}

/* Notifications */
.notification {
    background-color: var(--primary-color);
    border-left: 4px solid var(--accent-color);
}

/* Barre de progression */
.progress-bar {
    background-color: var(--accent-color);
}

/* Modales */
.modal {
    background-color: rgba(0, 0, 0, 0.9);
}

.modal-content {
    background-color: var(--secondary-color);
    border: 2px solid var(--primary-color);
    color: white;
}
EOF
    
    log_success "CSS personnalisé créé: $css_dir/custom.css"
}

# Modifier interface_config.js
modify_interface_config() {
    log_info "Modification de interface_config.js..."
    
    local config_file="$JITSI_DIR/interface_config.js"
    
    replace_in_file "$config_file" "APP_NAME: 'Jitsi Meet'" "APP_NAME: 'LiberChat Vidéo'" "Nom de l'app"
    replace_in_file "$config_file" "PROVIDER_NAME: 'Jitsi'" "PROVIDER_NAME: 'LiberChat'" "Nom du fournisseur"
    replace_in_file "$config_file" "DEFAULT_WELCOME_PAGE_LOGO_URL: 'images/watermark.svg'" "DEFAULT_WELCOME_PAGE_LOGO_URL: '$LOGO_URL'" "Logo d'accueil"
    replace_in_file "$config_file" "JITSI_WATERMARK_LINK: 'https://jitsi.org'" "JITSI_WATERMARK_LINK: 'https://liberchat.org'" "Lien watermark"
    replace_in_file "$config_file" "SHOW_JITSI_WATERMARK: true" "SHOW_JITSI_WATERMARK: false" "Masquer watermark Jitsi"
    replace_in_file "$config_file" "SHOW_BRAND_WATERMARK: false" "SHOW_BRAND_WATERMARK: true" "Afficher watermark marque"
}

# Modifier package.json
modify_package_json() {
    log_info "Modification de package.json..."
    
    local package_file="$JITSI_DIR/package.json"
    
    replace_in_file "$package_file" '"name": "jitsi-meet"' '"name": "liberchat-video"' "Nom du package"
    replace_in_file "$package_file" '"description": "A sample app for the Jitsi Videobridge"' '"description": "Application de vidéoconférence LiberChat"' "Description"
}

# Modifier les fichiers HTML
modify_html_files() {
    log_info "Modification des fichiers HTML..."
    
    local html_files=("index.html" "base.html" "head.html" "title.html" "body.html" "fonts.html" "plugin.head.html")
    
    for html_file in "${html_files[@]}"; do
        local file_path="$JITSI_DIR/$html_file"
        if [ -f "$file_path" ]; then
            replace_in_file "$file_path" "Jitsi Meet" "LiberChat Vidéo" "Titre"
            replace_in_file "$file_path" "jitsi-meet" "liberchat-video" "Nom technique"
        fi
    done
}

# Modifier le manifest YunoHost
modify_yunohost_manifest() {
    log_info "Modification du manifest YunoHost..."
    
    local manifest_file="$YUNOHOST_DIR/manifest.toml"
    
    replace_in_file "$manifest_file" 'id = "jitsi"' 'id = "liberchat-video"' "ID de l'app"
    replace_in_file "$manifest_file" 'name = "Jitsi Meet"' 'name = "LiberChat Vidéo"' "Nom de l'app"
    replace_in_file "$manifest_file" 'description.en = "Video conferencing web application"' 'description.en = "LiberChat video conferencing application"' "Description EN"
    replace_in_file "$manifest_file" 'description.fr = "Application web de conférence vidéo"' 'description.fr = "Application de vidéoconférence LiberChat"' "Description FR"
    replace_in_file "$manifest_file" 'website = "https://jitsi.org/"' 'website = "https://liberchat.org/"' "Site web"
    replace_in_file "$manifest_file" 'demo = "https://meet.jit.si/"' 'demo = "https://meet.liberchat.org/"' "Démo"
}

# Modifier la configuration nginx
modify_nginx_config() {
    log_info "Modification de la configuration nginx..."
    
    local nginx_file="$YUNOHOST_DIR/conf/nginx.conf"
    
    # Autoriser tous les iframes
    replace_in_file "$nginx_file" 'more_set_headers "Content-Security-Policy: frame-ancestors '\''self'\''";' 'more_set_headers "Content-Security-Policy: frame-ancestors *";' "Autoriser tous les iframes"
    
    # Ajouter des headers personnalisés après la ligne ssi_types
    if grep -q "ssi_types application/x-javascript application/javascript;" "$nginx_file"; then
        sed -i '/ssi_types application\/x-javascript application\/javascript;/a\\n# Headers personnalisés LiberChat\nmore_set_headers "X-Frame-Options: ALLOWALL";\nmore_set_headers "X-Powered-By: LiberChat";' "$nginx_file"
        log_success "Headers personnalisés ajoutés à nginx.conf"
    fi
}

# Modifier les fichiers README
modify_readme_files() {
    log_info "Modification des fichiers README..."
    
    local readme_files=("README.md" "README_fr.md")
    
    for readme_file in "${readme_files[@]}"; do
        # YunoHost README
        local yunohost_readme="$YUNOHOST_DIR/$readme_file"
        if [ -f "$yunohost_readme" ]; then
            replace_in_file "$yunohost_readme" "# Jitsi Meet" "# LiberChat Vidéo" "Titre README"
            replace_in_file "$yunohost_readme" "Jitsi Meet" "LiberChat Vidéo" "Nom dans README"
            replace_in_file "$yunohost_readme" "jitsi-meet" "liberchat-video" "Nom technique README"
        fi
        
        # Jitsi README
        local jitsi_readme="$JITSI_DIR/$readme_file"
        if [ -f "$jitsi_readme" ]; then
            replace_in_file "$jitsi_readme" "# Jitsi Meet" "# LiberChat Vidéo" "Titre README Jitsi"
            replace_in_file "$jitsi_readme" "Jitsi Meet" "LiberChat Vidéo" "Nom dans README Jitsi"
        fi
    done
}

# Créer le script de déploiement
create_deployment_script() {
    log_info "Création du script de déploiement..."
    
    cat > "deploy_liberchat.sh" << 'EOF'
#!/bin/bash
# Script de déploiement LiberChat Vidéo
# Généré automatiquement

set -e

echo "🚀 Déploiement de LiberChat Vidéo..."

# Variables
JITSI_DIR="./jitsi-meet"
YUNOHOST_DIR="./jitsi_ynh"
BACKUP_DIR="./backup-$(date +%Y%m%d-%H%M%S)"

# Créer un backup
echo "📦 Création du backup..."
mkdir -p "$BACKUP_DIR"
cp -r "$JITSI_DIR" "$BACKUP_DIR/" 2>/dev/null || true
cp -r "$YUNOHOST_DIR" "$BACKUP_DIR/" 2>/dev/null || true

# Construire Jitsi Meet
echo "🔨 Construction de Jitsi Meet..."
cd "$JITSI_DIR"
if [ -f "package.json" ]; then
    npm install
    npm run build
fi
cd ..

# Empaqueter pour YunoHost
echo "📦 Empaquetage YunoHost..."
cd "$YUNOHOST_DIR"
# Commandes spécifiques à YunoHost si nécessaire

echo "✅ Déploiement terminé!"
echo "📁 Backup disponible dans: $BACKUP_DIR"
EOF
    
    chmod +x "deploy_liberchat.sh"
    log_success "Script de déploiement créé: deploy_liberchat.sh"
}

# Générer le rapport
generate_report() {
    log_info "Génération du rapport..."
    
    local report_file="rapport_modifications_liberchat.md"
    
    cat > "$report_file" << EOF
# Rapport de personnalisation LiberChat Vidéo
Généré le: $(date '+%Y-%m-%d %H:%M:%S')

## Résumé
- **Répertoire Jitsi Meet**: $JITSI_DIR
- **Répertoire YunoHost**: $YUNOHOST_DIR
- **Backup**: $BACKUP_DIR

## Modifications appliquées

### 1. Thème CSS personnalisé
- Fichier créé: \`$JITSI_DIR/css/custom.css\`
- Couleurs: Rouge (#8B0000), Noir (#000000), Rouge vif (#FF0000)

### 2. Configuration interface
- APP_NAME: "Jitsi Meet" → "LiberChat Vidéo"
- PROVIDER_NAME: "Jitsi" → "LiberChat"
- Logo: $LOGO_URL

### 3. Fichiers modifiés
- interface_config.js
- package.json
- Fichiers HTML (index.html, base.html, etc.)
- manifest.toml (YunoHost)
- nginx.conf
- README.md

### 4. Configuration nginx
- frame-ancestors: * (autorise tous les iframes)
- Headers personnalisés ajoutés

## Fichiers de sauvegarde
Tous les fichiers modifiés ont été sauvegardés avec l'extension \`.backup\`

## Prochaines étapes
1. Tester les modifications localement
2. Construire l'application avec \`npm run build\`
3. Déployer avec le script \`./deploy_liberchat.sh\`
4. Vérifier le fonctionnement sur YunoHost

## Restauration
Pour restaurer les fichiers originaux:
\`\`\`bash
find . -name "*.backup" -exec sh -c 'mv "\$1" "\${1%.backup}"' _ {} \\;
\`\`\`
EOF
    
    log_success "Rapport généré: $report_file"
}

# Fonction principale
main() {
    echo "🎨 Personnalisation Jitsi Meet → LiberChat Vidéo"
    echo "=================================================="
    
    check_prerequisites
    create_backup
    
    echo ""
    log_info "Début des modifications..."
    
    create_custom_css
    modify_interface_config
    modify_package_json
    modify_html_files
    modify_yunohost_manifest
    modify_nginx_config
    modify_readme_files
    create_deployment_script
    generate_report
    
    echo ""
    echo "=================================================="
    log_success "🎉 Personnalisation terminée avec succès!"
    echo ""
    echo "📋 Prochaines étapes:"
    echo "1. Vérifiez le rapport: rapport_modifications_liberchat.md"
    echo "2. Testez les changements localement"
    echo "3. Exécutez ./deploy_liberchat.sh pour déployer"
    echo "4. Backup disponible dans: $BACKUP_DIR"
}

# Afficher l'aide
show_help() {
    cat << EOF
Usage: $0 [JITSI_DIR] [YUNOHOST_DIR]

Personnalise automatiquement Jitsi Meet et YunoHost pour LiberChat Vidéo.

Arguments:
  JITSI_DIR     Chemin vers le répertoire Jitsi Meet (défaut: ./jitsi-meet)
  YUNOHOST_DIR  Chemin vers le répertoire YunoHost (défaut: ./jitsi_ynh)

Options:
  -h, --help    Affiche cette aide

Exemples:
  $0                                    # Utilise les répertoires par défaut
  $0 /path/to/jitsi-meet /path/to/jitsi_ynh
  
Le script applique automatiquement:
- Thème rouge/noir personnalisé
- Logo LiberChat
- Renommage "Jitsi Meet" → "LiberChat Vidéo"
- Configuration nginx pour iframes
- Modifications YunoHost

Tous les fichiers originaux sont sauvegardés avec l'extension .backup
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