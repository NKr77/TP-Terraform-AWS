# Architecture NovaSphere

Deux environnements isolés, `dev` et `prod`, de structure identique. Ils partagent le code
(module `web` versionné par tag), pas le state. Tout changement passe par la chaîne GitHub Actions.

```mermaid
flowchart TB
  subgraph GH["GitHub : NKr77/TP-Terraform-AWS"]
    PR["Pull request<br/>plan dev + plan prod en commentaire"] --> MAIN["main protégée<br/>merge après review"]
    MAIN --> ENVP["Environnement prod<br/>approbation d'un membre"]
  end
  RUN["Runner auto-hébergé<br/>VM esgidebian, utilisateur ghrunner"]
  PR -. plan .-> RUN
  MAIN -- apply dev --> RUN
  ENVP -- apply prod --> RUN
  subgraph AWS["Compte AWS Academy : us-east-1"]
    S3[("S3 novasphere-tfstate-nkr<br/>un state par environnement<br/>verrou use_lockfile")]
    SSM[("Parameter Store<br/>/novasphere/ENV/app_secret")]
    subgraph DEV["VPC dev 10.0.0.0/16, 2 AZ"]
      ALBD["ALB dev, HTTP 80"] --> ASGD["ASG dev<br/>2 instances nginx, IMDSv2"]
    end
    subgraph PROD["VPC prod 10.1.0.0/16, 2 AZ"]
      ALBP["ALB prod, HTTP 80"] --> ASGP["ASG prod<br/>2 instances nginx, IMDSv2"]
    end
  end
  RUN --> S3
  RUN -. terraform apply .-> DEV
  RUN -. terraform apply .-> PROD
  ASGD -. lecture au démarrage .-> SSM
  ASGP -. lecture au démarrage .-> SSM
  U(("Utilisateur")) --> ALBD
  U --> ALBP
```

## Composants

| Brique | Réalisation |
|--------|-------------|
| Réseau | Module du registre `terraform-aws-modules/vpc/aws` (~> 6.0), 2 subnets publics sur 2 AZ, sans NAT Gateway |
| Application | Module `modules/web` (tag `web-v2.0.0`) : ALB, target group, Launch Template, ASG, Security Groups |
| Instances | Debian 12 (AMI figée), nginx installé par un amorçage de 9 lignes, IMDSv2 exigé, pas de SSH |
| Secret | `ephemeral random_password` écrit avec `value_wo` dans Parameter Store, lu par l'instance via son rôle |
| State | Bucket S3 versionné et chiffré, une clé par environnement, verrou natif `use_lockfile` |
| CI/CD | Workflows PR (plan en commentaire), Apply (dev au merge, prod après approbation), Drift, Destroy |

## Plan d'adressage

| Élément | dev | prod |
|---------|-----|------|
| VPC | 10.0.0.0/16 | 10.1.0.0/16 |
| Subnet us-east-1a | 10.0.1.0/24 | 10.1.1.0/24 |
| Subnet us-east-1b | 10.0.2.0/24 | 10.1.2.0/24 |
| ASG | min 2, max 4, souhaité 2 | min 2, max 4, souhaité 2 |
| Secret | `/novasphere/dev/app_secret` | `/novasphere/prod/app_secret` |
| State | `novasphere/dev/terraform.tfstate` | `novasphere/prod/terraform.tfstate` |

## Flux réseau

Internet → ALB (80) → instances (80, uniquement depuis le Security Group de l'ALB).
Sortie des instances : 80 et 443 (paquets Debian, API Parameter Store).

Le détail de nos choix est dans `DECISIONS.md`, les risques et les écarts assumés dans `SECURITE.md`.
