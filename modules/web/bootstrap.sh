#!/bin/bash
apt-get update -y && apt-get install -y nginx
echo "<h1>NovaSphere</h1><p>Instance : $(hostname)</p><p>Deploiement automatise avec Terraform</p>" > /var/www/html/index.html
systemctl enable --now nginx
