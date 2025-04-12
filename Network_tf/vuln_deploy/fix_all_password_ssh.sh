#!/bin/bash

KEY_PATH="/home/ubuntu/RL4Deception.pem"
SCRIPT_NAME="enable_password_login.sh"
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

HOSTS=(
  10.0.1.204  # Public Web 1
#   10.0.1.117  # Public Web 2
  10.0.2.87   # NTP
  10.0.2.226  # DB
  10.0.3.151  # Internal Web
  10.0.3.65   # PC1
  10.0.3.136  # PC2
  10.0.3.67   # PC3
)

# Ensure script exists
if [ ! -f "$SCRIPT_NAME" ]; then
  echo "❌ Cannot find $SCRIPT_NAME in this directory"
  exit 1
fi

for HOST in "${HOSTS[@]}"; do
  echo -e "\n🚀 Fixing password login on $HOST"

  LOGFILE="$LOG_DIR/ssh_fix_${HOST}.txt"

  # Step 1: Copy script
  echo "📤 Copying script..." | tee "$LOGFILE"
  scp -i "$KEY_PATH" -o StrictHostKeyChecking=no "$SCRIPT_NAME" ubuntu@"$HOST":/home/ubuntu/ >>"$LOGFILE" 2>&1 || {
    echo "❌ SCP failed for $HOST" | tee -a "$LOGFILE"
    continue
  }

  # Step 2: Execute it remotely
  echo "🔧 Executing script..." | tee -a "$LOGFILE"
  ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ubuntu@"$HOST" "chmod +x /home/ubuntu/$SCRIPT_NAME && sudo /home/ubuntu/$SCRIPT_NAME" >>"$LOGFILE" 2>&1 || {
    echo "❌ SSH execution failed on $HOST" | tee -a "$LOGFILE"
    continue
  }

  echo "✅ Fix completed for $HOST" | tee -a "$LOGFILE"
done

echo -e "\n📁 All logs saved in: $LOG_DIR"
