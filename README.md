# 🌍 Site Personnel — Abdel-aziz Harane
**Quarto · GitHub Pages · CI/CD automatique**

---

## 📁 Architecture complète du projet

```
abdelazizharane.github.io/
│
├── _quarto.yml                  ← Configuration centrale du site
├── index.qmd                    ← Page Home
├── references.bib               ← Bibliographie globale BibTeX
├── .gitignore
│
├── blog/
│   ├── index.qmd                ← Listing automatique des articles
│   ├── _template-article.qmd   ← Modèle pour nouveaux articles
│   ├── 2025-06-10-laal-*.qmd
│   ├── 2025-05-22-wav2vec-*.qmd
│   └── 2025-03-08-big-tech-*.qmd
│
├── articles/
│   ├── index.qmd                ← Page publications scientifiques
│   └── _template-publication.qmd
│
├── about/
│   └── index.qmd                ← Page À propos
│
├── assets/
│   ├── css/
│   │   ├── harane.css           ← Styles custom principaux
│   │   ├── harane-light.scss    ← Thème clair (variables SCSS)
│   │   └── harane-dark.scss     ← Thème sombre
│   ├── html/
│   │   ├── head-extra.html      ← Fonts, JSON-LD, meta
│   │   └── body-extra.html      ← Scroll-to-top, analytics
│   ├── img/                     ← Images, favicons, OG card
│   └── csl/
│       └── apa.csl              ← Style bibliographique (APA)
│
└── .github/
    └── workflows/
        └── deploy.yml           ← CI/CD GitHub Actions
```

---

## 🚀 Processus de déploiement pas à pas

### Étape 1 — Prérequis à installer sur ta machine

#### A) Quarto
```bash
# Télécharger depuis https://quarto.org/docs/get-started/
# Linux :
wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.557/quarto-1.4.557-linux-amd64.deb
sudo dpkg -i quarto-1.4.557-linux-amd64.deb
quarto --version

# macOS :
brew install quarto
```

#### B) R (recommandé pour les visualisations)
```bash
# Ubuntu/Debian :
sudo apt install r-base r-base-dev

# macOS :
brew install r

# Packages R essentiels (depuis R ou RStudio) :
install.packages(c(
  "tidyverse", "ggplot2", "knitr", "rmarkdown",
  "plotly", "DT", "leaflet", "htmlwidgets"
))
```

#### C) Python (pour les notebooks Python)
```bash
pip install jupyter matplotlib numpy pandas seaborn
```

#### D) RStudio (recommandé pour l'écriture)
- Télécharger : https://posit.co/downloads/
- RStudio 2023.09+ supporte nativement Quarto avec aperçu live

---

### Étape 2 — Créer le dépôt GitHub

```bash
# Le nom du dépôt DOIT être exactement :
# abdelazizharane.github.io
# (ton GitHub username + .github.io)

# Sur GitHub.com → New repository
# Name : abdelazizharane.github.io
# Visibility : Public
# ✓ Add README
```

---

### Étape 3 — Cloner et initialiser

```bash
git clone https://github.com/abdelazizharane/abdelazizharane.github.io.git
cd abdelazizharane.github.io

# Copier tous les fichiers du projet dans ce dossier
# (ceux que tu as reçus dans cette session)
```

---

### Étape 4 — Configuration GitHub Pages

Sur GitHub.com, dans ton dépôt :

```
Settings → Pages → Source → "GitHub Actions"
```

⚠️ C'est **GitHub Actions** (pas "Deploy from a branch") qui doit être sélectionné.

---

### Étape 5 — Premier déploiement

```bash
# Test local AVANT de pousser (très important)
quarto preview

# Si tout s'affiche correctement dans ton navigateur :
git add .
git commit -m "feat: site initial Quarto"
git push origin main

# GitHub Actions se déclenche automatiquement
# Aller dans : GitHub → ton dépôt → onglet "Actions"
# Attendre ~3-5 minutes pour le premier build
```

Ton site sera disponible sur :
**https://abdelazizharane.github.io**

---

### Étape 6 — Workflow quotidien (écrire et publier)

#### Écrire un nouvel article de blog

```bash
# 1. Copier le template
cp blog/_template-article.qmd blog/$(date +%Y-%m-%d)-titre-article.qmd

# 2. Éditer dans RStudio ou VSCode
# - Changer title, description, date, categories
# - Écrire le contenu en Markdown/Quarto
# - Mettre draft: false quand l'article est prêt

# 3. Prévisualiser localement
quarto preview

# 4. Publier
git add blog/2025-XX-XX-titre-article.qmd
git commit -m "blog: nouvel article sur [sujet]"
git push origin main
# → déploiement automatique en ~2 minutes
```

#### Ajouter une publication scientifique

```bash
# Option A : Via la page articles/index.qmd
# Éditer directement le fichier, ajouter un bloc HTML
# suivant le modèle des publications existantes

# Option B : Créer une page dédiée
cp articles/_template-publication.qmd articles/2025-kalam-na.qmd
# Éditer et pousser
```

---

## 🎨 Personnalisation du design

### Changer la palette de couleurs

Éditer `assets/css/harane.css` :
```css
:root {
  --h-green: #1B5E3B;    /* Couleur principale — vert sahélien */
  --h-ocre:  #C8963E;    /* Couleur secondaire — ocre Sahara  */
  /* ... */
}
```

