#!/usr/bin/env python3
# EXECUTEUR TEST AUTOMATIQUE - Trouve et lance le test dans le bon dossier

import subprocess
import sys
from pathlib import Path
import os

print("="*70)
print("🧪 LANCEUR DE TEST INTELLIGENT")
print("="*70)
print()

# ============================================================================
# ETAPE 1 : Trouver le dossier du projet (même avec apostrophe)
# ============================================================================
# Obtenir le dossier où se trouve ce script
script_dir = Path(__file__).parent.resolve()
print(f"📁 Dossier du script : {script_dir}")

# Vérifier si test_game.js existe ici
test_file = script_dir / "test_game.js"
if not test_file.exists():
    print("❌ test_game.js introuvable dans ce dossier !")
    print("💡 Créez-le d'abord avec upgrade_to_v4.2.bat")
    input("\nAppuyez sur Entrée pour quitter...")
    sys.exit(1)

print(f"✅ test_game.js trouvé : {test_file}")

# ============================================================================
# ETAPE 2 : Vérifier Node.js
# ============================================================================
print()
print("🔍 Vérification de Node.js...")
try:
    result = subprocess.run(['node', '--version'], capture_output=True, text=True, timeout=5)
    if result.returncode == 0:
        print(f"  ✅ Node.js {result.stdout.strip()}")
    else:
        print("  ❌ Node.js non accessible")
        sys.exit(1)
except Exception as e:
    print(f"  ❌ Erreur : {e}")
    input("\nAppuyez sur Entrée pour quitter...")
    sys.exit(1)

# ============================================================================
# ETAPE 3 : Exécuter le test dans le BON dossier
# ============================================================================
print()
print("🚀 Exécution du test unitaire...")
print("="*70)
print()

# Changer de dossier (même avec apostrophe)
os.chdir(script_dir)

try:
    result = subprocess.run(['node', 'test_game.js'], 
                          capture_output=True, 
                          text=True, 
                          timeout=30,
                          cwd=script_dir)  # FORCER le dossier de travail
    
    print(result.stdout)
    if result.stderr:
        print("❌ ERREURS :")
        print(result.stderr)
    
    print("="*70)
    if result.returncode == 0:
        print("✅ TEST TERMINÉ AVEC SUCCÈS")
    else:
        print(f"❌ TEST ÉCHOUÉ (code : {result.returncode})")
    print("="*70)
        
except subprocess.TimeoutExpired:
    print("❌ Timeout - Le test a pris trop de temps")
except Exception as e:
    print(f"❌ Erreur : {e}")

# ============================================================================
# ETAPE 4 : GARDER LA FENETRE OUVERTE
# ============================================================================
print()
input("Appuyez sur Entrée pour fermer cette fenêtre...")