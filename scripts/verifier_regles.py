#!/usr/bin/env python3
"""Vérifie les règles métier documentées, indépendamment du code Flutter.

- specs/regles-garde.yaml : chaque règle a debut <= apogee <= fin, ids uniques, dernière règle sans condition.
- Algorithme de statut de garde de docs/04-modele-donnees.md : tous les cas de test documentés.
- specs/dictionnaire-donnees.yaml : clés uniques par entité, colonnes Excel uniques par onglet,
  listes et énumérations référencées existantes.

Usage : python3 scripts/verifier_regles.py   (dépendance : pip install pyyaml)
Le code Dart reprend les mêmes cas de test : ce script est la référence en cas de désaccord.
"""
import pathlib
import sys

import yaml

RACINE = pathlib.Path(__file__).resolve().parent.parent
erreurs = []


def statut_garde(annee, debut, apogee, fin):
    if debut is None or fin is None:
        return "inconnu"
    if annee > fin:
        return "passe"
    if annee < debut:
        return "trop_jeune"
    if annee >= fin - 1:
        return "a_boire_vite"
    if apogee is not None and abs(annee - apogee) <= 1:
        return "apogee"
    return "a_boire"


CAS_GARDE = [
    # (annee, debut, apogee, fin, attendu)
    (2025, 2026, 2029, 2032, "trop_jeune"),
    (2026, 2026, 2029, 2032, "a_boire"),
    (2027, 2026, 2029, 2032, "a_boire"),
    (2028, 2026, 2029, 2032, "apogee"),
    (2030, 2026, 2029, 2032, "apogee"),
    (2031, 2026, 2029, 2032, "a_boire_vite"),
    (2032, 2026, 2029, 2032, "a_boire_vite"),
    (2033, 2026, 2029, 2032, "passe"),
    (2029, 2026, None, 2032, "a_boire"),
    (2025, 2026, 2026, 2026, "trop_jeune"),
    (2026, 2026, 2026, 2026, "a_boire_vite"),
    (2027, 2026, 2026, 2026, "passe"),
    (2026, None, None, 2032, "inconnu"),
]

for annee, debut, apogee, fin, attendu in CAS_GARDE:
    obtenu = statut_garde(annee, debut, apogee, fin)
    if obtenu != attendu:
        erreurs.append(f"garde {annee} ({debut}, {apogee}, {fin}) : attendu {attendu}, obtenu {obtenu}")

regles = yaml.safe_load((RACINE / "specs" / "regles-garde.yaml").read_text(encoding="utf-8"))
ids = [r["id"] for r in regles["regles"]]
if len(ids) != len(set(ids)):
    erreurs.append("regles-garde : identifiants en double")
for r in regles["regles"]:
    d = r["decalage"]
    if not (0 <= d["debut"] <= d["apogee"] <= d["fin"]):
        erreurs.append(f"regles-garde {r['id']} : il faut 0 <= debut <= apogee <= fin")
if regles["regles"][-1]["si"]:
    erreurs.append("regles-garde : la dernière règle doit être sans condition (règle par défaut)")

dico = yaml.safe_load((RACINE / "specs" / "dictionnaire-donnees.yaml").read_text(encoding="utf-8"))
listes, enums = set(dico["listes"]), set(dico["enums"])
colonnes = {}
for nom_entite, entite in dico["entites"].items():
    cles = [c["cle"] for c in entite["champs"]]
    if len(cles) != len(set(cles)):
        erreurs.append(f"dictionnaire {nom_entite} : clé en double")
    for c in entite["champs"]:
        if c.get("type") in ("liste", "liste_multiple") and c.get("liste") not in listes:
            erreurs.append(f"dictionnaire {nom_entite}.{c['cle']} : liste inconnue {c.get('liste')}")
        if c.get("type") == "enum" and c.get("enum") not in enums:
            erreurs.append(f"dictionnaire {nom_entite}.{c['cle']} : enum inconnue {c.get('enum')}")
        if "excel" in c:
            cible = c["excel"].removeprefix("RO:")
            onglet, _, colonne = cible.partition("/")
            if not colonne:
                erreurs.append(f"dictionnaire {nom_entite}.{c['cle']} : excel doit valoir Onglet/Colonne")
            cle_col = (onglet, colonne)
            if cle_col in colonnes:
                erreurs.append(f"dictionnaire : colonne Excel {cible} utilisée deux fois ({colonnes[cle_col]} et {nom_entite}.{c['cle']})")
            colonnes[cle_col] = f"{nom_entite}.{c['cle']}"

for e in erreurs:
    print("KO", e)
print(f"{len(CAS_GARDE)} cas de garde, {len(ids)} règles, {len(colonnes)} colonnes Excel vérifiés")
print("TOUT EST CONFORME" if not erreurs else f"{len(erreurs)} ÉCHEC(S)")
sys.exit(1 if erreurs else 0)
