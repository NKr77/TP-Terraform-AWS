# Registre de sécurité

## Contraintes AWS Academy (constatées le 02/10/2026)

| Test | Résultat |
|------|----------|
| Création d'un fournisseur OIDC | Refusé |
| Création d'un rôle IAM | Refusé |
| `LabRole` / `LabInstanceProfile` | Disponibles |
| Écriture SecureString (Parameter Store) | Autorisé |
| `autoscaling:StartInstanceRefresh` | Refusé par une Service Control Policy (SCP) |

## Le secret applicatif

- Généré par Terraform avec `ephemeral "random_password"` : la valeur n'existe qu'en mémoire pendant l'apply.
- Écrit dans Parameter Store (`/novasphere/<env>/app_secret`, SecureString) par l'argument write-only `value_wo` : Terraform l'envoie à AWS sans le garder.
- Lu au démarrage par l'instance (`aws ssm get-parameter --with-decryption`) grâce à son rôle, jamais écrit sur disque, effacé de la mémoire du script (`unset`).
- La page n'affiche qu'une empreinte de 8 caractères de son SHA-256.
- Rotation : passer `value_wo_version` à la valeur suivante dans `envs/<env>/secret.tf`.

## Où un secret pourrait fuir, et ce qu'on a fait

| Endroit | Mesure | Vérification |
|---------|--------|--------------|
| Code / historique Git | `.gitignore`, aucune valeur dans le dépôt | `git log --all -- '*.tfstate' '*.tfvars'` et `git grep` sur tout l'historique : vides |
| tfstate | `ephemeral` + `value_wo` : la valeur n'est jamais enregistrée | `SECRET=$(aws ssm get-parameter --name /novasphere/dev/app_secret --with-decryption --query Parameter.Value --output text); terraform -chdir=envs/dev state pull \| grep -c -F "$SECRET"; unset SECRET` → `0` |
| Plan et commentaires de PR | Le plan n'affiche pas la valeur d'un argument write-only | Relecture des commentaires de plan |
| user_data | Le script lit le secret, ne le contient pas | `aws ec2 describe-instance-attribute --attribute userData` puis décodage base64 |
| Page web | Empreinte seulement | `curl` sur l'ALB |
| Secrets GitHub | Aucune clé AWS dans GitHub : la CI utilise les credentials temporaires du lab présents sur le runner | Settings → Secrets : vide |
| Logs CI | Le secret ne passe ni par une variable ni par une sortie Terraform | Relecture des logs |

## Chaîne CI/CD

| Risque | Mesure |
|--------|--------|
| Code d'une PR exécuté sur la VM | Runner sous l'utilisateur `ghrunner` (sans sudo, dossier personnel en 700, credentials en 600) |
| PR malveillante venant d'un fork | Workflows refusés pour les forks (`if` dans le workflow) + approbation obligatoire des contributeurs externes |
| Droits trop larges du workflow | `permissions` minimales : `contents: read`, et `pull-requests: write` uniquement pour le workflow de PR |
| Merge sans relecture | `main` protégée : PR obligatoire, 1 approbation, checks `plan (dev)` et `plan (prod)` verts, pas de force push ni de suppression |
| Déploiement prod non contrôlé | Environnement `prod` : approbation d'un autre membre, branche `main` uniquement, pas de contournement administrateur |
| Version de module modifiée après coup | Tags `web-v*` protégés contre la modification et la suppression |
| Token GitHub trop puissant | Tokens personnels limités à `repo` et `workflow`, avec date d'expiration |

## Réseau et instances

- Security Group des instances : HTTP uniquement depuis le Security Group de l'ALB, pas de SSH.
- IMDSv2 exigé sur le Launch Template (`http_tokens = "required"`).
- Sortie des instances : 80 et 443 (paquets Debian, API Parameter Store) et 53 (DNS). La règle DNS est superflue, le résolveur du VPC n'étant pas filtré par les Security Groups : à retirer dans la prochaine version du module.

## Écarts assumés

- **Rôle des instances.** Les instances utilisent `LabInstanceProfile`, car AWS Academy interdit la création de rôles IAM. Ce rôle est trop large : une instance de dev pourrait lire le paramètre de prod. Hors Learner Lab, on créerait un rôle par environnement avec une seule autorisation :

  ```json
  {
    "Effect": "Allow",
    "Action": "ssm:GetParameter",
    "Resource": "arn:aws:ssm:us-east-1:<compte>:parameter/novasphere/<env>/*"
  }
  ```

- **Authentification de la CI.** Sans OIDC, la CI utilise les credentials temporaires du lab (valables environ 4 h), copiés sur le runner à chaque session. Hors Learner Lab, on utiliserait un fournisseur OIDC GitHub et un rôle par environnement, limité au dépôt (`repo:NKr77/TP-Terraform-AWS:*`) et, pour la prod, à l'environnement `prod`.
- **HTTP sans TLS.** Le lab n'a ni nom de domaine ni certificat : l'ALB écoute en HTTP. Hors lab : certificat ACM, écouteur HTTPS et redirection 80 → 443.
- **Renouvellement des instances.** `instance_refresh` est refusé par une SCP du lab. Les instances sont renouvelées en remplaçant l'ASG (voir `DECISIONS.md`, décision 7).
- **Plans publics.** Le dépôt est public (nécessaire pour protéger l'environnement `prod` sur un compte GitHub gratuit). Les plans publiés en commentaire montrent le numéro de compte AWS et les noms des ressources, mais aucun secret.
- **Détection de dérive.** Le job planifié ne s'exécute que si la VM du runner est allumée et les credentials du lab valides. Il est aussi lancé à la demande (`workflow_dispatch`).
