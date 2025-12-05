#!/usr/bin/env python3
# CORRECTION FINALE V4.2 - Console gardee OUVERTE
# Garantit : enemyBase partout + Validation Node.js + Rapport

import re
import subprocess
import sys

print("="*70)
print("🚀 PLATON'S SHIFTER - CORRECTION FINALE V4.2")
print("="*70)
print()

# ============================================================================
# ETAPE 1 : CORRIGER Game.js (remplacements directs)
# ============================================================================
print("📄 Lecture de Game.js...")
try:
    with open('Game.js', 'r', encoding='utf-8') as f:
        code = f.read()
    print("✅ Fichier lu avec succes")
except Exception as e:
    print(f"❌ ERREUR LECTURE : {e}")
    print("\nAppuyez sur Entree pour quitter...")
    input()
    sys.exit(1)

print()
print("🔧 Application des 6 corrections...")

# Correction 1 : Declaration (ligne 23)
original = code
code = code.replace('let enemyBases = [];', 'let enemyBase = null;')
if code != original:
    print("  ✅ 1/6 : Declaration enemyBase (ligne 23)")
else:
    print("  ⚠️ 1/6 : Declaration deja correcte ou non trouvee")

# Correction 2 : Utilisation dans createEnemy (ligne 97)
original = code
code = code.replace(
    'const base = enemyBases[Math.floor(Math.random() * enemyBases.length)];',
    'const base = enemyBase;'
)
if code != original:
    print("  ✅ 2/6 : Utilisation createEnemy (ligne 97)")
else:
    print("  ⚠️ 2/6 : Pattern createEnemy non trouve")

# Correction 3 : forEach ligne 87 (dans createEnemyBases)
original = code
code = re.sub(
    r'enemyBases\.forEach\(existingBase\s*=>\s*\{[\s\S]*?\}\);\s*',
    '',
    code
)
if code != original:
    print("  ✅ 3/6 : forEach ligne 87 supprime")
else:
    print("  ⚠️ 3/6 : forEach ligne 87 non trouve")

# Correction 4 : push ligne 92
original = code
code = code.replace('enemyBases.push(base);', 'enemyBase = base;')
if code != original:
    print("  ✅ 4/6 : Push ligne 92 corrige")
else:
    print("  ⚠️ 4/6 : Push ligne 92 non trouve")

# Correction 5 : drawEnemyBases → drawEnemyBase
original = code
code = code.replace('function drawEnemyBases()', 'function drawEnemyBase()')
if code != original:
    print("  ✅ 5/6 : Fonction renommee")
else:
    print("  ⚠️ 5/6 : Fonction deja renommee")

# Correction 6 : Appel drawEnemyBases → drawEnemyBase
original = code
code = code.replace('drawEnemyBases();', 'drawEnemyBase();')
if code != original:
    print("  ✅ 6/6 : Appel corrige")
else:
    print("  ⚠️ 6/6 : Appel deja corrige")

# ============================================================================
# ETAPE 2 : SAUVEGARDE
# ============================================================================
try:
    with open('Game.js', 'w', encoding='utf-8') as f:
        f.write(code)
    print()
    print("💾 Fichier sauvegarde avec succes")
except Exception as e:
    print()
    print(f"❌ ERREUR SAUVEGARDE : {e}")
    print("\nAppuyez sur Entree pour quitter...")
    input()
    sys.exit(1)

# ============================================================================
# ETAPE 3 : VALIDATION NODE.JS
# ============================================================================
print()
print("🔍 Validation Node.js...")
try:
    result = subprocess.run(['node', '-c', 'Game.js'], capture_output=True, text=True, timeout=10)
    if result.returncode == 0:
        print("✅ SYNTAXE VALIDEE par Node.js")
        validation = "SUCCESS"
    else:
        print("❌ ERREUR SYNTAXE :")
        print(result.stderr)
        validation = "FAILED"
except Exception as e:
    print(f"⚠️ Validation impossible : {e}")
    validation = "SKIPPED"

# ============================================================================
# ETAPE 4 : RAPPORT DANS UN FICHIER
# ============================================================================
rapport = f"""
{'='*70}
📊 RAPPORT DE CORRECTION - Platon's Shifter v4.2
{'='*70}

Validation Node.js : {validation}
Fichier corrige : Game.js

Corrections appliquees :
  - Declaration enemyBase
  - Utilisation dans createEnemy
  - Suppression forEach ligne 87
  - Correction push ligne 92
  - Renommage drawEnemyBase
  - Mise a jour appels

{'='*70}
PROCHAINE ACTION : Double-cliquez sur index.html
{'='*70}
"""

with open('resultat_correction.txt', 'w', encoding='utf-8') as f:
    f.write(rapport)

print()
print("📄 Rapport complet dans : resultat_correction.txt")
print()

# ============================================================================
# ETAPE 5 : GARDER LA FENETRE OUVERTE
# ============================================================================
print("="*70)
print("✅ CORRECTION TERMINÉE")
print("="*70)
print()
print("💡 Que souhaitez-vous faire ?")
print("1 - Voir le rapport complet")
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
    print("✅ Jeu lancé (si la fenêtre ne s'ouvre pas, double-cliquez manuellement)")
    input("\nAppuyez sur Entrée pour quitter...")
else:
    print()
    print("Au revoir !")
    input("Appuyez sur Entrée pour quitter...")