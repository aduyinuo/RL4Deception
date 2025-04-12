#!/bin/bash
# =====================================
# deploy_wordpress_vuln.sh
# Target: PublicWeb1 and PublicWeb2
# =====================================

KEY_PATH="/home/ubuntu/RL4Deception.pem"
USER="ubuntu"

HOSTS=(
  3.145.63.77     # PublicWeb1
  18.119.125.179  # PublicWeb2
)

for HOST in "${HOSTS[@]}"; do
  echo "\n🚀 Setting up WordPress + Vulnerabilities on $HOST"

  ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no $USER@$HOST bash -s <<EOF
    set -e
    PLUGIN_URL="https://downloads.wordpress.org/plugin/backup-backup.1.3.7.zip"
    REMOTE_TMP="/tmp/backup-backup.1.3.7.zip"

    echo "📦 Installing Apache, PHP, MySQL"
    sudo apt update -y
    sudo apt install -y apache2 php php-mysql libapache2-mod-php mysql-server unzip wget

    echo "🌀 Downloading and extracting WordPress"
    wget -q https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz
    tar -xzf /tmp/wp.tar.gz -C /tmp
    sudo rsync -av /tmp/wordpress/ /var/www/html/
    sudo chown -R www-data:www-data /var/www/html
    sudo chmod -R 755 /var/www/html

    echo "🔐 Configuring MySQL"
    sudo service mysql start
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS wordpress;"
    sudo mysql -e "CREATE USER IF NOT EXISTS 'wpuser'@'localhost' IDENTIFIED BY 'wp_pass';" || true
    sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';"
    sudo mysql -e "FLUSH PRIVILEGES;"

    echo "⚙️ Setting up wp-config"
    sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    sudo sed -i "s/database_name_here/wordpress/" /var/www/html/wp-config.php
    sudo sed -i "s/username_here/wpuser/" /var/www/html/wp-config.php
    sudo sed -i "s/password_here/wp_pass/" /var/www/html/wp-config.php
    sudo chown www-data:www-data /var/www/html/wp-config.php

    echo "🧩 Downloading vulnerable plugin"
    wget -q "\$PLUGIN_URL" -O "\$REMOTE_TMP"
    unzip -q "\$REMOTE_TMP" -d /tmp/plugin/
    sudo mv /tmp/plugin/backup-backup /var/www/html/wp-content/plugins/
    sudo chown -R www-data:www-data /var/www/html/wp-content/plugins/

    echo "🔓 Enabling privilege escalation via find"
    sudo chmod u+s /usr/bin/find

    echo "✅ WordPress + vulnerability deployed on \$(hostname)"
EOF

done