#!/bin/bash
# =====================================
# deploy_internal_vuln.sh
# Target: DB, InternalWeb, NTP, PC1–PC3
# =====================================

KEY_PATH="/home/ubuntu/RL4Deception.pem"
USER="ubuntu"

HOSTS=(
  10.0.2.226   # DB
  10.0.3.151   # InternalWeb
  10.0.2.87    # NTP
  10.0.3.65    # PC1
  10.0.3.136   # PC2
  10.0.3.67    # PC3
)

for HOST in "${HOSTS[@]}"; do
  echo -e "\n🔥 Deploying internal vulns on $HOST"

  ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no $USER@$HOST bash -s <<EOF
    set -e
    HOST_IP="$HOST"

    echo "👤 Creating user 'guest' with weak password"
    if ! id guest &>/dev/null; then
      sudo useradd -m guest
      echo "guest:guest123" | sudo chpasswd
    else
      echo "User 'guest' already exists. Skipping creation."
    fi

    echo "⚠️ Enabling sudo with no password for guest"
    SUDOERS_FILE="/etc/sudoers.d/guest"
    if [ ! -f "\$SUDOERS_FILE" ]; then
      echo "guest ALL=(ALL) NOPASSWD:ALL" | sudo tee "\$SUDOERS_FILE"
    fi

    echo "🧨 Privilege escalation: setting SUID on bash & find"
    sudo chmod u+s /bin/bash
    sudo chmod u+s /usr/bin/find

    echo "⏰ Setting up cronjob exploit (DB only)"
    if [ "\$HOST_IP" = "10.0.2.226" ]; then
      CRON_FILE="/etc/cron.d/hackedjob"
      if [ ! -f "\$CRON_FILE" ]; then
        echo "🔧 Creating cronjob in \$CRON_FILE"
        sudo bash -c 'cat > /etc/cron.d/hackedjob' <<'EOF_CRON'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

* * * * * root echo hacked > /tmp/cron_pwned
EOF_CRON
        sudo chmod 644 "\$CRON_FILE"
        sudo service cron restart
      else
        echo "🔁 Cronjob already exists, skipping."
      fi
    fi

    echo "✅ Vulnerability deployed on \$(hostname)"
EOF

done
