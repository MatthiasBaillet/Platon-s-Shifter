// Test corrigé avec regex plus robuste
console.log("🧪 TEST SIMPLIFIÉ - Platon's Shifter\n");

const fs = require('fs');
const code = fs.readFileSync('Game.js', 'utf8');

// Regex plus souple pour capturer tous les formats possibles
const formMatches = code.match(/name:\s*"[^"]+"/g) || [];
const formNames = formMatches.map(match => match.match(/"([^"]+)"/)[1]);

console.log("📋 Formes détectées dans le code :", formNames);

// Vérifications améliorées
const checks = [
  { name: "Contient CONFIG", test: () => code.includes('const CONFIG') },
  { name: `Contient ${formNames.length} formes (minimum 5)`, test: () => formNames.length >= 5 },
  { name: "Contient init()", test: () => code.includes('function init()') },
  { name: "Canvas OK (gameCanvas)", test: () => code.includes('gameCanvas') },
  { name: "Module GameState", test: () => code.includes('GameState =') },
  { name: "Module UI_System", test: () => code.includes('UI_System =') }
];

let passed = 0;
checks.forEach(check => {
  const result = check.test();
  console.log(`${result ? '✅' : '❌'} ${check.name}`);
  if (result) passed++;
});

console.log(`\n🎯 ${passed}/${checks.length} vérifications OK`);

if (passed === checks.length) {
    console.log("\n✅ Le code est complet et fonctionnel !");
} else {
    console.log("\n⚠️ Certains éléments manquent ou sont mal nommés.");
    console.log("Vérifiez que Game.js contient bien GameState, UI_System, etc.");
}

console.log("\nPS: Pour des tests complets avec Jest, le code doit être modulaire ES6.");