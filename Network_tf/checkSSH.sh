#!/bin/bash

KEY=/home/ubuntu/RL4Deception.pem
USER=ubuntu
HOSTFILE=hosts.txt

# Read IPs into an array
mapfile -t HOSTS < <(awk '{print $1}' "$HOSTFILE" | grep -v '^#' | grep -v '^$')

echo -e "\n📡 Verifying SSH connectivity to all hosts as '$USER'...\n"
printf "%-15s %-10s\n" "IP Address" "Status"
printf "%-15s %-10s\n" "----------" "------"

for ip in "${HOSTS[@]}"; do
  ssh -i "$KEY" -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USER@$ip" 'echo OK' &>/dev/null
  if [ $? -eq 0 ]; then
    printf "%-15s ✅\n" "$ip"
  else
    printf "%-15s ❌\n" "$ip"
  fi
done
