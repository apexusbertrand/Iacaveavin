#!/usr/bin/env python3
"""Génère les référentiels embarqués dans app/assets/referentiels/.

1. Toujours : listes-dictionnaire.json, à partir des listes à valeurs fixes de
   specs/dictionnaire-donnees.yaml (couleur, type, signe de qualité, classement,
   certification, format, motif de mouvement, critique). Le test Dart
   test/data/referentiels_test.dart vérifie que ce fichier reste aligné.

2. Sur demande : appellations.json à partir du jeu de données ouvert de l'INAO
   (« Aires et produits AOC/AOP et IGP », data.gouv.fr), téléchargé à la main :

     python3 scripts/generer_referentiels.py --inao chemin/vers/fichier.csv \
         [--col-appellation "Appellation"] [--col-signe "Signe"] \
         [--col-categorie "Catégorie"] [--filtre-categorie "Vin"]

   Les noms de colonnes du CSV INAO changent selon les versions : vérifier l'en-tête
   et passer les bons noms. Les appellations reprises de l'INAO sont rattachées
   au parent de la liste provisoire quand le libellé existe déjà, sinon elles restent
   sans parent (à compléter dans le Paramétrage). Citer la date du jeu dans la
   source écrite dans le fichier.

Usage : python3 scripts/generer_referentiels.py   (dépendance : pip install pyyaml)
"""
import argparse
import csv
import json
import pathlib
import re
import sys
import unicodedata

import yaml

RACINE = pathlib.Path(__file__).resolve().parent.parent
SORTIE = RACINE / "app" / "assets" / "referentiels"

# Libellés affichés des codes du dictionnaire qui ne sont pas déjà lisibles.
LIBELLES = {
    "couleur": {"rose": "Rosé"},
    "type_vin": {"mute": "Muté"},
    "certification": {"HVE": "HVE"},
}

LISTES_FIXES = [
    "couleur", "type_vin", "signe_qualite", "classement",
    "certification", "motif_mouvement", "critique",
]


def libelle(liste, code):
    if code in LIBELLES.get(liste, {}):
        return LIBELLES[liste][code]
    if code.isupper() or liste == "critique":
        return code
    return code[:1].upper() + code[1:]


def format_cl(valeur):
    texte = f"{valeur:g}".replace(".", ",")
    return f"{texte} cl"


def listes_dictionnaire():
    dico = yaml.safe_load((RACINE / "specs" / "dictionnaire-donnees.yaml").read_text(encoding="utf-8"))
    listes = []
    for nom in LISTES_FIXES:
        valeurs = dico["listes"][nom]["valeurs"]
        listes.append({
            "liste": nom,
            "valeurs": [{"code": v, "libelle": libelle(nom, v)} for v in valeurs],
        })
    fmt = dico["listes"]["format"]
    listes.append({
        "liste": "format",
        "defaut": f"{fmt['defaut_cl']:g}",
        "valeurs": [{"code": f"{v:g}", "libelle": format_cl(v)} for v in fmt["valeurs_cl"]],
    })
    return {
        "source": "specs/dictionnaire-donnees.yaml (généré par scripts/generer_referentiels.py)",
        "listes": listes,
    }


def slug(texte):
    t = unicodedata.normalize("NFKD", texte).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "-", t.lower()).strip("-")


def appellations_inao(chemin, args):
    actuel = json.loads((SORTIE / "appellations.json").read_text(encoding="utf-8"))
    parents = {v["libelle"]: v.get("parent_code") for v in actuel["valeurs"]}
    vues = {}
    with open(chemin, encoding="utf-8-sig", newline="") as f:
        echantillon = f.read(4096)
        f.seek(0)
        dialecte = csv.Sniffer().sniff(echantillon, delimiters=";,\t")
        lecteur = csv.DictReader(f, dialect=dialecte)
        manquantes = [c for c in (args.col_appellation, args.col_signe) if c not in (lecteur.fieldnames or [])]
        if manquantes:
            sys.exit(f"Colonnes absentes du CSV : {manquantes}. En-tête lu : {lecteur.fieldnames}")
        for ligne in lecteur:
            if args.col_categorie and args.filtre_categorie:
                if args.filtre_categorie.lower() not in (ligne.get(args.col_categorie) or "").lower():
                    continue
            nom = (ligne[args.col_appellation] or "").strip()
            signe = (ligne[args.col_signe] or "").strip()
            if not nom or signe.upper() not in ("AOC", "AOP"):
                continue
            vues.setdefault(nom, {"code": "fr-" + slug(nom), "libelle": nom, "parent_code": parents.get(nom)})
    valeurs = sorted(vues.values(), key=lambda v: slug(v["libelle"]))
    return {
        "liste": "appellation",
        "source": f"INAO, données ouvertes data.gouv.fr, fichier {pathlib.Path(chemin).name}",
        "provisoire": False,
        "valeurs": valeurs,
    }


def ecrire(nom, contenu):
    chemin = SORTIE / nom
    chemin.write_text(json.dumps(contenu, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"{chemin.relative_to(RACINE)} écrit")


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--inao", help="CSV des aires et produits AOC/AOP de l'INAO")
    p.add_argument("--col-appellation", default="Appellation")
    p.add_argument("--col-signe", default="Signe")
    p.add_argument("--col-categorie", default="")
    p.add_argument("--filtre-categorie", default="")
    args = p.parse_args()
    ecrire("listes-dictionnaire.json", listes_dictionnaire())
    if args.inao:
        ecrire("appellations.json", appellations_inao(args.inao, args))


if __name__ == "__main__":
    main()
