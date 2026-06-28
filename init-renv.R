# ═══════════════════════════════════════════════════════════════
# init-renv.R — Initialiser renv pour la reproductibilité
# Exécuter APRÈS setup.R, une seule fois
# ═══════════════════════════════════════════════════════════════

# renv "gèle" les versions exactes de tes packages
# → le site se construit identiquement sur ta machine ET sur GitHub CI

library(renv)

# Initialise renv (crée renv.lock et renv/)
renv::init(
  bioconductor = FALSE,
  settings = list(
    snapshot.type = "explicit",  # ne capture que les packages explicitement utilisés
    ignored.packages = c("renv") # évite de s'auto-capturer
  )
)

# Capture l'état actuel
renv::snapshot()

cat("\n✅ renv initialisé !\n")
cat("   Fichier créé : renv.lock (à committer dans git)\n\n")
cat("   Sur une autre machine / GitHub CI :\n")
cat("   renv::restore()  ← restaure exactement les mêmes versions\n")
