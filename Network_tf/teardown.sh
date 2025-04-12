#!/bin/bash

echo "⚠️  WARNING: This will permanently destroy all deployed AWS resources!"
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    echo "🔧 Destroying infrastructure..."
    terraform destroy -auto-approve
    echo "✅ Teardown complete."
else
    echo "❌ Teardown aborted."
fi
