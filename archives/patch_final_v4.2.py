#!/usr/bin/env python3
# PATCH FINAL V4.2 - Corrige TOUTES les occurrences de enemyBases

import re
import subprocess

def corriger_tout():
    with open('Game.js', 'r', encoding='utf-8') as f:
        code = f.read()
    
    print("🔧 CORRECTION EN COURS...")
    
    # 1. Déclaration (ligne 23)
    code = re.sub(r'let\s+enemyBases\s*=\s*\[\s*\]\s*;', 'let enemyBase = null;', code)
    
    # 2. Fonction createEnemyBases() (lignes 68-92)
    code = re.sub(
        r'function createEnemyBases\(\)\s*\{[\s\S]*?while\s*\(\s*!\s*validPosition\s*&&\s*attempts\s*<\s*50\s*\)\s*\{[\s\S]*?\}\s+enemyBases\.push\(base\);\s+\}',
        '''function createEnemyBases() {
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
}''',
        code,
        flags=re.MULTILINE
    )
    
    # 3. drawEnemyBases() → drawEnemyBase() (ligne 222)
    code = re.sub(r'function drawEnemyBases\(\)', 'function drawEnemyBase()', code)
    
    # 4. Remplacer le contenu de drawEnemyBase (lignes 223+)
    code = re.sub(
        r'function drawEnemyBase\(\)\s*\{[\s\S]*?enemyBases\.forEach\(base\s*=>\s*\{[\s\S]*?ctx\.stroke\(\);\s+ctx\.restore\(\);\s+\}\);\s+\}',
        '''function drawEnemyBase() {
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
}''',
        code,
        flags=re.MULTILINE
    )
    
    # 5. Appel de la fonction (ligne 131)
    code = re.sub(r'drawEnemyBases\(\);', 'drawEnemyBase();', code)
    
    # 6. S'assurer qu'init() appelle createEnemyBases
    if 'createEnemyBases();' not in code[:1000]:
        code = re.sub(r'function init\(\)\s*\{', 'function init() {\n    createEnemyBases();', code)
    
    with open('Game.js', 'w', encoding='utf-8') as f:
        f.write(code)
    
    print("✅ Toutes les corrections appliquées")
    return True

def valider():
    result = subprocess.run(['node', '-c', 'Game.js'], capture_output=True, text=True)
    if result.returncode == 0:
        print("✅ VALIDATION NODE.JS : SUCCESS")
        return True
    else:
        print("❌ ERREUR SYNTAXE :")
        print(result.stderr)
        return False

if __name__ == '__main__':
    corriger_tout()
    if valider():
        print("\n🎮 Jeu prêt ! Exécutez : start index.html")
    else:
        print("\n❌ Corrigez manuellement avec le diagnostic")