# NovaSphere — infrastructure dev / prod

Infrastructure de l'application NovaSphere sur AWS, décrite avec Terraform et
déployée sur GitHub. Deux environnements isolés (`dev`, `prod`) qui
partagent le code (modules versionnés), pas le state.

## Les trois points importants

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
modules/web           ALB, Launch Template, ASG, Security Groups (versionné par tag web-vX.Y.Z)
scripts/              outillage hors Terraform (création du bucket de state)
.github/workflows/    PR (plan), apply, dérive, destroy
```

## Déployer de zéro

### Prérequis

- Un Learner Lab AWS Academy démarré (région `us-east-1`).
- Une VM Linux avec Terraform ≥ 1.14, AWS CLI v2 et Git.
- Les droits d'administration sur le dépôt GitHub.

### 1. Credentials du lab

Copier les credentials affichés dans *AWS Details* du lab dans `~/.aws/credentials`, puis vérifier :

```bash
aws sts get-caller-identity
```

Ils changent à chaque session du lab (environ 4 h).

### 2. Bucket de state (une seule fois)

```bash
bash scripts/create_state_bucket.sh novasphere-tfstate-nkr
```

Le nom du bucket doit être celui de `envs/*/backend.tf`.

### 3. Runner GitHub Actions (une seule fois)

Le Learner Lab interdit OIDC (voir `SECURITE.md`). La CI tourne donc sur un runner
auto-hébergé installé sur la VM :

1. Créer l'utilisateur `ghrunner` (sans sudo).
2. *Settings → Actions → Runners → New self-hosted runner* : suivre les commandes
   en tant que `ghrunner`, ajouter le label `novasphere`, installer le service (`svc.sh install ghrunner`).

À **chaque session du lab**, recopier les credentials pour le runner :

```bash
sudo install -o ghrunner -g ghrunner -m 600 ~/.aws/credentials /home/ghrunner/.aws/credentials
sudo -u ghrunner -H aws sts get-caller-identity
```

### 4. Réglages GitHub (une seule fois)

- **Environnements** : `dev` sans règle ; `prod` avec *Required reviewers* (un autre membre),
  *Prevent self-review*, branche `main` uniquement, sans contournement administrateur.
- **Ruleset sur `main`** : pull request obligatoire, 1 approbation, checks `plan (dev)` et `plan (prod)` obligatoires.
- **Ruleset sur les tags `web-v*`** : modification et suppression interdites.

### 5. Déployer

Par la chaîne normale : une pull request, le plan en commentaire, la review, le merge.
Le merge sur `main` déploie dev, puis prod après approbation.

Sans nouveau commit (par exemple après un destroy) : *Actions → Terraform Apply → Run workflow* sur `main`.

L'URL de chaque environnement est affichée sur le job d'apply. La page donne
l'environnement, le nom de l'instance et l'empreinte du secret lu dans Parameter Store.

### 6. Détruire en fin de session

*Actions → Terraform Destroy → Run workflow*, choisir l'environnement et retaper son nom.
La destruction de prod demande la même approbation que son déploiement.

## Publier une nouvelle version du module web

1. PR sur `modules/web`, review, merge.
2. Tag sur le commit de merge : `git tag -a web-vX.Y.Z -m "..." && git push origin web-vX.Y.Z`
   (version majeure si une variable obligatoire est ajoutée).
3. PR qui change le `ref` dans `envs/dev/web.tf`, puis, une fois dev validé, dans `envs/prod/web.tf`.

## Tester dans son propre lab

Chaque membre peut tester une branche dans son Learner Lab, avec son propre bucket,
sans toucher au state de l'équipe :

```bash
terraform -chdir=envs/dev init -reconfigure -backend-config="bucket=novasphere-tfstate-<initiales>"
```

Ne jamais commiter de changement de `backend.tf` ou de source de module fait pour un test.
