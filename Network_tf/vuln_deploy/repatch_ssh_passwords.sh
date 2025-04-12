#!/bin/bash

KEY_PATH="/home/ubuntu/RL4Deception.pem"
declare -A PASSWORDS=(
  [10.0.1.204]="Z}A9u;5T5M3."
  [10.0.2.87]="Z}A9u;5T5M3."
  [10.0.2.226]="impatricka"
  [10.0.3.151]="password"
  [10.0.3.65]="password"
  [10.0.3.136]="password"
  [10.0.3.67]="password"
)

HOSTS=(
  10.0.1.204
  10.0.2.87
  10.0.2.226
  10.0.3.151
  10.0.3.65
  10.0.3.136
  10.0.3.67
)

for HOST in "${HOSTS[@]}"; do
  PASSWORD="${PASSWORDS[$HOST]}"
  echo -e "\n🔧 Deep repairing SSH on $HOST..."

  ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@"$HOST" bash -s <<EOF
    set -e
    echo "👤 Rebuilding user"
    sudo useradd -m -s /bin/bash user 2>/dev/null || echo "user already exists"
    echo "user:$PASSWORD" | sudo chpasswd
    sudo mkdir -p /home/user
    sudo chown -R user:user /home/user

    echo "🔧 Rewriting sshd_config"
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    sudo awk '
      BEGIN { skip = 0 }
      /^Match/ { skip = 1; next }
      skip && /^$/ { skip = 0; next }
      skip { next }
      /^PasswordAuthentication/ { print "PasswordAuthentication yes"; next }
      /^UsePAM/ { print "UsePAM yes"; next }
      /^ChallengeResponseAuthentication/ { print "ChallengeResponseAuthentication no"; next }
      { print }
      END {
        print "PasswordAuthentication yes"
        print "UsePAM yes"
        print "ChallengeResponseAuthentication no"
      }
    ' /etc/ssh/sshd_config | sudo tee /etc/ssh/sshd_config.fixed >/dev/null
    sudo mv /etc/ssh/sshd_config.fixed /etc/ssh/sshd_config

    echo "🔁 Restarting ssh"
    sudo systemctl restart ssh
EOF

  echo "🔍 Verifying sshpass login to $HOST"
  sshpass -p "$PASSWORD" ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no -o StrictHostKeyChecking=no -o ConnectTimeout=5 user@"$HOST" "echo ✅ $HOST login success" \
    || echo "❌ sshpass login FAILED for $HOST"
done
