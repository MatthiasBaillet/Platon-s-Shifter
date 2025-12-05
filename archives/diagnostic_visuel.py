#!/usr/bin/env python3
# Affiche VISUELLEMENT les lignes avec "enemy" dedans

with open('Game.js', 'r', encoding='utf-8') as f:
    lines = f.readlines()

print("="*70)
print("🔍 TOUS LES ENDROITS OÙ 'enemy' APPARAÎT")
print("="*70)

for i, line in enumerate(lines, start=1):
    if 'enemy' in line.lower():
        print(f"LIGNE {i:3d}: {line.rstrip()}")

print("="*70)
print("📌 Recherchez 'enemyBases' ou 'enemyBase' dans la liste ci-dessus")