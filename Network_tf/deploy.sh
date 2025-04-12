#!/bin/bash

echo "Initializing Terraform..."
terraform init

echo "Planning deployment..."
terraform plan

echo "Applying infrastructure..."
terraform apply -auto-approve

echo "Deployment complete. Public IPs:"
terraform output
