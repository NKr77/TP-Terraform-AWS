#!/bin/bash
apt-get update -y && apt-get install -y nginx
echo "<h1>NovaSphere</h1><p>$(hostname)</p>" > /var/www/html/index.html
systemctl enable --now nginx
