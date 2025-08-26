/**
 * LiberChat - Éliminateur de bleu dynamique
 * Ce script traque et élimine toute trace de bleu dans l'interface
 */

(function() {
    'use strict';

    // Configuration des couleurs LiberChat
    const LIBERCHAT_COLORS = {
        primary: '#8B0000',
        accent: '#FF0000',
        text: '#FFFFFF',
        background: '#000000'
    };

    // Liste des couleurs bleues à remplacer
    const BLUE_COLORS = [
        '#0000FF', '#0074E0', '#4687ED', '#007bff', '#0052CC', '#00225A',
        '#1976d2', '#2196f3', '#03a9f4', '#00bcd4', '#0d6efd', '#0a58ca',
        'rgb(0, 116, 224)', 'rgb(70, 135, 237)', 'rgb(0, 123, 255)',
        'rgb(13, 110, 253)', 'rgb(25, 118, 210)', 'blue'
    ];

    // Fonction pour vérifier si une couleur est bleue
    function isBlueColor(color) {
        if (!color) return false;
        
        const colorStr = color.toLowerCase().trim();
        
        // Vérifier les couleurs nommées
        if (colorStr === 'blue') return true;
        
        // Vérifier les couleurs hex
        if (colorStr.match(/#[0-9a-f]{6}/i)) {
            const hex = colorStr.replace('#', '');
            const r = parseInt(hex.substr(0, 2), 16);
            const g = parseInt(hex.substr(2, 2), 16);
            const b = parseInt(hex.substr(4, 2), 16);
            
            // Si le bleu est dominant et les autres couleurs sont faibles
            return b > 150 && b > r + 50 && b > g + 50;
        }
        
        // Vérifier les couleurs RGB
        const rgbMatch = colorStr.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/);
        if (rgbMatch) {
            const r = parseInt(rgbMatch[1]);
            const g = parseInt(rgbMatch[2]);
            const b = parseInt(rgbMatch[3]);
            
            return b > 150 && b > r + 50 && b > g + 50;
        }
        
        // Vérifier la liste des couleurs bleues connues
        return BLUE_COLORS.some(blueColor => colorStr.includes(blueColor.toLowerCase()));
    }

    // Fonction pour remplacer une couleur bleue
    function replaceBlueColor(color) {
        if (!color) return color;
        
        const colorStr = color.toLowerCase().trim();
        
        // Remplacements spécifiques
        const replacements = {
            '#0074E0': LIBERCHAT_COLORS.primary,
            '#4687ED': LIBERCHAT_COLORS.accent,
            '#007bff': LIBERCHAT_COLORS.primary,
            'rgb(0, 116, 224)': LIBERCHAT_COLORS.primary,
            'rgb(70, 135, 237)': LIBERCHAT_COLORS.accent,
            'blue': LIBERCHAT_COLORS.accent
        };

        for (const [blueColor, replacement] of Object.entries(replacements)) {
            if (colorStr.includes(blueColor)) {
                return replacement;
            }
        }

        // Si c'est une couleur bleue non listée, utiliser la couleur primaire
        if (isBlueColor(color)) {
            return LIBERCHAT_COLORS.primary;
        }

        return color;
    }

    // Fonction pour traiter un élément
    function processElement(element) {
        if (!element || element.nodeType !== Node.ELEMENT_NODE) return;

        // Traiter les styles inline
        const style = element.style;
        if (style) {
            // Background color
            if (style.backgroundColor && isBlueColor(style.backgroundColor)) {
                style.backgroundColor = replaceBlueColor(style.backgroundColor);
            }

            // Color
            if (style.color && isBlueColor(style.color)) {
                style.color = replaceBlueColor(style.color);
            }

            // Border color
            if (style.borderColor && isBlueColor(style.borderColor)) {
                style.borderColor = replaceBlueColor(style.borderColor);
            }

            // Border (shorthand)
            if (style.border && isBlueColor(style.border)) {
                style.border = style.border.replace(/blue|#[0-9a-f]{6}/gi, LIBERCHAT_COLORS.accent);
            }
        }

        // Traiter les styles calculés
        const computedStyle = window.getComputedStyle(element);
        if (computedStyle) {
            const bgColor = computedStyle.backgroundColor;
            const textColor = computedStyle.color;
            const borderColor = computedStyle.borderColor;

            if (isBlueColor(bgColor)) {
                element.style.backgroundColor = replaceBlueColor(bgColor);
            }

            if (isBlueColor(textColor)) {
                element.style.color = replaceBlueColor(textColor);
            }

            if (isBlueColor(borderColor)) {
                element.style.borderColor = replaceBlueColor(borderColor);
            }
        }

        // Traiter les attributs spéciaux
        ['fill', 'stroke'].forEach(attr => {
            const value = element.getAttribute(attr);
            if (value && isBlueColor(value)) {
                element.setAttribute(attr, replaceBlueColor(value));
            }
        });

        // Traiter les classes suspectes
        const className = element.className;
        if (typeof className === 'string') {
            const suspiciousClasses = ['primary', 'info', 'blue'];
            const hasBlueClass = suspiciousClasses.some(cls => 
                className.toLowerCase().includes(cls)
            );

            if (hasBlueClass) {
                element.style.backgroundColor = LIBERCHAT_COLORS.primary;
                element.style.borderColor = LIBERCHAT_COLORS.accent;
                element.style.color = LIBERCHAT_COLORS.text;
            }
        }
    }

    // Fonction pour scanner tous les éléments
    function scanAllElements() {
        const elements = document.querySelectorAll('*');
        elements.forEach(processElement);
    }

    // Observer pour les changements DOM
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            // Traiter les nouveaux nœuds
            mutation.addedNodes.forEach(function(node) {
                if (node.nodeType === Node.ELEMENT_NODE) {
                    processElement(node);
                    // Traiter aussi les enfants
                    const children = node.querySelectorAll('*');
                    children.forEach(processElement);
                }
            });

            // Traiter les changements d'attributs
            if (mutation.type === 'attributes') {
                processElement(mutation.target);
            }
        });
    });

    // Fonction d'initialisation
    function init() {
        console.log('🔴 LiberChat - Éliminateur de bleu activé');

        // Scanner initial
        scanAllElements();

        // Démarrer l'observation
        observer.observe(document.body, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['style', 'class', 'fill', 'stroke']
        });

        // Scanner périodique (au cas où)
        setInterval(scanAllElements, 2000);

        // Scanner lors des événements
        ['load', 'DOMContentLoaded', 'resize'].forEach(event => {
            window.addEventListener(event, scanAllElements);
        });

        console.log('✅ Éliminateur de bleu initialisé');
    }

    // Démarrer quand le DOM est prêt
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Exposer globalement pour debug
    window.LiberChatNoBlue = {
        scan: scanAllElements,
        process: processElement,
        isBlue: isBlueColor,
        replace: replaceBlueColor,
        colors: LIBERCHAT_COLORS
    };

})();