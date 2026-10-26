#!/usr/bin/env node
// Icône « Château Apexus » : château aux couleurs de la marque, engrenage
// Apexus en rosace, carré orange en drapeau, rangs de vigne au pied.
// Les couleurs viennent de specs/design-tokens.json (rubrique marque).
//
// Usage, depuis la racine : node scripts/generer_icones.js
// Écrit docs/reference/icone/*.svg et les PNG Android (icône classique,
// icône adaptative et monochrome Android 13) et iOS. Rendu par Chromium
// (Playwright), installé sur le poste de développement, pas dans l'app.
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const racine = path.resolve(__dirname, '..');
const marque = JSON.parse(fs.readFileSync(path.join(racine, 'specs/design-tokens.json'), 'utf8')).marque;
const res = path.join(racine, 'app/android/app/src/main/res');
const ios = path.join(racine, 'app/ios/Runner/Assets.xcassets/AppIcon.appiconset');
const sources = path.join(racine, 'docs/reference/icone');

// Engrenage à 8 dents centré sur (cx, cy).
function engrenage(cx, cy, rExt, rInt, dents = 8) {
  const pts = [];
  const pas = (2 * Math.PI) / dents;
  for (let i = 0; i < dents; i++) {
    const a = i * pas - Math.PI / 2;
    for (const [da, r] of [[-0.24, rInt], [-0.14, rExt], [0.14, rExt], [0.24, rInt]]) {
      pts.push([cx + r * Math.cos(a + da * pas * 2), cy + r * Math.sin(a + da * pas * 2)]);
    }
  }
  return 'M' + pts.map(([x, y]) => `${x.toFixed(1)},${y.toFixed(1)}`).join('L') + 'Z';
}

// Créneaux : n merlons de largeur l sur [x0, x1], de y à y + h.
function creneaux(x0, x1, y, h, n) {
  const l = (x1 - x0) / (2 * n - 1);
  let d = '';
  for (let i = 0; i < n; i++) d += `M${x0 + 2 * i * l},${y + h}V${y}h${l}V${y + h}Z`;
  return d;
}

// Silhouette pleine du château, coordonnées autour de (0, 0).
const corps = [
  'M-95,-170H95V230H-95Z', // donjon
  creneaux(-95, 95, -210, 40, 5),
  'M-260,-60H-150V230H-260Z', // tour gauche
  'M150,-60H260V230H150Z', // tour droite
  'M-278,-60L-205,-215L-132,-60Z', // toits en poivrière
  'M132,-60L205,-215L278,-60Z',
  'M-150,40H-95V230H-150Z', // courtines
  'M95,40H150V230H95Z',
  creneaux(-150, -95, 12, 28, 2),
  creneaux(95, 150, 12, 28, 2),
].join('');
// Ouvertures : rosace, porte en arc, meurtrières.
const ouvertures = [
  'M0,-60m-78,0a78,78 0 1,0 156,0a78,78 0 1,0 -156,0',
  'M-42,230V128A42,42 0 0,1 42,128V230Z',
  'M-213,10h16v62h-16Z',
  'M197,10h16v62h-16Z',
].join('');
const rosace = engrenage(0, -60, 64, 46);
const moyeu = 'M0,-60m-19,0a19,19 0 1,0 38,0a19,19 0 1,0 -38,0';
const mat = 'M-4,-292H4V-210H-4Z';
const drapeau = 'M4,-292H62V-242H4Z';
// Colline et rangs de vigne.
// La colline passe sous le pied du château (sommet à y = 225).
const colline = 'M-340,340Q0,110 340,340Q0,372 -340,340Z';
const rangs = [1, 2, 3].map((k) => `M${-300 + 30 * k},${342}Q0,${150 + 40 * k} ${300 - 30 * k},${342}`);

