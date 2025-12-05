#!/usr/bin/env python3
# Écrit le diagnostic dans diagnostic.txt

with open('Game.js', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Écriture dans un fichier
with open('diagnostic.txt', 'w', encoding='utf-8') as out:
    out.write("="*70 + "\n")
    out.write("🔍 TOUS LES ENDROITS OÙ 'enemy' APPARAÎT\n")
    out.write("="*70 + "\n\n")
    
    for i, line in enumerate(lines, start=1):
        if 'enemy' in line.lower():
            out.write(f"LIGNE {i:3d}: {line.rstrip()}\n")
    
    out.write("\n" + "="*70 + "\n")
    out.write("📌 Recherchez 'enemyBases' ou 'enemyBase'\n")

print("✅ Diagnostic écrit dans diagnostic.txt")
print("📄 Ouvrez diagnostic.txt avec le Bloc-notes")