# Registre de sécurité

## Contraintes AWS Academy (constatées le 02/10/2026)

| Test | Résultat |
|------|----------|
| Création d'un fournisseur OIDC | Refusé |
| Création d'un rôle IAM | Refusé |
| `LabRole` / `LabInstanceProfile` | Disponibles |
| Écriture SecureString (Parameter Store) | Autorisé |

## Où un secret pourrait fuir, et ce qu'on a fait

| Endroit | Mesure | Vérification |
|---------|--------|--------------|
| Code / historique Git | `.gitignore`, aucune valeur dans le dépôt | `git log -p \| grep <valeur>` vide |
| tfstate | À compléter (étape 4) | `terraform state pull \| grep` vide |
| user_data | Le script lit le secret, ne le contient pas | `describe-instance-attribute` |
| Logs CI | À compléter (étape 5) | Relecture des logs |

## Écarts assumés

> À compléter (rôle d'instance, authentification de la CI).
