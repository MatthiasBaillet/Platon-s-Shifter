#!/usr/bin/env python3
# PATCH RUNTIME BUGS - Corrige les erreurs dans Game.js
# Bug 1 : handleMouseDown non défini
# Bug 2 : textContent sur null

import re

with open('Game.js', 'r', encoding='utf-8') as f:
    code = f.read()

original = code

# ============================================
# CORRECTION BUG 1 : Ligne 890 (handleMouseDown)
# ============================================
# Trouver et supprimer les références à handleMouseDown
code = re.sub(r'window\.removeEventListener\([\'"]mousedown[\'"],\s*handleMouseDown\)\s*;?', '', code)

# ============================================
# CORRECTION BUG 2 : Ligne 732 (textContent sur null)
# ============================================
# Remplacer le code qui crée statusDiv par une récupération simple
code = re.sub(
    r'// Initialisation du DOM\s*const statusDiv = document\.createElement\(\'div\'\);[\s\S]*?document\.querySelector\(\'\.main-panel\'\)\.appendChild\(statusDiv\);',
    '// Le statusDiv est déjà dans l\'HTML (id="status")',
    code
)

# ============================================
# VÉRIFIER SI statusDiv est bien récupéré
# ============================================
if "document.getElementById('status')" not in code:
    # Ajouter la récupération si elle manque
    code = re.sub(
        r'const killsDiv = document\.getElementById\(\'killsDisplay\'\);',
        'const statusDiv = document.getElementById(\'status\');\nconst killsDiv = document.getElementById(\'killsDisplay\');',
        code
    )

print("🔧 Application des corrections...")
changes = 0
if code != original:
    changes += 1
    print("  ✅ Bug 1 : handleMouseDown corrigé")
    changes += 1
    print("  ✅ Bug 2 : statusDiv corrigé")

if changes == 0:
    print("  ⚠️ Aucune correction nécessaire (code déjà propre)")

# Sauvegarder
with open('Game.js', 'w', encoding='utf-8') as f:
    f.write(code)

print(f"\n💾 Fichier sauvegardé ({changes} corrections appliquées)")
print("\n🎮 Relancez index.html pour tester")
input("\nAppuyez sur Entrée pour quitter...")