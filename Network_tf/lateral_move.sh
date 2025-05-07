#!/usr/bin/env bash
#
# lateral_move.sh
# SSH from your local → PublicWeb1 → internal hosts as guest
#

KEY=~/RL4Deception.pem
PUB_HOST=3.144.10.220
GUEST_PW="guest123"

# Ensure sshpass is installed locally
command -v sshpass >/dev/null 2>&1 || {
  echo "❌ sshpass not installed locally. sudo apt install sshpass"
  exit 1
}

sshpass -p "" ssh -i "$KEY" \
  -o StrictHostKeyChecking=no \
  ubuntu@"$PUB_HOST" bash -s <<'EOF'
set -e
echo "✅ Logged into PublicWeb1 ($(hostname -I)) as ubuntu"

# Install sshpass on PublicWeb1 if missing
if ! command -v sshpass &>/dev/null; then
  echo "🔄 Installing sshpass on PublicWeb1..."
  sudo apt update -y
  sudo apt install -y sshpass >/dev/null
fi

# Define internal hosts
INTERNAL_HOSTS=(
  10.0.2.87
  10.0.2.226
  10.0.3.151
  10.0.3.65
  10.0.3.136
  10.0.3.67
)

for IP in "${INTERNAL_HOSTS[@]}"; do
  echo -e "\n➡️  SSH to $IP as guest"
  sshpass -p "$GUEST_PW" ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o PubkeyAuthentication=no \
    -o PreferredAuthentications=password \
    guest@"$IP" <<'INNER'
  echo "  ✅ Reached $(hostname) [$IP]"
  echo "     UID: $(id)"
  echo "     Uptime: $(uptime)"
  exit
INNER
done

echo -e "\n🎉 All internal hops complete!"
EOF
