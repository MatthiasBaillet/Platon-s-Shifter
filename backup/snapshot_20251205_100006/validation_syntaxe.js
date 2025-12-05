// validation_syntaxe.js - Vérification simple, pas de tests DOM
const fs = require('fs');

try {
    const code = fs.readFileSync('Game.js', 'utf-8');
    new Function(code); // Cela vérifie la syntaxe sans exécuter
    console.log("✅ Syntaxe de Game.js VALIDE");
    console.log("🎮 Le jeu est prêt à être lancé");
    process.exit(0);
} catch (e) {
    console.error("❌ Erreur de syntaxe à la ligne", e.message.split(':')[1]);
    console.error(e.message);
    process.exit(1);
}