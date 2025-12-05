#!/usr/bin/env python3
# CORRECTION DEFINITIVE - Garde la console OUVERTE

import re
import subprocess

print("="*70)
print("🚀 PLATON'S SHIFTER - CORRECTION DEFINITIVE")
print("="*70)
print()

# ============================================================================
# ETAPE 1 : LIRE Game.js ET CORRIGER LES ERREURS DE SYNTAXE
# ============================================================================
try:
    with open('Game.js', 'r', encoding='utf-8') as f:
        code = f.read()
    print("✅ Fichier lu")
except Exception as e:
    print(f"❌ ERREUR LECTURE : {e}")
    input("\nAppuyez sur Entrée...")
    exit()

# Supprimer TOUT ce qui contient "enemyBases.forEach" (lignes 87 et 223)
print("🔧 Suppression des forEach ennemis...")
code = re.sub(r'[\t ]*enemyBases\.forEach\(.*?[\s\S]*?\}\);\s*', '', code)

# Remplacer l'assignation push
print("🔧 Correction de l'assignation...")
code = re.sub(r'[\t ]*enemyBases\.push\(base\);', '    enemyBase = base;', code)

# S'assurer que drawEnemyBase est propre
print("🔧 Vérification drawEnemyBase...")
code = re.sub(
    r'function drawEnemyBase\(\)\s*\{[\s\S]*?if\s*\(!enemyBase\)\s*return;[\s\S]*?ctx\.restore\(\);\s+\}',
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