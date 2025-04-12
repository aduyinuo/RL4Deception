#!/bin/bash

echo "🐍 Installing Cowrie honeypot for user: $(whoami)"

# Exit early if already installed
if [ -d "$HOME/cowrie" ]; then
  echo "🟡 Cowrie already appears installed — skipping"
  exit 0
fi

set -e

# Update and install dependencies
echo "📦 Installing required packages..."
sudo apt-get update -y
sudo apt-get install -y python3-venv git build-essential libssl-dev libffi-dev libpython3-dev

# Clone Cowrie
echo "📥 Cloning Cowrie..."
git clone https://github.com/cowrie/cowrie.git ~/cowrie
cd ~/cowrie

# Set up virtual environment
echo "🐍 Creating Python venv..."
python3 -m venv cowrie-env
source cowrie-env/bin/activate

# Upgrade pip and install requirements
pip install --upgrade pip
pip install -r requirements.txt

echo "✅ Cowrie configured. You can now run it using:"
echo "    source cowrie-env/bin/activate && bin/cowrie start"
