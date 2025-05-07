#!/bin/bash
set -euo pipefail

KEY="/home/ubuntu/RL4Deception.pem"
USER="ubuntu"
HOSTS=(
  10.0.3.136
  10.0.3.151
  10.0.1.11
  10.0.2.226
  10.0.2.87
  10.0.1.204
  10.0.3.67
  10.0.4.206
  10.0.3.65
)

echo "🚀 Configuring & starting Zeek via systemd on all sensors…"
for ip in "${HOSTS[@]}"; do
  echo -e "\n🖥️  Host: $ip"

  ssh -i "$KEY" -o StrictHostKeyChecking=no "$USER@$ip" "\
    set -euo pipefail; \
    echo ' • Locating node.cfg…'; \
    CFG=\$(sudo find /etc/zeek -maxdepth 2 -type f -name node.cfg || :) ; \
    if [ -z \"\$CFG\" ]; then \
      echo '   ❌ node.cfg not found, skipping bind'; \
    else \
      echo \"   ✅ Found at \$CFG, binding to eth0…\"; \
      sudo sed -i 's!^interface=.*!interface=eth0!' \"\$CFG\"; \
    fi; \
    echo ' • Enabling Zeek service…'; \
    sudo systemctl enable zeek; \
    echo ' • Restarting Zeek service…'; \
    sudo systemctl restart zeek; \
    echo '--- Zeek service status ---'; \
    sudo systemctl status zeek --no-pager; \
    LOG=\"/var/lib/zeek/logs/current/conn.log\"; \
    if sudo test -s \"\$LOG\"; then \
      echo \" • ✅ conn.log data present at \$LOG\"; \
    else \
      echo \" • ⚠️  conn.log missing or empty at \$LOG\"; \
    fi"

  echo "✅ Done on $ip"
done

echo -e "\n🎉 Zeek configured & running on all hosts!"
