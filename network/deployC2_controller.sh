#!/bin/bash

# =============================
# CONFIGURATION
# =============================
KEY_PATH="/home/ubuntu/RL4Deception.pem"
C2_CODE_PATH="/home/ubuntu/Daedalus/c2"
REMOTE_DIR="~"
USER="ubuntu"

HOSTS=(
  10.0.2.226   # DB
  10.0.3.151   # InternalWeb
  10.0.2.87    # NTP
  10.0.3.65    # PC1
  10.0.3.136   # PC2
  10.0.3.67    # PC3
)

# =============================
# START DEPLOYMENT
# =============================
echo "🚀 Starting deployment"
echo "🔑 SSH Key: $KEY_PATH"
echo "📁 C2 code path: $C2_CODE_PATH"
echo "📁 Remote path: $REMOTE_DIR"

# Check if key exists
if [[ ! -f "$KEY_PATH" ]]; then
  echo "❌ ERROR: SSH key not found at $KEY_PATH"
  exit 1
fi

# Check if code directory exists
if [[ ! -d "$C2_CODE_PATH" ]]; then
  echo "❌ ERROR: C2 code directory not found at $C2_CODE_PATH"
  exit 1
fi

# =============================
# PER-HOST DEPLOY LOOP
# =============================
for HOST in "${HOSTS[@]}"; do
  echo -e "\n🧭 Deploying to $HOST..."

  echo "🔄 Copying code to $HOST..."
  scp -i "$KEY_PATH" -o StrictHostKeyChecking=no -r "$C2_CODE_PATH" "$USER@$HOST:$REMOTE_DIR"
  if [[ $? -ne 0 ]]; then
    echo "❌ SCP failed for $HOST"
    continue
  fi

  echo "⚙️  Setting up environment on $HOST..."
  ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no "$USER@$HOST" bash -s <<'EOF'
    set -e
    echo "🖥️ Connected to $(hostname)"
    echo "📦 Updating packages and installing venv..."
    sudo apt update -y
    sudo apt install -y python3-venv

    echo "🐍 Creating virtual environment..."
    python3 -m venv ~/venv
    source ~/venv/bin/activate

    echo "📦 Installing Python dependencies..."
    pip install grpcio protobuf inotify

    echo "✅ Setup complete on $(hostname)"
EOF

  if [[ $? -eq 0 ]]; then
    echo "✅ Deployment successful on $HOST"
  else
    echo "❌ Deployment failed on $HOST"
  fi
done

# =============================
# DONE
# =============================
echo -e "\n🎉 All deployments attempted!"
