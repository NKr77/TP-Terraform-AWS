#!/usr/bin/env bash
# Crée le bucket S3 du state Terraform (une seule fois, hors Terraform :
# le bucket qui stocke le state ne peut pas être géré par ce même state).
# Usage : bash scripts/create_state_bucket.sh <nom-du-bucket>
set -euo pipefail
export AWS_PAGER=""
BUCKET="${1:?Usage: $0 <nom-du-bucket>}"
REGION=us-east-1

if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  echo "Bucket $BUCKET déjà présent : on vérifie seulement sa configuration."
else
  aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"
fi
aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "OK : $BUCKET (versionné, chiffré, accès public bloqué)"
