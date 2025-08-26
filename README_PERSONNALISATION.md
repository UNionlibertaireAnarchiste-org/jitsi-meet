# 🎨 Personnalisation Jitsi Meet → LiberChat Vidéo

Ce projet contient des scripts automatisés pour transformer les forks Jitsi Meet et YunoHost de **UNionlibertaireAnarchiste-org** en une solution de vidéoconférence personnalisée **LiberChat Vidéo**.

## 🔗 Repositories source
- **Jitsi Meet**: https://github.com/UNionlibertaireAnarchiste-org/jitsi-meet
- **YunoHost**: https://github.com/UNionlibertaireAnarchiste-org/jitsi_ynh

## 📋 Fonctionnalités

### ✨ Personnalisation visuelle
- **Thème rouge/noir** avec couleurs personnalisées
- **Logo LiberChat** intégré dans l'interface
- **CSS personnalisé** avec design moderne

### 🔧 Modifications techniques
- Renommage complet "Jitsi Meet" → "LiberChat Vidéo"
- Configuration nginx pour autoriser les iframes partout
- Adaptation du manifest YunoHost
- Scripts de déploiement automatisés

### 📊 Suivi des modifications
- Sauvegarde automatique des fichiers originaux
- Rapport détaillé des changements appliqués
- Possibilité de restauration complète

## 🚀 Utilisation rapide

### Option 1: Configuration automatique (recommandée)
```bash
# Cloner et configurer automatiquement les forks
chmod +x setup_liberchat_forks.sh
./setup_liberchat_forks.sh

# Aller dans l'espace de travail créé
cd liberchat-workspace

# Appliquer les personnalisations
./customize_jitsi_liberchat.sh

# Valider les modifications
./validate_customization.sh
```

### Option 2: Configuration manuelle
```bash
# Cloner manuellement les repositories
git clone https://github.com/UNionlibertaireAnarchiste-org/jitsi-meet.git
git clone https://github.com/UNionlibertaireAnarchiste-org/jitsi_ynh.git

# Appliquer les personnalisations avec Python
python3 customize_jitsi_liberchat.py

# Ou avec le script Shell
./customize_jitsi_liberchat.sh

# Mode simulation (sans modifications)
python3 customize_jitsi_liberchat.py --dry-run
```

## 📁 Structure des répertoires

```
votre-projet/
├── jitsi-meet/                 # Votre fork Jitsi Meet
├── jitsi_ynh/                  # Votre fork YunoHost
├── customize_jitsi_liberchat.py # Script Python principal
├── customize_jitsi_liberchat.sh # Script Shell alternatif
├── deploy_liberchat.sh         # Script de déploiement (généré)
├── rapport_modifications_liberchat.md # Rapport détaillé (généré)
└── backup-YYYYMMDD-HHMMSS/     # Sauvegarde automatique (généré)
```

## 🎨 Configuration du thème

### Couleurs appliquées
- **Couleur primaire**: `#8B0000` (Rouge foncé)
- **Couleur secondaire**: `#000000` (Noir)
- **Couleur d'accent**: `#FF0000` (Rouge vif)

### Logo
- **URL**: `https://raw.githubusercontent.com/Liberchat/Liberchat/Liberchat6.1.20/icon.png`
- Intégré dans l'interface et la page d'accueil

## 📝 Modifications détaillées

### Fichiers Jitsi Meet modifiés
- `interface_config.js` - Configuration de l'interface
- `package.json` - Métadonnées du projet
- `css/custom.css` - Thème personnalisé (créé)
- Fichiers HTML - Titres et références
- `README.md` - Documentation

### Fichiers YunoHost modifiés
- `manifest.toml` - Configuration de l'application
- `conf/nginx.conf` - Configuration du serveur web
- `scripts/install` - Script d'installation
- `README.md` - Documentation

