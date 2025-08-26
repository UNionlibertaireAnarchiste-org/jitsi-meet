#!/bin/bash
# Script de validation simple pour LiberChat Vidéo

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

echo "🔍 Validation simple LiberChat Vidéo"
echo "===================================="

# Test 1: Vérifier les répertoires
log_info "Vérification des répertoires..."
if [ -d "$JITSI_DIR" ] && [ -d "$YUNOHOST_DIR" ]; then
    log_success "Répertoires présents"
else
    log_error "Répertoires manquants"
fi

# Test 2: Vérifier les fichiers principaux
log_info "Vérification des fichiers principaux..."
if [ -f "$JITSI_DIR/interface_config.js" ] && [ -f "$YUNOHOST_DIR/manifest.toml" ]; then
    log_success "Fichiers principaux présents"
else
    log_error "Fichiers principaux manquants"
fi

# Test 3: Vérifier le CSS personnalisé
log_info "Vérification du CSS personnalisé..."
if [ -f "$JITSI_DIR/css/custom.css" ]; then
    log_success "CSS personnalisé créé"
    
    # Vérifier le contenu du CSS
    if grep -q "primary-color" "$JITSI_DIR/css/custom.css"; then
        log_success "Variables CSS correctes"
    else
        log_error "Variables CSS incorrectes"
    fi
else
    log_error "CSS personnalisé manquant"
fi

# Test 4: Vérifier les modifications de nom dans interface_config.js
log_info "Vérification des modifications Jitsi Meet..."
if grep -q "LiberChat" "$JITSI_DIR/interface_config.js" 2>/dev/null; then
    log_success "Nom modifié dans interface_config.js"
else
    log_error "Nom non modifié dans interface_config.js"
fi

# Test 5: Vérifier les modifications dans package.json
log_info "Vérification du package.json..."
if grep -q "liberchat-video" "$JITSI_DIR/package.json" 2>/dev/null; then
    log_success "Package.json modifié"
else
    log_error "Package.json non modifié"
fi

# Test 6: Vérifier les modifications YunoHost
log_info "Vérification du manifest YunoHost..."
if grep -q "LiberChat" "$YUNOHOST_DIR/manifest.toml" 2>/dev/null; then
    log_success "Manifest YunoHost modifié"
else
    log_error "Manifest YunoHost non modifié"
fi

# Test 7: Vérifier la configuration nginx
log_info "Vérification de la configuration nginx..."
if grep -q "frame-ancestors \*" "$YUNOHOST_DIR/conf/nginx.conf" 2>/dev/null; then
    log_success "Configuration nginx modifiée"
else
    log_error "Configuration nginx non modifiée"
fi

# Test 8: Vérifier les sauvegardes
log_info "Vérification des sauvegardes..."
backup_count=$(find "$JITSI_DIR" "$YUNOHOST_DIR" -name "*.backup" 2>/dev/null | wc -l)
if [ "$backup_count" -gt 0 ]; then
    log_success "Sauvegardes présentes ($backup_count fichiers)"
else
    log_warning "Aucune sauvegarde trouvée"
fi

# Test 9: Vérifier le rapport de modifications
log_info "Vérification du rapport..."
if [ -f "rapport_modifications_liberchat.md" ]; then
    log_success "Rapport de modifications présent"
else
    log_warning "Rapport de modifications manquant"
fi

# Test 10: Vérifier le script de déploiement
log_info "Vérification du script de déploiement..."
if [ -f "deploy_liberchat.sh" ]; then
    log_success "Script de déploiement créé"
else
    log_warning "Script de déploiement manquant"
fi

# Résumé
echo ""
echo "=================================="
echo "📊 Résumé de la validation"
echo "=================================="

total_tests=$((TESTS_PASSED + TESTS_FAILED))
if [ $total_tests -gt 0 ]; then
    success_rate=$((TESTS_PASSED * 100 / total_tests))
    echo "Tests réussis: $TESTS_PASSED/$total_tests ($success_rate%)"
else
    echo "Aucun test exécuté"
fi

if [ $TESTS_FAILED -eq 0 ]; then
    log_success "🎉 Toutes les validations sont passées!"
    echo ""
    echo "✅ Votre LiberChat Vidéo est prêt!"
    echo ""
    echo "🚀 Prochaines étapes:"
    echo "   1. Testez l'interface: cd $JITSI_DIR && python3 -m http.server 8000"
    echo "   2. Ouvrez: http://localhost:8000"
    echo "   3. Déployez: yunohost app install $YUNOHOST_DIR"
    echo ""
    echo "📋 Fonctionnalités appliquées:"
    echo "   • Thème rouge/noir personnalisé"
    echo "   • Logo LiberChat intégré"
    echo "   • Nom changé en 'LiberChat Vidéo'"
    echo "   • Configuration nginx pour iframes"
    
    exit 0
else
    log_error "❌ $TESTS_FAILED test(s) ont échoué"
    echo ""
    echo "🔧 Actions recommandées:"
    echo "   1. Vérifiez les erreurs ci-dessus"
    echo "   2. Relancez le script de personnalisation"
    echo "   3. Consultez le rapport: rapport_modifications_liberchat.md"
    
    exit 1
fi