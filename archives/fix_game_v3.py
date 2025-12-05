#!/usr/bin/env python3
"""
Platon's Shifter - Correcteur Automatique v2.4
NOUVEAU : Validation après chaque correction + rollback automatique
"""

import urllib.request
import hashlib
import os
import re
import sys
import shutil
import subprocess
from pathlib import Path
from typing import Dict, Optional, Tuple, List

# ============================================
# CONFIGURATION DES CORRECTIONS
# ============================================
CORRECTIONS_CONFIG = [
    {
        "id": "taille_bases",
        "nom": "Reduire taille des bases (2.5→1.5)",
        "pattern": r"radius\s*:\s*GRID_SIZE\s*\*\s*2\.5",
        "replace": "radius: GRID_SIZE * 1.5",
        "marqueur": "CORRECT_TAILLE_BASES"
    },
    {
        "id": "base_unique_ennemi",
        "nom": "Passer a une seule base ennemi",
        "pattern": r"let\s+enemyBases\s*=\s*\[\s*\]\s*;",
        "replace": "let enemyBase = null;",
        "marqueur": "CORRECT_BASE_UNIQUE"
    },
    {
        "id": "bases_logique_spawn",
        "nom": "Simplifier logique de creation des bases",
        "pattern": r"// 3 bases ennemis[\s\S]*?enemyBases\.push\(base\);\s+}\s+}",
        "replace": """            // Une seule base ennemie
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
        "pattern": r"ctx\.fillText\s*\(\s*'BASE'\s*,\s*startBase\.x\s*,\s*startBase\.y\s*\+\s*5\s*\)\s*;",
        "replace": "",
        "marqueur": "CORRECT_STYLE"
    },
    {
        "id": "respawn_ennemis",
        "nom": "Corriger respawn ennemis",
        "pattern": r"//\s*DETRUIRE\s*L'ENNEMI\s*enemies\.splice\s*\(\s*index\s*,\s*1\s*\)\s*;",
        "replace": "// ✅ CORRIGE : Respawn apres 1s\n                    enemies.splice(index, 1);\n                    setTimeout(() => enemies.push(createEnemy()), 1000);",
        "marqueur": "CORRECT_RESPAWN"
    }
]

# ============================================
# CLASSE DE CORRECTION
# ============================================
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

# ============================================
# NOUVELLE FONCTION : Application avec validation rollback
# ============================================
def apply_with_rollback(code: str, correction: Correction) -> Tuple[str, bool, Optional[str]]:
    """
    Applique une correction avec rollback automatique si la validation échoue
    Retourne : (code_modifie, a_ete_modifie, message_erreur_ou_None)
    """
    backup_code = code  # Sauvegarde avant correction
    
    # Appliquer la correction
    new_code, modified = correction.apply(code)
    
    if not modified:
        return code, False, None  # Pas de changement
    
    # VALIDATION IMMÉDIATE
    is_valid, error = validate_syntax(new_code)
    
    if is_valid:
        # Ajouter le marqueur uniquement si validation OK
        new_code += f"\n// {correction.marqueur}\n"
        return new_code, True, None
    else:
        # ROLLBACK : retourner l'ancien code
        print(f"      ❌ ÉCHEC VALIDATION - Rollback automatique")
        print(f"         Erreur : {error[:80]}...")
        return backup_code, False, error

# ============================================
# GESTION CHARGEMENT (URL ou FICHIER LOCAL)
# ============================================
def load_content(source: str) -> str:
    """
    Charge le contenu soit depuis une URL, soit depuis un fichier local
    """
    # Vérifier si c'est une URL (http:// ou https://)
    if source.startswith(('http://', 'https://')):
        return download_from_url(source)
    else:
        return load_from_file(source)

def download_from_url(url: str) -> str:
    """Télécharge depuis une URL distante"""
    try:
        print(f"   Tentative de telechargement depuis {url}...")
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        
        with urllib.request.urlopen(req, timeout=15) as response:
            content_type = response.headers.get('Content-Type', '')
            if 'text/html' in content_type.lower():
                print(f" ❌ ERREUR : L'URL a renvoye une page HTML au lieu du fichier JS.")
                print(f"    Type de contenu recu: {content_type}")
                sys.exit(1)
            
            content = response.read()
            decoded = content.decode('utf-8', errors='strict')
            
            if decoded.strip().startswith('<!DOCTYPE html>') or '<html' in decoded[:100]:
                print(" ❌ ERREUR : Le contenu semble etre une page HTML.")
                sys.exit(1)
            
            return decoded
            
    except urllib.error.HTTPError as e:
        print(f" ❌ ERREUR HTTP {e.code}: {e.reason}")
        if e.code == 404:
            print("    Le fichier n'existe pas a cette adresse.")
        sys.exit(1)
    except urllib.error.URLError as e:
        print(f" ❌ ERREUR DE CONNEXION: {e.reason}")
        print("    Verifiez votre connexion internet.")
        sys.exit(1)
    except Exception as e:
        print(f" ❌ ERREUR INATTENDUE: {e}")
        sys.exit(1)

def load_from_file(filepath: str) -> str:
    """Charge depuis un fichier local"""
    try:
        print(f"   Chargement depuis fichier local : {filepath}")
        path = Path(filepath)
        
        if not path.exists():
            print(f" ❌ ERREUR : Le fichier n'existe pas : {filepath}")
            sys.exit(1)
        
        if path.stat().st_size > 500000:
            print(f" ❌ ERREUR : Fichier trop volumineux (> 500 Ko)")
            sys.exit(1)
        
        return path.read_text(encoding='utf-8')
        
    except Exception as e:
        print(f" ❌ ERREUR lors de la lecture du fichier : {e}")
        sys.exit(1)

# ============================================
# FONCTIONS UTILITAIRES
# ============================================
def validate_syntax(code: str) -> Tuple[bool, Optional[str]]:
    """Valide la syntaxe JavaScript avec Node.js"""
    try:
        temp_file = Path("temp_validation.js")
        temp_file.write_text(code, encoding='utf-8')
        
        result = subprocess.run(
            ["node", "-c", str(temp_file)],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        temp_file.unlink(missing_ok=True)
        
        if result.returncode == 0:
            return True, None
        return False, result.stderr
    except FileNotFoundError:
        print(" ⚠️  Node.js non trouve - validation desactivee")
        return True, None
    except Exception as e:
        return False, str(e)

def save_with_backup(filepath: str, content: str):
    path = Path(filepath)
    if path.exists():
        backup_path = path.with_suffix(path.suffix + '.backup')
        shutil.copy2(path, backup_path)
        print(f" 💾 Backup cree : {backup_path.name}")
    path.write_text(content, encoding='utf-8')
    print(f" ✅ Fichier sauvegarde : {filepath}")

def calculate_hash(content: str) -> str:
    return hashlib.sha256(content.encode('utf-8')).hexdigest()

# ============================================
# MAIN
# ============================================
def main():
    # Gestion de la source (fichier ou URL)
    if len(sys.argv) > 1:
        source = sys.argv[1]  # Peut être un chemin ou une URL
        print(f"📥 Source specifiee : {source}")
    else:
        # URL par default si aucun argument
        source = "https://raw.githubusercontent.com/MatthiasBaillet/Platon-s-Shifter/main/Game.js"
        print(f"📥 Aucune source specifiee, utilisation de l'URL par defaut")

    OUTPUT = "Game_fixed.js"
    HASH_FILE = ".last_verified_hash"
    
    print("=" * 70)
    print("🔧 PLATON'S SHIFTER v2.4 - Correcteur Validé par étape")
    print("=" * 70)
    
    # Chargement du contenu (depuis URL ou fichier)
    print(f"\n📥 Chargement du contenu...")
    content = load_content(source)
    print(f"✅ {len(content):,} caracteres charges")
    
    # Validation syntaxe initiale
    print("\n🔍 Validation syntaxe originale...")
    is_valid, error = validate_syntax(content)
    if not is_valid:
        print(f"⚠️  Avertissement : Le code source a déjà des erreurs !")
        print(f"   {error}")
        print("   Le correcteur tentera de continuer, mais les résultats peuvent être imprévisibles.")
    else:
        print("✅ Syntaxe JS valide")
    
    # Chargement corrections
    corrections = [Correction(c) for c in CORRECTIONS_CONFIG]
    
    # Application avec validation PAR ÉTAPE
    print(f"\n🛠️ Application de {len(corrections)} corrections (avec validation)...")
    print("-" * 70)
    
    applied: List[str] = []
    skipped: List[str] = []
    errors: List[str] = []
    
    for i, corr in enumerate(corrections, 1):
        print(f"   [{i}/{len(corrections)}] {corr.nom}...", end=" ")
        
        # Vérification si déjà appliquée
        if corr.marqueur in content:
            print("⏭️ déjà marquée")
            skipped.append(corr.nom)
            continue
        
        # Test si applicable
        if not corr.test(content):
            print("⏭️ déjà corrigé")
            skipped.append(corr.nom)
            continue
        
        # Application avec rollback
        new_content, was_modified, error_msg = apply_with_rollback(content, corr)
        
        if was_modified:
            content = new_content
            applied.append(corr.nom)
            print("✅ APPLIQUÉ")
        elif error_msg:
            errors.append(f"{corr.nom}: {error_msg}")
        else:
            print("❌ Échec inattendu")
    
    # Rapport final
    print("\n" + "=" * 70)
    print("📊 RAPPORT FINAL")
    print("=" * 70)
    
    if applied:
        print(f"✅ {len(applied)} correction(s) appliquée(s) avec succès:")
        for nom in applied:
            print(f"   • {nom}")
    
    if skipped:
        print(f"\n⏭️ {len(skipped)} correction(s) déjà présente(s)")
    
    if errors:
        print(f"\n❌ {len(errors)} erreur(s) de validation:")
        for err in errors:
            print(f"   • {err}")
        print("\n⚠️  Le code a été restauré à son état avant chaque correction ayant échoué.")
    
    if not applied and not errors:
        print("🎉 Aucune correction nécessaire")
    
    # Sauvegarde finale
    print("\n💾 Sauvegarde du résultat...")
    save_with_backup(OUTPUT, content)
    Path(HASH_FILE).write_text(calculate_hash(content), encoding='utf-8')
    
    print("\n" + "=" * 70)
    print("⚡ ACTION : Renommez Game_fixed.js → Game.js")
    print("=" * 70)

if __name__ == "__main__":
    main()