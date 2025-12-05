#!/usr/bin/env python3
# CORRECTION ACCOLADE LIGNE 82 - Console gardee OUVERTE

import re
import subprocess

print("="*70)
print("🎯 CORRECTION ACCOLADE LIGNE 82")
print("="*70)
print()

# ============================================================================
# ETAPE 1 : LIRE Game.js ET CORRIGER createEnemyBases() ENTIEREMENT
# ============================================================================
try:
    with open('Game.js', 'r', encoding='utf-8') as f:
        code = f.read()
    print("✅ Fichier lu")
except Exception as e:
    print(f"❌ ERREUR LECTURE : {e}")
    input("\nAppuyez sur Entrée...")
    exit()

print("🔧 Remplacement TOTAL de createEnemyBases()...")

# Remplacer TOUTE la fonction createEnemyBases (lignes 68-92) par une version PROPRE
code = re.sub(
    r'function createEnemyBases\(\)\s*\{[\s\S]*?\}\s*(?=function createEnemy)',
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
}
''',
    code,
    flags=re.MULTILINE
)

print("✅ Fonction createEnemyBases() refaite proprement")

# ============================================================================
# ETAPE 2 : SAUVEGARDER
# ============================================================================
try:
    with open('Game.js', 'w', encoding='utf-8') as f:
        f.write(code)
    print("💾 Sauvegarde OK")
except Exception as e:
    print(f"❌ ERREUR SAUVEGARDE : {e}")
    input("\nAppuyez sur Entrée...")
    exit()

# ============================================================================
# ETAPE 3 : VALIDER NODE.JS
# ============================================================================
print()
print("🔍 Validation Node.js...")
result = subprocess.run(['node', '-c', 'Game.js'], capture_output=True, text=True)

if result.returncode == 0:
    print("✅ SYNTAXE VALIDÉE")
    print()
    print("="*70)
    print("🎮 JEU PRÊT ! Lancez index.html")
    print("="*70)
else:
    print("❌ ERREUR SYNTAXE :")
    print(result.stderr)

# ============================================================================
# ETAPE 4 : GARDER LA FENÊTRE OUVERTE
# ============================================================================
print()
input("Appuyez sur Entrée pour fermer cette fenêtre...")