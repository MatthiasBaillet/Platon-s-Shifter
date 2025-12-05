#!/usr/bin/env python3
# PATCH CHIRURGICAL FINAL - Supprime TOUTE création de statusDiv
# Cible les lignes exactes 730-735 et les supprime

import re

print("="*70)
print("🔪 PATCH CHIRURGICAL - Suppression totale création statusDiv")
print("="*70)
print()

with open('Game.js', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# ============================================================================
# ÉTAPE 1 : Identifier et supprimer les lignes de création
# ============================================================================
print("📍 Recherche des lignes de création statusDiv...")

new_lines = []
supprimer = False
lignes_supprimees = []

for i, line in enumerate(lines, 1):
    # Marquer le début du bloc à supprimer
    if "// Initialisation du DOM" in line or ("const statusDiv" in line and "createElement" in line):
        supprimer = True
        lignes_supprimees.append(i)
        continue
    
    # Marquer la fin du bloc (appendChild)
    if supprimer and "appendChild(statusDiv)" in line:
        supprimer = False
        lignes_supprimees.append(i)
        continue
    
    # Supprimer toutes les lignes intermédiaires
    if supprimer:
        lignes_supprimees.append(i)
        continue
    
    # Garder les autres lignes
    new_lines.append(line)

print(f"  📄 Lignes à supprimer : {lignes_supprimees}")

# ============================================================================
# ÉTAPE 2 : S'assurer que statusDiv est récupéré par getElementById
# ============================================================================
print("\n🔍 Vérification de la récupération statusDiv...")

# Trouver la ligne avec killsDiv
for i, line in enumerate(new_lines):
    if 'const killsDiv = document.getElementById(\'killsDisplay\');' in line:
        # Vérifier si statusDiv est déjà au-dessus
        if i > 0 and 'statusDiv' not in new_lines[i-1]:
            # Insérer la ligne statusDiv avant killsDiv
            new_lines.insert(i, 'const statusDiv = document.getElementById(\'status\');\n')
            print("  ✅ Ligne statusDiv ajoutée")
            break

# ============================================================================
# ÉTAPE 3 : Supprimer les window.removeEventListener orphelines
# ============================================================================
print("\n🧹 Suppression des removeEventListener orphelins...")

# Supprimer les lignes exactes qui causent les erreurs
final_lines = []
for line in new_lines:
    # Supprimer window.removeEventListener sur handleMouseDown/handleMouseMove
    if 'window.removeEventListener' in line and ('handleMouseDown' in line or 'handleMouseMove' in line):
        print(f"  🗑️ Ligne supprimée : {line.strip()[:60]}...")
        continue
    final_lines.append(line)

# ============================================================================
# ÉTAPE 4 : Sauvegarde
# ============================================================================
print(f"\n💾 Sauvegarde du fichier corrigé ({len(lignes_supprimees)} lignes supprimées)...")

with open('Game.js', 'w', encoding='utf-8') as f:
    f.writelines(final_lines)

print("\n✅ Patch chirurgical appliqué avec succès")
print("🎮 Relancez index.html IMMÉDIATEMENT")
input("\nAppuyez sur Entrée pour quitter...")