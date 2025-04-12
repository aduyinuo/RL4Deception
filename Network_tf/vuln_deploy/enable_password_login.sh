#!/bin/bash

echo "🔧 Fixing SSH config on $(hostname)"
SSHD_CONF="/etc/ssh/sshd_config"
TMP_CONF="/tmp/sshd_config.fixed"

# Step 1: Clean up sshd_config
echo "📄 Backing up sshd_config..."
sudo cp "$SSHD_CONF" "${SSHD_CONF}.bak.$(date +%s)"

echo "✏️ Rewriting sshd_config..."
sudo awk '
  BEGIN { skip = 0 }
  # Start of Match block that could override our settings
  /^Match/ { skip = 1; next }
  # If currently skipping, skip until a blank line
  skip && /^$/ { skip = 0; next }
  skip { next }

  # Replace or ensure correct global settings
  /^PasswordAuthentication/ { print "PasswordAuthentication yes"; next }
  /^ChallengeResponseAuthentication/ { print "ChallengeResponseAuthentication no"; next }
  /^UsePAM/ { print "UsePAM yes"; next }

  # Keep other lines as is
  { print }

  END {
    print "PasswordAuthentication yes"
    print "ChallengeResponseAuthentication no"
    print "UsePAM yes"
  }
' "$SSHD_CONF" | sudo tee "$TMP_CONF" >/dev/null

# Step 2: Apply fixed config
sudo mv "$TMP_CONF" "$SSHD_CONF"
echo "✅ Applied cleaned sshd_config"

# Step 3: Restart SSH
echo "🔄 Restarting SSH..."
sudo systemctl restart ssh

# Step 4: Confirm
echo "🔍 Current SSH login settings:"
sudo grep -Ei 'PasswordAuthentication|ChallengeResponseAuthentication|UsePAM|Match' "$SSHD_CONF"
