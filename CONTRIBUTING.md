# Conventions d'équipe

1. Une branche par changement (`feat/...`, `fix/...`), jamais de commit direct sur `main`.
2. Toute pull request est relue par un autre membre avant merge.
3. Le plan Terraform (commenté par la CI) est lu intégralement avant d'approuver.
4. Jamais commités : `*.tfstate*`, `*.tfvars`, `*.pem`, `.env`, credentials. Le `.gitignore` ne se modifie jamais à la baisse.
5. `git grep` sur toute valeur sensible avant chaque push.
6. On ne lève jamais un verrou (`force-unlock`) sans avoir demandé à l'équipe.
7. Les modules se versionnent par tag `vX.Y.Z` ; dev reçoit la nouvelle version avant prod.
8. Fins de ligne LF uniquement (`.gitattributes`).
9. Rien ne tourne entre deux sessions : `destroy` (via la CI) en fin de session.
10. Tag de gel du rendu : `v1.0.0-rendu`.
