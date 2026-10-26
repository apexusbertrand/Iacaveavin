#!/usr/bin/env python3
"""Valide les schémas du contrat n8n, les exemples (doivent passer) et des mutations (doivent être rejetées).
Usage : python3 scripts/valider_contrat.py   (dépendance : pip install jsonschema)
Code retour 1 si un cas échoue : utilisé par la CI et par le flux n8n avant toute mise en production."""
import json, sys, pathlib
from jsonschema import Draft202012Validator, FormatChecker
base = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parent.parent / "specs" / "contrat-n8n"
schemas = {n: json.loads((base / n).read_text()) for n in ["requete-enrichissement.schema.json","requete-prix.schema.json","reponse-job.schema.json"]}
for s in schemas.values(): Draft202012Validator.check_schema(s)
cas = {
 "requete-enrichissement.json": ("requete-enrichissement.schema.json", True),
 "requete-prix.json": ("requete-prix.schema.json", True),
 "job-en-cours.json": ("reponse-job.schema.json", True),
 "enrichissement-termine.json": ("reponse-job.schema.json", True),
 "enrichissement-partiel.json": ("reponse-job.schema.json", True),
 "prix-termine.json": ("reponse-job.schema.json", True),
 "erreur-quota.json": ("reponse-job.schema.json", True),
}
ok = True
for f,(s,attendu) in cas.items():
    v = Draft202012Validator(schemas[s], format_checker=FormatChecker())
    errs = sorted(v.iter_errors(json.loads((base/"exemples"/f).read_text())), key=lambda e: e.path)
    valide = not errs
    print(("OK " if valide==attendu else "KO ") + f, "" if valide else [ (list(e.path), e.message[:120]) for e in errs[:5]])
    ok &= (valide==attendu)
# Cas négatifs : chaque mutation doit être REJETÉE
neg = json.loads((base/"exemples"/"enrichissement-termine.json").read_text())
import copy
mut = {}
m = copy.deepcopy(neg); m["resultat"]["fiche"]["cuvee"].pop("motif"); mut["valeur nulle sans motif"] = m
m = copy.deepcopy(neg); m["resultat"]["fiche"]["commentaire_millesime"].pop("url"); mut["source web sans url"] = m
m = copy.deepcopy(neg); m["resultat"]["fiche"]["couleur"]["valeur"] = "violet"; mut["couleur inconnue"] = m
m = copy.deepcopy(neg); m["resultat"]["notes_critiques"] = [{"source_critique":"Robert Parker Wine Advocate","note":91,"echelle":100,"acces":"citee","url":"https://x.fr","confiance":0.7}]; mut["note citée sans citee_par"] = m
m = copy.deepcopy(neg); m["resultat"]["prix"][0].pop("prix"); mut["prix trouvé sans montant"] = m
m = copy.deepcopy(neg); m["statut"]="termine"; m.pop("resultat"); mut["termine sans resultat"] = m
m = copy.deepcopy(neg); m["resultat"]["fiche"]["garde"] = {"valeur":{"debut":2026,"fin":2032},"source":"estimation","confiance":0.5}; mut["garde estimée par l'agent"] = m
m = copy.deepcopy(neg); m["resultat"]["champ_inconnu"] = 1; mut["propriété inconnue dans resultat"] = m
m = copy.deepcopy(neg); m["resultat"]["fiche"]["millesime"]["valeur"] = 1850; mut["millésime hors bornes"] = m
m = copy.deepcopy(neg); m["resultat"]["cadrages"][0]["cadre"]["largeur"] = 1.4; mut["cadre d'étiquette hors de l'image"] = m
m = copy.deepcopy(neg); m["resultat"]["cadrages"][0]["cadre"].pop("hauteur"); mut["cadre d'étiquette incomplet"] = m
v = Draft202012Validator(schemas["reponse-job.schema.json"], format_checker=FormatChecker())
for k,doc in mut.items():
    rejete = any(True for _ in v.iter_errors(doc))
    print(("OK " if rejete else "KO ") + "rejet attendu : " + k)
    ok &= rejete
print("TOUT EST CONFORME" if ok else "ÉCHECS")
sys.exit(0 if ok else 1)
