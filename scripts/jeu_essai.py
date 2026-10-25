#!/usr/bin/env python3
"""Jeu d'essai de l'agent n8n (lot 2b, docs/06 et n8n/jeu-essai/README.md).

Envoie chaque dossier de n8n/jeu-essai/ au flux réel, attend le job, compare la
fiche à attendu.json et écrit un rapport Markdown : taux de bonnes réponses par
champ, notes sans source vérifiable, prix d'un autre millésime, durée, appels au
modèle et crédits de recherche.

Usage (depuis un poste qui joint l'instance n8n) :
    export IACAVE_URL=https://apexus.app.n8n.cloud
    export IACAVE_CLE=...            # la clé cle_app, jamais dans git
    python3 scripts/jeu_essai.py [--prix] [--dossier n8n/jeu-essai] [--seulement 01-...]
    python3 scripts/jeu_essai.py --auto-test   # vérifie signature et comparaisons, sans réseau

Dépendances : bibliothèque standard ; Pillow facultatif pour réduire les photos
de plus de 2 Mo (sinon la photo est refusée avec un message).
"""
import argparse
import base64
import datetime
import hashlib
import hmac
import io
import json
import os
import pathlib
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.request
import uuid

RACINE = pathlib.Path(__file__).resolve().parent.parent
CIBLES = {"domaine": 0.95, "millesime": 0.95, "appellation": 0.85}
CHAMPS = ["domaine", "cuvee", "appellation", "signe_qualite", "classement", "millesime", "couleur", "degre", "cepages"]
TAILLE_MAX = 2_000_000  # octets avant base64 (contrat : 2 800 000 caractères base64)
TYPES_PHOTO = {"etiquette": "etiquette", "contre-etiquette": "contre_etiquette", "capsule": "capsule", "collerette": "collerette"}


def normaliser(texte):
    """Même règle que n8n/code/lib/normalisation.js."""
    t = "" if texte is None else str(texte)
    for a, b in (("œ", "oe"), ("Œ", "oe"), ("æ", "ae"), ("Æ", "ae"), ("ß", "ss")):
        t = t.replace(a, b)
    t = "".join(c for c in unicodedata.normalize("NFD", t) if not ("̀" <= c <= "ͯ"))
    return re.sub(r"^-+|-+$", "", re.sub(r"[^a-z0-9]+", "-", t.lower()))


def signature(cle, horodatage, methode, chemin, corps):
    empreinte = hashlib.sha256(corps).hexdigest()
    texte = f"{horodatage}\n{methode.upper()}\n{chemin}\n{empreinte}"
    return hmac.new(cle.encode("utf-8"), texte.encode("utf-8"), hashlib.sha256).hexdigest()


def appeler(url, cle, installation, methode, chemin, corps=b""):
    ts = str(int(time.time()))
    entetes = {
        "Content-Type": "application/json",
        "X-IACAV-Installation": installation,
        "X-IACAV-Horodatage": ts,
        "X-IACAV-Signature": signature(cle, ts, methode, chemin, corps),
    }
    req = urllib.request.Request(url.rstrip("/") + chemin, data=corps if methode == "POST" else None, headers=entetes, method=methode)
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status, json.loads(r.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read().decode("utf-8") or "{}")


def photo_base64(chemin):
    octets = chemin.read_bytes()
    if len(octets) > TAILLE_MAX:
        try:
            from PIL import Image
        except ImportError:
            raise SystemExit(f"{chemin} dépasse 2 Mo : réduisez-la ou installez Pillow (pip install pillow).")
        img = Image.open(io.BytesIO(octets)).convert("RGB")
        img.thumbnail((1600, 1600))
        sortie = io.BytesIO()
        img.save(sortie, "JPEG", quality=85)
        octets = sortie.getvalue()
    return base64.b64encode(octets).decode("ascii")


def requete(dossier, avec_prix):
    photos = []
    for i, f in enumerate(sorted(p for p in dossier.iterdir() if p.suffix.lower() in (".jpg", ".jpeg"))[:4]):
        photos.append({"index": i, "type_photo": TYPES_PHOTO.get(f.stem, "autre"), "mime": "image/jpeg", "base64": photo_base64(f)})
    if not photos:
        raise SystemExit(f"{dossier} : aucune photo .jpg")
    return {
        "version_contrat": "1.0",
        "request_id": str(uuid.uuid4()),
        "photos": photos,
        "champs_verrouilles": [],
        "inclure_prix": avec_prix,
        "langue": "fr",
        "date_client": datetime.date.today().isoformat(),
    }


def egal(champ, attendu, obtenu):
    if attendu is None:
        return obtenu is None
    if champ == "millesime":
        return str(attendu) == str(obtenu)
    if champ == "degre":
        return obtenu is not None and abs(float(attendu) - float(obtenu)) < 0.05
    if champ == "cepages":
        noms = lambda v: sorted(normaliser(c["cepage"] if isinstance(c, dict) else c) for c in (v or []))
        return noms(attendu) == noms(obtenu)
    return normaliser(attendu) == normaliser(obtenu)


