print("Diagnostic Platon Shifter")
print("=========================")
print()

# Vérification basique
import os

if os.path.exists("Game.js"):
    print("? Game.js existe")
else:
    print("? Game.js manquant")

if os.path.exists("index.html"):
    print("? index.html existe")
else:
    print("? index.html manquant")

print()
input("Appuyez sur Entrée...")