#!/usr/bin/env python3
# Correction manuelle ligne 87

with open('Game.js', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Vérifier si ligne 87 existe
if len(lines) >= 87:
    ligne_87 = lines[86]  # Index 86 = ligne 87
    
    # Si c'est l'ancien pattern
    if 'enemyBases[' in ligne_87:
        print(f"❌ LIGNE 87 À CORRIGER: {ligne_87.strip()}")
        lines[86] = "    const base = enemyBase; // ✅ CORRECT\n"
        print("✅ LIGNE 87 CORRIGÉE")
    
    # Sauvegarder
    with open('Game.js', 'w', encoding='utf-8') as f:
        f.writelines(lines)
else:
    print("❌ Le fichier a moins de 87 lignes !")

# Vérifier la déclaration (ligne ~15)
if len(lines) >= 15:
    if 'let enemyBases' in lines[14]:
        print("❌ DÉCLARATION À CORRIGER (ligne 15)")
        lines[14] = "let enemyBase = null;\n"
        print("✅ DÉCLARATION CORRIGÉE")

# Ré-écrire
with open('Game.js', 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("✅ Sauvegarde du fichier corrigé")