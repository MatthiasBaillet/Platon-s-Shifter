#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PATCH MEMOIRE - Supprime les fuites d'événements
"""

import re

def corriger_fuites_memoire(fichier_entree, fichier_sortie):
    with open(fichier_entree, 'r', encoding='utf-8', errors='ignore') as f:
        code = f.read()
    
    # Ajout des removeEventListener pour chaque addEventListener
    corrections = []
    
    # Pattern pour trouver les addEventListener sans remove
    event_pattern = r'\.addEventListener\s*\(\s*[\'"](\w+)[\'"]\s*,\s*([^)]+)\)'
    
    # Pour chaque événement trouvé, ajouter le remove correspondant
    for match in re.finditer(event_pattern, code):
        event_name = match.group(1)
        handler = match.group(2)
        
        # Vérifier si le remove existe déjà
        remove_pattern = rf'\.removeEventListener\s*\(\s*[\'"]{event_name}[\'"]\s*,'
        if not re.search(remove_pattern, code):
            # Créer le remove correspondant (à placer avant la fin du script)
            correction = f"    window.removeEventListener('{event_name}', {handler});\n"
            corrections.append(correction)
    
    if corrections:
        # Insérer les removes avant la fermeture du script
        code = code.replace("// FIN DU SCRIPT", "".join(corrections) + "\n// FIN DU SCRIPT")
    
    # Sauvegarder
    with open(fichier_sortie, 'w', encoding='utf-8') as f:
        f.write(code)
    
    return len(corrections)

if __name__ == "__main__":
    corrections = corriger_fuites_memoire("Game.js", "Game_corrige.js")
    print(f"✅ {corrections} fuites mémoire corrigées")
    print("Fichier créé : Game_corrige.js")
    input("Appuyez sur Entrée...")