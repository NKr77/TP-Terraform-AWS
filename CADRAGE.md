# Fiche de cadrage

**Équipe :** NovaSphere **Classe :** Master SRC (5SRC4)

| Membre | Rôle | Compte AWS de démonstration |
|--------|------|-----------------------------|
| Krusic Nicolas (NKr77) | Référent AWS et Git : state, dev, prod, runner CI | Learner Lab porteur |
| Ballereau Fabien (FabienBll) | Module web, secret Parameter Store | Son Learner Lab (bac à sable) |
| Monte Fabio (fabio-91130) | Relectures, approbation des déploiements de prod | Son Learner Lab (bac à sable) |

## Contexte
NovaSphere : application web servie par nginx derrière un ALB. Les instances
servent une page qui affiche l'environnement et prouve la lecture du secret
depuis Parameter Store. Environnements : `dev`, `prod`.

## Extension choisie (une seule)
[x] Aucune : nous avons consacré l'alternance au socle du cahier des charges.

Ce qu'elle exige en plus du socle : rien.

## Ce que l'équipe écarte, et pourquoi
- NAT Gateway : coût (environ 0,05 $/h), inutile avec des subnets publics.
- Ansible au démarrage (bonus) : notre amorçage tient en 9 lignes.
- HTTPS : pas de nom de domaine ni de certificat dans le Learner Lab.
- Workspaces : nous préférons un répertoire par environnement (voir `DECISIONS.md`).

## Validation
Validée par l'intervenant le ____ : [ ] telle quelle [ ] réduite à : ____
