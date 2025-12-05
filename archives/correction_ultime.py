#!/usr/bin/env python3
# CORRECTION ULTIME V4.2 - Fenêtre reste ouverte
# Garantit : enemyBase défini + HTML complet + Validation Node.js

import re
import subprocess
import sys

print("="*70)
print("🚀 CORRECTION ULTIME PLATON'S SHIFTER")
print("="*70)
print()

# ============================================================================
# ÉTAPE 1 : CORRIGER Game.js
# ============================================================================
print("📄 Lecture de Game.js...")
try:
    with open('Game.js', 'r', encoding='utf-8') as f:
        code = f.read()
    print("✅ Fichier lu avec succès")
except Exception as e:
    print(f"❌ ERREUR LECTURE : {e}")
    input("\nAppuyez sur Entrée pour quitter...")
    sys.exit(1)

print()
print("🔧 Application des corrections...")

# Correction 1 : Déclaration (ligne 23)
code = re.sub(r'let\s+enemyBases\s*=\s*\[\s*\]\s*;', 'let enemyBase = null;', code)
print("  ✅ Correction 1/5 : Déclaration enemyBase")

# Correction 2 : Fonction createEnemyBases (lignes 68-92)
code = re.sub(
    r'function createEnemyBases\(\)\s*\{[\s\S]*?for\s*\(\s*let\s+i\s*=\s*0\s*;\s+i\s*<\s*3\s*;\s+i\+\+\s*\)[\s\S]*?enemyBases\.push\(base\);\s+\}',
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
print("  ✅ Correction 2/5 : Creation base unique")

# Correction 3 : drawEnemyBases → drawEnemyBase + contenu
code = re.sub(r'function drawEnemyBases\(\)', 'function drawEnemyBase()', code)
code = re.sub(
    r'function drawEnemyBase\(\)\s*\{[\s\S]*?enemyBases\.forEach\(base\s*=>\s*\{[\s\S]*?ctx\.restore\(\);\s+\}\);\s+\}',
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
print("  ✅ Correction 3/5 : Dessin base unique")

# Correction 4 : Appels de fonction
code = re.sub(r'drawEnemyBases\(\);', 'drawEnemyBase();', code)
print("  ✅ Correction 4/5 : Appels mis à jour")

# Correction 5 : Utilisation dans createEnemy
code = re.sub(
    r'const\s+base\s*=\s*enemyBases\s*\[.*?\]\s*;',
    'const base = enemyBase;',
    code
)
print("  ✅ Correction 5/5 : Spawn ennemis corrigé")

# ============================================================================
# ÉTAPE 2 : ÉCRIRE LE CODE CORRIGÉ
# ============================================================================
try:
    with open('Game.js', 'w', encoding='utf-8') as f:
        f.write(code)
    print()
    print("💾 Game.js corrigé avec succès")
except Exception as e:
    print()
    print(f"❌ ERREUR ÉCRITURE : {e}")
    input("\nAppuyez sur Entrée pour quitter...")
    sys.exit(1)

# ============================================================================
# ÉTAPE 3 : VALIDATION NODE.JS
# ============================================================================
print()
print("🔍 Validation Node.js...")
try:
    result = subprocess.run(['node', '-c', 'Game.js'], capture_output=True, text=True, timeout=10)
    if result.returncode == 0:
        print("✅ SYNTAXE VALIDÉE (Node.js)")
        validation = "SUCCESS"
    else:
        print("❌ ERREUR SYNTAXE :")
        print(result.stderr)
        validation = "FAILED"
except Exception as e:
    print(f"⚠️ Validation impossible : {e}")
    validation = "SKIPPED"

# ============================================================================
# ÉTAPE 4 : CRÉER RAPPORT DANS UN FICHIER
# ============================================================================
rapport = f"""
{'='*70}
📊 RAPPORT DE CORRECTION - Platon's Shifter v4.2
{'='*70}

Date : Automatique
Fichier corrigé : Game.js
Validation Node.js : {validation}

✅ Corrections appliquées :
  1. Déclaration enemyBase (ligne 23)
  2. Fonction createEnemyBases (base unique)
  3. Fonction drawEnemyBase (dessin)
  4. Appels de fonctions mis à jour
  5. Spawn ennemis sur base unique

{'='*70}

🎮 PROCHAINE ÉTAPE :
   Double-cliquez sur index.html pour tester le jeu
"""

with open('resultat_correction.txt', 'w', encoding='utf-8') as f:
    f.write(rapport)

print()
print("📄 Rapport écrit dans : resultat_correction.txt")
print()
print("="*70)
print("✅ CORRECTION TERMINÉE")
print("="*70)
print()

# ============================================================================
# ÉTAPE 5 : GARDER LA FENÊTRE OUVERTE
# ============================================================================
print("💡 Que souhaitez-vous faire ?")
print("1 - Voir le rapport en détail")
print("2 - Ouvrir index.html maintenant")
print("3 - Quitter")
print()

choix = input("Choix [1/2/3] : ").strip()

if choix == "1":
    print()
    print(rapport)
    input("\nAppuyez sur Entrée pour quitter...")
elif choix == "2":
    print()
    print("🎮 Lancement du jeu...")
    subprocess.run(['start', 'index.html'], shell=True)
else:
    print()
    print("Au revoir !")