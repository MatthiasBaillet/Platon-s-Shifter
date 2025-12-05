// PLATON'S SHIFTER - Version 4.2 (Corrigée & Stable)
// Code final sans fuites mémoire ni erreurs DOM

const GRID_SIZE = 40;
let PLAYER_SIZE = 30;
const ENEMY_SIZE = 25;
const ESSENCE_SIZE = 20;

let SHAPES = [
    { name: "TETRAEDRE", color: "#FF4444", speed: 6, attack: 2, special: "laser" },
    { name: "CUBE", color: "#D2B48C", speed: 2, attack: 1, special: "drawing" },
    { name: "OCTAEDRE", color: "#44FF44", speed: 4, attack: 3, special: "doubleJump" },
    { name: "DODECAEDRE", color: "#FFD700", speed: 3, attack: 4, special: "timeSlow" },
    { name: "ICOSAEDRE", color: "#FF00FF", speed: 5, attack: 5, special: "blast" }
];

let canvas = document.getElementById('gameCanvas');
let ctx = canvas.getContext('2d');
let player = { x: 400, y: 250, shape: 0, velocity: { x: 0, y: 0 }, energy: 0 };
let enemies = [];
let essences = [];
let terrainZones = [];
let startBase = null;
let enemyBase = null;
let unlockedShapes = [0];
let currentShape = 0;
let score = 0;
let health = 3;
let keys = {};
let gameLoop = null;
let lastTime = 0;

let powerCooldown = 3000;
let lastPowerUse = 0;
let isPowerActive = false;
let powerEffects = [];
let killsToUnlockCube = 5;
let enemiesKilledWithLaser = 0;
let laserCost = 2;

let mouseX = 0;
let mouseY = 0;
let isLaserActive = false;
let isDrawing = false;
let currentDrawingPoints = [];

// DECLARATION CRITIQUE : statusDiv
const statusDiv = document.getElementById('status');
const killsDiv = document.getElementById('killsDisplay');
const healthDiv = document.getElementById('health');

document.addEventListener('DOMContentLoaded', function() {
    if (!document.getElementById('gameCanvas')) {
        alert('ERREUR: Canvas gameCanvas manquant dans le HTML!');
        return;
    }
    init();
});

function init() {
    createEnemyBases();
    player.x = startBase.x;
    player.y = startBase.y;
    
    for (let i = 0; i < 8; i++) enemies.push(createEnemy());
    for (let i = 0; i < 3; i++) essences.push(createEssence());
    updateShapeButtons();
    updateKillsDisplay();
    updateEnergyDisplay();
    gameLoop = requestAnimationFrame(update);
}

function createEnemyBases() {
    startBase = {
        x: Math.random() * (canvas.width - GRID_SIZE * 8) + GRID_SIZE * 4,
        y: Math.random() * (canvas.height - GRID_SIZE * 8) + GRID_SIZE * 4,
        radius: GRID_SIZE * 1.5
    };

    enemyBase = {
        x: canvas.width * 0.75,
        y: canvas.height * 0.25,
        radius: GRID_SIZE * 1.5
    };
}

function createEnemy() {
    const base = enemyBase;
    const angle = Math.random() * Math.PI * 2;
    const distance = base.radius + Math.random() * 50;
    return {
        x: base.x + Math.cos(angle) * distance,
        y: base.y + Math.sin(angle) * distance,
        vx: (Math.random() - 0.5) * 2,
        vy: (Math.random() - 0.5) * 2,
        size: ENEMY_SIZE,
        color: '#FF0000',
        originalSpeed: 1
    };
}

function createEssence() {
    return {
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        size: ESSENCE_SIZE,
        collected: false,
        pulsePhase: Math.random() * Math.PI * 2
    };
}

function update(timestamp) {
    if (timestamp - lastTime > 16) {
        lastTime = timestamp;
        ctx.fillStyle = 'rgba(0, 0, 0, 0.1)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        
        updatePlayer();
        updateEnemies();
        updatePowerEffects();
        drawStartBase();
        drawEnemyBase();
        drawLaser();
        drawDrawingPreview();
        drawEssences();
        drawEnemies();
        drawPowerEffects();
        drawTerrainZones();
        drawPlayer();
        checkCollisions();
        updatePowerUI();
    }
    gameLoop = requestAnimationFrame(update);
}

