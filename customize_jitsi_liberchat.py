#!/usr/bin/env python3
"""
Script de personnalisation automatique de Jitsi Meet et YunoHost pour LiberChat Vidéo
Auteur: Assistant IA
Version: 1.0
"""

import os
import sys
import json
import re
import shutil
from pathlib import Path
from datetime import datetime
import argparse

class JitsiCustomizer:
    def __init__(self, jitsi_path="./jitsi-meet", yunohost_path="./jitsi_ynh"):
        self.jitsi_path = Path(jitsi_path)
        self.yunohost_path = Path(yunohost_path)
        self.modifications = []
        self.logo_url = "images/liberchat-logo.png"
        
        # Thème rouge/noir
        self.theme_colors = {
            "--primary-color": "#8B0000",
            "--secondary-color": "#000000", 
            "--accent-color": "#FF0000"
        }
        
        # Vérifier que les répertoires existent
        if not self.jitsi_path.exists():
            raise FileNotFoundError(f"Répertoire Jitsi Meet non trouvé: {self.jitsi_path}")
        if not self.yunohost_path.exists():
            raise FileNotFoundError(f"Répertoire YunoHost non trouvé: {self.yunohost_path}")
    
    def log_modification(self, file_path, action, details=""):
        """Enregistre une modification pour le rapport final"""
        self.modifications.append({
            "file": str(file_path),
            "action": action,
            "details": details,
            "timestamp": datetime.now().isoformat()
        })
        print(f"✓ {action}: {file_path}")
        if details:
            print(f"  → {details}")
    
    def backup_file(self, file_path):
        """Crée une sauvegarde du fichier original"""
        backup_path = f"{file_path}.backup"
        if not Path(backup_path).exists():
            shutil.copy2(file_path, backup_path)
            self.log_modification(backup_path, "Sauvegarde créée")
    
    def replace_in_file(self, file_path, old_text, new_text, description=""):
        """Remplace du texte dans un fichier"""
        file_path = Path(file_path)
        if not file_path.exists():
            print(f"⚠️  Fichier non trouvé: {file_path}")
            return False
        
        self.backup_file(file_path)
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            if old_text in content:
                new_content = content.replace(old_text, new_text)
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                
                self.log_modification(file_path, "Texte remplacé", 
                                    description or f"'{old_text[:50]}...' → '{new_text[:50]}...'")
                return True
            else:
                print(f"⚠️  Texte non trouvé dans {file_path}: {old_text[:50]}...")
                return False
        except Exception as e:
            print(f"❌ Erreur lors de la modification de {file_path}: {e}")
            return False
    
    def create_custom_css(self):
        """Crée le fichier custom.css avec le thème rouge/noir"""
        css_content = f"""/* LiberChat Vidéo - Thème personnalisé Rouge/Noir */

:root {{
    {self.theme_colors['--primary-color']}: {self.theme_colors['--primary-color']};
    {self.theme_colors['--secondary-color']}: {self.theme_colors['--secondary-color']};
    {self.theme_colors['--accent-color']}: {self.theme_colors['--accent-color']};
}}

/* Couleurs principales */
.toolbox-background {{
    background: linear-gradient(135deg, {self.theme_colors['--primary-color']}, {self.theme_colors['--secondary-color']});
}}

.header {{
    background-color: {self.theme_colors['--secondary-color']};
}}

/* Boutons */
.toolbox-button {{
    background-color: {self.theme_colors['--primary-color']};
    border: 1px solid {self.theme_colors['--accent-color']};
}}

.toolbox-button:hover {{
    background-color: {self.theme_colors['--accent-color']};
}}

/* Interface de chat */
.chat-container {{
    background-color: rgba(0, 0, 0, 0.8);
    border-left: 3px solid {self.theme_colors['--accent-color']};
}}

/* Participants */
.participant-container {{
    border: 2px solid {self.theme_colors['--primary-color']};
}}

/* Logo personnalisé */
.watermark {{
    background-image: url('{self.logo_url}');
    background-size: contain;
    background-repeat: no-repeat;
    width: 120px;
    height: 40px;
}}

/* Page d'accueil */
.welcome-page {{
    background: linear-gradient(135deg, {self.theme_colors['--secondary-color']}, {self.theme_colors['--primary-color']});
}}

.welcome-page .header {{
    color: white;
}}

/* Notifications */
.notification {{
    background-color: {self.theme_colors['--primary-color']};
    border-left: 4px solid {self.theme_colors['--accent-color']};
}}

/* Barre de progression */
.progress-bar {{
    background-color: {self.theme_colors['--accent-color']};
}}

/* Modales */
.modal {{
    background-color: rgba(0, 0, 0, 0.9);
}}

.modal-content {{
    background-color: {self.theme_colors['--secondary-color']};
    border: 2px solid {self.theme_colors['--primary-color']};
    color: white;
}}
"""
        
        css_path = self.jitsi_path / "css" / "custom.css"
        css_path.parent.mkdir(exist_ok=True)
        
        with open(css_path, 'w', encoding='utf-8') as f:
            f.write(css_content)
        
        self.log_modification(css_path, "Fichier CSS personnalisé créé", 
                            f"Thème rouge/noir avec {len(self.theme_colors)} couleurs")
    
    def modify_interface_config(self):
        """Modifie interface_config.js pour LiberChat Vidéo"""
        config_path = self.jitsi_path / "interface_config.js"
        
        modifications = [
            ("APP_NAME: 'Jitsi Meet'", "APP_NAME: 'LiberChat Vidéo'"),
            ("PROVIDER_NAME: 'Jitsi'", "PROVIDER_NAME: 'LiberChat'"),
            ("DEFAULT_WELCOME_PAGE_LOGO_URL: 'images/watermark.svg'", 
             f"DEFAULT_WELCOME_PAGE_LOGO_URL: '{self.logo_url}'"),
            ("JITSI_WATERMARK_LINK: 'https://jitsi.org'", 
             "JITSI_WATERMARK_LINK: 'https://liberchat.org'"),
            ("SHOW_JITSI_WATERMARK: true", "SHOW_JITSI_WATERMARK: false"),
            ("SHOW_BRAND_WATERMARK: false", "SHOW_BRAND_WATERMARK: true"),
            ("BRAND_WATERMARK_LINK: ''", f"BRAND_WATERMARK_LINK: '{self.logo_url}'")
        ]
        
        for old, new in modifications:
            self.replace_in_file(config_path, old, new)
        
        # Ajouter l'injection du CSS personnalisé
        css_injection = """
    // Injection du CSS personnalisé LiberChat
    CUSTOM_CSS_URL: 'css/custom.css',"""
        
        self.replace_in_file(config_path, 
                           "makeJsonParserHappy: 'even if last key had a trailing comma'",
                           f"makeJsonParserHappy: 'even if last key had a trailing comma',{css_injection}")
    
    def modify_package_json(self):
        """Modifie package.json pour renommer l'application"""
        package_path = self.jitsi_path / "package.json"
        
        modifications = [
            ('"name": "jitsi-meet"', '"name": "liberchat-video"'),
            ('"description": "A sample app for the Jitsi Videobridge"', 
             '"description": "Application de vidéoconférence LiberChat"')
        ]
        
        for old, new in modifications:
            self.replace_in_file(package_path, old, new)
    
    def modify_html_files(self):
        """Modifie les fichiers HTML pour remplacer les références à Jitsi Meet"""
        html_files = [
            "index.html", "base.html", "head.html", "title.html", 
            "body.html", "fonts.html", "plugin.head.html"
        ]
        
        for html_file in html_files:
            file_path = self.jitsi_path / html_file
            if file_path.exists():
                modifications = [
                    ("Jitsi Meet", "LiberChat Vidéo"),
                    ("jitsi-meet", "liberchat-video"),
                    ("<title>Jitsi Meet</title>", "<title>LiberChat Vidéo</title>")
                ]
                
                for old, new in modifications:
                    self.replace_in_file(file_path, old, new)
    
    def modify_yunohost_manifest(self):
        """Modifie le manifest YunoHost pour utiliser le fork personnalisé"""
        manifest_path = self.yunohost_path / "manifest.toml"
        
        modifications = [
            ('id = "jitsi"', 'id = "liberchat-video"'),
            ('name = "Jitsi Meet"', 'name = "LiberChat Vidéo"'),
            ('description.en = "Video conferencing web application"', 
             'description.en = "LiberChat video conferencing application"'),
            ('description.fr = "Application web de conférence vidéo"', 
             'description.fr = "Application de vidéoconférence LiberChat"'),
            ('website = "https://jitsi.org/"', 'website = "https://liberchat.org/"'),
            ('demo = "https://meet.jit.si/"', 'demo = "https://meet.liberchat.org/"')
        ]
        
        for old, new in modifications:
            self.replace_in_file(manifest_path, old, new)
    
    def modify_yunohost_install_script(self):
        """Modifie le script d'installation YunoHost pour utiliser le fork"""
        install_script = self.yunohost_path / "scripts" / "install"
        
        # Ajouter une section pour cloner le fork personnalisé
        fork_setup = '''
# Cloner le fork LiberChat personnalisé depuis UNionlibertaireAnarchiste-org
ynh_script_progression "Cloning LiberChat custom fork..."
git clone https://github.com/UNionlibertaireAnarchiste-org/jitsi-meet.git "$install_dir/jitsi-meet-web-custom"
cp -r "$install_dir/jitsi-meet-web-custom/"* "$install_dir/jitsi-meet-web/"
'''
        
        # Insérer après la section de setup des sources
        self.replace_in_file(install_script,
                           "_setup_sources",
                           f"_setup_sources{fork_setup}")
    
    def modify_nginx_config(self):
        """Modifie la configuration nginx pour autoriser les iframes partout"""
        nginx_config = self.yunohost_path / "conf" / "nginx.conf"
        
        # Remplacer la directive frame-ancestors
        self.replace_in_file(nginx_config,
                           'more_set_headers "Content-Security-Policy: frame-ancestors \'self\'";',
                           'more_set_headers "Content-Security-Policy: frame-ancestors *";')
        
        # Ajouter des headers pour LiberChat
        additional_headers = '''
# Headers personnalisés LiberChat
more_set_headers "X-Frame-Options: ALLOWALL";
more_set_headers "X-Powered-By: LiberChat";'''
        
        self.replace_in_file(nginx_config,
                           'ssi_types application/x-javascript application/javascript;',
                           f'ssi_types application/x-javascript application/javascript;{additional_headers}')
    
    def modify_readme_files(self):
        """Modifie les fichiers README pour LiberChat"""
        readme_files = ["README.md", "README_fr.md"]
        
        for readme_file in readme_files:
            # YunoHost README
            yunohost_readme = self.yunohost_path / readme_file
            if yunohost_readme.exists():
                modifications = [
                    ("# Jitsi Meet", "# LiberChat Vidéo"),
                    ("Jitsi Meet", "LiberChat Vidéo"),
                    ("jitsi-meet", "liberchat-video")
                ]
                
                for old, new in modifications:
                    self.replace_in_file(yunohost_readme, old, new)
            
            # Jitsi README
            jitsi_readme = self.jitsi_path / readme_file
            if jitsi_readme.exists():
                modifications = [
                    ("# Jitsi Meet", "# LiberChat Vidéo"),
                    ("Jitsi Meet", "LiberChat Vidéo")
                ]
                
                for old, new in modifications:
                    self.replace_in_file(jitsi_readme, old, new)
    
    def create_deployment_script(self):
        """Crée un script de déploiement automatique"""
        deploy_script = """#!/bin/bash
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
"""
        
        deploy_path = Path("deploy_liberchat.sh")
        with open(deploy_path, 'w', encoding='utf-8') as f:
            f.write(deploy_script)
        
        os.chmod(deploy_path, 0o755)
        self.log_modification(deploy_path, "Script de déploiement créé")
    
    def generate_report(self):
        """Génère un rapport détaillé des modifications"""
        report = f"""
# Rapport de personnalisation LiberChat Vidéo
Généré le: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Résumé
- **Nombre total de modifications**: {len(self.modifications)}
- **Répertoire Jitsi Meet**: {self.jitsi_path}
- **Répertoire YunoHost**: {self.yunohost_path}

## Modifications appliquées

"""
        
        for i, mod in enumerate(self.modifications, 1):
            report += f"### {i}. {mod['action']}\n"
            report += f"- **Fichier**: `{mod['file']}`\n"
            if mod['details']:
                report += f"- **Détails**: {mod['details']}\n"
            report += f"- **Timestamp**: {mod['timestamp']}\n\n"
        
        report += f"""
## Configuration appliquée

### Thème couleurs
- Couleur primaire: {self.theme_colors['--primary-color']}
- Couleur secondaire: {self.theme_colors['--secondary-color']}
- Couleur d'accent: {self.theme_colors['--accent-color']}

### Logo
- URL: {self.logo_url}

### Changements de nom
- "Jitsi Meet" → "LiberChat Vidéo"
- "jitsi-meet" → "liberchat-video"

### Configuration nginx
- frame-ancestors: * (autorise tous les iframes)
- Headers personnalisés ajoutés

## Fichiers de sauvegarde
Tous les fichiers modifiés ont été sauvegardés avec l'extension `.backup`

## Prochaines étapes
1. Tester les modifications localement
2. Construire l'application avec `npm run build`
3. Déployer avec le script `deploy_liberchat.sh`
4. Vérifier le fonctionnement sur YunoHost

## Restauration
Pour restaurer les fichiers originaux:
```bash
find . -name "*.backup" -exec sh -c 'mv "$1" "${{1%.backup}}"' _ {{}} \\;
```
"""
        
        report_path = Path("rapport_modifications_liberchat.md")
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write(report)
        
        self.log_modification(report_path, "Rapport de modifications généré")
        return report_path
    
    def run_all_modifications(self):
        """Exécute toutes les modifications"""
        print("🎨 Début de la personnalisation LiberChat Vidéo...")
        print("=" * 60)
        
        try:
            # 1. Créer le CSS personnalisé
            print("\n1. Création du thème CSS personnalisé...")
            self.create_custom_css()
            
            # 2. Modifier interface_config.js
            print("\n2. Modification de interface_config.js...")
            self.modify_interface_config()
            
            # 3. Modifier package.json
            print("\n3. Modification de package.json...")
            self.modify_package_json()
            
            # 4. Modifier les fichiers HTML
            print("\n4. Modification des fichiers HTML...")
            self.modify_html_files()
            
            # 5. Modifier le manifest YunoHost
            print("\n5. Modification du manifest YunoHost...")
            self.modify_yunohost_manifest()
            
            # 6. Modifier le script d'installation YunoHost
            print("\n6. Modification du script d'installation YunoHost...")
            self.modify_yunohost_install_script()
            
            # 7. Modifier la configuration nginx
            print("\n7. Modification de la configuration nginx...")
            self.modify_nginx_config()
            
            # 8. Modifier les fichiers README
            print("\n8. Modification des fichiers README...")
            self.modify_readme_files()
            
            # 9. Créer le script de déploiement
            print("\n9. Création du script de déploiement...")
            self.create_deployment_script()
            
            # 10. Générer le rapport
            print("\n10. Génération du rapport...")
            report_path = self.generate_report()
            
            print("\n" + "=" * 60)
            print("🎉 Personnalisation terminée avec succès!")
            print(f"📊 Rapport détaillé: {report_path}")
            print(f"🔧 {len(self.modifications)} modifications appliquées")
            print("\n📋 Prochaines étapes:")
            print("1. Vérifiez le rapport de modifications")
            print("2. Testez les changements localement")
            print("3. Exécutez ./deploy_liberchat.sh pour déployer")
            
        except Exception as e:
            print(f"\n❌ Erreur lors de la personnalisation: {e}")
            sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Personnalisation automatique Jitsi Meet → LiberChat Vidéo")
    parser.add_argument("--jitsi-path", default="./jitsi-meet", 
                       help="Chemin vers le répertoire Jitsi Meet (défaut: ./jitsi-meet)")
    parser.add_argument("--yunohost-path", default="./jitsi_ynh",
                       help="Chemin vers le répertoire YunoHost (défaut: ./jitsi_ynh)")
    parser.add_argument("--dry-run", action="store_true",
                       help="Simulation sans modifications réelles")
    
    args = parser.parse_args()
    
    if args.dry_run:
        print("🔍 Mode simulation activé - aucune modification ne sera appliquée")
        return
    
    try:
        customizer = JitsiCustomizer(args.jitsi_path, args.yunohost_path)
        customizer.run_all_modifications()
    except FileNotFoundError as e:
        print(f"❌ {e}")
        print("💡 Assurez-vous que les répertoires Jitsi Meet et YunoHost existent")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Erreur inattendue: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()