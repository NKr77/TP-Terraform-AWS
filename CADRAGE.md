# Fiche de cadrage

**Équipe :** NovaSphere **Classe :** Master SRC

| Membre | Rôle | Compte AWS de démonstration |
|--------|------|-----------------------------|
| Nicolas KRUSIC (NKr77) | Porteur AWS et Git : state, dev, prod, runner CI | Learner Lab porteur |
| FabienBll | Module web, secret Parameter Store | Learner Lab personnel (bac à sable) |
| fabio-91130 | Revues, approbation des déploiements prod | Learner Lab personnel (bac à sable) |

## Contexte
NovaSphere : application web servie par nginx derrière un ALB. Les instances
servent une page qui affiche l'environnement et prouve la lecture du secret
depuis Parameter Store. Environnements : `dev`, `prod`.

## Extension choisie (une seule)
[x] Aucune : le temps de l'alternance est consacré au socle.

Ce qu'elle exige en plus du socle : —

## Ce que l'équipe écarte, et pourquoi
- NAT Gateway (coût).
- Ansible au démarrage (bonus) : l'amorçage tient en 9 lignes.
- HTTPS : pas de nom de domaine ni de certificat dans le Learner Lab.
- Workspaces : un répertoire par environnement (voir `DECISIONS.md`).

## Validation
Validée par l'intervenant le ____ : [ ] telle quelle [ ] réduite à : ____
