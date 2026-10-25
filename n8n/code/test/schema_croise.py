#!/usr/bin/env python3
"""Compare le validateur JS des nœuds Code (n8n/code/lib/schema.js) à jsonschema
sur les exemples du contrat et sur des milliers de mutations aléatoires.
Usage : python3 n8n/code/test/schema_croise.py  (code retour 1 au premier désaccord)."""
import copy, json, pathlib, random, subprocess, sys
from jsonschema import Draft202012Validator, FormatChecker

racine = pathlib.Path(__file__).resolve().parents[3]
contrat = racine / "specs" / "contrat-n8n"
schemas = {n: json.loads((contrat / n).read_text()) for n in
           ["requete-enrichissement.schema.json", "requete-prix.schema.json", "reponse-job.schema.json"]}
exemples = {
    "requete-enrichissement.json": "requete-enrichissement.schema.json",
    "requete-prix.json": "requete-prix.schema.json",
    "job-en-cours.json": "reponse-job.schema.json",
    "enrichissement-termine.json": "reponse-job.schema.json",
    "enrichissement-partiel.json": "reponse-job.schema.json",
    "prix-termine.json": "reponse-job.schema.json",
    "erreur-quota.json": "reponse-job.schema.json",
}
# jsonschema ne contrôle « uri » qu'avec rfc3987 : même règle que le JS,
# plus stricte, pour comparer à égalité.
import re
verif = FormatChecker()
verif.checks("uri")(lambda s: not isinstance(s, str) or re.match(r"^[a-z][a-z0-9+.-]*:[^\s]*$", s, re.I) is not None)
rnd = random.Random(20261021)
VALEURS = [None, 0, -1, 1850, 2024, 12.5, 101, "", "x", "NM", "violet", "rouge", "etiquette", "estimation",
           "2026-13-45", "2026-10-21", "pas-une-url", "https://exemple.fr", True, False, [], {}, ["a", "a"],
           "00000000-0000-4000-8000-000000000000", {"debut": 2030, "fin": 2020}]

def chemins(o, p=()):
    yield p
    if isinstance(o, dict):
        for k, v in o.items():
            yield from chemins(v, p + (k,))
    elif isinstance(o, list):
        for i, v in enumerate(o):
            yield from chemins(v, p + (i,))

def muter(doc):
    d = copy.deepcopy(doc)
    p = rnd.choice([c for c in chemins(d) if c])
    parent = d
    for k in p[:-1]:
        parent = parent[k]
    op = rnd.random()
    if op < 0.35:
        parent[p[-1]] = copy.deepcopy(rnd.choice(VALEURS))
    elif op < 0.6 and isinstance(parent, dict):
        parent.pop(p[-1])
    elif op < 0.8 and isinstance(parent, dict):
        parent["champ_inconnu_" + str(rnd.randint(0, 9))] = 1
    elif isinstance(parent[p[-1]], list) and parent[p[-1]]:
        parent[p[-1]].append(copy.deepcopy(parent[p[-1]][0]))
    else:
        parent[p[-1]] = copy.deepcopy(rnd.choice(VALEURS))
    return d

cas = []
for f, s in exemples.items():
    doc = json.loads((contrat / "exemples" / f).read_text())
    cas.append((s, doc))
    for _ in range(600):
        m = muter(doc)
        if rnd.random() < 0.3:
            m = muter(m)
        cas.append((s, m))

entree = "\n".join(json.dumps({"schema": s, "doc": d}) for s, d in cas)
js = """
const { validateSchema } = require(%s);
const schemas = %s;
const lignes = require('fs').readFileSync(0, 'utf8').split('\\n').filter(Boolean);
for (const l of lignes) {
  const c = JSON.parse(l);
  process.stdout.write(JSON.stringify(validateSchema(schemas[c.schema], c.doc)) + '\\n');
}
""" % (json.dumps(str(racine / "n8n/code/lib/schema.js")), json.dumps(schemas))
sortie = subprocess.run(["node", "-e", js], input=entree, capture_output=True, text=True, check=True).stdout.splitlines()

desaccords = 0
for (s, d), ligne in zip(cas, sortie):
    attendu = not any(True for _ in Draft202012Validator(schemas[s], format_checker=verif).iter_errors(d))
    obtenu = json.loads(ligne) == []
    if attendu != obtenu:
        desaccords += 1
        if desaccords <= 5:
            print("DÉSACCORD", s, "jsonschema:", attendu, "js:", obtenu, json.loads(ligne)[:3])
            print(json.dumps(d, ensure_ascii=False)[:600])
valides = sum(1 for (s, d) in cas if not any(True for _ in Draft202012Validator(schemas[s], format_checker=verif).iter_errors(d)))
print(f"{len(cas)} documents comparés ({valides} valides), {desaccords} désaccord(s)")
sys.exit(1 if desaccords else 0)
