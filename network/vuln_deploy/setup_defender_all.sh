#!/bin/bash

KEY_PATH="$HOME/.ssh/user_key"
COWRIE_SCRIPT="deploy_cowrie.sh"
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

HOSTS=(
  10.0.1.204
  10.0.2.87
  10.0.2.226
  10.0.3.151
  10.0.3.65
  10.0.3.136
  10.0.3.67
)

# Check key file
if [ ! -f "$KEY_PATH" ]; then
  echo "❌ SSH key not found: $KEY_PATH"
  exit 1
fi

# Check Cowrie script
if [ ! -f "$COWRIE_SCRIPT" ]; then
  echo "❌ Missing $COWRIE_SCRIPT"
  exit 1
fi

for HOST in "${HOSTS[@]}"; do
  LOGFILE="$LOG_DIR/setup_log_$HOST.txt"
  echo -e "\n🚀 Setting up Cowrie on $HOST" | tee "$LOGFILE"

  echo "📤 Copying Cowrie script..." | tee -a "$LOGFILE"
  scp -i "$KEY_PATH" -o StrictHostKeyChecking=no "$COWRIE_SCRIPT" user@"$HOST":~/ 2>>"$LOGFILE" || {
    echo "❌ SCP failed on $HOST" | tee -a "$LOGFILE"
    continue
  }

  echo "🐍 Installing Cowrie..." | tee -a "$LOGFILE"
  ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no user@"$HOST" bash -s <<'EOF' | tee -a "$LOGFILE"
    set -e
    if [ -d "$HOME/cowrie" ]; then
      echo "🟡 Cowrie already appears installed — skipping"
      exit 0
    fi
    bash ~/deploy_cowrie.sh
EOF

  echo "✅ Finished $HOST" | tee -a "$LOGFILE"
done

echo -e "\n📁 Logs saved in: $LOG_DIR"