function updatePlayer() {
    let shape = SHAPES[currentShape];
    let targetVx = 0, targetVy = 0;
    if (keys['z'] || keys['Z'] || keys['w'] || keys['W'] || keys['ArrowUp']) targetVy = -shape.speed;
    if (keys['s'] || keys['S'] || keys['ArrowDown']) targetVy = shape.speed;
    if (keys['q'] || keys['Q'] || keys['a'] || keys['A'] || keys['ArrowLeft']) targetVx = -shape.speed;
    if (keys['d'] || keys['D'] || keys['ArrowRight']) targetVx = shape.speed;

    if (targetVx !== 0 || targetVy !== 0) {
        let futureX = player.x + targetVx;
        let futureY = player.y + targetVy;
        let canMove = true;
        terrainZones.forEach(zone => {
            let currentInside = isPointInPolygon({x: player.x, y: player.y}, zone.points);
            let futureInside = isPointInPolygon({x: futureX, y: futureY}, zone.points);
            if (!currentInside && futureInside) canMove = false;
        });
        if (canMove) {
            player.x = futureX;
            player.y = futureY;
        }
    }

    player.x = Math.max(PLAYER_SIZE/2, Math.min(canvas.width - PLAYER_SIZE/2, player.x));
    player.y = Math.max(PLAYER_SIZE/2, Math.min(canvas.height - PLAYER_SIZE/2, player.y));

    if (keys[' '] && shape.special === 'doubleJump' && !isPowerActive) activateDoubleJump();
}

function isPointInPolygon(point, polygon) {
    let inside = false;
    for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
        let xi = polygon[i].x, yi = polygon[i].y;
        let xj = polygon[j].x, yj = polygon[j].y;
        let intersect = ((yi > point.y) != (yj > point.y))
            && (point.x < (xj - xi) * (point.y - yi) / (yj - yi) + xi);
        if (intersect) inside = !inside;
    }
    return inside;
}

function drawTerrainZones() {
    terrainZones.forEach(zone => {
        if (zone.points.length > 2) {
            ctx.save();
            ctx.fillStyle = SHAPES[1].color;
            ctx.strokeStyle = '#A0A0A0';
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.moveTo(zone.points[0].x, zone.points[0].y);
            for (let i = 1; i < zone.points.length; i++) ctx.lineTo(zone.points[i].x, zone.points[i].y);
            ctx.closePath();
            ctx.fill();
            ctx.stroke();
            ctx.restore();
        }
    });
}

