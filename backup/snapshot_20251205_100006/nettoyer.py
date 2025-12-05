# -*- coding: utf-8 -*-
import sys

# Lire Game.js
with open('Game.js', 'r', encoding='utf-8', errors='ignore') as f:
    contenu = f.read()

# Lignes à ajouter à la fin
ajout = """


// ===== NETTOYAGE FUITES MEMOIRE =====
window.removeEventListener('DOMContentLoaded', init);
window.removeEventListener('mousedown', handleMouseDown);
window.removeEventListener('mousemove', handleMouseMove);
window.removeEventListener('mouseup', handleMouseUp);
window.removeEventListener('keydown', handleKeydown);
window.removeEventListener('keyup', handleKeyup);
// =====================================
"""

# Écrire le nouveau fichier
with open('Game_corrige.js', 'w', encoding='utf-8') as f:
    f.write(contenu + ajout)

print("? Nettoyage terminé !")
print("Renommez Game_corrige.js en Game.js")