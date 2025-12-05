#!/usr/bin/env python3
# VERIFICATION COMPLETE - index.html + Game.js
# Version ASCII sans caracteres speciaux (emojis supprimes)

import re
from pathlib import Path

print("="*70)
print("VERIFICATION COMPLETE - Platon's Shifter v4.2")
print("="*70)
print()

# ============================================================================
# ETAPE 1 : Verification de index.html
# ============================================================================
html_file = Path("index.html")
if not html_file.exists():
    print("ERREUR : index.html introuvable !")
    exit()

print("Analyse de index.html...")

with open(html_file, 'r', encoding='utf-8') as f:
    html_content = f.read()

# Liste des elements CRITIQUES a verifier
ELEMENTS_CRITIQUES = {
    'canvas': r'<canvas id="gameCanvas".*?width="800".*?height="500".*?>',
    'currentForm': r'<div id="currentForm">',
    'score': r'<span id="score">',
    'energy': r'<span id="energy">',
    'killsDisplay': r'<span id="killsDisplay">',
    'health': r'<span id="health">',
    'powerStatus': r'<div id="powerStatus">',
    'powerCooldown': r'<div id="powerCooldown"',
    'status': r'<div id="status".*?>Jouez !</div>',  # CRITIQUE
    'main-panel': r'<div class="main-panel">',
    'script': r'<script src="Game\.js"></script>'
}

print("\n[ELEMENTS HTML CRITIQUES]")
tous_presents = True
for nom, pattern in ELEMENTS_CRITIQUES.items():
    if re.search(pattern, html_content):
        print(f"  OK : {nom}")
    else:
        print(f"  MANQUANT : {nom}")
        tous_presents = False

if not tous_presents:
    print("\nATTENTION : Des elements critiques sont manquants !")
    print("   Ajoutez-les avant de continuer.")
else:
    print("\nOK : Tous les elements HTML sont presents")

# ============================================================================
# ETAPE 2 : Verification de Game.js (correspondance)
# ============================================================================
print("\nAnalyse de Game.js...")

js_file = Path("Game.js")
if not js_file.exists():
    print("ERREUR : Game.js introuvable !")
    exit()

with open(js_file, 'r', encoding='utf-8') as f:
    js_content = f.read()

# Verifier si Game.js essaie de creer des elements qui existent deja
print("\n[ANALYSE Game.js - Creations d'elements]")
problemes = []

# Recherche de creation d'elements
if "document.createElement('div')" in js_content and "status" in js_content:
    problemes.append("Game.js cree un element 'div' (status) qui existe deja dans l'HTML")

# Recherche de references a des fonctions inexistantes
for func in ["handleMouseDown", "handleMouseMove"]:
    if f"window.removeEventListener('{func.lower()}'" in js_content:
        problemes.append(f"Reference orpheline a {func}")

if problemes:
    print("  Problemes detectes :")
    for p in problemes:
        print(f"    - {p}")
else:
    print("  OK : Game.js ne cree pas de conflits")

# ============================================================================
# ETAPE 3 : Verification de la structure complete
# ============================================================================
print("\n[STRUCTURE COMPLETE]")
print(f"  index.html : {len(html_content)} caracteres")
print(f"  Game.js    : {len(js_content)} caracteres")
print(f"  Ratio      : 1:{len(js_content)//len(html_content)}")

# ============================================================================
# ETAPE 4 : Rapport final
# ============================================================================
print("\n" + "="*70)
print("RAPPORT DE VERIFICATION")
print("="*70)

if tous_presents and not problemes:
    print("\nOK : STRUCTURE VALIDE ET PROPRE")
    print("\nVOUS POUVEZ LANCER LE JEU :")
    print("   Double-cliquez sur index.html")
    print("   OU executez launcher_final_v4.1.bat -> [1]")
else:
    print("\nCORRECTIONS NECESSAIRES")
    print("   1. Executez CORRECTEUR_FINAL_V4.2.py")
    print("   2. Puis revalidez avec ce script")

print("\n" + "="*70)