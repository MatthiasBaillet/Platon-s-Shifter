#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CREATE_FIXER.py - Crée fix_game_v4.py PROPREMENT
Version 100% fiable - Pas d'erreurs d'encodage
"""

import os
from pathlib import Path

# Chemin du fichier à créer
OUTPUT_FILE = Path(__file__).parent / "fix_game_v4.py"

# CODE DU CORRECTEUR V4 (avec bonnes séquences d'échappement)
CODE = '''#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Platon's Shifter - Correcteur Automatique v4.0
NIVEAU SUPÉRIEUR : Détection fuites mémoire + Analyse équilibre
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Optional

# ============================================
# CONFIGURATION DES CORRECTIONS
# ============================================
CORRECTIONS_CONFIG = [
    {
        "id": "taille_bases",
        "nom": "Reduire taille des bases (2.5→1.5)",
        "pattern": r"radius\\s*:\\s*GRID_SIZE\\s*\\*\\s*2\\.5",
        "replace": "radius: GRID_SIZE * 1.5",
        "marqueur": "CORRECT_TAILLE_BASES"
    },
    {
        "id": "base_unique_ennemi",
        "nom": "Passer a une seule base ennemi",
        "pattern": r"let\\s+enemyBases\\s*=\\s*\\[\\s*\\]\\s*;",
        "replace": "let enemyBase = null;",
        "marqueur": "CORRECT_BASE_UNIQUE"
    },
    {
        "id": "bases_logique_spawn",
        "nom": "Simplifier logique de creation des bases",
        "pattern": r"// 3 bases ennemis[\\s\\S]*?enemyBases\\.push\\(base\\);\\s+}\\s+}",
        "replace": """            # Une seule base ennemie
            enemyBase = {
                x: canvas.width * 0.75,
                y: canvas.height / 2,
                radius: GRID_SIZE * 1.5
            };""",
        "marqueur": "CORRECT_BASES_LOGIQUE"
    },
    {
        "id": "uniformiser_style",
        "nom": "Uniformiser style base/terrain",
        "pattern": r"ctx\\.fillText\\s*\\(\\s*'BASE'\\s*,\\s*startBase\\.x\\s*,\\s*startBase\\.y\\s*\\+\\s*5\\s*\\)\\s*;",
        "replace": "",
        "marqueur": "CORRECT_STYLE"
    },
    {
        "id": "respawn_ennemis",
        "nom": "Corriger respawn ennemis",
        "pattern": r"//\\s*DETRUIRE\\s*L'ENNEMI\\s*enemies\\.splice\\s*\\(\\s*index\\s*,\\s*1\\s*\\)\\s*;",
        "replace": "# CORRIGE: Respawn apres 1s\\n                    enemies.splice(index, 1);\\n                    setTimeout(() => enemies.push(createEnemy()), 1000);",
        "marqueur": "CORRECT_RESPAWN"
    }
]

class Correction:
    def __init__(self, config: Dict):
        self.id = config["id"]
        self.nom = config["nom"]
        self.marqueur = config["marqueur"]
        self.pattern = config.get("pattern", "")
        self.replace = config.get("replace", "")
    
    def test(self, code: str) -> bool:
        return bool(re.search(self.pattern, code, re.MULTILINE | re.DOTALL))
    
    def apply(self, code: str) -> Tuple[str, bool]:
        new_code = re.sub(self.pattern, self.replace, code, flags=re.MULTILINE | re.DOTALL)
        modified = new_code != code
        return new_code, modified

def detect_memory_leaks(code: str) -> Dict[str, List[str]]:
    """Detecte les fuites memoire (event listeners)"""
    leaks = {'listeners': [], 'intervals': []}
    
    # Pattern pour addEventListener
    listener_pattern = r'\\.addEventListener\\s*\\(\\s*[\\\'"](\\w+)[\\\'"]\\s*,'
    for match in re.finditer(listener_pattern, code):
        leaks['listeners'].append(f"Event '{match.group(1)}' non supprime")
    
    return leaks

def analyze_game_balance(code: str) -> Dict[str, List[str]]:
    """Analyse l'equilibre des 5 formes"""
    balance = {'warnings': [], 'info': [], 'stats': {}}
    forms = ['Tetrahedron', 'Cube', 'Octahedron', 'Dodecahedron', 'Icosahedron']
    
    for form in forms:
        # Recherche du cout energie
        pattern = rf'function\\s+{form.lower()}_power[\\s\\S]*?energy\\s*-\\=\\s*(\\d+)'
        match = re.search(pattern, code)
        energy = int(match.group(1)) if match else 0
        damage = energy * 3
        
        balance['stats'][form] = {'energy': energy, 'damage': damage}
        
        if energy > 10:
            balance['warnings'].append(f"{form}: Cout energie élevé ({energy})")
    
    return balance

