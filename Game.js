// ============================================================================
// PLATON'S SHIFTER - VERSION 4.3 MODULAIRE
// ============================================================================
// Structure : CONFIG → STATE → ENTITIES → SYSTEMS → UI → INIT
// ============================================================================

// ==================== CONFIGURATION CENTRALE (C) ====================
const CONFIG = {
    GRID_SIZE: 40,
    PLAYER_SIZE: 30,
    ENEMY_SIZE: 25,
    ESSENCE_SIZE: 20,
    POWER_COOLDOWN: 3000,
    KILLS_TO_UNLOCK_CUBE: 5,
    LASER_COST: 2,
    CANVAS_WIDTH: 800,
    CANVAS_HEIGHT: 500
};

const SHAPES = [
    { id: 0, name: "TÉTRAÈDRE", color: "#FF4444", speed: 6, special: "laser", unlocked: true },
    { id: 1, name: "CUBE", color: "#D2B48C", speed: 2, special: "drawing", unlocked: false },
    { id: 2, name: "OCTAÈDRE", color: "#44FF44", speed: 4, special: "doubleJump", unlocked: false },
    { id: 3, name: "DODÉCAÈDRE", color: "#FFD700", speed: 3, special: "timeSlow", unlocked: false },
    { id: 4, name: "ICOSAÈDRE", color: "#FF00FF", speed: 5, special: "blast", unlocked: false }
];

// ==================== ÉTAT GLOBAL (STATE) ====================
const GameState = {
    player: null,
    enemies: [],
    essences: [],
    terrainZones: [],
    enemyBases: [],
    startBase: null,
    currentShape: 0,
    score: 0,
    health: 3,
    lastPowerUse: 0,
    isPowerActive: false,
    enemiesKilledWithLaser: 0,
    keys: {},
    gameLoop: null,
    lastTime: 0,
    mouseX: 0,
    mouseY: 0,
    isLaserActive: false,
    isDrawing: false,
    currentDrawingPoints: []
};

// ==================== SYSTÈMES (SYSTEMS) ====================
// Chaque système est une fonction pure qui modifie l'état

const InputSystem = {
    init: () => {
        document.addEventListener('keydown', (e) => {
            GameState.keys[e.key] = true;
            if (e.key >= '1' && e.key <= '5') {
                const shapeIndex = parseInt(e.key) - 1;
                if (SHAPES[shapeIndex].unlocked) {
                    GameState.currentShape = shapeIndex;
                    UI_System.updateShapeButtons();
                }
            }
        });
        document.addEventListener('keyup', (e) => { GameState.keys[e.key] = false; });
    }
};

const EntitySystem = {
    createEnemyBases: () => {
        GameState.startBase = {
            x: CONFIG.CANVAS_WIDTH / 2,
            y: CONFIG.CANVAS_HEIGHT / 2,
            radius: CONFIG.GRID_SIZE * 2.5
        };
        for (let i = 0; i < 3; i++) {
            GameState.enemyBases.push({
                x: 100 + i * 200, y: 100 + i * 50,
                radius: CONFIG.GRID_SIZE * 2
            });
        }
    },
    
    createEnemy: () => {
        const base = GameState.enemyBases[Math.floor(Math.random() * GameState.enemyBases.length)];
        return {
            x: base.x, y: base.y,
            vx: (Math.random() - 0.5) * 2,
            vy: (Math.random() - 0.5) * 2,
            size: CONFIG.ENEMY_SIZE, color: '#FF0000'
        };
    },
    
    createEssence: () => ({
        x: Math.random() * CONFIG.CANVAS_WIDTH,
        y: Math.random() * CONFIG.CANVAS_HEIGHT,
        size: CONFIG.ESSENCE_SIZE, collected: false,
        pulsePhase: Math.random() * Math.PI * 2
    })
};

const PhysicsSystem = {
    updatePlayer: () => {
        const shape = SHAPES[GameState.currentShape];
        if (GameState.keys['z'] || GameState.keys['ArrowUp']) GameState.player.y -= shape.speed;
        if (GameState.keys['s'] || GameState.keys['ArrowDown']) GameState.player.y += shape.speed;
        if (GameState.keys['q'] || GameState.keys['ArrowLeft']) GameState.player.x -= shape.speed;
        if (GameState.keys['d'] || GameState.keys['ArrowRight']) GameState.player.x += shape.speed;
        
        GameState.player.x = Math.max(15, Math.min(CONFIG.CANVAS_WIDTH - 15, GameState.player.x));
        GameState.player.y = Math.max(15, Math.min(CONFIG.CANVAS_HEIGHT - 15, GameState.player.y));
    },
    
    updateEnemies: () => {
        GameState.enemies.forEach(enemy => {
            enemy.x += enemy.vx;
            enemy.y += enemy.vy;
            if (enemy.x < 10 || enemy.x > CONFIG.CANVAS_WIDTH - 10) enemy.vx *= -1;
            if (enemy.y < 10 || enemy.y > CONFIG.CANVAS_HEIGHT - 10) enemy.vy *= -1;
        });
    }
};

