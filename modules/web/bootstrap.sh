#!/bin/bash
set -euo pipefail
apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y nginx awscli
rm -f /var/www/html/index.html /var/www/html/index.nginx-debian.html
SECRET="$(aws ssm get-parameter --region "${aws_region}" --name "${app_secret_parameter_name}" --with-decryption --query Parameter.Value --output text)"
test -n "$SECRET"
EMPREINTE="$(printf '%s' "$SECRET" | sha256sum | cut -c1-8)"; unset SECRET
echo "<h1>NovaSphere ${environment}</h1><p>Instance : $(hostname)</p><p>Secret lu depuis Parameter Store - empreinte : $EMPREINTE</p>" > /var/www/html/index.html
systemctl enable --now nginx
