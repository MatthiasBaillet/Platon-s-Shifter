#!/usr/bin/env python3
# Patch d'urgence - Corrige enemyBases → enemyBase

import re

with open('Game.js', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Remplacer la déclaration
code = re.sub(r'let\s+enemyBases\s*=\s*\[\s*\]\s*;', 'let enemyBase = null;', code)

# 2. Remplacer l'utilisation dans createEnemy
code = re.sub(r'const\s+base\s*=\s*enemyBases\s*\[.*?\]\s*;', 'const base = enemyBase;', code)

# 3. Remplacer l'assignation dans createEnemyBases
code = re.sub(r'enemyBases\s*=\s*\[base\]\s*;', 'enemyBase = base;', code)

with open('Game.js', 'w', encoding='utf-8') as f:
    f.write(code)

print("✅ Patch appliqué : enemyBases → enemyBase")