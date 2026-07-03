#!/usr/bin/env python3
"""
translate_articles.py — Traduction automatique des articles Quarto
via l'API DeepL (gratuite jusqu'à 500k caractères/mois).

Usage :
  python scripts/translate_articles.py --key YOUR_DEEPL_KEY
  python scripts/translate_articles.py --key YOUR_DEEPL_KEY --dir blog
  python scripts/translate_articles.py --key YOUR_DEEPL_KEY --dir articles

Variables d'environnement :
  DEEPL_API_KEY=your_key python scripts/translate_articles.py
"""

import os, re, sys, json, time, argparse, pathlib, textwrap
import urllib.request, urllib.parse

# ── Config ────────────────────────────────────────────────────────
LANGS = {
    "en": "EN-US",   # Anglais
    "ar": "AR",      # Arabe
}
DIRS_DEFAULT = ["blog", "articles"]
SKIP_PATTERNS = [
    r"^_template",           # templates
    r"^index\.qmd$",         # listings
]

# ── DeepL API ─────────────────────────────────────────────────────
def deepl_translate(text: str, target_lang: str, api_key: str) -> str:
    """Traduit un texte via l'API DeepL Free."""
    url = "https://api-free.deepl.com/v2/translate"
    data = urllib.parse.urlencode({
        "auth_key": api_key,
        "text": text,
        "source_lang": "FR",
        "target_lang": target_lang,
        "tag_handling": "html",
        "split_sentences": "1",
    }).encode("utf-8")
    req = urllib.request.Request(url, data=data, method="POST")
    req.add_header("Content-Type", "application/x-www-form-urlencoded")
    with urllib.request.urlopen(req, timeout=30) as resp:
        result = json.loads(resp.read())
    return result["translations"][0]["text"]

# ── Parser YAML front matter ──────────────────────────────────────
FRONT_MATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)

def parse_qmd(path: pathlib.Path):
    content = path.read_text(encoding="utf-8")
    m = FRONT_MATTER_RE.match(content)
    if not m:
        return None, None, content
    return m.group(0), m.group(1), content[m.end():]

def update_yaml_field(yaml_str: str, key: str, value: str) -> str:
    pattern = re.compile(rf'^({key}:\s*)(.+)$', re.MULTILINE)
    if pattern.search(yaml_str):
        return pattern.sub(rf'\g<1>"{value}"', yaml_str)
    return yaml_str + f'\n{key}: "{value}"'

# ── Segments à NE PAS traduire ────────────────────────────────────
# Blocs de code, HTML brut, chemins de fichiers, etc.
CODE_BLOCK_RE  = re.compile(r"(```[\s\S]*?```)", re.MULTILINE)
HTML_BLOCK_RE  = re.compile(r"(```\{=html\}[\s\S]*?```)", re.MULTILINE)
INLINE_CODE_RE = re.compile(r"(`[^`]+`)")

def split_translatable(text: str):
    """Découpe le texte en segments (à traduire / à conserver)."""
    parts = []
    pos = 0
    for pat in [HTML_BLOCK_RE, CODE_BLOCK_RE, INLINE_CODE_RE]:
        for m in pat.finditer(text):
            if m.start() > pos:
                parts.append(("text", text[pos:m.start()]))
            parts.append(("code", m.group(0)))
            pos = m.end()
    if pos < len(text):
        parts.append(("text", text[pos:]))
    return parts

def translate_body(body: str, target_lang: str, api_key: str) -> str:
    parts = split_translatable(body)
    result = []
    for kind, chunk in parts:
        if kind == "code" or not chunk.strip():
            result.append(chunk)
        else:
            # Découper en paragraphes pour respecter la limite DeepL (128KB)
            paras = chunk.split("\n\n")
            translated_paras = []
            for p in paras:
                if len(p.strip()) > 2 and not p.strip().startswith("---"):
                    try:
                        t = deepl_translate(p, target_lang, api_key)
                        translated_paras.append(t)
                        time.sleep(0.15)   # éviter le rate-limit
                    except Exception as e:
                        print(f"  ⚠ Erreur traduction: {e} — conservation du texte original")
                        translated_paras.append(p)
                else:
                    translated_paras.append(p)
            result.append("\n\n".join(translated_paras))
    return "".join(result)

