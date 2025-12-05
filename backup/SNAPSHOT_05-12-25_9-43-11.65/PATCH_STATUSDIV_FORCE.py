#!/usr/bin/env python3
# PATCH STATUSDIV FORCE - Placement au debut de Game.js
# Supprime TOUTES les creations et place la declaration correcte

import re  # ✅ IMPORT CRITIQUE AJOUTÉ

print("="*70)
print("🔧 PATCH STATUSDIV FORCE - Placement au debut")
print("="*70)
print()

with open('Game.js', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# ============================================================================
# ETAPE 1 : Trouver ou inserer (apres les declarations globales)
# ============================================================================
print("📍 Recherche de l'endroit d'insertion...")

insert_index = 0
for i, line in enumerate(lines):
    if line.strip().startswith(('let ', 'const ')) and line.strip().endswith(';'):
        insert_index = i + 1
    if line.strip().startswith('function '):
        break

print(f"  ✅ Insertion prevue apres la ligne {insert_index}")

# ============================================================================
# ETAPE 2 : Supprimer TOUTES les declarations statusDiv existantes
# ============================================================================
print("\n🧹 Suppression des anciennes declarations...")

# Supprimer les lignes qui creent ou modifient statusDiv
new_lines = []
lignes_supprimees = []

for i, line in enumerate(lines, 1):
    # Supprimer le bloc de creation
    if "// Initialisation du DOM" in line or re.search(r'const\s+statusDiv\s*=\s*document\.createElement', line):
        lignes_supprimees.append(i)
        continue
    
    # Supprimer le appendChild
    if "appendChild(statusDiv)" in line:
        lignes_supprimees.append(i)
        continue
    
    # Supprimer les lignes intermediaires (style, textContent, etc.)
    if "statusDiv.style" in line or "statusDiv.textContent" in line:
        lignes_supprimees.append(i)
        continue
    
    new_lines.append(line)

print(f"  📄 Lignes supprimees : {lignes_supprimees}")

# ============================================================================
# ETAPE 3 : Inserer la declaration PROPRE
# ============================================================================
print("\n✅ Insertion de la declaration correcte...")
decl = "const statusDiv = document.getElementById('status');\n"

# Verifier si deja presente
if decl.strip() not in ''.join(new_lines):
    new_lines.insert(insert_index, decl)
    print(f"  ✅ Declaration inseree a la ligne {insert_index+1}")
else:
    print("  ✅ Declaration deja presente")

# ============================================================================
# ETAPE 4 : Supprimer les removeEventListener orphelins
# ============================================================================
print("\n🧹 Nettoyage des removeEventListener orphelins...")

final_lines = []
for line in new_lines:
    if 'window.removeEventListener' in line and ('handleMouseDown' in line or 'handleMouseMove' in line):
        continue
    final_lines.append(line)

# ============================================================================
# ETAPE 5 : Sauvegarde
# ============================================================================
print(f"\n💾 Sauvegarde du fichier corrige...")

with open('Game.js', 'w', encoding='utf-8') as f:
    f.writelines(final_lines)

print("\n✅ Patch applique avec succes")
print("🎮 Relancez index.html immédiatement")
input("\nAppuyez sur Entree pour quitter...")