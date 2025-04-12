#!/bin/bash

KEY=~/.ssh/user_key
HOSTS=(
  10.0.1.204
  10.0.2.87
  10.0.2.226
  10.0.3.151
  10.0.3.65
  10.0.3.136
  10.0.3.67
)

for ip in "${HOSTS[@]}"; do
  echo "🔍 Verifying Cowrie on $ip..."
  ssh -i "$KEY" -o StrictHostKeyChecking=no user@$ip '
    if pgrep -f "cowrie" > /dev/null; then
      echo "✅ Cowrie is running"
    else
      echo "❌ Cowrie is NOT running"
    fi
  '
done
