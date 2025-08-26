#!/bin/bash
# Script de contribution pour les forks LiberChat
# Facilite la création de branches et pull requests

set -e

# Configuration
GITHUB_ORG="UNionlibertaireAnarchiste-org"
JITSI_REPO="jitsi-meet"
YUNOHOST_REPO="jitsi_ynh"

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

# Vérifier le statut Git
check_git_status() {
    local repo_dir="$1"
    local repo_name="$2"
    
    if [ ! -d "$repo_dir" ]; then
        log_error "Répertoire $repo_name non trouvé: $repo_dir"
        return 1
    fi
    
    cd "$repo_dir"
    
    # Vérifier s'il y a des modifications
    if ! git diff-index --quiet HEAD --; then
        log_info "$repo_name: Modifications détectées"
        git status --porcelain
        return 0
    else
        log_info "$repo_name: Aucune modification"
        return 1
    fi
}

# Créer une nouvelle branche de fonctionnalité
create_feature_branch() {
    local repo_dir="$1"
    local repo_name="$2"
    local branch_name="$3"
    
    cd "$repo_dir"
    
    # Vérifier si la branche existe déjà
    if git branch | grep -q "$branch_name"; then
        log_warning "La branche '$branch_name' existe déjà dans $repo_name"
        read -p "Voulez-vous la supprimer et la recréer ? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git branch -D "$branch_name"
            log_info "Branche supprimée"
        else
            git checkout "$branch_name"
            log_info "Basculement vers la branche existante"
            return 0
        fi
    fi
    
    # Créer et basculer vers la nouvelle branche
    git checkout -b "$branch_name"
    log_success "Branche '$branch_name' créée dans $repo_name"
}

# Commiter les modifications
commit_changes() {
    local repo_dir="$1"
    local repo_name="$2"
    local commit_message="$3"
    
    cd "$repo_dir"
    
    # Ajouter tous les fichiers modifiés
    git add .
    
    # Afficher les modifications qui seront commitées
    echo ""
    log_info "Modifications à commiter dans $repo_name:"
    git diff --cached --name-status
    echo ""
    
    read -p "Confirmer le commit ? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        log_warning "Commit annulé"
        return 1
    fi
    
    # Commiter
    git commit -m "$commit_message"
    log_success "Modifications commitées dans $repo_name"
}

# Pousser vers le repository distant
push_changes() {
    local repo_dir="$1"
    local repo_name="$2"
    local branch_name="$3"
    
    cd "$repo_dir"
    
    # Pousser la branche
    git push origin "$branch_name"
    log_success "Branche '$branch_name' poussée vers $repo_name"
    
    # Afficher l'URL pour créer une pull request
    echo ""
    log_info "🔗 Créer une pull request:"
    echo "   https://github.com/$GITHUB_ORG/$repo_name/compare/$branch_name"
}

# Synchroniser avec upstream
sync_with_upstream() {
    local repo_dir="$1"
    local repo_name="$2"
    
    cd "$repo_dir"
    
    # Vérifier si upstream existe
    if ! git remote | grep -q "upstream"; then
        log_warning "Remote upstream non configuré pour $repo_name"
        return 1
    fi
    
    # Récupérer les dernières modifications d'upstream
    git fetch upstream
    
    # Basculer vers main/master
    local main_branch="main"
    if git branch -r | grep -q "origin/master"; then
        main_branch="master"
    fi
    
    git checkout "$main_branch"
    git merge "upstream/$main_branch"
    git push origin "$main_branch"
    
    log_success "$repo_name synchronisé avec upstream"
}

# Workflow complet de contribution
full_contribution_workflow() {
    local feature_name="$1"
    local commit_message="$2"
    
    if [ -z "$feature_name" ]; then
        read -p "Nom de la fonctionnalité/branche: " feature_name
    fi
    
    if [ -z "$commit_message" ]; then
        read -p "Message de commit: " commit_message
    fi
    
    local branch_name="feature/$feature_name"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    
    echo ""
    log_info "🚀 Workflow de contribution LiberChat"
    echo "======================================"
    echo "Fonctionnalité: $feature_name"
    echo "Branche: $branch_name"
    echo "Message: $commit_message"
    echo ""
    
    # Vérifier les modifications dans jitsi-meet
    if check_git_status "jitsi-meet" "Jitsi Meet"; then
        echo ""
        read -p "Contribuer les modifications Jitsi Meet ? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            create_feature_branch "jitsi-meet" "Jitsi Meet" "$branch_name"
            commit_changes "jitsi-meet" "Jitsi Meet" "$commit_message"
            push_changes "jitsi-meet" "$JITSI_REPO" "$branch_name"
        fi
        cd ..
    fi
    
    # Vérifier les modifications dans jitsi_ynh
    if check_git_status "jitsi_ynh" "YunoHost"; then
        echo ""
        read -p "Contribuer les modifications YunoHost ? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            create_feature_branch "jitsi_ynh" "YunoHost" "$branch_name"
            commit_changes "jitsi_ynh" "YunoHost" "$commit_message"
            push_changes "jitsi_ynh" "$YUNOHOST_REPO" "$branch_name"
        fi
        cd ..
    fi
    
    echo ""
    log_success "🎉 Workflow de contribution terminé!"
    echo ""
    echo "📋 Prochaines étapes:"
    echo "   1. Créez les pull requests via les liens affichés"
    echo "   2. Ajoutez une description détaillée"
    echo "   3. Assignez des reviewers si nécessaire"
    echo "   4. Surveillez les commentaires et tests CI"
}