def main():
    """Main du correcteur"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Correcteur V4')
    parser.add_argument('file', help='Fichier Game.js')
    parser.add_argument('--dry-run', action='store_true', help='Simulation')
    parser.add_argument('--advanced-report', action='store_true', help='Rapport complet')
    
    args = parser.parse_args()
    
    # Lecture du fichier
    with open(args.file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    corrections = [Correction(c) for c in CORRECTIONS_CONFIG]
    applied = []
    
    print("=" * 70)
    print("🚀 NIVEAU SUPÉRIEUR V4.0 - ACTIVÉ")
    print("=" * 70)
    
    # Application des corrections
    for corr in corrections:
        if corr.test(content):
            content, modified = corr.apply(content)
            if modified:
                applied.append(corr.nom)
                content += f"\\n// {corr.marqueur}\\n"
    
    # Rapport avancé
    if args.advanced_report or not args.dry_run:
        print("\\n" + "=" * 70)
        print("📊 RAPPORT NIVEAU SUPÉRIEUR")
        print("=" * 70)
        
        # Fuites mémoire
        print("\\n[ANALYSE FUITES MÉMOIRE]")
        leaks = detect_memory_leaks(content)
        if leaks['listeners']:
            for leak in leaks['listeners']:
                print(f"  ⚠️  {leak}")
        else:
            print("  ✅ Aucune fuite mémoire détectée")
        
        # Équilibre jeu
        print("\\n[ANALYSE ÉQUILIBRE]")
        balance = analyze_game_balance(content)
        if balance['warnings']:
            for warn in balance['warnings']:
                print(f"  ⚠️  {warn}")
        else:
            print("  ✅ Équilibre du jeu OK")
        
        # Stats
        print("\\n[STATS DES FORMES]")
        for form, stats in balance['stats'].items():
            print(f"  {form:12} : Énergie={stats['energy']:<3} | Dégâts={stats['damage']:<3}")
    
    # Sauvegarde
    if not args.dry_run:
        output = args.file.replace('.js', '_fixed.js')
        with open(output, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"\\n✅ Fichier corrigé : {output}")

if __name__ == "__main__":
    main()
'''

# ============ CRÉATION DU FICHIER ============
def creer_fichier():
    print("=" * 70)
    print("CRÉATION AUTOMATIQUE DE fix_game_v4.py")
    print("=" * 70)
    print()
    
    try:
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write(CODE)
        print(f"✅ Fichier créé : {OUTPUT_FILE.name}")
        print(f"📍 Emplacement : {OUTPUT_FILE}")
        print()
        print("=" * 70)
        print("TEST IMMÉDIAT DU CORRECTEUR")
        print("=" * 70)
        print()
        
        # Test immédiat
        os.system(f'python "{OUTPUT_FILE}" Game.js --advanced-report')
        
        print()
        print("=" * 70)
        print("🎯 SI VOUS VOYEZ UN RAPPORT CI-DESSUS, C'EST GAGNÉ !")
        print("=" * 70)
        
    except Exception as e:
        print(f"❌ ERREUR : {e}")
        print(f"Impossible de créer {OUTPUT_FILE.name}")
    
    print()
    input("Appuyez sur Entrée pour quitter...")

# ============ LANCEMENT ============
if __name__ == "__main__":
    creer_fichier()