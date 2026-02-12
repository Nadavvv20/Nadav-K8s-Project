#!/bin/bash

# 1. Variables set
PARAMETER_NAME="Nadav-db-secret" # Name of parameter in AWS
REGION="us-east-1"

echo "Fetching DB password from AWS Parameter Store..."

# 2. Pull the passwrod from AWS
DB_PASS=$(aws ssm get-parameter --name "$PARAMETER_NAME" \
--with-decryption --query "Parameter.Value" --output text --region "$REGION")

echo "DEBUG: The password fetched from AWS is: $DB_PASS"

if [ -z "$DB_PASS" ]; then
  echo "Error: Could not fetch password from AWS!"
  exit 1
fi

echo "Password fetched successfully. Deploying Helm Chart..."

# 3. Run Helm with password injection
helm upgrade --install nadav-wordpress ./wordpress-project \
  --set mysql.rootPassword="$DB_PASS"

echo "Deployment finished!"