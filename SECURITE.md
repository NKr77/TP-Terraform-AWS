# Registre de sécurité

## Contraintes AWS Academy (constatées le 02/10/2026)

| Test | Résultat |
|------|----------|
| Création d'un fournisseur OIDC | Refusé |
| Création d'un rôle IAM | Refusé |
| `LabRole` / `LabInstanceProfile` | Disponibles |
| Écriture SecureString (Parameter Store) | Autorisé |
| `autoscaling:StartInstanceRefresh` | Refusé par une Service Control Policy (SCP) |

## Où un secret pourrait fuir, et ce qu'on a fait

| Endroit | Mesure | Vérification |
|---------|--------|--------------|
| Code / historique Git | `.gitignore`, aucune valeur dans le dépôt | `git log -p \| grep <valeur>` vide |
| tfstate | À compléter (étape 4) | `terraform state pull \| grep` vide |
| user_data | Le script lit le secret, ne le contient pas | `describe-instance-attribute` |
| Logs CI | À compléter (étape 5) | Relecture des logs |

## Écarts assumés

- Les instances EC2 utilisent `LabInstanceProfile` car AWS Academy interdit la création de rôles IAM dédiés.
- Le renouvellement automatique des instances avec `instance_refresh` n'est pas utilisé car l'action `autoscaling:StartInstanceRefresh` est explicitement refusée par une Service Control Policy (SCP) du Learner Lab.
- Le Launch Template référence néanmoins explicitement sa dernière version. Une méthode compatible avec les permissions du lab sera utilisée pour renouveler les instances lors des changements nécessitant un redéploiement.
- L'authentification de la CI reste à compléter en tenant compte de l'impossibilité de créer un fournisseur OIDC et un rôle IAM dédié.
