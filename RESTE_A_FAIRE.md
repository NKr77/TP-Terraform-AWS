# Reste-à-faire

Nous n'avions pas versionné cette fiche à la fin de la séance 9. Nous l'avons remplie après coup, à partir de l'historique des pull requests.

**Équipe :** Krusic Nicolas, Monte Fabio, Ballereau Fabien

## Où nous en sommes

- [x] dev déployé par la CI, l'ALB répond (PR #9, 19/10/2026)
- [x] secret en Parameter Store, dépôt propre (PR #8 et #12, 29/10/2026)
- [x] prod : environnement protégé, plan lu, déployée après approbation (PR #14, 29/10/2026)

## Reste à faire pendant l'alternance

| # | Item | Qui | Quand |
|---|------|-----|-------|
| 1 | Lecture du secret dans Parameter Store par les instances (module `web-v2.0.0`) | Ballereau Fabien | 22/10/2026 (fusion le 29/10) |
| 2 | Environnement prod complet, déployé par la CI | Krusic Nicolas | 29/10/2026 |
| 3 | Livrables : README « déployer de zéro », décisions, sécurité, démonstration | Krusic Nicolas | 29/10/2026 |

Fabio et Fabien ont fait les relectures et approuvé les déploiements de prod.

**Date de gel :** 29/10/2026, tag `rendu-final`.

Nous avons ajouté ce fichier et `ARCHITECTURE.md` le 02/11/2026. L'état du dépôt au 29/10 reste disponible avec le tag `rendu-final-2026-10-29`.
