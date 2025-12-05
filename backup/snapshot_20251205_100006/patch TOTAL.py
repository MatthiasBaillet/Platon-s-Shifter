#!/usr/bin/env python3
# PATCH TOTAL v4.1 - Corrige enemyBase + HTML + Syntaxe

import re
import subprocess
import shutil

def patch_enemybase_complet():
    """Corrige tout le cycle de vie de enemyBase"""
    with open('Game.js', 'r', encoding='utf-8') as f:
        code = f.read()
    
    # 1. Déclaration globale fixe
    code = re.sub(r'let\s+enemyBases\s*=\s*\[\s*\]\s*;?', 'let enemyBase = null;', code)
    
    # 2. Initialisation dans init()
    if 'createEnemyBases();' not in code:
        code = re.sub(r'function init\(\)\s*\{', 
                      'function init() {\n    createEnemyBases();', code)
    
    # 3. Création de la base unique (ligne 97)
    code = re.sub(
        r'for\s*\(\s*let\s+i\s*=\s*0\s*;\s*i\s*<\s*3\s*;\s*i\+\+\s*\)\s*\{[\s\S]*?enemyBases\.push\(base\);\s+\}',
        '''// Base unique centralisée
        enemyBase = {
            x: canvas.width * 0.75,
            y: canvas.height / 2,
            radius: GRID_SIZE * 1.5
        };''',
        code,
        flags=re.MULTILINE
    )
    
    # 4. Utilisation dans createEnemy
    code = re.sub(
        r'const\s+base\s*=\s*enemyBases\s*\[.*?\]\s*;',
        'const base = enemyBase;',
        code
    )
    
    # 5. Supprimer références restantes
    code = re.sub(r'enemyBases\.length', '1', code)
    code = re.sub(r'enemyBases\[0\]', 'enemyBase', code)
    
    # 6. Corriger createEnemyBases pour qu'elle crée enemyBase
    code = re.sub(
        r'function createEnemyBases\(\)\s*\{[\s\S]*?\}',
        '''function createEnemyBases() {
    startBase = {
        x: canvas.width / 2,
        y: canvas.height / 2,
        radius: GRID_SIZE * 2
    };
    
    enemyBase = {
        x: canvas.width * 0.75,
        y: canvas.height * 0.25,
        radius: GRID_SIZE * 1.5
    };
}''',
        code
    )
    
    with open('Game.js', 'w', encoding='utf-8') as f:
        f.write(code)
    
    print("✅ Cycle enemyBase corrigé")

def corriger_html():
    """Crée index.html complet"""
    html_complet = '''<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Platon's Shifter v4.1</title>
    <style>
        body { margin: 0; padding: 20px; background: #0a0a0a; display: flex; justify-content: center; align-items: center; min-height: 100vh; font-family: Arial; color: white; }
        .game-container { text-align: center; max-width: 800px; }
        canvas { border: 2px solid #00ffff; background: #1a1a2e; display: block; margin: 0 auto; }
        .main-panel { margin-top: 15px; padding: 10px; background: rgba(0,255,255,0.1); border-radius: 5px; min-height: 50px; }
        #status { margin-top: 10px; padding: 5px; border-radius: 3px; background: #1a1a2e; color: #00ffff; }
    </style>
</head>
<body>
    <div class="game-container">
        <canvas id="gameCanvas" width="800" height="500"></canvas>
        <div class="main-panel">
            <div id="currentForm">FORME: TETRAEDRE</div>
            <div>Score: <span id="score">0</span></div>
            <div>Énergie: <span id="energy">0</span></div>
            <div>Kills: <span id="killsDisplay">0/5 [VERROU]</span></div>
            <div>Vie: <span id="health">[COEUR][COEUR][COEUR]</span></div>
            <div id="powerStatus">[CLIC] LASER</div>
            <div id="powerCooldown" style="width: 100%; height: 5px; background: #333; margin-top: 5px;"></div>
            <div id="status">Jouez !</div>
        </div>
    </div>
    <script src="Game.js"></script>
</body>
</html>'''
    
    with open('index.html', 'w', encoding='utf-8') as f:
        f.write(html_complet)
    
    print("✅ HTML complet créé")

def corriger_game_js_fin():
    """Corrige la fin de Game.js (appendChild)"""
    with open('Game.js', 'r', encoding='utf-8') as f:
        code = f.read()
    
    # Remplacer le code qui crée statusDiv
    code = re.sub(
        r'const\s+statusDiv\s*=\s*document\.createElement\(\'div\'\);\s*statusDiv\.className\s*=\s*\'status info\';\s*statusDiv\.textContent\s*=\s*\'Jouez\s*!\';\s*statusDiv\.style\.marginTop\s*=\s*\'10px\';\s*document\.querySelector\(\'\.main-panel\'\)\.appendChild\(statusDiv\);',
        '// StatusDiv déjà dans HTML (id="status")',
        code
    )
    
    # S'assurer qu'on récupère l'élément existant
    if 'document.getElementById(\'status\')' not in code:
        code = re.sub(
            r'const\s+killsDiv\s*=\s*document\.getElementById\(\'killsDisplay\'\);',
            'const statusDiv = document.getElementById(\'status\');\nconst killsDiv = document.getElementById(\'killsDisplay\');',
            code
        )
    
    with open('Game.js', 'w', encoding='utf-8') as f:
        f.write(code)
    
    print("✅ Fin Game.js corrigée")

def valider_tout():
    """Validation finale Node.js"""
    result = subprocess.run(['node', '-c', 'Game.js'], capture_output=True, text=True)
    if result.returncode == 0:
        print("✅ VALIDATION TOTALE : SUCCESS")
        return True
    else:
        print("❌ ERREUR VALIDATION :")
        print(result.stderr)
        return False

def main():
    print("="*60)
    print("🚀 PATCH TOTAL V4.1 - Industrialisé")
    print("="*60)
    
    # Sauvegarde de sécurité
    shutil.copy2('Game.js', 'Game.js.backup_urgence')
    print("💾 Sauvegarde créée : Game.js.backup_urgence")
    
    # Application
    corriger_html()
    patch_enemybase_complet()
    corriger_game_js_fin()
    
    # Validation
    if valider_tout():
        print("\n🎮 Jeu prêt ! Lancement...")
        subprocess.run(['start', 'index.html'], shell=True)
    else:
        print("\n❌ Restauration backup...")
        shutil.copy2('Game.js.backup_urgence', 'Game.js')

if __name__ == '__main__':
    main()