#!/bin/bash

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$SCRIPT_DIR/../infra/aws/project/init"
cd "$TF_DIR" || exit 1
export AWS_PROFILE=terraform

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear

# Step 1 – Local backend for bootstrapping
echo -e "\n========== Step 1: Initialize local backend and create S3/DynamoDB ==========\n"

cat <<EOF > backend.tf
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
EOF

terraform init
terraform apply -auto-approve

sleep 2
clear

# Step 2 – Capture backend values from outputs
echo -e "\n========== Step 2: Capturing Terraform outputs ==========\n"
bucket_name=$(terraform output -raw main_bucket)
dynamodb_table=$(terraform output -raw dynamodb_table)

echo -e "${GREEN}Bucket name:${NC} $bucket_name"
echo -e "${GREEN}DynamoDB table name:${NC} $dynamodb_table"

sleep 2
clear

# Step 3 – Generate backend.tf from template and migrate state
echo -e "\n========== Step 3: Switching backend to S3 and migrating state ==========\n"

# Export vars for envsubst
export TF_BACKEND_BUCKET="$bucket_name"
export TF_BACKEND_KEY="terraform.tfstate"
export TF_BACKEND_REGION="eu-central-1"
export TF_BACKEND_LOCK_TABLE="$dynamodb_table"

envsubst < backend.tf.tmpl > backend.tf

echo -n "Waiting for resources to become available"
for i in {1..5}; do
  echo -n "."
  sleep 1
done
echo ""

terraform init -migrate-state

sleep 2
clear

# Step 4 – Re-apply with S3 backend
echo -e "\n========== Step 4: Applying resources with the S3 backend ==========\n"
terraform apply -auto-approve

sleep 2
clear

# Step 5 – Validation & sanity check
echo -e "\n========== Step 5: Validate & inspect state ==========\n"

echo "Validating configuration..."
if terraform validate; then
  echo -e "${GREEN}✔ Terraform configuration is valid.${NC}"
else
  echo -e "${RED}✖ Validation failed. Please check the configuration.${NC}"
  exit 1
fi

echo -e "\nListing current resources in state:"
terraform state list || echo -e "${RED}✖ No resources found in state.${NC}"

echo -e "\n✅ ${GREEN}Migration, deployment, and validation complete!${NC}\n"