# Créer un release
create_release() {
    local version="$1"
    local release_notes="$2"
    
    if [ -z "$version" ]; then
        read -p "Version du release (ex: v1.0.0): " version
    fi
    
    if [ -z "$release_notes" ]; then
        read -p "Notes de release: " release_notes
    fi
    
    echo ""
    log_info "🏷️ Création du release $version"
    echo "================================"
    
    # Tag dans jitsi-meet
    if [ -d "jitsi-meet" ]; then
        cd jitsi-meet
        git tag -a "$version" -m "$release_notes"
        git push origin "$version"
        log_success "Tag $version créé dans jitsi-meet"
        cd ..
    fi
    
    # Tag dans jitsi_ynh
    if [ -d "jitsi_ynh" ]; then
        cd jitsi_ynh
        git tag -a "$version" -m "$release_notes"
        git push origin "$version"
        log_success "Tag $version créé dans jitsi_ynh"
        cd ..
    fi
    
    echo ""
    log_info "🔗 Créer les releases GitHub:"
    echo "   https://github.com/$GITHUB_ORG/$JITSI_REPO/releases/new?tag=$version"
    echo "   https://github.com/$GITHUB_ORG/$YUNOHOST_REPO/releases/new?tag=$version"
}

# Afficher le statut des repositories
show_status() {
    echo "📊 Statut des repositories LiberChat"
    echo "===================================="
    echo ""
    
    # Statut jitsi-meet
    if [ -d "jitsi-meet" ]; then
        echo "📁 jitsi-meet:"
        cd jitsi-meet
        echo "   Branche: $(git branch --show-current)"
        echo "   Dernier commit: $(git log -1 --pretty=format:'%h - %s (%cr)')"
        if ! git diff-index --quiet HEAD --; then
            echo "   ⚠️  Modifications non commitées"
        else
            echo "   ✅ Répertoire propre"
        fi
        cd ..
    else
        echo "❌ jitsi-meet: Répertoire non trouvé"
    fi
    
    echo ""
    
    # Statut jitsi_ynh
    if [ -d "jitsi_ynh" ]; then
        echo "📁 jitsi_ynh:"
        cd jitsi_ynh
        echo "   Branche: $(git branch --show-current)"
        echo "   Dernier commit: $(git log -1 --pretty=format:'%h - %s (%cr)')"
        if ! git diff-index --quiet HEAD --; then
            echo "   ⚠️  Modifications non commitées"
        else
            echo "   ✅ Répertoire propre"
        fi
        cd ..
    else
        echo "❌ jitsi_ynh: Répertoire non trouvé"
    fi
}

# Menu interactif
interactive_menu() {
    while true; do
        echo ""
        echo "🎨 Menu de contribution LiberChat"
        echo "================================"
        echo "1. Afficher le statut"
        echo "2. Synchroniser avec upstream"
        echo "3. Workflow de contribution complet"
        echo "4. Créer un release"
        echo "5. Quitter"
        echo ""
        read -p "Choisissez une option (1-5): " choice
        
        case $choice in
            1)
                show_status
                ;;
            2)
                echo ""
                log_info "Synchronisation avec upstream..."
                sync_with_upstream "jitsi-meet" "Jitsi Meet" || true
                sync_with_upstream "jitsi_ynh" "YunoHost" || true
                ;;
            3)
                full_contribution_workflow
                ;;
            4)
                create_release
                ;;
            5)
                log_info "Au revoir!"
                exit 0
                ;;
            *)
                log_error "Option invalide"
                ;;
        esac
    done
}

# Fonction principale
main() {
    local action="$1"
    
    case "$action" in
        "status")
            show_status
            ;;
        "sync")
            sync_with_upstream "jitsi-meet" "Jitsi Meet" || true
            sync_with_upstream "jitsi_ynh" "YunoHost" || true
            ;;
        "contribute")
            full_contribution_workflow "$2" "$3"
            ;;
        "release")
            create_release "$2" "$3"
            ;;
        "menu"|"")
            interactive_menu
            ;;
        *)
            show_help
            ;;
    esac
}

# Afficher l'aide
show_help() {
    cat << EOF
Usage: $0 [ACTION] [OPTIONS]

Script de contribution pour les forks LiberChat.

Actions:
  status                    Affiche le statut des repositories
  sync                      Synchronise avec upstream
  contribute [NAME] [MSG]   Workflow de contribution complet
  release [VERSION] [NOTES] Crée un release
  menu                      Menu interactif (défaut)

Options pour contribute:
  NAME    Nom de la fonctionnalité/branche
  MSG     Message de commit

Options pour release:
  VERSION Version du release (ex: v1.0.0)
  NOTES   Notes de release

Exemples:
  $0                                    # Menu interactif
  $0 status                             # Afficher le statut
  $0 contribute "theme-update" "Mise à jour du thème rouge"
  $0 release "v1.0.0" "Première version LiberChat"

Le script doit être exécuté depuis le répertoire contenant jitsi-meet/ et jitsi_ynh/
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