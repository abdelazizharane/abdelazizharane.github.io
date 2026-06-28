# ═══════════════════════════════════════════════════════════════
# setup.R — Installation de tous les packages nécessaires
# Exécuter UNE SEULE FOIS après avoir cloné le projet
# Dans RStudio : source("setup.R") ou Ctrl+Shift+S
# ═══════════════════════════════════════════════════════════════

cat("🚀 Installation des packages pour le site Quarto...\n\n")

# ── 1. Vérifier la version de R ─────────────────────────────────
cat("R version :", R.version.string, "\n")
if (getRversion() < "4.2.0") {
  warning("⚠️  R >= 4.2.0 recommandé. Mettre à jour : https://cloud.r-project.org")
}

# ── 2. Fonction helper d'installation ───────────────────────────
install_if_missing <- function(pkgs) {
  missing <- pkgs[!pkgs %in% rownames(installed.packages())]
  if (length(missing) > 0) {
    cat("📦 Installation de :", paste(missing, collapse = ", "), "\n")
    install.packages(missing, repos = "https://cloud.r-project.org", quiet = TRUE)
  } else {
    cat("✓ Tous les packages sont déjà installés.\n")
  }
}

# ── 3. Packages essentiels ───────────────────────────────────────
cat("\n--- Packages essentiels ---\n")
install_if_missing(c(
  "knitr",       # moteur de rendu des chunks de code
  "rmarkdown",   # base pour Quarto
  "quarto"       # interface R pour Quarto
))

# ── 4. Visualisation & Data ──────────────────────────────────────
cat("\n--- Visualisation & Data ---\n")
install_if_missing(c(
  "tidyverse",   # ggplot2, dplyr, tidyr, readr, purrr...
  "ggplot2",     # graphiques (déjà dans tidyverse, explicite ici)
  "plotly",      # graphiques interactifs
  "DT",          # tableaux interactifs DataTables
  "gt",          # tableaux académiques (type LaTeX)
  "kableExtra",  # amélioration des tableaux knitr
  "scales",      # formatage des axes (%, milliers...)
  "viridis",     # palettes de couleurs accessibles
  "patchwork"    # combiner plusieurs plots ggplot2
))

# ── 5. Cartographie (pour l'Atlas Linguistique) ──────────────────
cat("\n--- Cartographie ---\n")
install_if_missing(c(
  "leaflet",       # cartes interactives Leaflet.js
  "htmlwidgets",   # widgets HTML interactifs
  "sf",            # données géospatiales (Simple Features)
  "rnaturalearth", # frontières pays/régions
  "rnaturalearthdata"
))

# ── 6. NLP / Texte ───────────────────────────────────────────────
cat("\n--- NLP & Texte ---\n")
install_if_missing(c(
  "stringr",     # manipulation de chaînes (dans tidyverse)
  "tidytext",    # analyse de texte tidy
  "wordcloud2",  # nuages de mots
  "jsonlite",    # lecture/écriture JSON
  "yaml"         # lecture des fichiers YAML
))

# ── 7. Audio / Signal (pour Speech AI) ──────────────────────────
cat("\n--- Audio & Signal ---\n")
install_if_missing(c(
  "tuneR",   # lecture de fichiers audio WAV
  "seewave"  # analyse de spectrogrammes
))

# ── 8. Gestion de projet & Reproductibilité ──────────────────────
cat("\n--- Reproductibilité ---\n")
install_if_missing(c(
  "renv",   # gestion des dépendances (lockfile)
  "here"    # chemins relatifs robustes
))

# ── 9. Vérification finale ───────────────────────────────────────
cat("\n═══════════════════════════════════\n")
cat("✅ Installation terminée !\n\n")

cat("📋 Prochaines étapes dans RStudio :\n")
cat("  1. File → Open Project → harane-site.Rproj\n")
cat("  2. Onglet 'Build' → Render Website\n")
cat("  3. OU dans le Terminal : quarto preview\n\n")

# Vérifier que Quarto est disponible
quarto_path <- Sys.which("quarto")
if (nchar(quarto_path) > 0) {
  cat("✅ Quarto détecté :", quarto_path, "\n")
  system("quarto --version")
} else {
  cat("❌ Quarto non trouvé.\n")
  cat("   Installer depuis : https://quarto.org/docs/get-started/\n")
  cat("   Puis redémarrer RStudio.\n")
}
