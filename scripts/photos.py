#!/usr/bin/env python3
"""Prépare une photo pour la galerie (Médias → Photos).

    python scripts/photos.py chemin/vers/photo.jpg nom-court

Crée, à partir de l'original (jpg, png, heic converti, etc.) :
  assets/img/galerie/<nom-court>.webp        1000 px de côté (galerie, rapide à charger)
  assets/img/galerie/<nom-court>-large.webp  1800 px de côté (agrandissement)
corrige l'orientation (photos de téléphone) et retire les métadonnées EXIF (lieu GPS…),
puis affiche l'entrée à coller dans data/photos.yml.

Nécessite Pillow : pip install pillow
"""
import sys
from pathlib import Path

try:
    from PIL import Image, ImageOps
except ImportError:
    sys.exit("Pillow est requis : pip install pillow")

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "img" / "galerie"


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    src, name = Path(sys.argv[1]), sys.argv[2].strip().lower().replace(" ", "-")
    if not src.exists():
        sys.exit(f"Fichier introuvable : {src}")
    OUT.mkdir(parents=True, exist_ok=True)
    im = ImageOps.exif_transpose(Image.open(src)).convert("RGB")   # bonne orientation, sans EXIF
    for size, suffix in ((1000, ""), (1800, "-large")):
        c = im.copy()
        c.thumbnail((size, size), Image.LANCZOS)
        dest = OUT / f"{name}{suffix}.webp"
        c.save(dest, "WEBP", quality=82, method=6)
        print(f"  {dest.relative_to(ROOT)}  ({c.width}×{c.height}, {dest.stat().st_size // 1024} Ko)")
    w, h = im.size
    fmt = "tall" if h > w * 1.15 else ("wide" if w > h * 1.6 else "")
    print("\nÀ copier dans data/photos.yml :\n")
    print(f"- src: assets/img/galerie/{name}.webp")
    print(f"  large: assets/img/galerie/{name}-large.webp")
    print('  title: "…"')
    print('  event: "…"')
    print('  quand: "AAAA-MM-JJ"')
    print('  description: "…"')
    print('  alt: "…"')
    if fmt:
        print(f"  format: {fmt}")


if __name__ == "__main__":
    main()