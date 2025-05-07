#!/bin/bash
set -euo pipefail

KEY="/home/ubuntu/RL4Deception.pem"
USER="ubuntu"
HOSTS=(
  10.0.3.136
  10.0.3.151
  10.0.1.11
  10.0.2.226
  10.0.2.87
  10.0.1.204
  10.0.3.67
  10.0.4.206
  10.0.3.65
)

echo "🚀 Deploying Zeek to all sensor hosts…"
for ip in "${HOSTS[@]}"; do
  echo -e "\n🖥️  Host: $ip"

  ssh -i "$KEY" -o StrictHostKeyChecking=no "$USER@$ip" \
    "set -euo pipefail;
     echo ' • Installing prerequisites…';
     sudo apt-get update -y;
     sudo apt-get install -y wget gnupg;
     echo ' • Adding Zeek repo key…';
     wget -qO- https://download.opensuse.org/repositories/network:zeek:release:4/xUbuntu_24.04/Release.key \
       | sudo tee /usr/share/keyrings/zeek-archive-keyring.gpg > /dev/null;
     echo ' • Adding Zeek repo…';
     echo \"deb [signed-by=/usr/share/keyrings/zeek-archive-keyring.gpg] https://download.opensuse.org/repositories/network:/zeek:/release:4/xUbuntu_24.04/ /\" \
       | sudo tee /etc/apt/sources.list.d/zeek.list > /dev/null;
     echo ' • Updating package lists…';
     sudo apt-get update -y;
     echo ' • Installing Zeek…';
     sudo apt-get install -y zeek;
     echo ' • Configuring Zeek for eth0…';
     if [ -f /etc/zeek/node.cfg ]; then
       sudo sed -i 's!^interface=.*!interface=eth0!' /etc/zeek/node.cfg;
     else
       sudo sed -i 's!^interface=.*!interface=eth0!' /usr/local/zeek/etc/node.cfg;
     fi;
     echo ' • Deploying Zeek…';
     sudo zeekctl deploy;
     ip_addr=\$(hostname -I | cut -d' ' -f1);
     echo \"✅ Zeek is up on \$ip_addr\";"

  echo "✅ Completed on $ip"
done

echo -e "\n🎉 Zeek deployment finished across all sensors!"