# ── Traduction d'un fichier .qmd ──────────────────────────────────
def translate_file(src: pathlib.Path, target_lang_code: str,
                   deepl_lang: str, api_key: str, dry_run: bool = False):
    front_matter_raw, yaml_str, body = parse_qmd(src)
    if front_matter_raw is None:
        print(f"  ⏭ Ignoré (pas de front matter) : {src.name}")
        return

    # Nom du fichier de sortie : ex. article-fr.qmd → article-en.qmd
    stem = src.stem
    # Retirer suffixe de langue existant si présent
    for lc in list(LANGS.keys()) + ["fr"]:
        if stem.endswith(f"-{lc}"):
            stem = stem[: -(len(lc) + 1)]
            break
    out_path = src.parent / f"{stem}-{target_lang_code}.qmd"

    if out_path.exists():
        print(f"  ⏭ Déjà traduit : {out_path.name}")
        return

    print(f"  🌐 {src.name} → {out_path.name} ({deepl_lang})")
    if dry_run:
        return

    # Traduire title et description dans le YAML
    new_yaml = yaml_str
    for field in ["title", "description", "subtitle"]:
        m = re.search(rf'^{field}:\s*["\']?(.+?)["\']?\s*$', yaml_str, re.MULTILINE)
        if m:
            original = m.group(1).strip().strip("\"'")
            try:
                translated = deepl_translate(original, deepl_lang, api_key)
                new_yaml = update_yaml_field(new_yaml, field, translated.strip())
                time.sleep(0.1)
            except Exception as e:
                print(f"    ⚠ Champ {field}: {e}")

    # Ajouter lang dans le YAML
    new_yaml = update_yaml_field(new_yaml, "lang",
                                  "ar" if target_lang_code == "ar" else "en")

    # Traduire le corps
    print(f"    Traduction du corps ({len(body)} caractères)…")
    translated_body = translate_body(body, deepl_lang, api_key)

    # Écrire le fichier traduit
    out_content = f"---\n{new_yaml}\n---\n{translated_body}"
    out_path.write_text(out_content, encoding="utf-8")
    print(f"  ✓ Écrit : {out_path.name}")

# ── Main ──────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(
        description="Traduit les articles Quarto avec DeepL"
    )
    parser.add_argument("--key",  default=os.environ.get("DEEPL_API_KEY", ""),
                        help="Clé API DeepL Free")
    parser.add_argument("--dir",  default=None,
                        help="Dossier à traiter (blog|articles|all)")
    parser.add_argument("--dry-run", action="store_true",
                        help="Simulation sans écrire de fichiers")
    args = parser.parse_args()

    if not args.key:
        print("❌ Clé DeepL manquante. Utilise --key ou DEEPL_API_KEY=...")
        print("   Obtenir une clé gratuite : https://www.deepl.com/fr/pro-api")
        sys.exit(1)

    dirs = DIRS_DEFAULT if not args.dir or args.dir == "all" else [args.dir]
    root = pathlib.Path(__file__).parent.parent

    total = 0
    for d in dirs:
        folder = root / d
        if not folder.exists():
            continue
        qmd_files = sorted(folder.glob("*.qmd"))
        # Filtrer les templates, index et fichiers déjà traduits
        to_process = [
            f for f in qmd_files
            if not any(re.match(p, f.name) for p in SKIP_PATTERNS)
            and not any(f.stem.endswith(f"-{lc}") for lc in LANGS)
        ]
        print(f"\n📁 {d}/ — {len(to_process)} fichier(s) à traiter")
        for src in to_process:
            for lang_code, deepl_lang in LANGS.items():
                translate_file(src, lang_code, deepl_lang, args.key, args.dry_run)
                total += 1

    print(f"\n✅ Terminé — {total} traduction(s) effectuée(s)")

if __name__ == "__main__":
    main()
