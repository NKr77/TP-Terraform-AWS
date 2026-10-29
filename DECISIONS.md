# Décisions d'architecture (une page)

| # | Décision | Écarté | Pourquoi |
|---|----------|--------|----------|
| 1 | Un répertoire par environnement (`envs/dev`, `envs/prod`) | Workspaces | La cible est visible dans le chemin ; un state et une version de module par env. |
| 2 | Backend S3, verrou natif `use_lockfile` | Table DynamoDB | Dépréciée depuis Terraform 1.11. |
| 3 | VPC via `terraform-aws-modules/vpc/aws` | VPC écrit à la main | Brique standard, ~30 ressources maintenues par la communauté. |
| 4 | Subnets publics, **pas de NAT Gateway** | NAT + subnets privés | Coût (~0,05 $/h). Les instances restent fermées : SG n'acceptant que l'ALB. |
| 5 | Bucket de state créé en CLI (script) | Bucket géré par Terraform | Le state ne peut pas contenir le bucket qui le stocke. |
| 6 | Learner Lab : IAM verrouillé (création de rôle et de fournisseur OIDC refusées, testé le 02/10/2026) | Rôles dédiés, OIDC | Contrainte de la plateforme. Voir `SECURITE.md` pour la compensation. |
| 7 | Renouvellement des instances par remplacement de l'ASG : version du Launch Template dans le nom de l'ASG, `create_before_destroy`, `wait_for_elb_capacity` | `instance_refresh` | `autoscaling:StartInstanceRefresh` est refusée par une SCP AWS Academy. Le nouvel ASG est créé et healthy avant la suppression de l'ancien, sans coupure. |
| 8 | Module `web` versionné par tag Git (`web-v1.0.0`, `web-v2.0.0`), tags `web-v*` protégés contre la modification et la suppression | Source locale `../../modules/web` | Une version publiée ne change plus. Promotion dev → prod en changeant le `ref`. |
| 9 | Un seul compte AWS « porteur » (lab de l'équipe) pour dev et prod ; les autres membres testent dans leur propre lab avec leur bucket (`-backend-config`) | Partager les credentials du lab | Chaque Learner Lab est un compte séparé. Partager des credentials, c'est partager un secret. |
| 10 | CI GitHub Actions sur un **runner auto-hébergé** (VM du porteur), utilisateur dédié `ghrunner` sans sudo | OIDC ; clés du lab dans les secrets GitHub | OIDC impossible (décision 6). Aucune clé AWS n'est stockée dans GitHub. |
| 11 | `plan -out=tfplan` puis `apply tfplan` | `apply` direct | On applique exactement le plan calculé, rien d'autre. |
| 12 | Prod derrière un environnement GitHub protégé : approbation d'un autre membre (`Prevent self-review`), branche `main` uniquement, pas de contournement administrateur | Apply prod automatique | Exigence du cahier des charges : deux personnes pour toucher la prod. |
| 13 | Plan sur toutes les PR, checks `plan (dev)` et `plan (prod)` obligatoires avant merge | Filtre `paths` sur le workflow de PR | Avec un filtre, une PR de documentation attendrait des checks qui ne viennent jamais. |
| 14 | Pas de `concurrency` sur les jobs qui attendent une approbation (apply prod, destroy) | Concurrency sur tous les jobs | Un job en attente d'approbation garde le verrou et bloque les autres jobs de prod (constaté : 1 h 27 d'attente). Le verrou du state Terraform reste la protection. |
| 15 | Destruction en fin de session par le workflow `Terraform Destroy` (confirmation par le nom de l'environnement) | `terraform destroy` en local | Rien ne tourne entre deux sessions, et tout passe par la chaîne. |
| 16 | Secret généré par Terraform : `ephemeral "random_password"` écrit avec `value_wo` dans un paramètre SecureString `/novasphere/<env>/app_secret` | `random_password` classique ; paramètre créé à la main | La valeur n'est ni dans le plan ni dans le state, et l'environnement se recrée de zéro sur un compte vide. Rotation : `value_wo_version` + 1. |
| 17 | La page affiche une empreinte du secret (8 caractères de son SHA-256) | Afficher le secret ; texte fixe | Prouve que l'instance a lu le secret sans l'exposer. |
| 18 | Ajout de variables obligatoires au module publié en `web-v2.0.0` | `web-v1.1.0` | SemVer : une variable obligatoire de plus casse les appelants, c'est une version majeure. |
| 19 | Prod = même code et même `ref` de module que dev, VPC distinct `10.1.0.0/16` (dev : `10.0.0.0/16`) | Code prod divergent | Ce qui est testé en dev est ce qui part en prod. Plages séparées : pas de confusion, peering possible plus tard. |
| 20 | Apply aussi lançable à la main (`workflow_dispatch`) | Redéployer par un commit vide | Après un destroy, on redéploie sans modifier `main` (dépôt gelé par tag). |
| 21 | Pas d'extension ; Ansible au démarrage écarté | `ansible-pull` (bonus) | Le socle d'abord. L'amorçage tient en 9 lignes, Ansible n'apporterait rien ici. |