### Changer les polices

Dans `_quarto.yml` → `format.html.css`, ou dans `assets/html/head-extra.html` :
```html
<!-- Remplacer DM Serif Display par une autre police -->
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital@0;1&display=swap" rel="stylesheet" />
```

Puis dans `harane.css` :
```css
--h-font-serif: 'Playfair Display', Georgia, serif;
```

### Ajouter ta photo de profil

1. Mettre `avatar.jpg` dans `assets/img/`
2. Dans `index.qmd`, remplacer la div `.h-avatar` :
```html
<img src="assets/img/avatar.jpg" alt="Abdel-aziz Harane"
     class="h-avatar" style="object-fit:cover;" />
```

---

## 📝 Écrire avec R et Python

### Dans un article de blog — chunks R

````qmd
```{r}
#| echo: true
#| fig-cap: "Distribution des tons en Sara Ngambaye"
#| fig-width: 7
#| fig-height: 4

library(ggplot2)
library(dplyr)

# Ton code R ici
df <- data.frame(
  ton = c("H", "L", "HL", "LH", "M"),
  freq = c(312, 287, 145, 98, 43)
)

ggplot(df, aes(x=reorder(ton,-freq), y=freq)) +
  geom_col(fill="#1B5E3B", alpha=.85) +
  theme_minimal() +
  labs(title="Fréquence des tons", x="Ton", y="Occurrences")
```
````

### Dans un article — chunks Python

````qmd
```{python}
#| echo: true

import pandas as pd
import matplotlib.pyplot as plt

# Ton code Python ici
langues = {"Sara": 700000, "Laal": 750, "Tupuri": 215000}
fig, ax = plt.subplots(figsize=(7,3))
ax.barh(list(langues.keys()), list(langues.values()), color="#1B5E3B")
ax.set_xscale("log")
plt.tight_layout()
plt.show()
```
````

### Cache (évite de ré-exécuter le code à chaque build)

Dans `_quarto.yml` → `execute: freeze: auto` — déjà configuré.
Pour forcer la ré-exécution :
```bash
quarto render --cache-refresh
```

---

## 🔧 Commandes utiles

```bash
# Aperçu local avec rechargement automatique
quarto preview

# Construire le site sans démarrer un serveur
quarto render

# Rendre un seul fichier
quarto render blog/2025-06-10-laal-documenter-isolat.qmd

# Vérifier les dépendances
quarto check

# Mettre à jour Quarto
quarto update

# Forcer la ré-exécution de tout le code (ignore le cache)
quarto render --cache-refresh

# Voir les logs détaillés
quarto render --verbose
```

---

## 📦 Gestion des dépendances R avec renv (optionnel mais recommandé)

```r
# Dans R/RStudio, initialiser renv pour la reproductibilité
install.packages("renv")
renv::init()

# Installer les packages et les enregistrer
install.packages("tidyverse")
renv::snapshot()
# → crée renv.lock, committé dans git

# Sur une autre machine ou dans CI :
renv::restore()
```

Le workflow GitHub Actions détecte automatiquement `renv.lock` et restaure les packages.

---

## 🌐 Domaine personnalisé (optionnel)

Si tu veux `harane.org` ou `abdelazizharane.com` :

1. Acheter le domaine (Namecheap, Cloudflare Registrar...)
2. Sur GitHub → Settings → Pages → Custom domain → entrer le domaine
3. Chez ton registrar, ajouter ces enregistrements DNS :
```
Type   Nom    Valeur
A      @      185.199.108.153
A      @      185.199.109.153
A      @      185.199.110.153
A      @      185.199.111.153
CNAME  www    abdelazizharane.github.io
```
4. Créer `assets/CNAME` avec le contenu : `abdelazizharane.com`
5. Committer et pousser

---

## 📋 Checklist avant premier déploiement

```
□ Quarto installé (quarto --version fonctionne)
□ R installé avec les packages requis
□ Dépôt GitHub créé avec le bon nom (username.github.io)
□ GitHub Pages configuré sur "GitHub Actions"
□ Ta photo ajoutée dans assets/img/avatar.jpg
□ index.qmd : vérifier bio, liens, projets
□ references.bib : mettre à jour avec tes vraies publications
□ _quarto.yml : vérifier site-url et repo-url
□ quarto preview fonctionne en local sans erreur
□ Premier git push effectué
□ Onglet Actions → build vert ✓
□ Site accessible sur https://abdelazizharane.github.io
```

---

## 🆘 Résolution de problèmes fréquents

| Problème | Cause probable | Solution |
|----------|----------------|----------|
| `quarto: command not found` | Quarto non installé | Relancer le terminal après installation |
| Build CI échoue sur R | Package R manquant | Ajouter dans le step "Install R packages" du workflow |
| Styles non appliqués | Chemin CSS incorrect | Vérifier le chemin dans `_quarto.yml` |
| Fonts Google ne chargent pas | Problème réseau ou bloqueur pub | Vérifier `head-extra.html` |
| SCSS n'est pas compilé | `sass` manquant | `npm install -g sass` ou `quarto install tinytex` |
| `freeze` ne fonctionne pas | Dossier `_freeze` non commité | `git add _freeze/ && git commit` |

---

*Site construit avec [Quarto](https://quarto.org) · Hébergé sur [GitHub Pages](https://pages.github.com) · Design Sahel-inspired par Abdel-aziz Harane*