function chateau({ monochrome = false } = {}) {
  if (monochrome) {
    return `<defs><mask id="m"><rect x="-512" y="-512" width="1024" height="1024" fill="#000"/>
      <path d="${corps}${mat}${drapeau}" fill="#fff"/><path d="${ouvertures}" fill="#000"/>
      <path d="${rosace}" fill="#fff"/><path d="${moyeu}" fill="#000"/>
      <path d="${colline}" fill="#fff"/>${rangs.map((d) => `<path d="${d}" fill="none" stroke="#000" stroke-width="9"/>`).join('')}
    </mask></defs><rect x="-512" y="-512" width="1024" height="1024" fill="#fff" mask="url(#m)"/>`;
  }
  return `<defs><linearGradient id="pierre" x1="0" y1="-290" x2="0" y2="240" gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="${marque.orange}"/><stop offset="1" stop-color="${marque.rougeOrange}"/>
    </linearGradient></defs>
    <path d="${colline}" fill="${marque.rougeOrange}"/>
    ${rangs.map((d) => `<path d="${d}" fill="none" stroke="${marque.anthracite}" stroke-width="9" stroke-linecap="round"/>`).join('')}
    <path d="${corps}" fill="url(#pierre)"/>
    <path d="${ouvertures}" fill="${marque.anthracite}"/>
    <path d="${rosace}" fill="${marque.rougeOrange}"/><path d="${moyeu}" fill="${marque.anthracite}"/>
    <path d="${mat}" fill="${marque.orange}"/><path d="${drapeau}" fill="${marque.orange}"/>`;
}

const fond = `<defs><radialGradient id="fond" cx="512" cy="430" r="620" gradientUnits="userSpaceOnUse">
    <stop offset="0" stop-color="${marque.anthracite}"/><stop offset="1" stop-color="${marque.noir}"/>
  </radialGradient></defs><rect width="1024" height="1024" fill="url(#fond)"/>`;

const svg = (contenu) => `<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">${contenu}</svg>`;
// Icône complète (iOS, Android avant 8, store) : château à 0,9.
const complete = svg(`${fond}<g transform="translate(512,500) scale(0.9)">${chateau()}</g>`);
// Avant-plan adaptatif : contenu dans le zone visible de 72 dp sur 108.
const avantPlan = svg(`<g transform="translate(512,500) scale(0.66)">${chateau()}</g>`);
const fondAdaptatif = svg(fond);
const monochrome = svg(`<g transform="translate(512,500) scale(0.66)">${chateau({ monochrome: true })}</g>`);

async function rendre(page, contenu, taille, sortie) {
  await page.setViewportSize({ width: taille, height: taille });
  await page.setContent(`<html><body style="margin:0;background:transparent">${contenu.replace('width="1024" height="1024"', `width="${taille}" height="${taille}"`)}</body></html>`);
  fs.mkdirSync(path.dirname(sortie), { recursive: true });
  await page.screenshot({ path: sortie, omitBackground: true, clip: { x: 0, y: 0, width: taille, height: taille } });
}

(async () => {
  fs.mkdirSync(sources, { recursive: true });
  for (const [nom, contenu] of Object.entries({ complete, 'avant-plan': avantPlan, fond: fondAdaptatif, monochrome })) {
    fs.writeFileSync(path.join(sources, `chateau-apexus-${nom}.svg`), contenu + '\n');
  }
  const navigateur = await chromium.launch();
  const page = await navigateur.newPage();
  const densites = { mdpi: 1, hdpi: 1.5, xhdpi: 2, xxhdpi: 3, xxxhdpi: 4 };
  for (const [d, f] of Object.entries(densites)) {
    await rendre(page, complete, 48 * f, path.join(res, `mipmap-${d}/ic_launcher.png`));
    await rendre(page, avantPlan, 108 * f, path.join(res, `mipmap-${d}/ic_launcher_foreground.png`));
    await rendre(page, fondAdaptatif, 108 * f, path.join(res, `mipmap-${d}/ic_launcher_background.png`));
    await rendre(page, monochrome, 108 * f, path.join(res, `mipmap-${d}/ic_launcher_monochrome.png`));
  }
  const contents = JSON.parse(fs.readFileSync(path.join(ios, 'Contents.json'), 'utf8'));
  for (const i of contents.images) {
    const taille = Math.round(parseFloat(i.size) * parseInt(i.scale, 10));
    await rendre(page, complete, taille, path.join(ios, i.filename));
  }
  await rendre(page, complete, 512, path.join(sources, 'apercu-512.png'));
  await navigateur.close();
  console.log('icônes générées');
})();
