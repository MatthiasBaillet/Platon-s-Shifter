# -*- coding: ascii -*-
# SCRIPT ASCII PUR - PAS D'ERREURS D'ENCODAGE
import sys

# Lire Game.js
with open('Game.js', 'r', encoding='utf-8', errors='ignore') as f:
    code = f.read()

# Nettoyage a ajouter (ASCII pur)
clean = """

// ===== NETTOYAGE FUITES MEMOIRE =====
window.removeEventListener('DOMContentLoaded', init);
window.removeEventListener('mousedown', handleMouseDown);
window.removeEventListener('mousemove', handleMouseMove);
window.removeEventListener('mouseup', handleMouseUp);
window.removeEventListener('keydown', handleKeydown);
window.removeEventListener('keyup', handleKeyup);
// =====================================
"""

# Creer fichier corrige
with open('Game_corrige.js', 'w', encoding='utf-8') as f:
    f.write(code + clean)

print("SUCCESS !")
print("Renommez Game_corrige.js en Game.js")