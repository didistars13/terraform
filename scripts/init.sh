#!/bin/bash

set -e  # Exit on error

cd ../infra/aws/project/init || exit 1
export AWS_PROFILE=terraform

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear

# Step 1
echo -e "\n========== Step 1: Initialize local backend and create S3 bucket ==========\n"
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

# Step 2
echo -e "\n========== Step 2: Capturing Terraform outputs ==========\n"
bucket_name=$(terraform output -raw main_bucket)
dynamodb_table=$(terraform output -raw dynamodb_table)

echo -e "${GREEN}Bucket name:${NC} $bucket_name"
echo -e "${GREEN}DynamoDB table name:${NC} $dynamodb_table"

sleep 3
clear

# Step 3
echo -e "\n========== Step 3: Switching backend to S3 and migrating state ==========\n"
cat <<EOF > backend.tf
terraform {
  backend "s3" {
    bucket         = "$bucket_name"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "$dynamodb_table"
  }
}
EOF

echo -n "Waiting for resources to become available"
for i in {1..5}; do
  echo -n "."
  sleep 1
done
echo ""

terraform init -migrate-state

sleep 2
clear

# Step 4
echo -e "\n========== Step 4: Applying resources with the S3 backend ==========\n"
terraform apply -auto-approve

sleep 2
clear

# Step 5
echo -e "\n========== Step 5: Sanity check: validate and inspect resources ==========\n"

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