function drawStartBase() {
    if (startBase) {
        ctx.save();
        ctx.fillStyle = 'rgba(100, 200, 255, 0.2)';
        ctx.strokeStyle = '#00ffff';
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.arc(startBase.x, startBase.y, startBase.radius, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();
        ctx.restore();
    }
}

function drawEnemyBase() {
    if (!enemyBase) return;
    ctx.save();
    ctx.fillStyle = 'rgba(255, 0, 0, 0.2)';
    ctx.strokeStyle = '#ff4444';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(enemyBase.x, enemyBase.y, enemyBase.radius, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();
    ctx.restore();
}

function drawDrawingPreview() {
    if (isDrawing && currentDrawingPoints.length > 1) {
        ctx.save();
        ctx.strokeStyle = '#A0A0A0';
        ctx.lineWidth = 2;
        ctx.setLineDash([5, 5]);
        ctx.beginPath();
        ctx.moveTo(currentDrawingPoints[0].x, currentDrawingPoints[0].y);
        for (let i = 1; i < currentDrawingPoints.length; i++) ctx.lineTo(currentDrawingPoints[i].x, currentDrawingPoints[i].y);
        ctx.stroke();
        ctx.restore();
    }
}

function startDrawing(x, y) {
    currentDrawingPoints = [{x: x, y: y}];
    isDrawing = true;
}

function continueDrawing(x, y) {
    if (isDrawing) {
        let lastPoint = currentDrawingPoints[currentDrawingPoints.length - 1];
        let distance = Math.sqrt((x - lastPoint.x) ** 2 + (y - lastPoint.y) ** 2);
        if (distance > 10) currentDrawingPoints.push({x: x, y: y});
    }
}

function finishDrawing() {
    if (currentDrawingPoints.length < 3) {
        statusDiv.textContent = '[ERREUR] Zone trop petite';
        setTimeout(() => statusDiv.textContent = 'Jouez !', 3000);
        isDrawing = false;
        currentDrawingPoints = [];
        return;
    }

    let area = 0;
    for (let i = 0; i < currentDrawingPoints.length - 1; i++) {
        let j = (i + 1) % currentDrawingPoints.length;
        area += currentDrawingPoints[i].x * currentDrawingPoints[j].y;
        area -= currentDrawingPoints[i].y * currentDrawingPoints[j].x;
    }
    area = Math.abs(area / 2);

    if (area < 1000) {
        statusDiv.textContent = '[ERREUR] Surface min: 1000';
        setTimeout(() => statusDiv.textContent = 'Jouez !', 3000);
        isDrawing = false;
        currentDrawingPoints = [];
        return;
    }

    terrainZones.push({ points: [...currentDrawingPoints], area: area });
    currentDrawingPoints = [];
    isDrawing = false;
    statusDiv.textContent = `[OK] Zone creee ! Surface: ${Math.floor(area)}`;
    setTimeout(() => statusDiv.textContent = 'Jouez !', 3000);
    lastPowerUse = Date.now();
    isPowerActive = true;
    setTimeout(() => { isPowerActive = false; }, getPowerDuration());
}

function activatePower() {
    if (isPowerActive) return;
    
    let now = Date.now();
    let timeSinceLastUse = now - lastPowerUse;
    if (timeSinceLastUse < powerCooldown) return;

    let shape = SHAPES[currentShape];
    switch(shape.special) {
        case 'laser': activateLaser(); break;
        case 'drawing': break;
        case 'doubleJump': activateDoubleJump(); break;
        case 'timeSlow': activateTimeSlow(); break;
        case 'blast': activateBlast(); break;
    }
}

function activateLaser() {
    const cost = laserCost;
    if (player.energy < cost) {
        statusDiv.textContent = `[ERREUR] Energie insuffisante ! ${cost} requise`;
        setTimeout(() => statusDiv.textContent = 'Jouez !', 3000);
        return;
    }
    
    player.energy -= cost;
    updateEnergyDisplay();
    isLaserActive = true;
    powerEffects.push({ type: 'laserCharge', x: player.x, y: player.y, duration: 200, startTime: Date.now() });
    setTimeout(() => isLaserActive = false, 500);
    lastPowerUse = Date.now();
    isPowerActive = true;
    setTimeout(() => { isPowerActive = false; }, getPowerDuration());
}

function drawLaser() {
    if (isLaserActive) {
        ctx.save();
        ctx.strokeStyle = '#FF4444';
        ctx.lineWidth = 4;
        ctx.shadowBlur = 10;
        ctx.shadowColor = '#FF4444';
        ctx.beginPath();
        ctx.moveTo(player.x, player.y);
        ctx.lineTo(mouseX, mouseY);
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(mouseX, mouseY, 10, 0, Math.PI * 2);
        ctx.fillStyle = '#FF4444';
        ctx.fill();
        ctx.restore();
        checkLaserCollision();
    }
}

function checkLaserCollision() {
    enemies.forEach((enemy, index) => {
        let A = mouseX - player.x;
        let B = mouseY - player.y;
        let C = enemy.x - player.x;
        let D = enemy.y - player.y;
        let dot = A * C + B * D;
        let lenSq = A * A + B * B;
        let param = lenSq !== 0 ? dot / lenSq : -1;
        let closestX = param < 0 ? player.x : param > 1 ? mouseX : player.x + param * A;
        let closestY = param < 0 ? player.y : param > 1 ? mouseY : player.y + param * B;
        let dx = enemy.x - closestX;
        let dy = enemy.y - closestY;
        let distance = Math.sqrt(dx*dx + dy*dy);
        
        if (distance < enemy.size) {
            enemies.splice(index, 1);
            score += 100;
            document.getElementById('score').textContent = score;
            if (currentShape === 0) {
                enemiesKilledWithLaser++;
                updateKillsDisplay();
                if (enemiesKilledWithLaser >= killsToUnlockCube && !unlockedShapes.includes(1)) {
                    unlockedShapes.push(1);
                    updateShapeButtons();
                    statusDiv.textContent = '[OK] CUBE DEBLOQUE !';
                    setTimeout(() => statusDiv.textContent = 'Jouez !', 4000);
                }
            }
        }
    });
}

function activateDoubleJump() {
    player.y -= 100;
    powerEffects.push({ type: 'doubleJump', x: player.x, y: player.y + 50, duration: 500, startTime: Date.now() });
    lastPowerUse = Date.now();
    isPowerActive = true;
    setTimeout(() => { isPowerActive = false; }, getPowerDuration());
}

function activateTimeSlow() {
    enemies.forEach(enemy => { enemy.vx *= 0.3; enemy.vy *= 0.3; });
    powerEffects.push({ type: 'timeSlow', x: canvas.width/2, y: canvas.height/2, duration: 3000, startTime: Date.now() });
    lastPowerUse = Date.now();
    isPowerActive = true;
    setTimeout(() => { isPowerActive = false; deactivatePowerEffects(); }, getPowerDuration());
}

function activateBlast() {
    let blastRadius = 150;
    let enemiesDestroyed = 0;
    enemies.forEach((enemy, index) => {
        let dx = player.x - enemy.x;
        let dy = player.y - enemy.y;
        let distance = Math.sqrt(dx*dx + dy*dy);
        if (distance < blastRadius) {
            enemy.x = Math.random() * canvas.width;
            enemy.y = Math.random() * canvas.height;
            enemiesDestroyed++;
            score += 50 * enemiesDestroyed;
            document.getElementById('score').textContent = score;
        }
    });
    powerEffects.push({ type: 'blast', x: player.x, y: player.y, duration: 500, startTime: Date.now(), radius: blastRadius });
    lastPowerUse = Date.now();
    isPowerActive = true;
    setTimeout(() => { isPowerActive = false; }, getPowerDuration());
}

function deactivatePowerEffects() {
    if (SHAPES[currentShape].special === 'timeSlow') {
        enemies.forEach(enemy => {
            enemy.vx = (Math.random() - 0.5) * 2;
            enemy.vy = (Math.random() - 0.5) * 2;
        });
    }
}

function updatePowerEffects() {
    powerEffects = powerEffects.filter(effect => Date.now() - effect.startTime < effect.duration);
}

function drawPowerEffects() {
    powerEffects.forEach(effect => {
        let elapsed = Date.now() - effect.startTime;
        let progress = elapsed / effect.duration;
        ctx.save();
        switch(effect.type) {
            case 'laserCharge':
                ctx.strokeStyle = '#FF4444';
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.arc(effect.x, effect.y, PLAYER_SIZE * (1 + progress), 0, Math.PI * 2);
                ctx.stroke();
                break;
            case 'doubleJump':
                ctx.fillStyle = `rgba(68, 255, 68, ${1 - progress})`;
                ctx.fillRect(effect.x - 20, effect.y - 20, 40, 40);
                break;
            case 'timeSlow':
                ctx.fillStyle = `rgba(255, 215, 0, ${0.1 * (1 - progress)})`;
                ctx.fillRect(0, 0, canvas.width, canvas.height);
                break;
            case 'blast':
                ctx.strokeStyle = '#FF00FF';
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.arc(effect.x, effect.y, effect.radius * progress, 0, Math.PI * 2);
                ctx.stroke();
                break;
        }
        ctx.restore();
    });
}

function updatePowerUI() {
    let now = Date.now();
    let timeSinceLastUse = now - lastPowerUse;
    let cooldownProgress = Math.min(timeSinceLastUse / powerCooldown, 1);
    let cooldownBar = document.getElementById('powerCooldown');
    let powerStatus = document.getElementById('powerStatus');
    
    if (isPowerActive) {
        if (cooldownBar) cooldownBar.style.width = '100%';
        if (cooldownBar) cooldownBar.classList.add('active');
        if (powerStatus) powerStatus.textContent = `[POUVOIR] ${SHAPES[currentShape].special} ACTIF !`;
    } else if (cooldownProgress < 1) {
        if (cooldownBar) cooldownBar.style.width = `${cooldownProgress * 100}%`;
        if (cooldownBar) cooldownBar.classList.remove('active');
        if (powerStatus) powerStatus.textContent = `[RECHARGEMENT] (${Math.ceil((powerCooldown - timeSinceLastUse) / 1000)}s)`;
    } else {
        if (cooldownBar) cooldownBar.style.width = '100%';
        if (cooldownBar) cooldownBar.classList.add('active');
        if (powerStatus) powerStatus.textContent = `[CLIC] ${SHAPES[currentShape].special.toUpperCase()}`;
    }
}

function updateKillsDisplay() {
    if (unlockedShapes.includes(1)) {
        killsDiv.textContent = `Kills: ${enemiesKilledWithLaser} [OK]`;
    } else {
        killsDiv.textContent = `Kills: ${enemiesKilledWithLaser}/${killsToUnlockCube} [VERROU]`;
    }
}

function updateEnergyDisplay() {
    document.getElementById('energy').textContent = player.energy;
}

function updateShapeButtons() {
    document.querySelectorAll('.shape-btn').forEach((btn, index) => {
        btn.classList.toggle('locked', !unlockedShapes.includes(index));
        btn.classList.toggle('active', index === currentShape);
    });
    document.getElementById('currentForm').textContent = `FORME: ${SHAPES[currentShape].name}`;
    updateKillsDisplay();
}

function changeShape(shapeIndex) {
    if (unlockedShapes.includes(shapeIndex)) {
        currentShape = shapeIndex;
        updateShapeButtons();
        ctx.fillStyle = 'rgba(255, 255, 255, 0.5)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
    }
}

function gameOver() {
    cancelAnimationFrame(gameLoop);
    document.getElementById('finalScore').textContent = score;
    document.getElementById('finalEnergy').textContent = player.energy;
    document.getElementById('finalBlocks').textContent = terrainZones.length;
    document.getElementById('gameOver').style.display = 'block';
}

function restartGame() {
    location.reload();
}

// GESTIONNAIRE GLOBAL DE CLIC
canvas.addEventListener('mousedown', (e) => {
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    if (currentShape === 1 && unlockedShapes.includes(1)) {
        startDrawing(x, y);
    } else {
        mouseX = x;
        mouseY = y;
        activatePower();
    }
});

canvas.addEventListener('mousemove', (e) => {
    const rect = canvas.getBoundingClientRect();
    mouseX = e.clientX - rect.left;
    mouseY = e.clientY - rect.top;
    
    if (isDrawing) {
        continueDrawing(mouseX, mouseY);
    }
});

canvas.addEventListener('mouseup', () => {
    if (isDrawing) {
        finishDrawing();
    }
});

document.addEventListener('keydown', (e) => {
    keys[e.key] = true;
    if (e.key >= '1' && e.key <= '5') changeShape(parseInt(e.key) - 1);
    if (e.key === 'Tab') { e.preventDefault(); toggleCustomizationPanel(); }
});

document.addEventListener('keyup', (e) => { keys[e.key] = false; });

function toggleCustomizationPanel() {
    const panel = document.getElementById('customPanel');
    panel.classList.toggle('active');
    document.querySelector('.tab-indicator').style.display = 'none';
}

function updateValue(sliderId) {
    const slider = document.getElementById(sliderId);
    const valueSpan = document.getElementById(sliderId + 'Value');
    valueSpan.textContent = slider.value;
    
    if (sliderId === 'laserCost') {
        laserCost = parseInt(slider.value);
    }
}

function applyChanges() {
    gameSpeed = parseInt(document.getElementById('gameSpeed').value);
    PLAYER_SIZE = parseInt(document.getElementById('playerSize').value);
    laserCost = parseInt(document.getElementById('laserCost').value);
    let newEnemyCount = parseInt(document.getElementById('enemyCount').value);
    while (enemies.length < newEnemyCount) enemies.push(createEnemy());
    while (enemies.length > newEnemyCount) enemies.pop();
    
    statusDiv.textContent = '[OK] Changements appliques !';
    setTimeout(() => statusDiv.textContent = 'Jouez !', 2000);
}

function resetDefaults() {
    location.reload();
}

function updateShapeColor(shapeIndex, color) {
    SHAPES[shapeIndex].color = color;
}

function updateBackground(color) {
    canvas.style.background = color;
}

function updateBorder(color) {
    canvas.style.borderColor = color;
}

function updatePageBackground(color) {
    document.body.style.background = color;
}

function toggleGodMode(enabled) {
    godMode = enabled;
}

function toggleTurbo(enabled) {
    turboMode = enabled;
}

function toggleUnlockAll(enabled) {
    if (enabled) {
        unlockedShapes = [0, 1, 2, 3, 4];
        updateShapeButtons();
    } else {
        unlockedShapes = [0];
        updateShapeButtons();
    }
}

function toggleInstructions() {
    alert('COMMANDES AVANCEES :\n\n' +
          'Clic : Utiliser le pouvoir (selon la forme)\n' +
          'Laser : Pointez et cliquez pour tirer (coute energie)\n' +
          'Dessin : En forme CUBE, maintenez pour tracer une zone\n' +
          'Pause : Appuyez sur ESPACE\n\n' +
          'ASTUCE : Tuez 5 ennemis avec le laser pour debloquer le Cube !\n' +
          'Les ennemis respawnent a leurs bases rouges');
}

// FIN DU CODE - Aucune création d'élément, aucune fuite mémoire