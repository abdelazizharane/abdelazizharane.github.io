# Mon site personnel

Site académique trilingue (FR/EN/AR) construit avec [Quarto](https://quarto.org).

**URL :** https://abdelazizharane.com

---

## Stack

- **Quarto** — génération du site
- **R / Python** — visualisations et notebooks intégrés
- **GitHub Actions** — build et déploiement automatiques
- **DeepL API** — traduction automatique FR/EN/AR

---

## Structure

```
├── index.qmd            # Page d'accueil
├── blog/                # Articles (un fichier par article)
├── articles/             # Publications scientifiques
├── about/                # À propos
├── assets/               # CSS, images, polices
└── .github/workflows/    # CI/CD
```

---

## Installation locale

```bash
# Quarto
brew install quarto        # macOS
# ou télécharger depuis quarto.org pour Linux/Windows

# Dépendances R (optionnel)
install.packages(c("tidyverse", "ggplot2", "knitr"))

# Dépendances Python (optionnel)
pip install jupyter matplotlib pandas
```

```bash
git clone https://github.com/abdelazizharane/abdelazizharane.github.io.git
cd abdelazizharane.github.io
quarto preview   # aperçu local avant publication
```

---

## Publier un article

```bash
cp blog/_template-article.qmd blog/$(date +%Y-%m-%d)-titre.qmd
# éditer le contenu, passer draft: false

quarto preview               # vérifier localement
git add . && git commit -m "blog: nouvel article"
git push origin main          # déploiement automatique (~2-3 min)
```

---

## Personnalisation

- **Couleurs** → `assets/css/harane.css` (variables `--h-green`, `--h-ocre`)
- **Polices** → `assets/html/head-extra.html` + `harane.css`
- **Bibliographie** → `references.bib`

---

## Commandes utiles

```bash
quarto preview            # serveur local avec rechargement auto
quarto render              # build complet
quarto render --cache-refresh   # forcer la ré-exécution du code
```

---

*Construit avec Quarto (R & Python)*
