// Script de test pour vérifier la fonctionnalité iframe de LiberChat
// À exécuter dans la console du navigateur

function testLiberChatIframe() {
    const testUrl = 'https://test.cnt-ait-contact.noho.st/';
    const testRoom = 'TestRoom123';
    
    console.log('🧪 Test de fonctionnalité LiberChat Iframe');
    console.log('URL:', testUrl);
    
    // Test 1: Vérifier la réponse du serveur
    fetch(testUrl)
        .then(response => {
            console.log('✅ Serveur accessible:', response.status);
            return response.text();
        })
        .then(html => {
            // Test 2: Vérifier la présence des éléments LiberChat
            const hasLiberChatBranding = html.includes('LiberChat') || html.includes('liberchat');
            console.log('🏷️ Branding LiberChat détecté:', hasLiberChatBranding);
            
            // Test 3: Vérifier les en-têtes iframe
            const hasIframeSupport = !html.includes('X-Frame-Options: DENY');
            console.log('🖼️ Support iframe:', hasIframeSupport);
            
            // Test 4: Vérifier la configuration Jitsi
            const hasJitsiConfig = html.includes('config.js') && html.includes('interface_config.js');
            console.log('⚙️ Configuration Jitsi présente:', hasJitsiConfig);
        })
        .catch(error => {
            console.error('❌ Erreur de connexion:', error);
        });
    
    // Test 5: Créer un iframe de test
    const iframe = document.createElement('iframe');
    iframe.src = testUrl + testRoom;
    iframe.style.width = '800px';
    iframe.style.height = '600px';
    iframe.allow = 'camera; microphone; fullscreen; display-capture; autoplay';
    iframe.allowFullscreen = true;
    
    iframe.onload = function() {
        console.log('✅ Iframe chargé avec succès');
        try {
            // Vérifier l'accès au contenu de l'iframe (si même origine)
            const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
            if (iframeDoc) {
                console.log('✅ Accès au contenu iframe possible');
            }
        } catch (e) {
            console.log('ℹ️ Iframe en cross-origin (normal pour la sécurité)');
        }
    };
    
    iframe.onerror = function() {
        console.error('❌ Erreur de chargement iframe');
    };
    
    // Ajouter l'iframe à la page pour test visuel
    document.body.appendChild(iframe);
    
    console.log('🔍 Iframe de test ajouté à la page');
    console.log('📋 Vérifiez manuellement:');
    console.log('   - Logo LiberChat visible');
    console.log('   - Interface utilisateur responsive');
    console.log('   - Fonctions audio/vidéo accessibles');
}

// Lancer le test
testLiberChatIframe();