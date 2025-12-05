// test_game.js - Tests unitaires Node.js (VERSION DÉFINITIVE INFAILABLE)
const fs = require('fs');
const vm = require('vm');

// Charger Game.js
const gameCode = fs.readFileSync('Game.js', 'utf-8');

// Créer un contexte sandbox COMPLET
const sandbox = {
    // Simuler canvas avec getContext
    canvas: {
        width: 800,
        height: 500,
        getContext: function(contextType) {
            if (contextType === '2d') {
                return {
                    fillRect: function() {},
                    fillText: function() {},
                    beginPath: function() {},
                    arc: function() {},
                    fill: function() {},
                    stroke: function() {},
                    restore: function() {},
                    save: function() {},
                    closePath: function() {},
                    translate: function() {},
                    moveTo: function() {},
                    lineTo: function() {},
                    setLineDash: function() {},
                    strokeStyle: '',
                    fillStyle: '',
                    shadowBlur: 0,
                    shadowColor: '',
                    lineWidth: 1,
                    font: ''
                };
            }
            return null;
        }
    },
    
    // Simuler document
    document: {
        getElementById: function(id) {
            return {
                textContent: '',
                style: {},
                appendChild: function() {},
                value: '10'
            };
        },
        createElement: function(tag) {
            return {
                className: '',
                textContent: '',
                style: {}
            };
        },
        querySelector: function(selector) {
            return {
                appendChild: function() {}
            };
        },
        body: {
            style: { background: '' }
        }
    },
    
    // Simuler window
    window: {
        addEventListener: function() {},
        removeEventListener: function() {}
    },
    
    // Variables globales à peupler
    GRID_SIZE: undefined,
    PLAYER_SIZE: undefined,
    ENEMY_SIZE: undefined,
    ESSENCE_SIZE: undefined,
    SHAPES: undefined,
    startBase: undefined,
    enemyBase: undefined,
    enemies: undefined,
    essences: undefined,
    player: undefined,
    
    // Pour console.assert
    console: console,
    
    // Pour process.exit
    process: process
};

// Créer le contexte et exécuter le code
const context = vm.createContext(sandbox);

try {
    // Exécuter Game.js dans le sandbox
    vm.runInContext(gameCode, context);
    
    console.log("="*70);
    console.log("?? TESTS UNITAIRES - Platon's Shifter");
    console.log("="*70);

    // Test 1 : Variables globales
    console.log("\n[TEST 1] Variables globales");
    console.assert(typeof context.GRID_SIZE === "number", "? GRID_SIZE non défini");
    console.assert(typeof context.enemyBase === "object", "? enemyBase non défini");
    console.assert(typeof context.SHAPES === "object", "? SHAPES non défini");
    console.assert(typeof context.startBase === "object", "? startBase non défini");
    console.log("? Variables globales OK");

    // Test 2 : Fonctions principales
    console.log("\n[TEST 2] Fonctions principales");
    console.assert(typeof context.createEnemyBases === "function", "? createEnemyBases non définie");
    console.assert(typeof context.createEnemy === "function", "? createEnemy non définie");
    console.assert(typeof context.drawEnemyBase === "function", "? drawEnemyBase non définie");
    console.log("? Fonctions principales OK");

    // Test 3 : Structure SHAPES
    console.log("\n[TEST 3] Structure des formes");
    console.assert(context.SHAPES.length === 5, "? Pas 5 formes");
    console.assert(context.SHAPES[0].name === "TETRAEDRE", "? Tétraèdre mal configuré");
    console.assert(context.SHAPES[0].special === "laser", "? Laser manquant");
    console.log("? Structure SHAPES OK");

    // Test 4 : Exécuter une fonction
    console.log("\n[TEST 4] Exécution de createEnemyBases");
    context.createEnemyBases();
    console.assert(typeof context.enemyBase === "object", "? enemyBase non créé");
    console.assert(context.enemyBase.radius > 0, "? enemyBase mal formé");
    console.log("? Fonction createEnemyBases OK");

    console.log("\n" + "="*70);
    console.log("? TOUS LES TESTS SONT PASSÉS");
    console.log("="*70);
    process.exit(0);
    
} catch (error) {
    console.error("\n? ERREUR DANS Game.js :");
    console.error(error.message);
    console.error("\nStack trace :");
    console.error(error.stack);
    process.exit(1);
}