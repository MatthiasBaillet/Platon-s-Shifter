# diagnostic_simple.py
with open('Game.js', 'r', encoding='utf-8') as f:
    lines = f.readlines()

print("Lignes avec 'enemy' :")
for i, line in enumerate(lines, 1):
    if 'enemy' in line.lower():
        print(f"{i}: {line.strip()}")

input("\nAppuyez sur Entrée pour fermer...")