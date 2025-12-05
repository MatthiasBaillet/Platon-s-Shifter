# C:\Users\MATT\Desktop\Platon's Shifter\patch_final.py
import re

with open('Game.js', 'r', encoding='utf-8') as f:
    code = f.read()

# Remplacements SÉCURISÉS et COMPLETS
replacements = [
    (r'let\s+enemyBases\s*=\s*\[\s*\]\s*;', 'let enemyBase = null;'),
    (r'const\s+base\s*=\s*enemyBases\s*\[.*?\]\s*;', 'const base = enemyBase;'),
    (r'enemyBases\.forEach', '// enemyBase.forEach (supprimé)'),
    (r'enemyBases\.push\(base\)', 'enemyBase = base'),
    (r'if\s*\(enemyBases\.length\)', 'if (enemyBase)'),
]

for pattern, replacement in replacements:
    code = re.sub(pattern, replacement, code, flags=re.MULTILINE)

with open('Game.js', 'w', encoding='utf-8') as f:
    f.write(code)

print("✅ Patch enemyBase appliqué")