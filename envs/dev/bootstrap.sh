#!/bin/bash
set -e

dnf install -y nginx

cat > /usr/share/nginx/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>NovaSphere DEV</title>
</head>
<body>
    <h1>Bienvenue sur NovaSphere</h1>
    <p>Environnement : DEV</p>
    <p>Serveur web nginx sur AWS EC2</p>
</body>
</html>
EOF

systemctl enable nginx
systemctl start nginx
