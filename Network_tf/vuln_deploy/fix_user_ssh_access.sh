#!/bin/bash

KEY_PATH="/home/ubuntu/RL4Deception.pem"
declare -A PASSWORDS=(
  [10.0.1.204]="Z}A9u;5T5M3."
#   [10.0.1.117]="Z}A9u;5T5M3."
  [10.0.2.87]="Z}A9u;5T5M3."
  [10.0.2.226]="impatricka"
  [10.0.3.151]="password"
  [10.0.3.65]="password"
  [10.0.3.136]="password"
  [10.0.3.67]="password"
)

HOSTS=(
  10.0.1.204
  10.0.1.117
  10.0.2.87
  10.0.2.226
  10.0.3.151
  10.0.3.65
  10.0.3.136
  10.0.3.67
)

for HOST in "${HOSTS[@]}"; do
  PASSWORD="${PASSWORDS[$HOST]}"
  echo -e "\n🔧 Fixing SSH access for user@${HOST}"

  ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@"$HOST" bash -s <<EOF
    set -e

    echo "👤 Ensuring 'user' exists with correct password"
    if ! id user &>/dev/null; then
      sudo useradd -m -s /bin/bash user
    fi
    echo "user:$PASSWORD" | sudo chpasswd

    echo "🔐 Enabling password login in sshd_config"
    sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#\?UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config

    echo "🔄 Restarting SSH"
    sudo systemctl restart ssh
EOF

  echo "🔍 Testing sshpass login for user@$HOST ..."
  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@"$HOST" "echo ✅ sshpass login succeeded" \
    || echo "❌ sshpass login FAILED for user@$HOST"
done
