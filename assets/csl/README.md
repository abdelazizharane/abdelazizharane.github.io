# Fichier CSL (Citation Style Language)

Ce dossier doit contenir le fichier `apa.csl` pour le formatage des références bibliographiques.

## Téléchargement

```bash
# Depuis le dépôt officiel Citation Style Language :
curl -o assets/csl/apa.csl \
  https://raw.githubusercontent.com/citation-style-language/styles/master/apa.csl
```

## Alternatives

| Style | Fichier | Usage |
|-------|---------|-------|
| APA 7e éd. | `apa.csl` | Sciences sociales, NLP |
| ACL | `association-for-computational-linguistics.csl` | Conférences NLP/CL |
| Chicago | `chicago-author-date.csl` | Linguistique |
| IEEE | `ieee.csl` | Ingénierie |

```bash
# ACL (recommandé pour les articles NLP/Speech)
curl -o assets/csl/acl.csl \
  https://raw.githubusercontent.com/citation-style-language/styles/master/association-for-computational-linguistics.csl
```

Puis dans `_quarto.yml` changer `csl: assets/csl/apa.csl` par `csl: assets/csl/acl.csl`.
