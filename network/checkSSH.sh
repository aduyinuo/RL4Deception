#!/bin/bash

IP=${1:-3.148.118.121}  # Default to controller IP if none provided
PORT=22

echo "Checking SSH access to $IP:$PORT..."
if nc -zv -w 5 "$IP" "$PORT"; then
  echo "✅ Port $PORT is open on $IP"
else
  echo "❌ Port $PORT is NOT reachable on $IP"
fi
