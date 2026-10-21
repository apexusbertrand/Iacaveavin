#!/usr/bin/env python3
"""Matrice de traçabilité exigences -> tests (NFR-14).

Lit les identifiants d'exigences dans docs/05-fonctionnel.md (LST-01...),
docs/07-exigences-non-fonctionnelles.md (NFR-01...) et les règles de
docs/04-modele-donnees.md (STK-R1...), puis cherche dans app/test et
app/integration_test les noms de tests qui les citent.

Usage :
  python3 scripts/matrice_exigences.py                 # matrice complète
  python3 scripts/matrice_exigences.py --lot 0         # échoue si une exigence du lot 0 n'a pas de test
  python3 scripts/matrice_exigences.py --sortie docs/matrice-exigences.md

Les exigences d'un lot sont lues dans docs/journal-lots.md (ligne « Exigences : »),
plages comprises (« LST-01 à LST-10 »).
"""
import argparse
import pathlib
import re
import sys

RACINE = pathlib.Path(__file__).resolve().parent.parent
ID = r"[A-Z]{2,4}-(?:R)?\d{1,2}"
DOSSIERS_TESTS = [RACINE / "app" / "test", RACINE / "app" / "integration_test"]
APPEL_TEST = re.compile(r"\b(?:test|testWidgets|group)\(\s*(['\"])(.*?)\1", re.S)


def exigences():
    """Renvoie {id: (libellé court, source)} dans l'ordre des documents."""
    trouvees = {}
    f05 = (RACINE / "docs" / "05-fonctionnel.md").read_text(encoding="utf-8")
    for m in re.finditer(rf"^- ({ID})\. (.+)$", f05, re.M):
        trouvees.setdefault(m.group(1), (m.group(2)[:70], "05"))
    f07 = (RACINE / "docs" / "07-exigences-non-fonctionnelles.md").read_text(encoding="utf-8")
    for m in re.finditer(rf"^\| ({ID}) \| ([^|]+) \| ([^|]+) \|", f07, re.M):
        trouvees.setdefault(m.group(1), (f"{m.group(2).strip()} : {m.group(3).strip()[:55]}", "07"))
    f04 = (RACINE / "docs" / "04-modele-donnees.md").read_text(encoding="utf-8")
    for m in re.finditer(rf"^- ({ID})\. (.+)$", f04, re.M):
        trouvees.setdefault(m.group(1), (m.group(2)[:70], "04"))
    return trouvees


def tests_par_exigence():
    couverture = {}
    for dossier in DOSSIERS_TESTS:
        if not dossier.exists():
            continue
        for fichier in sorted(dossier.rglob("*_test.dart")):
            texte = fichier.read_text(encoding="utf-8")
            for m in APPEL_TEST.finditer(texte):
                for ident in re.findall(ID, m.group(2)):
                    couverture.setdefault(ident, []).append(
                        f"{fichier.relative_to(RACINE / 'app')} : {m.group(2)[:60]}"
                    )
    return couverture


def developper(texte):
    """« LST-01 à LST-10, FIC-01 » -> [LST-01, ..., LST-10, FIC-01]."""
    ids = []
    for morceau in re.split(r",\s*", texte):
        plage = re.match(rf"({ID}) à ({ID})", morceau.strip())
        if plage:
            a, b = plage.groups()
            prefixe = a.rsplit("-", 1)[0]
            debut, fin = int(re.sub(r"\D", "", a.rsplit("-", 1)[1])), int(re.sub(r"\D", "", b.rsplit("-", 1)[1]))
            regle = "R" in a.rsplit("-", 1)[1]
            largeur = len(re.sub(r"\D", "", a.rsplit("-", 1)[1]))
            for n in range(debut, fin + 1):
                ids.append(f"{prefixe}-{'R' if regle else ''}{n:0{largeur}d}")
        else:
            ids.extend(re.findall(ID, morceau))
    return ids


def exigences_du_lot(lot):
    journal = (RACINE / "docs" / "journal-lots.md").read_text(encoding="utf-8")
    bloc = re.search(rf"^## Lot {re.escape(lot)}\b.*?(?=^## |\Z)", journal, re.M | re.S)
    if not bloc:
        sys.exit(f"Lot {lot} absent de docs/journal-lots.md")
    ligne = re.search(r"^- Exigences : (.+)$", bloc.group(0), re.M)
    return developper(ligne.group(1)) if ligne else []


def main():
    p = argparse.ArgumentParser(description="Matrice exigences -> tests")
    p.add_argument("--lot", help="vérifie que toutes les exigences du lot ont un test")
    p.add_argument("--sortie", help="écrit la matrice Markdown dans ce fichier")
    args = p.parse_args()

    connues = exigences()
    couverture = tests_par_exigence()

    inconnues = sorted(set(couverture) - set(connues))
    lignes = ["# Matrice exigences -> tests", "",
              "Générée par `python3 scripts/matrice_exigences.py`. Ne pas modifier à la main.", "",
              "| Exigence | Source | Libellé | Tests |", "| --- | --- | --- | --- |"]
    for ident, (libelle, source) in connues.items():
        nb = len(couverture.get(ident, []))
        lignes.append(f"| {ident} | docs/{source} | {libelle.replace('|', '/')} | {nb or '-'} |")
    couvertes = sum(1 for i in connues if i in couverture)
    lignes += ["", f"{couvertes} exigences couvertes sur {len(connues)}."]
    texte = "\n".join(lignes) + "\n"
    if args.sortie:
        (RACINE / args.sortie).write_text(texte, encoding="utf-8")
        print(f"{args.sortie} écrit")
    else:
        print(texte)

    erreurs = []
    if inconnues:
        erreurs.append(f"identifiants cités dans les tests mais absents des docs : {', '.join(inconnues)}")
    if args.lot:
        attendues = exigences_du_lot(args.lot)
        manquantes = [i for i in attendues if i not in couverture]
        print(f"Lot {args.lot} : {len(attendues) - len(manquantes)}/{len(attendues)} exigences couvertes par un test")
        if manquantes:
            erreurs.append(f"lot {args.lot}, exigences sans test : {', '.join(manquantes)}")
    if erreurs:
        print("\n".join("ERREUR " + e for e in erreurs))
        sys.exit(1)
    print("TOUT EST CONFORME")


if __name__ == "__main__":
    main()