### Configuration nginx
```nginx
# Avant
more_set_headers "Content-Security-Policy: frame-ancestors 'self'";

# Après
more_set_headers "Content-Security-Policy: frame-ancestors *";
more_set_headers "X-Frame-Options: ALLOWALL";
more_set_headers "X-Powered-By: LiberChat";
```

## 🔄 Déploiement

Après exécution du script de personnalisation :

1. **Vérifiez les modifications**
   ```bash
   cat rapport_modifications_liberchat.md
   ```

2. **Testez localement**
   ```bash
   cd jitsi-meet
   npm install
   npm run build
   ```

3. **Déployez automatiquement**
   ```bash
   ./deploy_liberchat.sh
   ```

## 🛡️ Sauvegarde et restauration

### Sauvegarde automatique
- Tous les fichiers modifiés sont sauvegardés avec l'extension `.backup`
- Un répertoire de sauvegarde complet est créé : `backup-YYYYMMDD-HHMMSS/`

### Restauration manuelle
```bash
# Restaurer tous les fichiers depuis les .backup
find . -name "*.backup" -exec sh -c 'mv "$1" "${1%.backup}"' _ {} \;

# Ou restaurer depuis le répertoire de sauvegarde
cp -r backup-YYYYMMDD-HHMMSS/jitsi-meet/* jitsi-meet/
cp -r backup-YYYYMMDD-HHMMSS/jitsi_ynh/* jitsi_ynh/
```

## 🐛 Dépannage

### Erreurs communes

**"Répertoire non trouvé"**
```bash
# Vérifiez que les répertoires existent
ls -la jitsi-meet/
ls -la jitsi_ynh/

# Ou spécifiez les chemins corrects
python3 customize_jitsi_liberchat.py --jitsi-path /chemin/correct/jitsi-meet
```

**"Permission denied"**
```bash
# Rendez les scripts exécutables
chmod +x customize_jitsi_liberchat.sh
chmod +x deploy_liberchat.sh
```

**"Texte non trouvé"**
- Vérifiez que vous utilisez la bonne version de Jitsi Meet
- Consultez le rapport pour voir quelles modifications ont échoué
- Les fichiers peuvent avoir été modifiés manuellement auparavant

### Vérification post-installation

1. **Interface web**
   - Vérifiez que le titre affiche "LiberChat Vidéo"
   - Confirmez que le logo LiberChat est visible
   - Testez le thème rouge/noir

2. **Configuration nginx**
   ```bash
   # Vérifiez la configuration
   nginx -t
   
   # Testez les headers
   curl -I https://votre-domaine.com
   ```

3. **YunoHost**
   ```bash
   # Vérifiez l'application
   yunohost app list
   
   # Testez l'installation
   yunohost app install ./jitsi_ynh
   ```

## 📚 Personnalisation avancée

### Modifier les couleurs
Éditez le fichier `jitsi-meet/css/custom.css` après génération :
```css
:root {
    --primary-color: #VOTRE_COULEUR;
    --secondary-color: #VOTRE_COULEUR;
    --accent-color: #VOTRE_COULEUR;
}
```

### Changer le logo
Modifiez la variable `LOGO_URL` dans les scripts ou directement dans `interface_config.js`.

### Ajouter des fonctionnalités
Les scripts sont modulaires. Vous pouvez ajouter vos propres fonctions de modification.

## 🤝 Contribution

Pour contribuer à ce projet :

1. Forkez le repository
2. Créez une branche pour votre fonctionnalité
3. Testez vos modifications
4. Soumettez une pull request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

## 🆘 Support

En cas de problème :

1. Consultez la section dépannage ci-dessus
2. Vérifiez le rapport de modifications généré
3. Restaurez depuis la sauvegarde si nécessaire
4. Ouvrez une issue avec les détails de l'erreur

---

**Note**: Ces scripts modifient directement vos fichiers. Assurez-vous d'avoir des sauvegardes avant de les exécuter en production.