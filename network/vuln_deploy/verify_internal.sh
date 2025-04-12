#!/bin/bash
# =====================================
# verify_internal_vuln.sh
# Checks internal host vulnerabilities
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
  echo -e "\n🔍 Verifying $HOST"

  ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no $USER@$HOST bash -s <<'EOF'
    echo "🔐 Checking guest user..."
    id guest &>/dev/null && echo "✅ guest user exists" || echo "❌ guest user missing"

    echo "🛡️  Checking sudoers config..."
    sudo grep -q "guest ALL=(ALL) NOPASSWD:ALL" /etc/sudoers.d/guest && echo "✅ guest sudo rule present" || echo "❌ sudo rule missing"

    echo "🧨 Checking SUID bits on bash and find..."
    [[ -u /bin/bash && -u /usr/bin/find ]] && echo "✅ SUID bits set on bash and find" || echo "❌ SUID missing on bash or find"

    echo "⏰ Checking cronjob on DB (if applicable)..."
    if [ "$HOST" = "10.0.2.226" ]; then
      if sudo test -f /tmp/cron_pwned; then
        echo "✅ Cronjob successfully wrote to /tmp/cron_pwned"
        sudo cat /tmp/cron_pwned
      else
        echo "⚠️ Cronjob not triggered yet or failed"
      fi
    else
      echo "(not a DB node, skipping cron check)"
    fi
EOF

done
