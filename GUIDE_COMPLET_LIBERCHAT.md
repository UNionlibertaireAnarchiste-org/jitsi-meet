# 🎨 Guide Complet LiberChat Vidéo

## 📋 Vue d'ensemble

Ce projet transforme automatiquement vos forks Jitsi Meet et YunoHost en une solution de vidéoconférence personnalisée **LiberChat Vidéo** avec :

- **Thème rouge/noir** professionnel
- **Logo LiberChat** intégré
- **Renommage complet** de l'interface
- **Configuration nginx** pour iframes universels
- **Scripts de déploiement** automatisés

## 🔗 Repositories

- **Jitsi Meet**: https://github.com/UNionlibertaireAnarchiste-org/jitsi-meet
- **YunoHost**: https://github.com/UNionlibertaireAnarchiste-org/jitsi_ynh

## 🚀 Démarrage rapide (1 clic)

```bash
# Télécharger et exécuter le script tout-en-un
curl -sSL https://raw.githubusercontent.com/votre-repo/liberchat-one-click.sh | bash

# Ou localement
chmod +x liberchat_one_click.sh
./liberchat_one_click.sh
```

## 📁 Scripts disponibles

### 🎯 Scripts principaux

| Script | Description | Usage |
|--------|-------------|-------|
| `liberchat_one_click.sh` | **Configuration complète automatique** | `./liberchat_one_click.sh` |
| `setup_liberchat_forks.sh` | Clone et configure les forks | `./setup_liberchat_forks.sh` |
| `customize_jitsi_liberchat.py` | Personnalisation Python (avancé) | `python3 customize_jitsi_liberchat.py` |
| `customize_jitsi_liberchat.sh` | Personnalisation Shell | `./customize_jitsi_liberchat.sh` |

### 🔧 Scripts utilitaires

| Script | Description | Usage |
|--------|-------------|-------|
| `validate_customization.sh` | Valide les modifications | `./validate_customization.sh` |
| `contribute_liberchat.sh` | Outils de contribution Git | `./contribute_liberchat.sh` |
| `deploy_liberchat.sh` | Déploiement simple | `./deploy_liberchat.sh` |
| `deploy_full_liberchat.sh` | Déploiement complet | `./deploy_full_liberchat.sh` |

## 🎨 Personnalisations appliquées

