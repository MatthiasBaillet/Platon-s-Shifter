# C:\Users\MATT\Desktop\Platon's Shifter\patch_enemybase.py
import re

with open('Game.js', 'r', encoding='utf-8') as f:
    code = f.read()

# Remplacements critiques
code = re.sub(r'let\s+enemyBases\s*=\s*\[\s*\]\s*;', 'let enemyBase = null;', code)
code = re.sub(r'const\s+base\s*=\s*enemyBases\s*\[.*?\]\s*;', 'const base = enemyBase;', code)
code = re.sub(r'enemyBases\s*=\s*\[base\]\s*;', 'enemyBase = base;', code)

with open('Game.js', 'w', encoding='utf-8') as f:
    f.write(code)

print("✅ Patch enemyBase appliqué")