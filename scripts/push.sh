#!/bin/bash
# push.sh — Script de commit et push complet
# Exécuter dans le Terminal RStudio depuis la racine du projet

set -e

echo "🔍 Vérification de l'état Git..."
git status

echo ""
echo "📦 Ajout de tous les fichiers modifiés..."
git add .

echo ""
echo "📝 Commit..."
git commit -m "feat: couleurs #f9e2a8 + police Mono + traduction DeepL auto + corrections UI

- Couleur accent #f9e2a8 (jaune crème) appliquée proprement :
  badges/boutons = fond #f9e2a8 texte sombre, jamais en fond de texte
- Hover restauré en vert #1B5E3B sur TOUS les éléments interactifs
- Fond jaune supprimé du ticker et des titres h3 research cards
- JetBrains Mono sur interface (sidebar, badges, filtres, boutons)
- Sidebar police agrandie (0.9rem)
- Script DeepL auto-translation (scripts/translate_articles.py)
- CI/CD : step DeepL automatique si secret DEEPL_API_KEY configuré
- Bouton 'Code source' masqué partout"

echo ""
echo "🚀 Push vers GitHub..."
git push origin main

echo ""
echo "✅ Déployé ! Vérifier dans 2-3 min :"
echo "   https://github.com/abdelazizharane/abdelazizharane.github.io/actions"