### 🎭 Interface utilisateur
- **Nom**: "Jitsi Meet" → "LiberChat Vidéo"
- **Logo**: Intégration du logo LiberChat
- **Thème**: Rouge foncé (#8B0000) et noir (#000000)
- **Couleur d'accent**: Rouge vif (#FF0000)

### 🔧 Configuration technique
- **CSS personnalisé**: `jitsi-meet/css/custom.css`
- **Nginx**: `frame-ancestors *` (iframes autorisés partout)
- **Package.json**: Métadonnées mises à jour
- **Manifest YunoHost**: Configuration adaptée

### 📄 Fichiers modifiés
```
jitsi-meet/
├── interface_config.js     # Configuration interface
├── package.json           # Métadonnées projet
├── css/custom.css         # Thème personnalisé (créé)
├── index.html            # Page principale
└── README.md             # Documentation

jitsi_ynh/
├── manifest.toml         # Configuration YunoHost
├── conf/nginx.conf       # Configuration serveur
├── scripts/install       # Script d'installation
└── README.md            # Documentation
```

## 🛠️ Installation détaillée

### Étape 1: Prérequis
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install git curl python3 nodejs npm

# CentOS/RHEL
sudo yum install git curl python3 nodejs npm

# macOS
brew install git curl python3 node npm
```

### Étape 2: Configuration automatique
```bash
# Option A: Script tout-en-un (recommandé)
./liberchat_one_click.sh

# Option B: Étape par étape
./setup_liberchat_forks.sh
cd liberchat-workspace
./customize_jitsi_liberchat.sh
./validate_customization.sh
./deploy_full_liberchat.sh
```

### Étape 3: Déploiement YunoHost
```bash
# Installation directe
yunohost app install ./jitsi_ynh

# Ou avec le script
./deploy_full_liberchat.sh
```

## 🎯 Cas d'usage

### 🏢 Déploiement d'entreprise
```bash
# Configuration avec domaine personnalisé
./liberchat_one_click.sh --work-dir /opt/liberchat
cd /opt/liberchat
# Modifier les configurations selon vos besoins
./deploy_full_liberchat.sh
```

### 🧪 Développement et test
```bash
# Mode développement
./setup_liberchat_forks.sh ./dev-workspace
cd dev-workspace
./customize_jitsi_liberchat.py --dry-run  # Simulation
./customize_jitsi_liberchat.py            # Application
python3 -m http.server 8000               # Test local
```

### 🤝 Contribution
```bash
# Workflow de contribution
./contribute_liberchat.sh menu
# Ou directement
./contribute_liberchat.sh contribute "ma-fonctionnalite" "Description"
```

## 🔍 Validation et tests

### Tests automatiques
```bash
# Validation complète
./validate_customization.sh

# Tests spécifiques
python3 -c "
import json
with open('jitsi-meet/package.json') as f:
    data = json.load(f)
    print('✅ Package name:', data['name'])
    print('✅ Description:', data['description'])
"
```

### Tests manuels
1. **Interface web**: Vérifiez le titre "LiberChat Vidéo"
2. **Logo**: Confirmez l'affichage du logo LiberChat
3. **Thème**: Testez les couleurs rouge/noir
4. **Iframes**: Testez l'intégration dans d'autres sites

## 🚨 Dépannage

### Erreurs communes

**"Repository not found"**
```bash
# Vérifiez l'accès aux repositories
curl -I https://github.com/UNionlibertaireAnarchiste-org/jitsi-meet
git ls-remote https://github.com/UNionlibertaireAnarchiste-org/jitsi-meet.git
```

**"Permission denied"**
```bash
# Rendez les scripts exécutables
chmod +x *.sh
```

**"npm install failed"**
```bash
# Nettoyez le cache npm
cd jitsi-meet
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

**"Modifications not applied"**
```bash
# Vérifiez les sauvegardes
find . -name "*.backup" -exec ls -la {} \;
# Restaurez si nécessaire
find . -name "*.backup" -exec sh -c 'mv "$1" "${1%.backup}"' _ {} \;
```

### Logs et diagnostic
```bash
# Vérifiez les modifications appliquées
cat rapport_modifications_liberchat.md

# Statut Git
./contribute_liberchat.sh status

# Tests de validation
./validate_customization.sh
```

## 🔄 Mise à jour

### Mise à jour des forks
```bash
# Script automatique
./update_forks.sh

# Manuel
cd jitsi-meet && git pull origin main && cd ..
cd jitsi_ynh && git pull origin main && cd ..
```

### Re-application des personnalisations
```bash
# Après mise à jour des forks
./customize_jitsi_liberchat.sh
./validate_customization.sh
```

## 🎨 Personnalisation avancée

### Modifier les couleurs
```css
/* Éditez jitsi-meet/css/custom.css */
:root {
    --primary-color: #VOTRE_COULEUR;
    --secondary-color: #VOTRE_COULEUR;
    --accent-color: #VOTRE_COULEUR;
}
```

### Changer le logo
```bash
# Modifiez l'URL dans les scripts
sed -i 's|LOGO_URL=".*"|LOGO_URL="https://votre-logo.png"|' customize_jitsi_liberchat.sh
```

### Ajouter des fonctionnalités
```python
# Éditez customize_jitsi_liberchat.py
def ma_personnalisation(self):
    # Votre code ici
    pass

# Ajoutez dans run_all_modifications()
self.ma_personnalisation()
```

## 📊 Métriques et monitoring

### Fichiers de rapport
- `rapport_modifications_liberchat.md` - Détail des modifications
- `liberchat-video-dist/` - Distribution prête
- `backup-*/` - Sauvegardes automatiques

### Validation continue
```bash
# Script de monitoring
cat > monitor_liberchat.sh << 'EOF'
#!/bin/bash
while true; do
    ./validate_customization.sh
    sleep 3600  # Vérification horaire
done
EOF
chmod +x monitor_liberchat.sh
```

## 🤝 Contribution

### Workflow de développement
1. **Fork** les repositories
2. **Clone** avec `./setup_liberchat_forks.sh`
3. **Développez** vos fonctionnalités
4. **Testez** avec `./validate_customization.sh`
5. **Contribuez** avec `./contribute_liberchat.sh`

### Standards de code
- **Shell**: Suivre les conventions POSIX
- **Python**: PEP 8
- **CSS**: BEM methodology
- **Git**: Conventional commits

## 📄 Licence et crédits

- **Jitsi Meet**: Apache License 2.0
- **YunoHost**: AGPL-3.0
- **Scripts LiberChat**: MIT License

## 🆘 Support

### Ressources
- **Documentation**: README_PERSONNALISATION.md
- **Issues**: https://github.com/UNionlibertaireAnarchiste-org/jitsi-meet/issues
- **Discussions**: https://github.com/UNionlibertaireAnarchiste-org/jitsi_ynh/discussions

### Contact
- **Organisation**: UNionlibertaireAnarchiste-org
- **Repositories**: GitHub
- **Support**: Via issues GitHub

---

**🎉 Félicitations ! Vous avez maintenant une solution de vidéoconférence LiberChat Vidéo complètement personnalisée !**