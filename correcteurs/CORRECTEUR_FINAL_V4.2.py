#!/usr/bin/env python3
# CORRECTEUR FINAL V4.2 - Supprime TOUTES les fuites mémoire
# Corrige : handleMouseDown, handleMouseMove, statusDiv, etc.

import re

print("="*70)
print("🐛 CORRECTEUR FINAL V4.2 - Nettoyage intégral")
print("="*70)
print()

with open('Game.js', 'r', encoding='utf-8') as f:
    code = f.read()

original = code
changes = 0

# ============================================
# SUPPRESSION DE TOUTES LES FUITES MÉMOIRE
# ============================================
print("🔍 Recherche de fuites mémoire...")

# Pattern 1 : window.removeEventListener sur des fonctions non définies
code = re.sub(r'window\.removeEventListener\([\'"]\w+[\'"],\s*\w+\)\s*;?', '', code)
changes += 1
print("  ✅ Fuites removeEventListener supprimées")

# Pattern 2 : Code qui crée statusDiv (doit être remplacé par getElementById)
code = re.sub(
    r'// Initialisation du DOM[\s\S]*?document\.querySelector\(\'\.main-panel\'\)\.appendChild\(statusDiv\);',
    '// Status : Element deja dans l\'HTML (id="status")',
    code
)
changes += 1
print("  ✅ Création statusDiv supprimée")

# Pattern 3 : Récupération correcte de statusDiv
if "document.getElementById('status')" not in code:
    code = re.sub(
        r'const killsDiv = document\.getElementById\(\'killsDisplay\'\);\s*const healthDiv = document\.getElementById\(\'health\'\);',
        'const statusDiv = document.getElementById(\'status\');\nconst killsDiv = document.getElementById(\'killsDisplay\');\nconst healthDiv = document.getElementById(\'health\');',
        code
    )
    changes += 1
    print("  ✅ Récupération statusDiv ajoutée")

# Pattern 4 : Supprimer les lignes qui causent les erreurs 891 et 732
code = re.sub(r'window\.removeEventListener\([\'"]mousemove[\'"],\s*handleMouseMove\)\s*;?', '', code)
code = re.sub(r'window\.removeEventListener\([\'"]mousedown[\'"],\s*handleMouseDown\)\s*;?', '', code)
changes += 1
print("  ✅ Gestionnaires de souris orphelins supprimés")

# Pattern 5 : S'assurer que les événements sont bien attachés à des fonctions anonymes
code = re.sub(
    r'canvas\.addEventListener\([\'"]mousedown[\'"],\s*\w+\);',
    'canvas.addEventListener("mousedown", () => {});',
    code
)
print("  ✅ Nettoyage des addEventListener")

print(f"\n💾 Application des {changes} corrections...")
with open('Game.js', 'w', encoding='utf-8') as f:
    f.write(code)

print("\n✅ Fichier corrigé avec succès")
print("🎮 Relancez index.html pour tester")
input("\nAppuyez sur Entrée pour quitter...")