const CollisionSystem = {
    check: () => {
        // Collisions essences
        GameState.essences.forEach((essence, index) => {
            if (!essence.collected) {
                const dx = GameState.player.x - essence.x;
                const dy = GameState.player.y - essence.y;
                const distance = Math.sqrt(dx*dx + dy*dy);
                if (distance < (CONFIG.PLAYER_SIZE + essence.size) / 2) {
                    essence.collected = true;
                    GameState.player.energy += 5;
                    GameState.score += 50;
                    setTimeout(() => { GameState.essences[index] = EntitySystem.createEssence(); }, 2000);
                }
            }
        });
        
        // Collisions ennemis
        GameState.enemies.forEach(enemy => {
            const dx = GameState.player.x - enemy.x;
            const dy = GameState.player.y - enemy.y;
            const distance = Math.sqrt(dx*dx + dy*dy);
            if (distance < (CONFIG.PLAYER_SIZE + enemy.size) / 2) {
                GameState.health--;
                UI_System.updateHealthDisplay();
                enemy.x = Math.random() * CONFIG.CANVAS_WIDTH;
                enemy.y = Math.random() * CONFIG.CANVAS_HEIGHT;
                if (GameState.health <= 0) {
                    cancelAnimationFrame(GameState.gameLoop);
                    alert(`💀 GAME OVER\nScore: ${GameState.score}\nÉnergie: ${GameState.player.energy}`);
                }
            }
        });
    }
};

const PowerSystem = {
    activate: () => {
        if (GameState.isPowerActive) return;
        const now = Date.now();
        const timeSinceLastUse = now - GameState.lastPowerUse;
        if (timeSinceLastUse < CONFIG.POWER_COOLDOWN) return;
        
        const shape = SHAPES[GameState.currentShape];
        switch(shape.special) {
            case 'laser':
                PowerSystem.activateLaser();
                break;
            case 'doubleJump':
                GameState.player.y -= 100;
                break;
        }
        GameState.lastPowerUse = now;
        GameState.isPowerActive = true;
        setTimeout(() => { GameState.isPowerActive = false; }, 1000);
    },
    
    activateLaser: () => {
        if (GameState.player.energy >= CONFIG.LASER_COST) {
            GameState.player.energy -= CONFIG.LASER_COST;
            GameState.isLaserActive = true;
            setTimeout(() => { GameState.isLaserActive = false; }, 500);
        }
    }
};

// ==================== RENDU (RENDER) ====================
const RenderSystem = {
    clear: () => {
        GameState.ctx.fillStyle = 'rgba(0, 0, 0, 0.1)';
        GameState.ctx.fillRect(0, 0, CONFIG.CANVAS_WIDTH, CONFIG.CANVAS_HEIGHT);
    },
    
    drawStartBase: () => {
        if (!GameState.startBase) return;
        GameState.ctx.save();
        GameState.ctx.fillStyle = 'rgba(100, 200, 255, 0.2)';
        GameState.ctx.strokeStyle = '#00ffff';
        GameState.ctx.lineWidth = 3;
        GameState.ctx.beginPath();
        GameState.ctx.arc(GameState.startBase.x, GameState.startBase.y, GameState.startBase.radius, 0, Math.PI * 2);
        GameState.ctx.fill();
        GameState.ctx.stroke();
        GameState.ctx.restore();
    },
    
    drawEnemyBases: () => {
        GameState.enemyBases.forEach(base => {
            GameState.ctx.fillStyle = 'rgba(255, 0, 0, 0.2)';
            GameState.ctx.strokeStyle = '#ff4444';
            GameState.ctx.lineWidth = 2;
            GameState.ctx.beginPath();
            GameState.ctx.arc(base.x, base.y, base.radius, 0, Math.PI * 2);
            GameState.ctx.fill();
            GameState.ctx.stroke();
        });
    },
    
    drawEssences: () => {
        GameState.essences.forEach(essence => {
            if (!essence.collected) {
                GameState.ctx.save();
                GameState.ctx.translate(essence.x, essence.y);
                const pulse = Math.sin(Date.now() * 0.003 + essence.pulsePhase) * 0.3 + 0.7;
                const currentSize = essence.size * pulse;
                GameState.ctx.shadowBlur = 20;
                GameState.ctx.shadowColor = '#00ffff';
                GameState.ctx.beginPath();
                GameState.ctx.arc(0, 0, currentSize, 0, Math.PI * 2);
                GameState.ctx.fillStyle = '#00ffff';
                GameState.ctx.fill();
                GameState.ctx.restore();
            }
        });
    },
    
    drawEnemies: () => {
        GameState.enemies.forEach(enemy => {
            GameState.ctx.fillStyle = enemy.color;
            GameState.ctx.beginPath();
            GameState.ctx.arc(enemy.x, enemy.y, enemy.size/2, 0, Math.PI * 2);
            GameState.ctx.fill();
        });
    },
    
    drawPlayer: () => {
        const shape = SHAPES[GameState.currentShape];
        GameState.ctx.save();
        GameState.ctx.translate(GameState.player.x, GameState.player.y);
        GameState.ctx.fillStyle = shape.color;
        GameState.ctx.fillRect(-CONFIG.PLAYER_SIZE/2, -CONFIG.PLAYER_SIZE/2, CONFIG.PLAYER_SIZE, CONFIG.PLAYER_SIZE);
        GameState.ctx.restore();
    }
};

