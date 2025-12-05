#!/usr/bin/env python3
# Affiche les lignes 85 à 100 EXACTES

with open('Game.js', 'r', encoding='utf-8') as f:
    lines = f.readlines()

print("="*60)
print("🔍 LIGNES 85 À 100 DE Game.js")
print("="*60)
for i in range(84, min(100, len(lines))):
    print(f"LIGNE {i+1:3d}: {lines[i].rstrip()}")
print("="*60)