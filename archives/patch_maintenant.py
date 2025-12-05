#!/usr/bin/env python3
# Patch immédiat - double-clic et c'est tout

import re

with open('Game.js', 'r', encoding='utf-8') as f:
    code = f.read()

# Remplacements directs (force brute)
code = code.replace('let enemyBases = [];', 'let enemyBase = null;')
code = code.replace(
    'const base = enemyBases[Math.floor(Math.random() * enemyBases.length)];',
    'const base = enemyBase;'
)

with open('Game.js', 'w', encoding='utf-8') as f:
    f.write(code)

print("✅ CORRECT")
print("🎮 Lancez index.html")
input("Appuyez sur Entrée pour fermer...")