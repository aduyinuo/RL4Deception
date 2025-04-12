#!/bin/bash

KEY_PATH=~/.ssh/RL4Deception.pem
C2_CODE_PATH="Daedalus/"
REMOTE_DIR="~"
HOSTS=(
  3.148.118.121     # Controller
  3.145.63.77       # PublicWeb1
  18.119.125.179    # PublicWeb2
  # Add private IPs of internal nodes if reachable from controller
)

for HOST in "${HOSTS[@]}"; do
  echo "🚀 Deploying to $HOST..."

  scp -i "$KEY_PATH" -r "$C2_CODE_PATH" ubuntu@"$HOST":"$REMOTE_DIR"

  ssh -i "$KEY_PATH" ubuntu@"$HOST" bash -s <<EOF
    sudo apt update -y
    sudo apt install -y python3-venv

    python3 -m venv ~/venv
    source ~/venv/bin/activate

    pip install grpcio protobuf inotify
    echo "✅ Done on $HOST"
EOF

done

echo "🎉 Deployment complete!"
