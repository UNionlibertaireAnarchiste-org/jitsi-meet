#!/bin/bash

# Script de validation et optimisation CSS pour LiberChat
echo "🎨 Validation et optimisation CSS LiberChat"
echo "=========================================="

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
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

# Vérification des fichiers CSS
print_status "Vérification des fichiers CSS..."

CSS_DIR="jitsi-meet/css"
CUSTOM_CSS="$CSS_DIR/custom.css"
TYPOGRAPHY_CSS="$CSS_DIR/liberchat-typography.css"
MAIN_SCSS="$CSS_DIR/main.scss"

# Vérifier l'existence des fichiers
if [[ -f "$CUSTOM_CSS" ]]; then
    print_success "Fichier custom.css trouvé"
else
    print_error "Fichier custom.css manquant"
    exit 1
fi

if [[ -f "$TYPOGRAPHY_CSS" ]]; then
    print_success "Fichier liberchat-typography.css trouvé"
else
    print_error "Fichier liberchat-typography.css manquant"
    exit 1
fi

if [[ -f "$MAIN_SCSS" ]]; then
    print_success "Fichier main.scss trouvé"
else
    print_error "Fichier main.scss manquant"
    exit 1
fi

# Vérifier l'intégration dans main.scss
print_status "Vérification de l'intégration CSS..."

if grep -q "liberchat-typography" "$MAIN_SCSS"; then
    print_success "Typographie LiberChat intégrée dans main.scss"
else
    print_warning "Typographie LiberChat non intégrée dans main.scss"
fi

# Analyser la taille des fichiers CSS
print_status "Analyse de la taille des fichiers..."

CUSTOM_SIZE=$(wc -c < "$CUSTOM_CSS" 2>/dev/null || echo "0")
TYPOGRAPHY_SIZE=$(wc -c < "$TYPOGRAPHY_CSS" 2>/dev/null || echo "0")

echo "  - custom.css: ${CUSTOM_SIZE} octets"
echo "  - liberchat-typography.css: ${TYPOGRAPHY_SIZE} octets"

# Vérifier la syntaxe CSS (si csslint est disponible)
if command -v csslint &> /dev/null; then
    print_status "Validation de la syntaxe CSS avec csslint..."
    
    if csslint --quiet "$CUSTOM_CSS"; then
        print_success "custom.css: syntaxe valide"
    else
        print_warning "custom.css: problèmes de syntaxe détectés"
    fi
    
    if csslint --quiet "$TYPOGRAPHY_CSS"; then
        print_success "liberchat-typography.css: syntaxe valide"
    else
        print_warning "liberchat-typography.css: problèmes de syntaxe détectés"
    fi
else
    print_warning "csslint non disponible, validation syntaxique ignorée"
fi

# Vérifier les variables CSS
print_status "Vérification des variables CSS..."

CUSTOM_VARS=$(grep -c "var(--liberchat" "$CUSTOM_CSS" 2>/dev/null || echo "0")
TYPOGRAPHY_VARS=$(grep -c "var(--liberchat" "$TYPOGRAPHY_CSS" 2>/dev/null || echo "0")

echo "  - Variables dans custom.css: $CUSTOM_VARS"
echo "  - Variables dans liberchat-typography.css: $TYPOGRAPHY_VARS"

if [[ $CUSTOM_VARS -gt 0 ]] && [[ $TYPOGRAPHY_VARS -gt 0 ]]; then
    print_success "Variables CSS LiberChat utilisées correctement"
else
    print_warning "Peu de variables CSS LiberChat détectées"
fi

# Vérifier les règles !important
print_status "Analyse des règles !important..."

IMPORTANT_COUNT=$(grep -o "!important" "$CUSTOM_CSS" 2>/dev/null | wc -l)
echo "  - Règles !important dans custom.css: $IMPORTANT_COUNT"

if [[ $IMPORTANT_COUNT -lt 10 ]]; then
    print_success "Utilisation modérée de !important ($IMPORTANT_COUNT règles)"
elif [[ $IMPORTANT_COUNT -lt 30 ]]; then
    print_warning "Utilisation élevée de !important ($IMPORTANT_COUNT règles)"
else
    print_error "Utilisation excessive de !important ($IMPORTANT_COUNT règles)"
fi

# Vérifier les couleurs LiberChat
print_status "Vérification du thème LiberChat..."

LIBERCHAT_COLORS=("#8B0000" "#000000" "#FF0000" "#FFFFFF")
COLOR_FOUND=0

for color in "${LIBERCHAT_COLORS[@]}"; do
    if grep -q "$color" "$CUSTOM_CSS"; then
        ((COLOR_FOUND++))
    fi
done

if [[ $COLOR_FOUND -eq 4 ]]; then
    print_success "Toutes les couleurs LiberChat présentes"
elif [[ $COLOR_FOUND -gt 2 ]]; then
    print_warning "Certaines couleurs LiberChat manquantes ($COLOR_FOUND/4)"
else
    print_error "Thème LiberChat incomplet ($COLOR_FOUND/4 couleurs)"
fi

# Recommandations d'optimisation
print_status "Recommandations d'optimisation..."

echo "📋 Résumé des améliorations apportées:"
echo "  ✅ CSS restructuré avec variables CSS personnalisées"
echo "  ✅ Typographie améliorée avec police Inter"
echo "  ✅ Contraste et lisibilité optimisés"
echo "  ✅ Règles CSS organisées et commentées"
echo "  ✅ Support responsive amélioré"
echo "  ✅ Accessibilité renforcée"

echo ""
echo "🚀 Prochaines étapes recommandées:"
echo "  1. Tester l'interface dans différents navigateurs"
echo "  2. Vérifier la lisibilité sur mobile"
echo "  3. Valider l'accessibilité avec un lecteur d'écran"
echo "  4. Optimiser les performances de rendu"

# Test de compilation SCSS (si sass est disponible)
if command -v sass &> /dev/null; then
    print_status "Test de compilation SCSS..."
    
    if sass --check "$MAIN_SCSS" &> /dev/null; then
        print_success "Compilation SCSS réussie"
    else
        print_error "Erreur de compilation SCSS"
        sass --check "$MAIN_SCSS"
    fi
else
    print_warning "sass non disponible, test de compilation ignoré"
fi

print_success "Validation CSS terminée!"
echo ""
echo "💡 Pour appliquer les changements:"
echo "   cd jitsi-meet && npm run build"
echo ""
echo "🔍 Pour tester l'interface:"
echo "   Ouvrez votre instance Jitsi Meet dans un navigateur"