def analyser(attendu, reponse):
    """Comparaison d'une réponse de job à attendu.json."""
    res = reponse.get("resultat") or {}
    fiche = res.get("fiche") or {}
    champs = {}
    for c in CHAMPS:
        if c in attendu:
            champs[c] = egal(c, attendu[c], (fiche.get(c) or {}).get("valeur"))
    consultees = {s.get("url") for s in res.get("sources_consultees", [])}
    notes_sans_source = sum(1 for n in res.get("notes_critiques", []) if not n.get("url") or n.get("url") not in consultees)
    prix_autre_millesime = sum(
        1 for p in res.get("prix", []) for o in p.get("offres", []) if o.get("millesime_verifie") is not True
    )
    cout = res.get("cout") or {}
    return {
        "statut": reponse.get("statut"),
        "champs": champs,
        "notes_sans_source": notes_sans_source,
        "prix_autre_millesime": prix_autre_millesime,
        "duree_ms": cout.get("duree_ms"),
        "appels_modele": cout.get("appels_modele", 0),
        "credits_recherche": cout.get("credits_recherche", 0),
        "erreur": (reponse.get("erreur") or {}).get("message"),
    }


def rapport(lignes):
    total = len(lignes)
    out = [f"# Jeu d'essai du {datetime.date.today().isoformat()}", "", f"{total} bouteilles envoyées au flux.", ""]
    out += ["| Champ | Justes | Taux | Cible |", "| --- | --- | --- | --- |"]
    for c in CHAMPS:
        vals = [l["champs"][c] for _, l in lignes if c in l["champs"]]
        if vals:
            taux = sum(vals) / len(vals)
            cible = f"{CIBLES[c]:.0%}" if c in CIBLES else ""
            ok = "" if c not in CIBLES else (" atteinte" if taux >= CIBLES[c] else " manquée")
            out.append(f"| {c} | {sum(vals)}/{len(vals)} | {taux:.0%} | {cible}{ok} |")
    nss = sum(l["notes_sans_source"] for _, l in lignes)
    pam = sum(l["prix_autre_millesime"] for _, l in lignes)
    durees = [l["duree_ms"] for _, l in lignes if l["duree_ms"]]
    appels = [l["appels_modele"] for _, l in lignes]
    credits = [l["credits_recherche"] for _, l in lignes]
    moy = lambda v: (sum(v) / len(v)) if v else 0
    out += [
        "",
        f"Notes critiques sans source vérifiable : {nss} (cible 0).",
        f"Prix d'un autre millésime : {pam} (cible 0).",
        f"Durée moyenne côté flux : {moy(durees) / 1000:.1f} s.",
        f"Coût moyen d'un enrichissement : {moy(appels):.1f} appels au modèle, {moy(credits):.1f} crédits de recherche.",
        "",
        "| Bouteille | Statut | Champs faux | Durée | Appels | Crédits |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for nom, l in lignes:
        faux = ", ".join(c for c, v in l["champs"].items() if not v) or "aucun"
        if l["erreur"]:
            faux = "erreur : " + l["erreur"]
        out.append(f"| {nom} | {l['statut']} | {faux} | {(l['duree_ms'] or 0) / 1000:.1f} s | {l['appels_modele']} | {l['credits_recherche']} |")
    return "\n".join(out) + "\n"


def auto_test():
    v = json.loads((RACINE / "specs/contrat-n8n/vecteur-signature.json").read_text())
    assert signature(v["cle"], v["horodatage"], v["methode"], v["chemin"], v["corps"].encode("utf-8")) == v["signature"]
    assert normaliser("Guillaume L'Echanson") == "guillaume-l-echanson"
    assert normaliser("Côte-Rôtie") == "cote-rotie"
    exemple = json.loads((RACINE / "specs/contrat-n8n/exemples/enrichissement-termine.json").read_text())
    f = exemple["resultat"]["fiche"]
    attendu = {"domaine": f["domaine"]["valeur"].upper(), "millesime": f["millesime"]["valeur"], "appellation": "autre"}
    a = analyser(attendu, exemple)
    assert a["champs"] == {"domaine": True, "millesime": True, "appellation": False}, a
    print("OK auto-test : signature au vecteur du contrat, normalisation, comparaison")


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--dossier", default=str(RACINE / "n8n/jeu-essai"))
    p.add_argument("--prix", action="store_true", help="demander aussi le prix (inclure_prix)")
    p.add_argument("--seulement", help="un seul dossier")
    p.add_argument("--auto-test", action="store_true")
    a = p.parse_args()
    if a.auto_test:
        return auto_test()
    url, cle = os.environ.get("IACAVE_URL"), os.environ.get("IACAVE_CLE")
    if not url or not cle:
        raise SystemExit("IACAVE_URL et IACAVE_CLE sont requis (la clé reste hors git).")
    installation = str(uuid.uuid4())
    dossiers = sorted(d for d in pathlib.Path(a.dossier).iterdir() if d.is_dir() and (d / "attendu.json").exists())
    if a.seulement:
        dossiers = [d for d in dossiers if d.name == a.seulement]
    lignes = []
    for d in dossiers:
        attendu = json.loads((d / "attendu.json").read_text())
        corps = json.dumps(requete(d, a.prix), ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        code, rep = appeler(url, cle, installation, "POST", "/webhook/iacave/enrichissement", corps)
        debut = time.time()
        while code in (200, 202) and rep.get("statut") in ("en_attente", "en_cours") and time.time() - debut < 180:
            time.sleep(3 if time.time() - debut < 30 else 10)
            code, rep = appeler(url, cle, installation, "GET", "/webhook/iacave/jobs?job_id=" + rep["job_id"])
        l = analyser(attendu, rep)
        lignes.append((d.name, l))
        print(d.name, l["statut"], {c: v for c, v in l["champs"].items() if not v} or "tout juste")
    sortie = pathlib.Path(a.dossier) / f"rapport-{datetime.date.today().isoformat()}.md"
    sortie.write_text(rapport(lignes))
    print("Rapport :", sortie)


if __name__ == "__main__":
    main()
