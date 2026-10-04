# Décisions d'architecture (une page)

| # | Décision | Écarté | Pourquoi |
|---|----------|--------|----------|
| 1 | Un répertoire par environnement (`envs/dev`, `envs/prod`) | Workspaces | La cible est visible dans le chemin ; un state et une version de module par env. |
| 2 | Backend S3, verrou natif `use_lockfile` | Table DynamoDB | Dépréciée depuis Terraform 1.11. |
| 3 | VPC via `terraform-aws-modules/vpc/aws` | VPC écrit à la main | Brique standard, ~30 ressources maintenues par la communauté. |
| 4 | Subnets publics, **pas de NAT Gateway** | NAT + subnets privés | Coût (~0,05 $/h). Les instances restent fermées : SG n'acceptant que l'ALB. |
| 5 | Bucket de state créé en CLI (script) | Bucket géré par Terraform | Le state ne peut pas contenir le bucket qui le stocke. |
| 6 | Learner Lab : IAM verrouillé (création de rôle et de fournisseur OIDC refusées, testé le 02/10/2026) | Rôles dédiés, OIDC | Contrainte de la plateforme. Voir `SECURITE.md` pour la compensation. |
| 7 | Pas d'`instance_refresh` automatique dans le Learner Lab | `instance_refresh` Terraform | `autoscaling:StartInstanceRefresh` est explicitement refusée par une SCP AWS Academy. Le Launch Template reste versionné explicitement et une méthode compatible avec le lab sera utilisée pour renouveler les instances. |

> À compléter : secret, CI, extension.
