#!/bin/bash
# Script de validation des modifications LiberChat Vidéo
# Vérifie que toutes les personnalisations ont été appliquées correctement

set -e

# Configuration
JITSI_DIR="${1:-./jitsi-meet}"
YUNOHOST_DIR="${2:-./jitsi_ynh}"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Compteurs
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((TESTS_PASSED++))
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    ((TESTS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Fonction de test générique
test_file_content() {
    local file="$1"
    local expected_content="$2"
    local test_name="$3"
    
    ((TESTS_TOTAL++))
    
    if [ ! -f "$file" ]; then
        log_error "$test_name: Fichier non trouvé - $file"
        return 1
    fi
    
    if grep -q "$expected_content" "$file"; then
        log_success "$test_name: OK"
        return 0
    else
        log_error "$test_name: Contenu non trouvé dans $file"
        return 1
    fi
}

# Tests pour Jitsi Meet
test_jitsi_modifications() {
    log_info "Tests des modifications Jitsi Meet..."
    
    # Test interface_config.js
    test_file_content "$JITSI_DIR/interface_config.js" "APP_NAME: 'LiberChat Vidéo'" "Nom de l'application"
    test_file_content "$JITSI_DIR/interface_config.js" "PROVIDER_NAME: 'LiberChat'" "Nom du fournisseur"
    test_file_content "$JITSI_DIR/interface_config.js" "SHOW_JITSI_WATERMARK: false" "Masquage watermark Jitsi"
    test_file_content "$JITSI_DIR/interface_config.js" "SHOW_BRAND_WATERMARK: true" "Affichage watermark marque"
    
    # Test package.json
    test_file_content "$JITSI_DIR/package.json" '"name": "liberchat-video"' "Nom du package"
    test_file_content "$JITSI_DIR/package.json" '"description": "Application de vidéoconférence LiberChat"' "Description du package"
    
    # Test CSS personnalisé
    ((TESTS_TOTAL++))
    if [ -f "$JITSI_DIR/css/custom.css" ]; then
        log_success "CSS personnalisé: Fichier créé"
        test_file_content "$JITSI_DIR/css/custom.css" "--primary-color: #8B0000" "Couleur primaire CSS"
        test_file_content "$JITSI_DIR/css/custom.css" "--secondary-color: #000000" "Couleur secondaire CSS"
        test_file_content "$JITSI_DIR/css/custom.css" "--accent-color: #FF0000" "Couleur d'accent CSS"
    else
        log_error "CSS personnalisé: Fichier non trouvé"
    fi
    
    # Test fichiers HTML
    local html_files=("index.html" "base.html" "title.html")
    for html_file in "${html_files[@]}"; do
        if [ -f "$JITSI_DIR/$html_file" ]; then
            test_file_content "$JITSI_DIR/$html_file" "LiberChat Vidéo" "HTML: $html_file"
        fi
    done
}

# Tests pour YunoHost
test_yunohost_modifications() {
    log_info "Tests des modifications YunoHost..."
    
    # Test manifest.toml
    test_file_content "$YUNOHOST_DIR/manifest.toml" 'id = "liberchat-video"' "ID de l'application YunoHost"
    test_file_content "$YUNOHOST_DIR/manifest.toml" 'name = "LiberChat Vidéo"' "Nom de l'application YunoHost"
    test_file_content "$YUNOHOST_DIR/manifest.toml" 'description.fr = "Application de vidéoconférence LiberChat"' "Description française"
    
    # Test nginx.conf
    test_file_content "$YUNOHOST_DIR/conf/nginx.conf" 'frame-ancestors \*' "Configuration iframe nginx"
    test_file_content "$YUNOHOST_DIR/conf/nginx.conf" 'X-Powered-By: LiberChat' "Header personnalisé nginx"
    
    # Test README
    if [ -f "$YUNOHOST_DIR/README.md" ]; then
        test_file_content "$YUNOHOST_DIR/README.md" "LiberChat Vidéo" "README YunoHost"
    fi
}

# Tests des fichiers générés
test_generated_files() {
    log_info "Tests des fichiers générés..."
    
    ((TESTS_TOTAL++))
    if [ -f "deploy_liberchat.sh" ]; then
        log_success "Script de déploiement: Créé"
        ((TESTS_TOTAL++))
        if [ -x "deploy_liberchat.sh" ]; then
            log_success "Script de déploiement: Exécutable"
        else
            log_error "Script de déploiement: Non exécutable"
        fi
    else
        log_error "Script de déploiement: Non trouvé"
    fi
    
    ((TESTS_TOTAL++))
    if [ -f "rapport_modifications_liberchat.md" ]; then
        log_success "Rapport de modifications: Créé"
    else
        log_error "Rapport de modifications: Non trouvé"
    fi
}

# Tests des sauvegardes
test_backups() {
    log_info "Tests des sauvegardes..."
    
    local backup_files_found=0
    
    # Chercher les fichiers .backup
    while IFS= read -r -d '' backup_file; do
        ((backup_files_found++))
    done < <(find "$JITSI_DIR" "$YUNOHOST_DIR" -name "*.backup" -print0 2>/dev/null)
    
    ((TESTS_TOTAL++))
    if [ $backup_files_found -gt 0 ]; then
        log_success "Sauvegardes: $backup_files_found fichiers trouvés"
    else
        log_warning "Sauvegardes: Aucun fichier .backup trouvé"
    fi
    
    # Chercher les répertoires de sauvegarde
    ((TESTS_TOTAL++))
    if ls backup-* 1> /dev/null 2>&1; then
        local backup_dirs=$(ls -d backup-* 2>/dev/null | wc -l)
        log_success "Répertoires de sauvegarde: $backup_dirs trouvé(s)"
    else
        log_warning "Répertoires de sauvegarde: Aucun trouvé"
    fi
}

# Test de syntaxe des fichiers modifiés
test_syntax() {
    log_info "Tests de syntaxe..."
    
    # Test JavaScript (interface_config.js)
    ((TESTS_TOTAL++))
    if command -v node &> /dev/null; then
        if node -c "$JITSI_DIR/interface_config.js" 2>/dev/null; then
            log_success "Syntaxe JavaScript: OK"
        else
            log_error "Syntaxe JavaScript: Erreur dans interface_config.js"
        fi
    else
        log_warning "Syntaxe JavaScript: Node.js non disponible, test ignoré"
    fi
    
    # Test JSON (package.json)
    ((TESTS_TOTAL++))
    if command -v python3 &> /dev/null; then
        if python3 -m json.tool "$JITSI_DIR/package.json" > /dev/null 2>&1; then
            log_success "Syntaxe JSON: OK"
        else
            log_error "Syntaxe JSON: Erreur dans package.json"
        fi
    else
        log_warning "Syntaxe JSON: Python3 non disponible, test ignoré"
    fi
    
    # Test CSS
    ((TESTS_TOTAL++))
    if [ -f "$JITSI_DIR/css/custom.css" ]; then
        # Test basique de syntaxe CSS (recherche d'accolades non fermées)
        local open_braces=$(grep -o '{' "$JITSI_DIR/css/custom.css" | wc -l)
        local close_braces=$(grep -o '}' "$JITSI_DIR/css/custom.css" | wc -l)
        
        if [ $open_braces -eq $close_braces ]; then
            log_success "Syntaxe CSS: OK"
        else
            log_error "Syntaxe CSS: Accolades non équilibrées"
        fi
    else
        log_error "Syntaxe CSS: Fichier custom.css non trouvé"
    fi
}

# Test de cohérence des modifications
test_consistency() {
    log_info "Tests de cohérence..."
    
    # Vérifier que tous les "Jitsi Meet" ont été remplacés dans les fichiers principaux
    local jitsi_references=0
    
    for file in "$JITSI_DIR/interface_config.js" "$JITSI_DIR/package.json"; do
        if [ -f "$file" ]; then
            local count=$(grep -c "Jitsi Meet" "$file" 2>/dev/null || echo 0)
            jitsi_references=$((jitsi_references + count))
        fi
    done
    
    ((TESTS_TOTAL++))
    if [ $jitsi_references -eq 0 ]; then
        log_success "Cohérence: Toutes les références 'Jitsi Meet' ont été remplacées"
    else
        log_warning "Cohérence: $jitsi_references références 'Jitsi Meet' restantes"
    fi
    
    # Vérifier la cohérence des couleurs CSS
    ((TESTS_TOTAL++))
    if [ -f "$JITSI_DIR/css/custom.css" ]; then
        local color_vars=$(grep -c "var(--.*-color)" "$JITSI_DIR/css/custom.css" 2>/dev/null || echo 0)
        if [ $color_vars -gt 0 ]; then
            log_success "Cohérence CSS: Variables de couleur utilisées ($color_vars références)"
        else
            log_warning "Cohérence CSS: Aucune variable de couleur trouvée"
        fi
    fi
}

# Fonction principale
main() {
    echo "🔍 Validation des modifications LiberChat Vidéo"
    echo "=============================================="
    
    # Vérification des prérequis
    if [ ! -d "$JITSI_DIR" ]; then
        log_error "Répertoire Jitsi Meet non trouvé: $JITSI_DIR"
        exit 1
    fi
    
    if [ ! -d "$YUNOHOST_DIR" ]; then
        log_error "Répertoire YunoHost non trouvé: $YUNOHOST_DIR"
        exit 1
    fi
    
    echo ""
    
    # Exécuter tous les tests
    test_jitsi_modifications
    echo ""
    test_yunohost_modifications
    echo ""
    test_generated_files
    echo ""
    test_backups
    echo ""
    test_syntax
    echo ""
    test_consistency
    
    # Résumé final
    echo ""
    echo "=============================================="
    echo "📊 Résumé de la validation"
    echo "=============================================="
    
    local success_rate=0
    if [ $TESTS_TOTAL -gt 0 ]; then
        success_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
    fi
    
    echo "Tests réussis: $TESTS_PASSED/$TESTS_TOTAL ($success_rate%)"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "🎉 Toutes les validations sont passées!"
        echo ""
        echo "✅ Votre personnalisation LiberChat Vidéo est prête!"
        echo "📋 Prochaines étapes:"
        echo "   1. Testez l'interface web"
        echo "   2. Déployez avec ./deploy_liberchat.sh"
        echo "   3. Vérifiez le fonctionnement complet"
    else
        log_error "❌ $TESTS_FAILED test(s) ont échoué"
        echo ""
        echo "🔧 Actions recommandées:"
        echo "   1. Vérifiez les erreurs ci-dessus"
        echo "   2. Relancez le script de personnalisation si nécessaire"
        echo "   3. Consultez le rapport de modifications"
        
        exit 1
    fi
}

# Afficher l'aide
show_help() {
    cat << EOF
Usage: $0 [JITSI_DIR] [YUNOHOST_DIR]

Valide que toutes les personnalisations LiberChat Vidéo ont été appliquées correctement.

Arguments:
  JITSI_DIR     Chemin vers le répertoire Jitsi Meet (défaut: ./jitsi-meet)
  YUNOHOST_DIR  Chemin vers le répertoire YunoHost (défaut: ./jitsi_ynh)

Options:
  -h, --help    Affiche cette aide

Le script vérifie:
- Modifications des fichiers de configuration
- Présence du thème CSS personnalisé
- Cohérence des changements de nom
- Syntaxe des fichiers modifiés
- Présence des sauvegardes
- Fichiers générés (scripts, rapports)

Code de sortie:
  0  Toutes les validations sont passées
  1  Une ou plusieurs validations ont échoué
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