# ENCODAGE FORCÉ UTF-8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Write-Host "📚 GÉNÉRATION DOCUMENTATION AVANCÉE" -ForegroundColor Cyan
Write-Host "========================================="

# Créer dossier docs
New-Item -ItemType Directory -Force -Path "docs" | Out-Null

# Extraction COMMENTAIRES uniquement
$code = Get-Content "Game.js" -Raw

# Documentation Markdown professionnelle
$doc = @"
# 📖 Documentation Technique - Platon's Shifter V4.3

## ℹ️ INFORMATIONS GÉNÉRALES
- **Version** : 4.3
- **Date** : $(Get-Date -Format "dd/MM/yyyy")
- **Fichier** : Game.js
- **Taille** : $((Get-Item "Game.js").Length) bytes

## 🔧 CONFIGURATION
```javascript
$(($code | Select-String -Pattern "const CONFIG = \{.*?\}" -AllMatches).Matches.Value)