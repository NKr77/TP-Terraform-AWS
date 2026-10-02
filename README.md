# NovaSphere — infrastructure dev / prod

Infrastructure de l'application NovaSphere sur AWS, décrite avec Terraform et
déployée sur GitHub. Deux environnements isolés (`dev`, `prod`) qui
partagent le code (modules versionnés), pas le state.

## Les points trois importants

1. **Backend partagé dès le premier commit.** Le state de chaque environnement
   vit dans le bucket S3 de l'équipe, avec verrouillage natif (`use_lockfile`).
   Personne ne garde de `terraform.tfstate` local.
2. **Aucun secret nulle part.** Ni dans le code, ni dans le tfstate, ni dans
   `user_data`, ni dans l'historique Git, ni dans les logs de CI. Le secret
   applicatif vit uniquement dans Parameter Store et seule l'instance le lit.
3. **Tout passe par la chaîne.** Pull request → plan en commentaire → merge →
   apply par la CI → page servie par l'ALB. Aucun `apply` manuel sur dev ou prod.

## Arborescence

```
envs/dev, envs/prod   un répertoire = un environnement = un state
modules/              modules NovaSphere (versionnés par tag Git)
scripts/              outillage hors Terraform (création du bucket de state)
docs/                 schéma d'architecture, reste-à-faire signé
.github/workflows/    pipelines PR / apply / dérive
```

## Déployer de zéro

> Section complétée au fil du projet.

1. Démarrer le Learner Lab, coller les credentials dans `~/.aws/credentials`.
2. Créer le bucket de state (une seule fois) :
   `bash scripts/create_state_bucket.sh novasphere-tfstate-nkr`
3. `cd envs/dev && terraform init && terraform plan`
