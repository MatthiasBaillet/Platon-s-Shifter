#!/usr/bin/env python3
"""
Diagnostic complet du fichier Game.js
"""

import re
from pathlib import Path

def diagnostic_file(filepath):
    content = Path(filepath).read_text(encoding='utf-8')
    
    print("=" * 70)
    print("🔍 DIAGNOSTIC COMPLET")
    print("=" * 70)
    
    # Vérifie si c'est du HTML
    if content.strip().startswith('<!DOCTYPE') or '<html' in content[:100]:
        print("❌ ERREUR CRITIQUE : Le fichier est une page HTML, pas du JavaScript !")
        print("   → Vous devez obtenir le vrai fichier Game.js")
        return False
    
    # Vérifie les patterns critiques
    patterns = {
        "Taille bases (2.5)": r"radius\s*:\s*GRID_SIZE\s*\*\s*2\.5",
        "Tableau enemyBases": r"let\s+enemyBases\s*=\s*\[\s*\]\s*;",
        "Texte BASE": r"ctx\.fillText\s*\(\s*'BASE'",
        "Boucle 3 bases": r"// 3 bases ennemis",
    }
    
    print(f"\n📊 Contenu analysé : {len(content)} caractères")
    print(f"\n✅ PATTERNS TROUVES DANS VOTRE FICHIER :\n")
    
    for nom, pattern in patterns.items():
        matches = re.findall(pattern, content)
        if matches:
            print(f"  [TROUVE] {nom} : {len(matches)} occurrence(s)")
        else:
            print(f"  [MANQUANT] {nom}")
    
    # Affiche les 10 premières lignes
    print(f"\n📋 Les 10 PREMIERES LIGNES DE VOTRE FICHIER :\n")
    lignes = content.splitlines()[:10]
    for i, ligne in enumerate(lignes, 1):
        print(f"  {i:2d} | {ligne[:80]}")
    
    print("\n" + "=" * 70)
    return True

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        fichier = sys.argv[1]
    else:
        fichier = "Game.js"
    
    print(f"Analyse du fichier : {fichier}\n")
    diagnostic_file(fichier)