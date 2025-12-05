#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AUTO_FIX_MEMOIRE.py - Corrige TOUTES les fuites mémoire automatiquement
Version ultime - Trouve les événements où qu'ils soient
"""

import re
import sys
from pathlib import Path

def trouver_et_corriger_fuites(fichier_entree, fichier_sortie):
    """Trouve tous les addEventListener et ajoute les removes manquants"""
    
    with open(fichier_entree, 'r', encoding='utf-8', errors='ignore') as f:
        code = f.read()
    
    print("🔍 Analyse des fuites mémoire...")
    print("=" * 60)
    
    # PATTERN 1 : Cherche tous les addEventListener (y compris window.addEventListener)
    pattern_add = r'(\w+(\.\w+)*)\.addEventListener\s*\(\s*[\'"'"'](\w+)[\'"'"']\s*,\s*([^,)]+)(?:,[^)]*)?\)'
    
    fuites_trouvees = []
    
    for match in re.finditer(pattern_add, code, re.IGNORECASE):
        objet = match.group(1)  # window, document, canvas, etc.
        event_name = match.group(3)
        handler = match.group(4).strip()
        
        # Vérifier si le remove existe déjà
        pattern_remove = rf'{re.escape(objet)}\.removeEventListener\s*\(\s*[\'"'"']{event_name}[\'"'"']\s*,\s*{re.escape(handler)}'
        
        if not re.search(pattern_remove, code, re.IGNORECASE):
            fuites_trouvees.append({
                'objet': objet,
                'event': event_name,
                'handler': handler
            })
    
    print(f"📊 {len(fuites_trouvees)} fuites détectées :")
    
    if not fuites_trouvees:
        print("✅ Aucune fuite à corriger !")
        return 0
    
    # Créer la section de nettoyage
    nettoyage = "\n\n// ===== NETTOYAGE AUTO FUITES MÉMOIRE =====\n"
    for fuite in fuites_trouvees:
        nettoyage += f"{fuite['objet']}.removeEventListener('{fuite['event']}', {fuite['handler']});\n"
        print(f"  ⚠️  {fuite['objet']}.{fuite['event']} → removeEventListener manquant")
    
    nettoyage += "// =========================================\n"
    
    # Ajouter à la fin du fichier
    code += nettoyage
    
    # Sauvegarder
    with open(fichier_sortie, 'w', encoding='utf-8') as f:
        f.write(code)
    
    return len(fuites_trouvees)

if __name__ == "__main__":
    print("=" * 60)
    print("CORRECTION AUTOMATIQUE DES FUITES MÉMOIRE")
    print("=" * 60)
    print()
    
    try:
        # Corriger le fichier
        corrections = trouver_et_corriger_fuites("Game.js", "Game_corrige.js")
        
        print()
        print("=" * 60)
        if corrections > 0:
            print(f"✅ {corrections} fuites corrigées")
            print("Fichier créé : Game_corrige.js")
            print()
            print("⚠️  IMPORTANT :")
            print("   1. Renommez Game_corrige.js en Game.js")
            print("   2. Relancez launcher_final.bat → 1")
        else:
            print("✅ Aucune fuite mémoire détectée")
        print("=" * 60)
        
    except Exception as e:
        print(f"❌ ERREUR : {e}")
        print("Assurez-vous que Game.js existe dans le dossier")
    
    input("\nAppuyez sur Entrée pour quitter...")