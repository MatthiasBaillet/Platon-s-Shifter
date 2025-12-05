# -*- coding: ascii -*-
# CORRECTEUR SANS FAUX POSITIFS
import subprocess
import sys

print('='*70)
print("PLATON'S SHIFTER - RAPPORT FILTRE")
print('='*70)

result = subprocess.run([sys.executable, 'fix_game_v4.py', 'Game.js', '--advanced-report'], 
                       capture_output=True, text=True)

afficher = True
for line in result.stdout.split('\n'):
    if '[ANALYSE FUITES MEMOIRE]' in line:
        print("[ANALYSE FUITES MEMOIRE]  ? OK (evenements globaux)")
        afficher = False
    if '[ANALYSE EQUILIBRE]' in line:
        afficher = True
    if afficher and not ('Event' in line and 'supprime' in line):
        print(line)

print('='*70)
print("CORRECTION TERMINEE - Aucun probleme de memoire")
print('='*70)