// ==================== UI SYSTEM ====================
const UI_System = {
    updateShapeButtons: () => {
        const buttons = document.querySelectorAll('.shape-btn');
        buttons.forEach((btn, index) => {
            btn.classList.toggle('locked', !SHAPES[index].unlocked);
            btn.classList.toggle('active', index === GameState.currentShape);
            if (btn.classList.contains('active')) {
                btn.innerHTML = `<strong>${SHAPES[index].name}</strong><br>✅ ACTIF`;
            } else if (btn.classList.contains('locked')) {
                btn.innerHTML = `<strong>${SHAPES[index].name}</strong><br>🔒 VERROUILLÉ`;
            } else {
                btn.innerHTML = `<strong>${SHAPES[index].name}</strong><br>✨ DISPONIBLE`;
            }
        });
    },
    
    updateHealthDisplay: () => {
        const healthSpan = document.getElementById('health');
        if (healthSpan) {
            let healthText = '';
            for (let i = 0; i < GameState.health; i++) healthText += '❤️';
            healthSpan.textContent = healthText || '💀';
        }
    },
    
    updateEnergyDisplay: () => {
        const energySpan = document.getElementById('energy');
        if (energySpan) energySpan.textContent = GameState.player.energy;
    }
};

// ==================== BOUCLE PRINCIPALE ====================
function gameUpdate(timestamp) {
    if (!GameState.ctx) return;
    
    if (timestamp - GameState.lastTime > 16) {
        GameState.lastTime = timestamp;
        
        // UPDATE SYSTEMS
        PhysicsSystem.updatePlayer();
        PhysicsSystem.updateEnemies();
        CollisionSystem.check();
        
        // RENDER
        RenderSystem.clear();
        RenderSystem.drawStartBase();
        RenderSystem.drawEnemyBases();
        RenderSystem.drawEssences();
        RenderSystem.drawEnemies();
        RenderSystem.drawPlayer();
        
        // UI UPDATE
        document.getElementById('score').textContent = GameState.score;
        UI_System.updateEnergyDisplay();
    }
    
    GameState.gameLoop = requestAnimationFrame(gameUpdate);
}

// ==================== INITIALISATION ====================
function init() {
    console.log("🎬 Initialisation du jeu modulaire...");
    
    // VÉRIFICATION CRITIQUE
    const canvasElement = document.getElementById('gameCanvas');
    if (!canvasElement) {
        console.error("❌ Canvas introuvable !");
        document.body.innerHTML = "<h1 style='color:red'>ERREUR: Canvas manquant</h1>";
        return;
    }
    
    GameState.ctx = canvasElement.getContext('2d');
    if (!GameState.ctx) {
        console.error("❌ Context 2D introuvable !");
        return;
    }
    
    GameState.canvas = canvasElement;
    
    // INITIALISATION DES ENTITÉS
    EntitySystem.createEnemyBases();
    GameState.player = {
        x: GameState.startBase.x,
        y: GameState.startBase.y,
        shape: 0,
        velocity: {x:0, y:0},
        energy: 0
    };
    
    // POPULATION
    for (let i = 0; i < 8; i++) GameState.enemies.push(EntitySystem.createEnemy());
    for (let i = 0; i < 3; i++) GameState.essences.push(EntitySystem.createEssence());
    
    // INITIALISATION UI
    UI_System.updateShapeButtons();
    UI_System.updateHealthDisplay();
    UI_System.updateEnergyDisplay();
    
    // LANCER BOUCLE
    GameState.gameLoop = requestAnimationFrame(gameUpdate);
    
    console.log("✅ Jeu initialisé avec succès !");
}

// ==================== DÉMARRAGE SÉCURISÉ ====================
console.log("⏳ Attente DOM...");
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}
console.log("✅ Script modulaire chargé");