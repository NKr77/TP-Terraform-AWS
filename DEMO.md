# Démonstration (8 minutes)

## La veille ou 30 minutes avant

1. Lab démarré, credentials copiés pour soi et pour le runner (`README.md`, étape 3).
2. *Actions → Terraform Apply → Run workflow* sur `main` ; un membre approuve prod.
3. Vérifier que les deux URL répondent (dev et prod).
4. Préparer la PR de démo depuis `main` : branche `demo/scale-dev`, `asg_desired_capacity = 3`
   dans `envs/dev/web.tf`. Ouvrir la PR et attendre le commentaire de plan.

## Déroulé

| Temps | Ce qu'on montre |
|-------|-----------------|
| 0:00 – 1:00 | Le schéma : 2 environnements, VPC sur 2 AZ, ALB, ASG, Parameter Store, CI sur runner |
| 1:00 – 2:30 | La PR : le diff (une ligne), le plan lu à voix haute : `~ desired_capacity = 2 -> 3`, `1 to change`, prod `No changes` |
| 2:30 – 3:00 | Review d'un membre, merge |
| 3:00 – 5:30 | Le run *Terraform Apply* : `apply (dev)` en direct, puis `apply (prod)` qui attend une approbation |
| 5:30 – 7:00 | La page dev : en rafraîchissant, trois noms d'instance, la même empreinte du secret |
| 7:00 – 8:00 | La page prod, et le paramètre dans Parameter Store (type SecureString, valeur jamais affichée) |

## Questions probables, réponses prêtes

- **« Cherchez le mot de passe dans le tfstate. »** Commande de vérification de `SECURITE.md` : résultat `0`.
- **« Changez `instance_type` : que propose le plan ? »** Nouvelle version du Launch Template, donc un nouvel ASG créé avant la suppression de l'ancien (décision 7).
- **« Changez le CIDR du VPC. »** Remplacement du VPC, donc de tout ce qui est dedans : on ne le fait pas sur un environnement en service.
- **« Votre apply échoue avec `ExpiredToken`. »** Credentials du lab expirés sur le runner : les recopier, puis *Re-run failed jobs*.
- **« Error acquiring the state lock. »** Un autre job ou un membre utilise le state : attendre (`-lock-timeout=5m`), jamais de `force-unlock` sans demander.
