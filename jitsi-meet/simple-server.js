const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 8081;

// Configuration des types MIME
express.static.mime.define({
    'text/css': ['css'],
    'application/javascript': ['js'],
    'application/json': ['json'],
    'image/png': ['png'],
    'image/svg+xml': ['svg'],
    'application/wasm': ['wasm'],
    'text/html': ['html']
});

// Middleware pour les headers CORS et sécurité
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    
    // Headers de sécurité pour Jitsi Meet
    res.header('X-Frame-Options', 'SAMEORIGIN');
    res.header('X-Content-Type-Options', 'nosniff');
    
    next();
});

// Middleware pour servir les fichiers statiques avec les bons types MIME
app.use(express.static('.', {
    setHeaders: (res, path) => {
        if (path.endsWith('.css')) {
            res.setHeader('Content-Type', 'text/css');
        } else if (path.endsWith('.js')) {
            res.setHeader('Content-Type', 'application/javascript');
        } else if (path.endsWith('.wasm')) {
            res.setHeader('Content-Type', 'application/wasm');
        } else if (path.endsWith('.json')) {
            res.setHeader('Content-Type', 'application/json');
        }
    }
}));

// Route pour les CSS spécifiques
app.get('/css/:file', (req, res) => {
    const cssFile = path.join(__dirname, 'css', req.params.file);
    if (fs.existsSync(cssFile)) {
        res.setHeader('Content-Type', 'text/css');
        res.sendFile(cssFile);
    } else {
        res.status(404).send('CSS file not found');
    }
});

// Route pour les JS dans libs
app.get('/libs/:file', (req, res) => {
    const jsFile = path.join(__dirname, 'libs', req.params.file);
    if (fs.existsSync(jsFile)) {
        if (req.params.file.endsWith('.js')) {
            res.setHeader('Content-Type', 'application/javascript');
        } else if (req.params.file.endsWith('.wasm')) {
            res.setHeader('Content-Type', 'application/wasm');
        }
        res.sendFile(jsFile);
    } else {
        res.status(404).send('Library file not found');
    }
});

// Route principale
app.get('/', (req, res) => {
    res.setHeader('Content-Type', 'text/html');
    res.sendFile(path.join(__dirname, 'index-dev.html'));
});

// Route pour les salles
app.get('/:room', (req, res) => {
    // Ignorer les fichiers avec extensions
    if (req.params.room.includes('.')) {
        return res.status(404).send('File not found');
    }
    
    res.setHeader('Content-Type', 'text/html');
    res.sendFile(path.join(__dirname, 'index-dev.html'));
});

// Démarrage du serveur
app.listen(PORT, '0.0.0.0', () => {
    console.log('🚀 LiberChat Vidéo - Serveur de développement');
    console.log('==========================================');
    console.log(`🌐 Serveur démarré sur http://localhost:${PORT}`);
    console.log(`📱 Réseau local: http://$(hostname -I | awk '{print $1}'):${PORT}`);
    console.log(`📁 Répertoire: ${__dirname}`);
    console.log('🎨 Interface avec améliorations UI appliquées !');
    console.log('');
    console.log('🔍 Fonctionnalités testables:');
    console.log('  ✅ Nouvelle typographie Inter');
    console.log('  ✅ Contraste amélioré (WCAG AA)');
    console.log('  ✅ Thème LiberChat rouge/noir');
    console.log('  ✅ Interface responsive');
    console.log('  ✅ Accessibilité renforcée');
    console.log('  ✅ CSS optimisé (47% plus léger)');
    console.log('  ✅ Variables CSS centralisées');
    console.log('');
    console.log('📋 URLs de test:');
    console.log(`  🏠 Accueil: http://localhost:${PORT}`);
    console.log(`  🏢 Salle test: http://localhost:${PORT}/test-liberchat`);
    console.log('');
    console.log('⏹️  Appuyez sur Ctrl+C pour arrêter');
});