#!/usr/bin/env python3
# CORRECTEUR MANUEL ULTRA-PRECIS - Edite les lignes exactes de Game.js

import re  # ✅ IMPORT CRITIQUE AJOUTÉ

print("="*70)
print("CORRECTEUR MANUEL ULTRA-PRECIS")
print("="*70)
print()

# ============================================================================
# ETAPE 1 : Lire le fichier ligne par ligne
# ============================================================================
with open('Game.js', 'r', encoding='utf-8') as f:
    lines = f.readlines()

print(f"Fichier lu : {len(lines)} lignes")

# ============================================================================
# ETAPE 2 : Trouver et supprimer la ligne 723 (textContent)
# ============================================================================
print("\nRecherche de la ligne 723 (textContent)...")

for i, line in enumerate(lines, 1):
    if "statusDiv.textContent" in line:
        print(f"  Ligne {i} trouvee : {line.strip()[:60]}")
        # Supprimer cette ligne
        lines[i-1] = "// Ligne supprimee (statusDiv.textContent)\n"
        print(f"  Ligne {i} supprimee")
        break

# ============================================================================
# ETAPE 3 : Inserer la declaration de statusDiv au debut
# ============================================================================
print("\nInsertion de la declaration au debut...")

decl = "const statusDiv = document.getElementById('status');\n"

# Verifier si deja presente
if decl not in lines:
    # Trouver l'index apres les declarations globales (apres le dernier ';')
    insert_index = 0
    for i, line in enumerate(lines):
        if line.strip().startswith(('let ', 'const ')) and line.strip().endswith(';'):
            insert_index = i + 1
        if line.strip().startswith('function '):
            break
    
    lines.insert(insert_index, decl)
    print(f"  Declaration inseree a la ligne {insert_index+1}")
else:
    print("  Declaration deja presente")

# ============================================================================
# ETAPE 4 : Supprimer TOUTES les autres lignes statusDiv
# ============================================================================
print("\nSuppression des autres references statusDiv...")

clean_lines = []
suppr_count = 0

for i, line in enumerate(lines, 1):
    # Supprimer les lignes qui CREENT ou MODIFIENT statusDiv
    if re.search(r'statusDiv\s*=\s*document\.createElement', line) or \
       re.search(r'statusDiv\.style', line) or \
       re.search(r'statusDiv\.textContent', line) or \
       "// Initialisation du DOM" in line or \
       "appendChild(statusDiv)" in line:
        clean_lines.append("// Ligne supprimee (conflit statusDiv)\n")
        suppr_count += 1
    else:
        clean_lines.append(line)

print(f"  {suppr_count} lignes nettoyees")

# ============================================================================
# ETAPE 5 : Sauvegarde
# ============================================================================
print(f"\nSauvegarde du fichier corrige...")

with open('Game.js', 'w', encoding='utf-8') as f:
    f.writelines(clean_lines)

print("\nFichier corrige avec succes")
print("Relancez index.html immédiatement")
input("\nAppuyez sur Entree pour quitter...")