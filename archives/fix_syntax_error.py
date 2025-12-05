#!/usr/bin/env python3
# Fix SyntaxError ligne 89 (enemyBase)

import re
import subprocess

def fix_line_89():
    with open('Game.js', 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Vérifier ligne 89 (index 88)
    if len(lines) > 88:
        line = lines[88]
        print(f"LIGNE 89 AVANT : {repr(line)}")
        
        # CORRECTION : Supprime parenthèse orpheline
        # Pattern : "const base = enemyBases[...]);" → "const base = enemyBase;"
        line = re.sub(r'const\s+base\s*=\s*enemyBases\s*\[.*?\]\s*\)\s*;', 'const base = enemyBase;', line)
        line = re.sub(r'\s+\)\s*;', ';', line)  # Sécurité : enlève ) orphelin
        
        lines[88] = line
        print(f"LIGNE 89 APRÈS : {repr(line)}")
    
    # Écrire
    with open('Game.js', 'w', encoding='utf-8') as f:
        f.writelines(lines)
    
    print("✅ Ligne 89 corrigée")

def valider_syntaxe():
    result = subprocess.run(['node', '-c', 'Game.js'], capture_output=True, text=True)
    if result.returncode == 0:
        print("✅ Syntaxe Node.js VALIDÉE")
        return True
    else:
        print("❌ ERREUR SYNTAXE :")
        print(result.stderr)
        return False

if __name__ == '__main__':
    fix_line_89()
    valider_syntaxe()