#!/bin/bash
set -e

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx awscli

rm -f /var/www/html/index.html /var/www/html/index.nginx-debian.html

APP_SECRET="$(aws ssm get-parameter \
  --region "${aws_region}" \
  --name "${app_secret_parameter_name}" \
  --with-decryption \
  --query 'Parameter.Value' \
  --output text)"

test -n "$APP_SECRET"
unset APP_SECRET

echo "<h1>NovaSphere</h1><p>Instance : $(hostname)</p><p>Deploiement automatise avec Terraform - v3</p><p>Secret charge depuis Parameter Store</p>" > /var/www/html/index.html

systemctl enable --now nginx
