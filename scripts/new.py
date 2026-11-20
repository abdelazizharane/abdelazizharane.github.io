#!/usr/bin/env python3
"""Crée un article à partir d'un modèle.

    python scripts/new.py tutoriel "Préparer un corpus audio"
    python scripts/new.py note     "Tons et wav2vec"
    python scripts/new.py annonce  "Sortie de Kalam-na v2"
    python scripts/new.py essai    "Qui possède les données ?"

Un article = un fichier :  blog/<slug>.qmd  ou  essais/<slug>.qmd
(un essai a aussi ses sources à côté :  essais/<slug>.bib).
On écrit en français ; les autres langues sont traduites automatiquement sur le site.

Un nouvel article est créé avec `draft: true` : il n'apparaît ni dans les listes,
ni dans la recherche, ni dans le plan du site tant que cette ligne est présente.
Supprimez-la pour publier. Aucune dépendance : Python 3.8+ suffit.
"""
import argparse
import datetime as dt
import re
import shutil
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MODELS = {
    "tutoriel": ROOT / "blog" / "_modeles" / "tutoriel.qmd",
    "note": ROOT / "blog" / "_modeles" / "note.qmd",
    "annonce": ROOT / "blog" / "_modeles" / "annonce.qmd",
    "essai": ROOT / "essais" / "_modeles" / "essai.qmd",
}
LANGS = ("fr", "en", "ar")


def slugify(text: str) -> str:
    text = re.sub(r"[’'‘]", " ", text)  # « l’essai » -> l-essai, pas « lessai »
    s = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode("ascii")
    s = re.sub(r"[^a-zA-Z0-9]+", "-", s).strip("-").lower()
    return s[:60].strip("-") or "article"


def die(msg: str) -> None:
    print("Erreur : " + msg, file=sys.stderr)
    sys.exit(1)


def set_line(text: str, key: str, value: str) -> str:
    """Remplace la valeur d'une clé de premier niveau en gardant son commentaire."""
    pat = re.compile(r"^(" + re.escape(key) + r":\s*)([^#\n]*?)(\s*(#.*)?)$", re.M)
    if not pat.search(text):
        die("le modèle n'a pas de ligne « %s: » (modèle modifié ?)" % key)
    return pat.sub(lambda m: m.group(1) + value + (m.group(3) or ""), text, count=1)


def new_article(args) -> None:
    model = MODELS[args.kind]
    if not model.exists():
        die("modèle introuvable : %s" % model)
    section = "essais" if args.kind == "essai" else "blog"
    slug = args.slug or slugify(args.title)
    target = ROOT / section / (slug + ".qmd")
    if target.exists() or (ROOT / section / slug).exists():
        die("%s/%s existe déjà" % (section, slug))
    date = args.date or dt.date.today().isoformat()
    try:
        dt.date.fromisoformat(date)
    except ValueError:
        die("date invalide (attendu AAAA-MM-JJ) : %s" % date)

    text = model.read_text(encoding="utf-8")
    title = args.title.replace("\\", "\\\\").replace('"', '\\"')
    text = set_line(text, "title", '"%s"' % title)
    text = set_line(text, "lang", args.lang)
    if args.lang == "ar":
        # Quarto n'a pas de traduction arabe : ce fichier fournit les libellés (Citation, copier…).
        text = re.sub(r"^(lang: ar.*)$", r"\1\nlanguage: ../assets/i18n/ar.yml          # libellés arabes générés par Quarto", text, count=1, flags=re.M)
    text = set_line(text, "date", date)
    if args.kind == "essai":
        text = set_line(text, "date-modified", date)
    # Le brouillon est actif dès la création.
    text, n = re.subn(r"^# draft: true.*$", "draft: true                                    # supprimer cette ligne pour publier", text, count=1, flags=re.M)
    if n == 0:
        text = text.replace("\n---\n", "\ndraft: true\n---\n", 1)

    if args.kind == "essai":
        text = set_line(text, "bibliography", slug + ".bib")
    target.write_text(text, encoding="utf-8")
    if args.kind == "essai":
        bib = model.parent / "sources.bib"
        if bib.exists():
            shutil.copy(bib, ROOT / section / (slug + ".bib"))
    print("Créé : %s/%s.qmd" % (section, slug))
    print("Étapes : 1) remplacer le texte d'exemple et les champs marqués * ;")
    print("         2) supprimer « draft: true » pour publier ;")
    print("         3) quarto render (ou quarto preview).")
    if args.kind == "essai":
        print("         L'essai exige des sources : remplir %s/%s.bib." % (section, slug))


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("kind", nargs="?", choices=sorted(MODELS), help="type d'article")
    ap.add_argument("title", nargs="?", help="titre de l'article")
    ap.add_argument("--lang", choices=LANGS, default="fr", help="langue de rédaction (défaut : fr)")
    ap.add_argument("--slug", help="nom du fichier, sans .qmd (défaut : dérivé du titre)")
    ap.add_argument("--date", help="AAAA-MM-JJ (défaut : aujourd'hui)")
    args = ap.parse_args()

    if not args.kind or not args.title:
        ap.error("indiquez le type et le titre, ex. : new.py tutoriel \"Mon titre\"")
    new_article(args)


if __name__ == "__main__":
    main()
