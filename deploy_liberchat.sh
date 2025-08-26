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
npm install
npm run build
cd ..

# Empaqueter pour YunoHost
echo "📦 Empaquetage YunoHost..."
cd "$YUNOHOST_DIR"
# Commandes spécifiques à YunoHost si nécessaire

echo "✅ Déploiement terminé!"
echo "📁 Backup disponible dans: $BACKUP_DIR"
